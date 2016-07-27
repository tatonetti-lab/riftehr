### Import output_actual_and_inferred_relationships.csv into database as actual_and_inf_rel_part1

### Creating table with unique pairs and relationships
create table actual_and_inf_rel_part1_unique
select distinct mrn, relationship, relation_mrn
from actual_and_inf_rel_part1;


### Add new field to "actual_and_inf_rel_part1_unique" called provided_relationship (INT)
update actual_and_inf_rel_part1_unique a
join patient_relations_w_opposites_clean b on a.mrn = b.mrn and a.relationship = b.relationship and a.relation_mrn = b.relation_mrn
set provided_relationship = 1;


### Duplicate table actual_and_inf_rel_part1_unique and name it actual_and_inf_rel_part1_unique_clean


### Add indexes


### Identifying mrn = to relation_mrn (Self) <--- 0 cases! If not = 0, exclude those
select*
from actual_and_inf_rel_part1_unique_clean
where mrn = relation_mrn;



### Creating conflicting provided relationships table 
create table provided_relationships_conflicting
select mrn, relation_mrn, count(relationship)
from (
select *
from actual_and_inf_rel_part1_unique_clean
where provided_relationship = 1
)a
group by mrn, relation_mrn
having count(relationship)>1;

### Create new column conflicting_provided_relationship at actual_and_inf_rel_part1_unique_clean

### Tagging conflicting provided relationships
update actual_and_inf_rel_part1_unique_clean a
join provided_relationships_conflicting b on (a.mrn = b. mrn) and (a.relation_mrn = b.relation_mrn)
set conflicting_provided_relationship = 1
where provided_relationship =1;

### Create new column relationship_specific at actual_and_inf_rel_part1_unique_clean

### Identifying and updating PROVIDED mothers for not conflicting cases

update actual_and_inf_rel_part1_unique_clean a
join database.pt_matches b on a.mrn = b.mrn and a.relation_mrn = b.relation_mrn
join relationship_lookup c on b.relationship = c.relationship
SET a.relationship_specific = 'Mother'
where a.relationship = 'Parent' and c.relationship_name = "Mother" and a.provided_relationship = 1 and a.conflicting_provided_relationship is NULL and a.relationship_specific is NULL;

### Identifying and updating PROVIDED fathers for not conflicting cases

update actual_and_inf_rel_part1_unique_clean a
join database.pt_matches b on a.mrn = b.mrn and a.relation_mrn = b.relation_mrn
join relationship_lookup c on b.relationship = c.relationship
SET a.relationship_specific = 'Father'
where a.relationship = 'Parent' and c.relationship_name = "Father" and a.provided_relationship = 1 and a.conflicting_provided_relationship is NULL and a.relationship_specific is NULL;


### Identifying and updating PROVIDED aunts for not conflicting cases
update actual_and_inf_rel_part1_unique_clean a
join database.pt_matches b on a.mrn = b.mrn and a.relation_mrn = b.relation_mrn
join relationship_lookup c on b.relationship = c.relationship
SET a.relationship_specific = 'Aunt'
where a.relationship = 'Aunt/Uncle' and c.relationship_name = "Aunt" and a.provided_relationship = 1 and a.conflicting_provided_relationship is NULL and a.relationship_specific is NULL;


### Identifying all "Parent" that are = MOTHER by gender 

update actual_and_inf_rel_part1_unique_clean x
join (
select d.relation_mrn
from (
select c.relation_mrn, count(c.relation_mrn)
from (
select distinct a.relation_mrn, b.SEX
from actual_and_inf_rel_part1_unique_clean a
join database.pt_demog b on (a.relation_mrn = b.mrn)
where a.relationship = "Parent" and a.relationship_specific is NULL
) c
group by c.relation_mrn
having count(c.relation_mrn) =1 
) d
join database.pt_demog e on d.relation_mrn = e.mrn
where e.SEX = 'F'
)y on x.relation_mrn = y.relation_mrn
SET x.relationship_specific = 'Mother' 
where x.relationship = "Parent" and x.relationship_specific is NULL;

### Identifying all "Parent" that are = FATHER by gender 

update actual_and_inf_rel_part1_unique_clean x
join (
select d.relation_mrn
from (
select c.relation_mrn, count(c.relation_mrn)
from (
select distinct a.relation_mrn, b.SEX
from actual_and_inf_rel_part1_unique_clean a
join database.pt_demog b on (a.relation_mrn = b.mrn)
where a.relationship = "Parent" and a.relationship_specific is NULL
) c
group by c.relation_mrn
having count(c.relation_mrn) =1 
) d
join database.pt_demog e on d.relation_mrn = e.mrn
where e.SEX = 'M'
)y on x.relation_mrn = y.relation_mrn
SET x.relationship_specific = 'Father' 
where x.relationship = "Parent" and x.relationship_specific is NULL;

### Identifying all "Aunt/Uncle" that are = Aunt by gender 

update actual_and_inf_rel_part1_unique_clean x
join (
select d.relation_mrn
from (
select c.relation_mrn, count(c.relation_mrn)
from (
select distinct a.relation_mrn, b.SEX
from actual_and_inf_rel_part1_unique_clean a
join database.pt_demog b on (a.relation_mrn = b.mrn)
where a.relationship = "Aunt/Uncle" and a.relationship_specific is NULL
) c
group by c.relation_mrn
having count(c.relation_mrn) =1 
) d
join database.pt_demog e on d.relation_mrn = e.mrn
where e.SEX = 'F'
)y on x.relation_mrn = y.relation_mrn
SET x.relationship_specific = 'Aunt' 
where x.relationship = "Aunt/Uncle" and x.relationship_specific is NULL;

### Identifying all "Aunt/Uncle" that are = Uncle by gender 

update actual_and_inf_rel_part1_unique_clean x
join (
select d.relation_mrn
from (
select c.relation_mrn, count(c.relation_mrn)
from (
select distinct a.relation_mrn, b.SEX
from actual_and_inf_rel_part1_unique_clean a
join database.pt_demog b on (a.relation_mrn = b.mrn)
where a.relationship = "Aunt/Uncle" and a.relationship_specific is NULL
) c
group by c.relation_mrn
having count(c.relation_mrn) =1 
) d
join database.pt_demog e on d.relation_mrn = e.mrn
where e.SEX = 'M'
)y on x.relation_mrn = y.relation_mrn
SET x.relationship_specific = 'Uncle' 
where x.relationship = "Aunt/Uncle" and x.relationship_specific is NULL;


### Removing Parent/Aunt/Uncle from pairs that have Parent or Aunt/Uncle (count = 2) and cases that have Parent/Aunt/Uncle and Parent and Aunt/Uncle (count = 3)
create table delete_part1_parent_aunt_uncle_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship like 'Parent' or relationship like '%Aunt/Uncle'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Parent/Aunt/Uncle'
;


### Delete "Parent/Aunt/Uncle that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_parent_aunt_uncle_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);


### Removing Child/Nephew/Niece from pairs that have Child or Nephew/Niece or both 
create table delete_part1_child_nephew_niece_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship like 'Child' or relationship like '%Nephew/Niece'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Child/Nephew/Niece'
;



### Delete Child/Nephew/Niece that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_child_nephew_niece_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);


### Removing Sibling/Cousin from pairs that have Child or Nephew/Niece or both
create table delete_part1_sibling_cousin_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship like 'Sibling' or relationship like '%Cousin'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Sibling/Cousin'
;

### Delete Sibling/Cousin that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_sibling_cousin_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);

### Removing Parent/Parent-in-law from pairs that have Parent 
create table delete_part1_parent_in_law_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship ='Parent' or relationship like 'Parent/Parent%'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Parent/Parent%'
;

### Delete Parent/Parent-in-law that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_parent_in_law_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);

### Removing Child/Child-in-law from pairs that have Child
create table delete_part1_child_in_law_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship ='Child' or relationship like 'Child/Child%'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Child/Child%'
;

### Delete Child/Child-in-law that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_child_in_law_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);
 

### Removing Grandaunt/Granduncle/Grandaunt-in-law/Granduncle-in-law from pairs that have Grandaunt/Granduncle
create table delete_part1_grandaunt_in_law_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship ='Grandaunt/Granduncle' or relationship like 'Grandaunt/Granduncle/Grandaunt%'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Grandaunt/Granduncle/Grandaunt%'
;

### Delete Grandaunt/Granduncle/Grandaunt-in-law/Granduncle-in-law that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_grandaunt_in_law_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);



### Removing Grandchild/Grandchild-in-law from pairs that have Grandchild
create table delete_part1_grandchild_in_law_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship ='Grandchild' or relationship like 'Grandchild/Grandchild%'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Grandchild/Grandchild%'
;

### Delete Grandchild/Grandchild-in-law that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_grandchild_in_law_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);


### Removing Grandnephew/Grandniece/Grandnephew-in-law/Grandniece-in-law from pairs that have Grandnephew/Grandniece
create table delete_part1_grandnephew_in_law_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship ='Grandnephew/Grandniece' or relationship like 'Grandnephew/Grandniece/Grandnephew%'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Grandnephew/Grandniece/Grandnephew%'
;

### Delete Grandnephew/Grandniece/Grandnephew-in-law/Grandniece-in-law that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_grandnephew_in_law_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);



### Removing Grandparent/Grandparent-in-law from pairs that have Grandparent
create table delete_part1_grandparent_in_law_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship ='Grandparent' or relationship like 'Grandparent/Grandparent%'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Grandparent/Grandparent%'
;

### Delete Grandparent/Grandparent-in-law that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_grandparent_in_law_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);


### Removing Great-grandchild/Great-grandchild-in-law from pairs that have Great-grandchild
create table delete_part1_greatgrandchild_in_law_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship ='Great-grandchild' or relationship like 'Great-grandchild/Great-grandchild%'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Great-grandchild/Great-grandchild%'
;

### Delete Great-grandchild/Great-grandchild-in-law that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_greatgrandchild_in_law_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);


# Great-grandparent/Great-grandparent-in-law

### Removing Great-grandparent/Great-grandparent-in-law from pairs that have Great-grandparent
create table delete_part1_greatgrandparent_in_law_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship ='Great-grandparent' or relationship like 'Great-grandparent/Great-grandparent%'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Great-grandparent/Great-grandparent%'
;

### Delete Great-grandparent/Great-grandparent-in-law that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_greatgrandparent_in_law_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);


# Nephew/Niece/Nephew-in-law/Niece-in-law

### Removing Nephew/Niece/Nephew-in-law/Niece-in-law from pairs that have Nephew/Niece
create table delete_part1_nephew_in_law_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship ='Nephew/Niece' or relationship like 'Nephew/Niece/Nephew%'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Nephew/Niece/Nephew%'
;

### Delete Nephew/Niece/Nephew-in-law/Niece-in-law that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_nephew_in_law_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);


# Sibling/Sibling-in-law

### Removing Sibling/Sibling-in-law from pairs that have Sibling
create table delete_part1_sibling_in_law_cases
select b.mrn, b.relation_mrn, c.relationship
from(
select mrn, relation_mrn, count(relationship)
from (
select distinct mrn, relationship, `relation_mrn`
from actual_and_inf_rel_part1_unique_clean
where relationship ='Sibling' or relationship like 'Sibling/Sibling%'
)a
group by  mrn, relation_mrn
having count(relationship)>1
)b
join actual_and_inf_rel_part1_unique_clean c on (b.mrn = c.mrn) and (b.relation_mrn = c.relation_mrn)
where c.relationship like 'Sibling/Sibling%'
;

### Delete Sibling/Sibling-in-law that can be excluded from the table unique_clean
delete a
from actual_and_inf_rel_part1_unique_clean a
join delete_part1_sibling_in_law_cases b on (a.mrn = b.mrn) and (a.relation_mrn = b.relation_mrn) and (a.relationship = b.relationship);



### Creating table to run new script
create table database.patient_relations_w_opposites_part2
select distinct empi_or_mrn, relationship, relation_empi_or_mrn
from actual_and_inf_rel_part1_unique_clean
union
select distinct a.relation_empi_or_mrn as empi_or_mrn, b.relationship_opposite as relationship, a.empi_or_mrn as relation_empi_or_mrn
from actual_and_inf_rel_part1_unique_clean a
join relationship_lookup b on a.relationship = b.relationship
;

























