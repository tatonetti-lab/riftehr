### Identify conflicting relationships
create table ACTUAL_AND_INF_REL_CLEAN_FINAL_count_rels
select family_id, mrn, relation_mrn, count(distinct relationship) as num_uniq_rels
from family_IDs
join ACTUAL_AND_INF_REL_CLEAN_FINAL on (individual_id = mrn)
group by mrn, relation_mrn;
​
create table family_ids_count_conflicted
select family_id, count(distinct mrn) as num_individuals, sum(num_uniq_rels > 1) as num_rels_conflicted
from ACTUAL_AND_INF_REL_CLEAN_FINAL_count_rels
group by family_id;