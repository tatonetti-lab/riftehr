

### Exclude spouses and self 
create table database.matches_wo_spouse
select a.mrn, l.relationship_group, a.relation_mrn, a.matched_path
from database.pt_matches a
join database.relationship_lookup l using (relationship)
where relationship_group != ''
and relationship_group != 'Spouse'
and mrn != relation_mrn;

### Exclude emergency contacts with most matches 
create table database.ec_exclude
select relation_mrn, count(distinct m.mrn), demog.*
from matches_wo_spouse m
join pt_demog demog on (demog.mrn = relation_mrn)
group by relation_mrn
having count(distinct.mrn) >= 20;
