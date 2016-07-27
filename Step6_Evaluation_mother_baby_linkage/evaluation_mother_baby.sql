### Evaluation of maternal relationships using the mother-baby linkage from EHR


## Overall performance query for relationship = mother

select *, tp/(tp+fn) as sensitivity, tp/(tp+fp) as ppv
from
(
	# True Positives (TP)
	select count(distinct mrn, relation_mrn) as tp
	from database.ACTUAL_AND_INF_REL_CLEAN_FINAL
	join database.mother_child_linkage on (mrn = child_mrn and relation_mrn = mother_mrn)
	where relationship_specific = 'Mother'
) tp 
join
(
	# False Positives (FP)
	select sum(mismatch) as fp
	from 
	(
		select mrn, sum(mother_mrn = relation_mrn) = 0 as mismatch
		from database.ACTUAL_AND_INF_REL_CLEAN_FINAL
		join database.mother_child_linkage on (mrn = child_mrn)
		where relationship_specific = 'Mother'
		group by mrn
	) a
) fp 
join
(
	# False Negatives (FN)
	select count(*) as fn
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL)
) fn
order by ppv desc;

### Create table to include matched path

create table database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path
select distinct a.mrn, a.relationship, a.relation_mrn, a.relationship_specific, b.matched_path
from ACTUAL_AND_INF_REL_CLEAN_FINAL a
join relations_matched_clean b on (a.mrn = b.mrn and a.relationship = b.relationship and a.relation_mrn = b.matched_relation_mrn);

## Based on number of distinct paths
# False Negatives (FN) - zero since there is no match, zero paths therefore we are calculationg only PPV
select *, tp/(tp+fp) as ppv
from
(
	# True Positives (TP)
	select npath, count(*) as tp
	from
	(
		select mrn, relation_mrn, count(distinct matched_path) npath
		from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path
		join database.mother_child_linkage on (mrn = child_mrn and relation_mrn = mother_mrn)
		where relationship_specific = 'Mother'
		group by mrn, relation_mrn
	) a
	group by npath
) tp 
join
(
	# False Positives (FP)
	select npath, sum(mismatch) as fp
	from
	(
		select mrn, npath, sum(mother_mrn = relation_mrn) = 0 as mismatch
		from 
		(
			select mrn, relation_mrn, count(distinct matched_path) npath
			from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path
			where relationship_specific = 'Mother'
			group by mrn, relation_mrn
		) a 
		join database.mother_child_linkage on (mrn = child_mrn)
		group by mrn
	) b
	group by npath
) fp using (npath)
order by ppv desc;



## Calculate TP, FP, FN, sensitivity and PPV by path for mother 
select *, tp/(tp+fn) as sensitivity, tp/(tp+fp) as ppv
from
(
	# True Positives (TP)
	select matched_path, count(distinct mrn, relation_mrn) as tp
	from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path
	join database.mother_child_linkage on (mrn = child_mrn and relation_mrn = mother_mrn)
	where relationship_specific = 'Mother'
	group by matched_path
) tp 
join
(
	# False Positives (FP)
	select matched_path, sum(mismatch) as fp
	from 
	(
		select mrn, matched_path, sum(mother_mrn = relation_mrn) = 0 as mismatch
		from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path
		join database.mother_child_linkage on (mrn = child_mrn)
		where relationship_specific = 'Mother'
		group by mrn, matched_path
	) a
	group by matched_path
) fp using (matched_path)
join
(
	# False Negatives (FN)
	select 'first' as matched_path, count(*) as fn
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'first')
	union
	select 'first,last', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'first,last')
	union
	select 'first,last,phone', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'first,last,phone')
	union
	select 'first,last,phone,zip', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'first,last,phone,zip')
	union
	select 'first,last,zip', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'first,last,zip')
	union
	select 'first,phone', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'first,phone')
	union
	select 'first,phone,zip', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'first,phone,zip')
	union
	select 'first,zip', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'first,zip')
	union
	select 'last', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'last')
	union
	select 'last,phone', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'last,phone')
	union
	select 'last,phone,zip', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'last,phone,zip')
	union
	select 'last,zip', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'last,zip')
	union
	select 'phone', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'phone')
	union
	select 'phone,zip', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'phone,zip')
	union
	select 'zip', count(*)
	from database.mother_child_linkage
	where child_mrn not in (select mrn from database.ACTUAL_AND_INF_REL_CLEAN_FINAL_w_matched_path where matched_path = 'zip')
) fn using (matched_path)
order by ppv desc;

