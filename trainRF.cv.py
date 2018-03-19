#!/usr/bin/env python
import sys
import pandas as pd
from sklearn.preprocessing   import LabelEncoder, Imputer
from sklearn.model_selection import StratifiedKFold
from sklearn.ensemble        import RandomForestClassifier
from sklearn.metrics         import f1_score as f1, roc_auc_score as roc_auc

# Drop Variant_ID and GIAB columns: 'CLASSIFICATION' will be removed separately
columnsToRemove = ['Variant_ID','All.simplerepeatsnocov', 'Decoy.bed', 'Superdupsmerged_all_sort', 'Systematic.Sequencing.Errors',
                   'VQSRv2.18_filterABQD_sorted','VQSRv2.18_filterAlign_sorted','VQSRv2.18_filterConflicting',
                   'VQSRv2.18_filterlt2Datasets','VQSRv2.18_filterMap','VQSRv2.18_filterSSE','Num_uncertain_regions'
                  ]

class TrainRandomForestWithCrossValidation:
    def __init__(self):
        self.X = [] # (all) training data
        self.y = [] # (all) target variables

    def make_input(self, inputFile):
        data = pd.read_csv(inputFile, sep='\t')
        for c in columnsToRemove:
            if c in data.columns: data = data.drop(c, 1)

        # This column consists of string labels that cannot be imputed
        le = LabelEncoder()
        le = le.fit([b1 + b2 + b3 for b1 in 'AC' for b2 in 'ACGT' for b3 in 'ACGT']) # 32 contexts
        data['Trinucleotide_context'] = le.transform(data['Trinucleotide_context'])

        # Imputation: returns np array => need to convert pandas dataframe with column header
        imp = pd.DataFrame(Imputer(missing_values='NaN', strategy='mean', axis=0).fit_transform(data))
        imp.columns = data.columns

        # Make training data(X) and target variable(y) in numpy matrix format
        self.X, self.y = imp.drop('CLASSIFICATION', 1).as_matrix(), imp['CLASSIFICATION'].as_matrix()

    def train_rf_cv(self, nTree=1000, nFold=10):
        foldNum=1
        for trainIdx, testIdx in StratifiedKFold(n_splits=nFold, shuffle=True).split(self.X, self.y):
            trainX, trainY = self.X[trainIdx], self.y[trainIdx] # training data for the current fold
            testX,  testY  = self.X[testIdx],  self.y[testIdx]  # test data

            clf = RandomForestClassifier(n_estimators=nTree, class_weight='balanced', n_jobs=-1).fit(trainX, trainY)

            pred, prob = clf.predict(testX), clf.predict_proba(testX)[:,1]
            pd.DataFrame({'y':testY, 'pred':pred, 'prob':prob}).to_csv('fold%02d.tsv'%(foldNum), sep='\t') # save data for figures
            print('Fold%02d Test F1 score: %.5f, ROC_AUC score: %.5f' %(foldNum, f1(testY, pred), roc_auc(testY, prob)))
            foldNum +=1

def main():
    if len(sys.argv) != 2:
        print("Usage: python $THIS_SCRIPT TRAINING_FILE_NAME")
        sys.exit(1)

    rf = TrainRandomForestWithCrossValidation()
    rf.make_input(inputFile=sys.argv[1])
    rf.train_rf_cv(nTree=1000, nFold=10)

if __name__ == "__main__":
    main()

