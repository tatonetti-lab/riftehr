#Table with siblings and their date of birth
create table database.siblings_with_DOB
select distinct rel.empi_or_mrn, rel.relation_empi_or_mrn, rel.relationship, demog.BIRTH_DATE_STR as empi_DOB, demog2.BIRTH_DATE_STR as relation_empi_DOB
from database.ACTUAL_AND_INF_REL_CLEAN_FINAL rel
join database.pt_demog demog on rel.empi_or_mrn = demog.empi_or_mrn
join database.pt_demog demog2 on rel.relation_empi_or_mrn = demog2.empi_or_mrn
where rel.relationship = "Sibling"
;

# Select siblings with the same DOB 
select distinct *
from siblings_with_DOB
where empi_DOB = relation_empi_DOB;



