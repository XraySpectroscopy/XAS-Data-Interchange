#!/bin/sh

# run all the bad file tests such that the messages get printed to the
# screen.  this allows easy examination of the coverage test.

all=`ls *.t`
for f in $all; do
    perl $f
done
