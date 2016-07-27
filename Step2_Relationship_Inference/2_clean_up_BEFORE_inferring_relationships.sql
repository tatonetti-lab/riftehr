###Flip and clean up step

# Create table to be updated 
create table database.relations_matched_mrn_with_age_dif
select distinct a.mrn, b.relationship_group, a.relation_mrn, a.matched_path, child.year as DOB_empi, parent.year as DOB_matched, child.year - parent.year as age_dif, null as exclude
from database.pt_matches a
join database.relationship_lookup b on (a.relationship = b.relationship)
join database.pt_demog child on (child.mrn = a.mrn)
join database.pt_demog parent on (parent.mrn = a.relation_mrn)
;

##### exclude: 1 = delete / 2 = flip relationship

# exclude annotated cases with relationships that match multiple people (20+)
update database.relations_matched_mrn_with_age_dif a
join database.exclude_MRNs_before_inferences b
on a.relation_mrn = b.relation_mrn
set a.exclude = "1";
  
update database.relations_matched_mrn_with_age_dif a
join database.exclude_MRNs_before_inferences b
on a.mrn = b.relation_mrn
set a.exclude = "1";
  

# exclude patients with conflicting year of birth 
update database.relations_matched_mrn_with_age_dif a
join (
select distinct t1.mrn, t1.relation_mrn, count(t1.age_dif) as cnt
from (
select distinct mrn, relation_mrn, age_dif
from relations_matched_mrn_with_age_dif
group by mrn, relation_mrn, age_dif
) t1
group by t1.mrn, t1.relation_mrn
having cnt >1
) b
on a.mrn = b.mrn and a.relation_mrn = b.relation_mrn
set a.exclude ="1";
;


# exclude SELF
update database.relations_matched_mrn_with_age_dif a
set a.exclude ="1"
where a.mrn = a.relation_mrn;


# exclude PARENTS with age difference BETWEEN -10 AND 10 years
update database.relations_matched_mrn_with_age_dif a
set a.exclude ="1"
where a.relationship_group = "Parent" and a.age_dif between -10 and 10;

# exclude GRANDPARENTS with age difference BETWEEN -20 AND 20 years
update database.relations_matched_mrn_with_age_dif a
set a.exclude ="1"
where a.relationship_group = "Grandparent" and a.age_dif between -20 and 20;

# exclude CHILD with age difference BETWEEN -10 AND 10 years
update database.relations_matched_mrn_with_age_dif a
set a.exclude ="1"
where a.relationship_group = "Child" and a.age_dif between -10 and 10;


# exclude GRANDCHILD with age difference BETWEEN -20 AND 20 years
update database.relations_matched_mrn_with_age_dif a
set a.exclude ="1"
where a.relationship_group = "Grandchild" and a.age_dif between -20 and 20;

#exclude cases with year of birth <1900
update database.relations_matched_mrn_with_age_dif a
set a.exclude ="1"
where DOB_empi < 1900 or DOB_matched <1900;

# only consider matches that match on at least 2 items (first name, last name, phone, ZIP code)
create table pt_matches_clean
select *
from pt_matches_CLEAN
where matched_path like "%,%";

# create final table of matched relations
create table PATIENT_RELATIONS_W_OPPOSITES
select distinct mrn, relationship, relation_mrn
from pt_matches_clean
union
select distinct relation_mrn as mrn, b.opposite_relationship_group as relationship, mrn as relation_mrn
from pt_matches_clean a
join relationship_lookup b on (a.relationship = b.relationship_group);


# flip PARENTS with age difference <-10
update database.relations_matched_mrn_with_age_dif a
set a.exclude ="2"
where a.relationship_group = "Parent" and a.age_dif <-10 and a.exclude is NULL;

# flip GRANDPARENTS with age difference <-20
update database.relations_matched_mrn_with_age_dif a
set a.exclude ="2"
where a.relationship_group = "Grandparent" and a.age_dif <-20 and a.exclude is NULL;

# flip CHILD with age difference >10
update database.relations_matched_mrn_with_age_dif a
set a.exclude ="2"
where a.relationship_group = "Child" and a.age_dif >10 and a.exclude is NULL;

# flip GRANDCHILD with age difference >20
update database.relations_matched_mrn_with_age_dif a
set a.exclude ="2"
where a.relationship_group = "Grandchild" and a.age_dif >20 and a.exclude is NULL;

### Creating clean relations_matched_empi

# Flipping relationships 
create table database.relations_matched_mrn_fixed_flipped_rel
select distinct a.mrn, b.opposite_relationship_group as relationship, relation_mrn, matched_path, DOB_empi, DOB_matched, age_dif
from database.relations_matched_mrn_with_age_dif a
join relationship_lookup b on a.relationship_group = b.relationship_group
where a.exclude = 2;

# Creating relations_matched_clean
create table database.relations_matched_clean
select distinct a.mrn, a.relationship_group as relationship, relation_mrn, matched_path, DOB_empi, DOB_matched, age_dif
from database.relations_matched_mrn_with_age_dif a
where a.exclude is NULL
union
select distinct b.mrn, b.relationship, b.relation_mrn, b.matched_path, b.DOB_empi, b.DOB_matched, b.age_dif
from database.relations_matched_mrn_fixed_flipped_rel b
;

# Creating patient_relations_w_opposites_clean
create table database.patient_relations_w_opposites_clean
select distinct mrn, relationship, relation_mrn
from relations_matched_clean
union
select distinct a.relation_mrn as empi_or_mrn, b.opposite_relationship_group as relationship, a.empi_or_mrn as relation_mrn
from relations_matched_clean a
join relationship_lookup b on a.relationship = b.relationship_group
;
