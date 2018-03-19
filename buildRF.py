#!/usr/bin/env python
import sys
import pandas as pd
import pickle, gzip
from sklearn.preprocessing   import LabelEncoder, Imputer
from sklearn.ensemble        import RandomForestClassifier

# Variant_ID and GIAB columns to drop(): 'CLASSIFICATION' will be removed separately
col2Remove = ['Variant_ID','All.simplerepeatsnocov', 'Decoy.bed', 'Superdupsmerged_all_sort', 'Systematic.Sequencing.Errors',
              'VQSRv2.18_filterABQD_sorted','VQSRv2.18_filterAlign_sorted','VQSRv2.18_filterConflicting',
              'VQSRv2.18_filterlt2Datasets','VQSRv2.18_filterMap','VQSRv2.18_filterSSE','Num_uncertain_regions'
             ]

class BuildRandomForestModel:
    def __init__ (self):
        self.X = []  # training data
        self.y = []  # target variables

    def build_rf_model(self, inputFile, nTree=1000):
        data = pd.read_csv(inputFile, sep='\t')
        for col in col2Remove:
            if col in data.columns: data = data.drop(col, 1)

        # This column consists of string labels that cannot be imputed
        le = LabelEncoder()
        le = le.fit([b1 + b2 + b3 for b1 in 'AC' for b2 in 'ACGT' for b3 in 'ACGT']) # 32 contexts
        data['Trinucleotide_context'] = le.transform(data['Trinucleotide_context'])

        # Imputation: returns np array => need to convert pandas dataframe with column header
        imp = pd.DataFrame(Imputer(missing_values='NaN', strategy='mean', axis=0).fit_transform(data))
        imp.columns = data.columns

        # Make training data(X) and target variables(y) in numpy matrix format
        self.X, self.y = imp.drop('CLASSIFICATION', 1).as_matrix(), imp['CLASSIFICATION'].as_matrix()

        # Train RF and save the model
        clf = RandomForestClassifier(n_estimators=nTree, class_weight='balanced', n_jobs=-1).fit(self.X, self.y)
        pickle.dump(clf, gzip.open('RFmodel.pickle.gz', 'wb')) # save classifier using pickle: not JSON serializable

def main():
    if len(sys.argv) != 2:
        print("Usage: python $THIS_SCRIPT TRAINING_FILE_NAME")
        sys.exit(1)

    rf = BuildRandomForestModel()
    rf.build_rf_model(inputFile=sys.argv[1], nTree=1000)

if __name__ == "__main__":
    main()

