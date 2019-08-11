"""
June 16, 2019 rewrite of code to preprocess EC and PT tables, for further matching emergency contacts to patient demographics, using find_matches.sql script. PT tables should be pre-sorted by the MRN column, before running this code.

@authors Zhouzerui Liu

USAGE:
python split_names_combine.py ec_file.txt pt_file.txt
"""

import os
import sys
import csv
import bisect
from collections import defaultdict
from sets import Set

ec_fn = sys.argv[1]
pt_fn = sys.argv[2]

print >> sys.stderr, "Running with following arguments:"
print >> sys.stderr, "\tec_fn = ", ec_fn
print >> sys.stderr, "\tpt_fn = ", pt_fn

# read in the emergency contact data
delim = '\t' if ec_fn.endswith('txt') else ','
reader = csv.reader(open(ec_fn, 'rU'), delimiter=delim)
h = reader.next()
exp_header = ['MRN_1', 'EC_FirstName', 'EC_LastName', 'EC_PhoneNumber', 'EC_Zipcode', 'EC_Relationship']
if not h == exp_header:
    raise Exception("Emergency contact data file (%s) doesn't have the header expected: %s" % (ec_fn, exp_header))

ec_data = list()
for mrn, fn, ln, phone, zipcode, rel in reader:
    fn = fn.strip().lower()
    ln = ln.strip().lower()
    
    first_names = [fn]
    if fn.replace('-', ' ').find(' ') != -1:
        first_names += fn.replace('-',' ').split(' ')
    
    last_names = [ln]
    if ln.replace('-', ' ').find(' ') != -1:
        last_names += ln.replace('-', ' ').split(' ')
            
    for fn_comp in first_names:
        for ln_comp in last_names:
            ec_data.append([mrn, fn_comp, ln_comp, phone, zipcode, rel])

#write processed ec_data
ec_ofn = os.path.dirname(ec_fn) + '/ec_processed.csv'
ec_ofh = open(ec_ofn, 'w')
delim = '\t' if ec_ofn.endswith('txt') else ','
writer = csv.writer(ec_ofh, delimiter=delim)
writer.writerow(['MRN_1', 'EC_FirstName', 'EC_LastName', 'EC_PhoneNumber', 'EC_Zipcode', 'EC_Relationship'])

for mrn, fn_comp, ln_comp, phone, zipcode, rel in ec_data:
        writer.writerow([mrn, fn_comp, ln_comp, phone, zipcode, rel])

ec_ofh.close()

# read in the sorted (MRN) patient demographics data
delim = '\t' if pt_fn.endswith('txt') else ','
reader = csv.reader(open(pt_fn, 'rU'), delimiter=delim)
h = reader.next()
exp_header = ['MRN', 'FirstName', 'LastName', 'PhoneNumber', 'Zipcode']
if not h == exp_header:
    raise Exception("Patient demographic data file (%s) doesn't have the header expected:%s" % (pt_fn, exp_header))

current_mrn = None
current_fn = Set()
current_ln = Set()
current_phone = Set()
current_zip = Set()

#write processed pt_data
pt_ofn = os.path.dirname(pt_fn) + '/pt_processed.csv'
pt_ofh = open(pt_ofn, 'w')
delim = '\t' if pt_ofn.endswith('txt') else ','
writer = csv.writer(pt_ofh, delimiter=delim)
writer.writerow(['MRN', 'FirstName', 'LastName', 'PhoneNumber', 'Zipcode'])

for mrn, fn, ln, phone, zipcode in reader:
    if mrn != current_mrn and current_mrn is not None:
	for fn_comp in current_fn:
            for ln_comp in current_ln:
		for ph_comp in current_phone:
		    for zip_comp in current_zip:
			writer.writerow([current_mrn, fn_comp, ln_comp, ph_comp, zip_comp])
	current_fn.clear()
	current_ln.clear()
	current_phone.clear()
	current_zip.clear()	
				
    fn = fn.strip().lower()
    ln = ln.strip().lower()
    
    current_fn.add(fn)
    if fn.replace('-', ' ').find(' ') != -1:
      	current_fn.update(fn.replace('-',' ').split(' '))
    
    current_ln.add(ln)
    if ln.replace('-', ' ').find(' ') != -1:
        current_ln.update(ln.replace('-',' ').split(' '))	
    
    current_phone.add(phone)
    current_zip.add(zipcode)
    current_mrn = mrn

if len(current_fn) != 0:
    for fn_comp in current_fn:
        for ln_comp in current_ln:
            for ph_comp in current_phone:
                for zip_comp in current_zip:
                    writer.writerow([current_mrn, fn_comp, ln_comp, ph_comp, zip_comp])	
 
pt_ofh.close()




