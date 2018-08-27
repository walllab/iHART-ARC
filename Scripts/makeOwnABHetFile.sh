#!/bin/bash

# The annotation pipeline expects an ABHet file whose format is chr\tpos\tref\talt\tadjusted_abhet and has no header.
# The process that currently creates the adjusted ABHet file has these as columns 1,2,4,5,9 and has a header.
# This command will transform one into the other for you.

tail -n +2 $1 | cut -f1,2,4,5,9 > $2
