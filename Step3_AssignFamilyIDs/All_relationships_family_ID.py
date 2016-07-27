"""
Use graph theory packages to identify disconnected subgraphs of the inferred relationship. 
Each disconnected subgraph is called a "family." Each family is assigned a single identifer.

@author Fernanda Polubriaginof and Nicholas Tatonetti

USAGE:
-----
python all_relationships.csv all_family_IDS.csv

"""

import networkx as nx 
import matplotlib.pyplot as plt 
import csv
import sys
import os
import networkx.algorithms.isomorphism as iso

inf = sys.argv[1]
ouf = sys.argv[2]

reader = csv.reader(open(inf,'rU'), delimiter = ',')
header = reader.next()

a=[]
b=[]
rel=[]
all_relationships = []
for line in reader: 
	a.append(int(line[0]))
	b.append(int(line[2]))
	rel.append(line[1])

for i in xrange(len(a)):
	all_relationships.append(tuple([a[i], b[i], rel[i]]))


u = nx.Graph() #directed graph 

for i in xrange(len(all_relationships)):
    u.add_edge(all_relationships[i][0], all_relationships[i][1], rel = all_relationships[i][2])

#Components sorted by size
comp = sorted(nx.connected_component_subgraphs(u), key = len, reverse=True) 

outfh = open(ouf, 'w')
writer = csv.writer(outfh)
writer.writerow(['family_id', 'individual_id'])
for family_id in xrange(len(comp)):
    for individual_id in comp[family_id].nodes():
        writer.writerow([family_id, individual_id]) 
outfh.close()