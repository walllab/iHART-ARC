- trainRF.cv.py
  + Input: training data file
  + Output: 10 fold cross-validation results (`fold01.tsv` ... `fold10.tsv`) in the current directory

- trainRF.plot.py
  + Input: full directory path where `fold01.tsv` ... files are stored
  + Output: cross-validation result figures in the current directory (`train-*.png`)

- trainRF.rfecv.py
  + Input: training data file
  + Output: text output of RFECV and feature_importance, plus `rfecv.png` figure.

- buildRF.py
  + Input: training data file
  + Output: trained model as `RFmodel.pickle.gz` in the current directory

- testRF.py
  + Usage: `python testRF.py $INPUT $OUT_FILE_NAME [skip_imputation]`
  + Input: testing data file (plus `RFmodel.pickle.gz` file in the current directory from `buildRF.py`)
  + Output: test output result to $OUT_FILE_NAME

- testRF.plot.py
  + Input: test output file
  + Output: test output histograms and precision-recall figures (`test.*.png`)


- recursive feature selection (step 3) takes >4 hrs on a 4 core processor

- `RFmodel.pickle.gz`: random forest output file from `buildRF.py`

- `test.input`: test input file for `testRF.py`

- python3 requires parentheses around print statements
