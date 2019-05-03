"""
Encrypting the patient data produces two hash maps (one for all patients, one for emergency contacts), this script
merges them into one master. 

USAGE
python Step0_DataEncryption/merge_pt_hash_maps.py path/to/data/dir/

"""

import os
import sys

data_dir = sys.argv[1]

if not os.path.isdir(data_dir):
    raise Exception("Expected the first argument to be a directory.")

