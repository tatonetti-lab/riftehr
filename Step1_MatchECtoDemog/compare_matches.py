"""
Script to compare output from two match scripts.

USAGE:
python compare_matches.py matchfile1.txt matchfile2.txt

@authors Fernanda Polubriaginof and Nicholas P. Tatonetti
"""

import os
import sys
import csv

fn1 = sys.argv[1]
d1 = '\t' if fn1.endswith('txt') else ','

fn2 = sys.argv[2]
d2 = '\t' if fn2.endswith('txt') else ','

print >> sys.stderr, "Comparing: %s and %s." % (fn1, fn2)

pairs1 = set()
data1 = dict()
for row in csv.reader(open(fn1), delimiter=d1):
    pairs1.add( (row[0], row[2]) )
    data1[ (row[0], row[2]) ] = [row[1]] + row[3:]

pairs2 = set()
data2 = dict()
for row in csv.reader(open(fn2), delimiter=d2):
    pairs2.add( (row[0], row[2]) )
    data2[ (row[0], row[2]) ] = [row[1]] + row[3:]

print >> sys.stderr, "File 1 has %d pairs." % len(pairs1)
print >> sys.stderr, "File 2 has %d pairs." % len(pairs2)

print >> sys.stderr, "%d of %d are in common (%.3f%%)" % (len(pairs1 & pairs2), len(pairs1 | pairs2), len(pairs1 & pairs2)/float(len(pairs1 | pairs2)))

diff1 = pairs1 - pairs2
if len(diff1) > 0:
    print >> sys.stderr, "The following pairs are unique to %s" % fn1
    for e1, e2 in diff1:
        print >> sys.stderr, "%s\t%s: %s" % (e1, e2, data1[(e1,e2)])

diff2 = pairs2 - pairs1
if len(diff2) > 0:
    print >> sys.stderr, "The following pairs are unique to %s" % fn2
    for e1, e2 in diff2:
        print >> sys.stderr, "%s\t%s: %s" % (e1, e2, data2[(e1, e2)])
