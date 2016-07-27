"""
Run find_matches.py in batches using [nprocs] processors.

@authors Fernanda Polubriaginof and Nicholas P. Tatonetti

"""

nprocs = 30
# we need to the know the number of lines in the emergency contact file
# you can find that by running the find_matches.py script and seeing how many 
# ECs are parsed. It's one of the first lines of output after the arguments.

nlines = 2692317

lines_per_proc = nlines/nprocs

for start in range(0, nlines, lines_per_proc):
    end = start+lines_per_proc
    if start+lines_per_proc > nlines:
        end = nlines
    
    print "bsub python find_matches.py emergency_contact_table.txt all_patients_table.txt results/matches_%d_%d.csv %d:%d" % (start, end, start, end)