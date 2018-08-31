## Questions and Answers to Common Pipeline Errors
Below are common pipeline errors and their solution. Feel free to contact saarteag@g.ucla.edu to report any other errors you may run into. <br>

* **Question**: Received ValueError: Length mismatch: Expected axis has "X" elements, new values have "Y" elements <br>
	- **Answer**: As it stands, the sklearn.preprocessing.Imputer used by this script automatically drops columns when 100% of the values are missing (i.e., columns marked as only NA). If you run into this issue, use preimputation.py. <br>

* **Question**: Received ValueError: Input contains NaN, infinity or a value too large for dtype('float32') after using preimputation.py script. <br>
	- **Answer**: The preimputation.py script replaces NA values with the mean of all non-NA values within this column. If there are columns with only NA values, the script will report these columns (e.g., These columns have only missing values: ABHom, NDA, VQSLOD). These columns must then be replaced with an integer value of your choice (e.g., replace NA with 0) since they will be converted as “nan” in numpy and lead to the above error.
