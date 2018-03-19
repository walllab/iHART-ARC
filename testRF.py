#!/usr/bin/env python
import sys
import pandas as pd
import pickle, gzip
from sklearn.preprocessing   import LabelEncoder, Imputer
from sklearn.ensemble        import RandomForestClassifier
from sklearn.metrics         import f1_score as f1, roc_auc_score as roc_auc

# Variant_ID and GIAB columns to drop(): 'CLASSIFICATION' will be removed separately
col2Remove = ['Variant_ID','All.simplerepeatsnocov', 'Decoy.bed', 'Superdupsmerged_all_sort', 'Systematic.Sequencing.Errors',
              'VQSRv2.18_filterABQD_sorted','VQSRv2.18_filterAlign_sorted','VQSRv2.18_filterConflicting',
              'VQSRv2.18_filterlt2Datasets','VQSRv2.18_filterMap','VQSRv2.18_filterSSE','Num_uncertain_regions'
             ]

class TestRandomForestModel:
    def __init__ (self):
        self.X = []  # test data
        self.y = []  # test target variables

    def make_test_input(self, inputFile, skip_imputation=False):
        data = pd.read_csv(inputFile, sep='\t')
        for col in col2Remove:
            if col in data.columns: data = data.drop(col, 1)

        # This column consists of string labels that cannot be imputed
        le = LabelEncoder()
        le = le.fit([b1 + b2 + b3 for b1 in 'AC' for b2 in 'ACGT' for b3 in 'ACGT']) # 32 contexts
        data['Trinucleotide_context'] = le.transform(data['Trinucleotide_context'])

        if skip_imputation:
            self.X, self.y = data.drop('CLASSIFICATION', 1).as_matrix(), data['CLASSIFICATION'].as_matrix()

        else:
            # Imputation: returns np array => need to convert pandas dataframe with column header
            imp = pd.DataFrame(Imputer(missing_values='NaN', strategy='mean', axis=0).fit_transform(data))
            imp.columns = data.columns

            # Make test data(X) and test target variables(y) in numpy matrix format
            self.X, self.y = imp.drop('CLASSIFICATION', 1).as_matrix(), imp['CLASSIFICATION'].as_matrix()

    def test_rf_model(self, outputFile):
        clf = pickle.load(gzip.open('RFmodel.pickle.gz', 'rb'))

        pred, prob = clf.predict(self.X), clf.predict_proba(self.X)[:,1]
        pd.DataFrame({'y':self.y, 'prob':prob}).to_csv(outputFile, sep='\t') # save for figures
        print('Test F1 score: %.5f, ROC_AUC score: %.5f' %(f1(self.y, pred), roc_auc(self.y, prob)))

def main():
    if len(sys.argv) not in (3, 4):
        print("Usage: python $THIS_SCRIPT INPUT_FILE_NAME OUTPUT_FILE_NAME ['skip_imputation']")
        sys.exit(1)

    skip = False
    if len(sys.argv) == 4:
        if sys.argv[3] == 'skip_imputation':
            skip = True
        else:
          print("Usage: python $THIS_SCRIPT INPUT_FILE_NAME OUTPUT_FILE_NAME ['skip_imputation']")
          sys.exit(1)

    rf = TestRandomForestModel()
    rf.make_test_input(inputFile=sys.argv[1], skip_imputation=skip)
    rf.test_rf_model(outputFile=sys.argv[2])

if __name__ == "__main__":
    main()
