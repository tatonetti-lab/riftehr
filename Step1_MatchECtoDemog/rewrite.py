import sys
import csv

fh = sys.argv[1]
d = '\t' if fh.endswith('txt') else ','

data = [row for row in csv.reader(open(fh, 'rU'), delimiter=d)]

ofh = open(fh, 'w')
writer = csv.writer(ofh)
writer.writerows(data)
ofh.close()

