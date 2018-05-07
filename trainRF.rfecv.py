#!/usr/bin/env python
import sys
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.preprocessing     import LabelEncoder, Imputer
from sklearn.ensemble          import RandomForestClassifier
from sklearn.feature_selection import RFECV

# By default, this script will use all available cores in the machine
# It took about an hour to finish in a 16-core machine, with 50k variants input data.

# Variant_ID and GIAB columns to drop(): 'CLASSIFICATION' will be removed separately
col2Remove = ['Variant_ID','All.simplerepeatsnocov', 'Decoy.bed', 'Superdupsmerged_all_sort', 'Systematic.Sequencing.Errors',
              'VQSRv2.18_filterABQD_sorted','VQSRv2.18_filterAlign_sorted','VQSRv2.18_filterConflicting',
              'VQSRv2.18_filterlt2Datasets','VQSRv2.18_filterMap','VQSRv2.18_filterSSE','Num_uncertain_regions'
             ]

class TrainRandomForest_RFECV:
    def __init__(self):
        self.X = []  # training data
        self.y = []  # target variables
        self.features = []

    def make_input(self, inputFile):
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
        self.features  = imp.drop('CLASSIFICATION', 1).columns

    def run(self, nTrees=1000):

        clf = RandomForestClassifier(n_estimators=nTrees, class_weight='balanced', n_jobs=-1)
        feature_importance = clf.fit(self.X, self.y).feature_importances_

        selector  = RFECV(clf, step=1, cv=10, scoring='accuracy', n_jobs=-1).fit(self.X, self.y)
        print("Optimal number of features : %d" % selector.n_features_)

        # Show ranking from RFECV + (normalized) featuer importance from RF model
        for i,j in enumerate(self.features):
            print("%s\t%2d\t%.10f"%(j, selector.ranking_[i], feature_importance[i]))

        plt.figure()
        plt.xlabel("Number of Features Selected")
        plt.ylabel("Cross Validation Score")
        plt.plot(range(1, len(selector.grid_scores_) + 1), selector.grid_scores_)
        plt.savefig("rfecv.png")


def main():
    rfecv = TrainRandomForest_RFECV()
    rfecv.make_input(inputFile=sys.argv[1])
    rfecv.run(nTrees=1000)


if __name__ == "__main__":
    main()
