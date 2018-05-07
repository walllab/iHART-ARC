- Tested on Python 2.7.13 and 3.6.4.
  + Requires pandas, sklearn, scipy, and matplotlib packages

___


- trainRF.cv.py
  + Usage: `python trainRF.cv.py $TRAIN_INPUT_FILE`
  + Input: training data file
  + Output: 10 fold cross-validation results (`fold01.tsv` ... `fold10.tsv`) in the current directory

- trainRF.plot.py
  + Usage: `python trainRF.plot.py [$CV_OUTPUT_PATH]`
  + Input: full directory path where `fold01.tsv` ... files are stored (default: current dir.)
  + Output: cross-validation result figures in the current directory (`train-*.png`)

- trainRF.rfecv.py
  + Usage: `python trainRF.rfecv.py $TRAIN_INPUT_FILE`
  + Input: training data file
  + Output: text output of RFECV and feature_importance, plus `rfecv.png` figure.

- buildRF.py
  + Usage: `python buildRF.py $TRAIN_INPUT_FILE`
  + Input: training data file
  + Output: trained model as `RFmodel.pickle.gz` in the current directory

- testRF.py
  + Usage: `python testRF.py $INPUT $OUT_FILE_NAME [skip_imputation]`
  + Input: testing data file (plus `RFmodel.pickle.gz` file in the current directory from `buildRF.py`)
  + Output: test output result to `$OUT_FILE_NAME`

- testRF.plot.py
  + Usage: `python testRF.plot.py [$TEST_OUTPUT_FILE]`
  + Input: test output file (default: `test.tsv` in the current dir.)
  + Output: test output histograms and precision-recall figures (`test.*.png`)

___


- `RFmodel.pickle.gz`: random forest output file from `buildRF.py` (built with python2, so may not work with python3).

- `test.input`: test input file for `testRF.py`
