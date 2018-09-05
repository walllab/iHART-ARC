#!/bin/bash

# The annotation pipeline expects an input with two columns, variant id and classification.
# If you are running in production mode, classification is just a dummy column that can be FALSE everywhere
# but needs one TRUE in order not to crash at AUC calculation since we are overriding the testRF script.
# If you have already created an "own" flat db using makeOwnFlatDb.sh, this will transform that into a compatible input file.

awk '{if(NR==1) print $1"."$2"."$3"."$4"."$5"\tTRUE"; else print $1"."$2"."$3"."$4"."$5"\tFALSE"}' $1 > $2
