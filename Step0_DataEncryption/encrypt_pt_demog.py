"""
Perform some basic quality checks and encrypt the patient demographic data file.

USAGE
python Step0_DataEncryption/encrypt_pt_demog.py path/to/all_patients_table.csv

"""

import os
import sys
import csv
import hashlib

pt_fn = sys.argv[1]

# read in the patient demographics data
delim = '\t' if pt_fn.endswith('txt') else ','
reader = csv.reader(open(pt_fn, 'r'), delimiter=delim)

h = next(reader)
exp_header = ['MRN', 'FirstName', 'LastName', 'PhoneNumber', 'Zipcode']

if not h == exp_header:
    raise Exception("Patient demographic data file (%s) doesn't have the header expected:%s" % (pt_fn, exp_header))

filename, file_extension = os.path.splitext(pt_fn)
out_fn = '%s_enc' % filename + file_extension

out_fh = open(out_fn, 'w')
writer = csv.writer(out_fh, delimiter=delim)
writer.writerow(exp_header)

pt_mrn_hashes = dict()

for i, (mrn, fn, ln, phone, zipcode) in enumerate(reader):
    fn = fn.strip().lower()
    ln = ln.strip().lower()
    
    first_names = [fn]
    if fn.replace('-', ' ').find(' ') != -1:
        first_names += fn.replace('-',' ').split(' ')
    
    last_names = [ln]
    if ln.replace('-', ' ').find(' ') != -1:
        last_names += ln.replace('-',' ').split(' ')
    
    pt_mrn_hashes[mrn] = hashlib.sha224(mrn.encode('utf-8')).hexdigest()
    
    for fn_comp in first_names:
        for ln_comp in last_names:
            encrypted = map(lambda x: hashlib.sha224(x.encode('utf-8')).hexdigest(), [mrn, fn_comp, ln_comp, phone, zipcode])
            writer.writerow(encrypted)

out_fh.close()

map_fn = '%s_map' % filename + file_extension
map_fh = open(map_fn, 'w')
writer = csv.writer(map_fh, delimiter=delim)
writer.writerow(['mrn', 'hased_mrn'])

for mrn, hashed_mrn in pt_mrn_hashes.items():
    writer.writerow([mrn, hashed_mrn])

map_fh.close()