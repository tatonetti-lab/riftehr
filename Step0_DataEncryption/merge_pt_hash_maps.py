"""
Encrypting the patient data produces two hash maps (one for all patients, one for emergency contacts), this script
merges them into one master. 

USAGE
python Step0_DataEncryption/merge_pt_hash_maps.py path/to/data/dir/ ec_map.txt pt_map.txt 

"""

import os
import sys
import csv

data_dir = sys.argv[1]

if not os.path.isdir(data_dir):
    raise Exception("Expected the first argument to be a directory.")

ec_map_fn = data_dir + sys.argv[2]
pt_map_fn = data_dir + sys.argv[3]
 
# read in the patient demographics map data
delim = '\t' if pt_map_fn.endswith('txt') else ','
reader = csv.reader(open(pt_map_fn, 'rU'), delimiter=delim)

h = next(reader)
exp_header = ['mrn', 'hased_mrn']
if not h == exp_header:
    raise Exception("Patient demographics map data file (%s) doesn't have the header expected:%s" % (pt_map_fn, exp_header))

hashed_data = dict()
for mrn, hashed_mrn in reader:
    hashed_data[mrn] = hashed_mrn

# read in the emergency contacts map data
delim = '\t' if ec_map_fn.endswith('txt') else ','
reader = csv.reader(open(ec_map_fn, 'rU'), delimiter=delim)

h = next(reader)
exp_header = ['mrn', 'hased_mrn']
if not h == exp_header:
    raise Exception("Emergency contacts map data file (%s) doesn't have the header expected:%s" % (ec_map_fn, exp_header))

for mrn, hashed_mrn in reader:
    if mrn not in hashed_data:
        hashed_data[mrn] = hashed_mrn

#write merged hashed map
filename, file_extension = os.path.splitext(pt_map_fn)
merged_fn = data_dir + "merged_map" + file_extension

ofh = open(merged_fn, 'w')
delim = '\t' if merged_fn.endswith('txt') else ','
writer = csv.writer(ofh, delimiter=delim)

writer.writerow(exp_header)
for mrn, hashed_mrn in hashed_data.items():
    writer.writerow([mrn, hashed_mrn])

ofh.close()
