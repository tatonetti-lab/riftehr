# this script will find matches between EC and PT data. Two datasets should be preprocessed by the split_names_combine.py script, and input as `x_ec_processed` and `x_pt_processed`
#map FirstName
create table x_fn_distint
select distinct MRN, `FirstName`
from `x_pt_processed`;

create table x_fn_cnt (primary key(FirstName))
select a.FirstName, count(distinct MRN) as cnt
from x_fn_distint a
group by a.FirstName;

create table x_fn_unique (primary key(FirstName))
select distinct a.MRN, a.`FirstName`
from `x_pt_processed` a
join x_fn_cnt b on a.`FirstName` = b.`FirstName` 
where b.cnt = 1 ;

create table x_fn_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_fn_unique b on a.`EC_FirstName` = b.`FirstName`;

alter table x_fn_matched
modify matched_path varchar(255);

update x_fn_matched
set matched_path = 'first';

drop table `x_fn_distint`, `x_fn_cnt`, `x_fn_unique`;

#map LastName
create table x_ln_distint
select distinct MRN, LastName
from `x_pt_processed`;

create table x_ln_cnt (primary key(LastName))
select a.LastName, count(distinct MRN) as cnt
from x_ln_distint a
group by a.LastName;

create table x_ln_unique (primary key(LastName))
select distinct a.MRN, a.LastName
from `x_pt_processed` a
join x_ln_cnt b on a.`LastName` = b.`LastName`
where b.cnt = 1 ;

create table x_ln_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_ln_unique b on a.`EC_LastName` = b.`LastName`;

alter table x_ln_matched
modify matched_path varchar(255);

update x_ln_matched
set matched_path = 'last';

drop table `x_ln_distint`, `x_ln_cnt`, `x_ln_unique`;

#map Phone
create table x_ph_distint
select distinct MRN, PhoneNumber
from `x_pt_processed`;

create table x_ph_cnt (primary key(PhoneNumber))
select a.PhoneNumber, count(distinct MRN) as cnt
from x_ph_distint a
group by a.PhoneNumber;

create table x_ph_unique (primary key(PhoneNumber))
select distinct a.MRN, a.PhoneNumber
from `x_pt_processed` a
join x_ph_cnt b on a.`PhoneNumber` = b.`PhoneNumber`
where b.cnt = 1 ;

create table x_ph_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_ph_unique b on a.`EC_PhoneNumber` = b.`PhoneNumber`;

alter table x_ph_matched
modify matched_path varchar(255);

update x_ph_matched
set matched_path = 'phone';

drop table `x_ph_distint`, `x_ph_cnt`, `x_ph_unique`;

#map Zip
create table x_zip_distint
select distinct MRN, `Zipcode`
from `x_pt_processed`;

create table x_zip_cnt (primary key(Zipcode))
select a.Zipcode, count(distinct MRN) as cnt
from x_zip_distint a
group by a.Zipcode;

create table x_zip_unique (primary key(Zipcode))
select distinct a.MRN, a.`Zipcode`
from `x_pt_processed` a
join x_zip_cnt b on a.`Zipcode` = b.`Zipcode`
where b.cnt = 1 ;

create table x_zip_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_zip_unique b on a.`EC_Zipcode` = b.`Zipcode`;

alter table x_zip_matched
modify matched_path varchar(255);

update x_zip_matched
set matched_path = 'zip';

drop table `x_zip_distint`, `x_zip_cnt`, `x_zip_unique`;

#map FirstName, LastName
create table x_fn_ln_distint
select distinct MRN, `FirstName`, LastName
from `x_pt_processed`;

create table x_fn_ln_cnt (primary key(FirstName, LastName))
select a.FirstName, a.LastName, count(distinct MRN) as cnt
from x_fn_ln_distint a
group by a.FirstName, a.LastName;

create table x_fn_ln_unique (primary key(FirstName, LastName))
select distinct a.MRN, a.`FirstName`, a.LastName
from `x_pt_processed` a
join x_fn_ln_cnt b on a.`FirstName` = b.`FirstName` and a.`LastName` = b.`LastName`
where b.cnt = 1 ;

create table x_fn_ln_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_fn_ln_unique b on a.`EC_FirstName` = b.`FirstName` and a.`EC_LastName` = b.`LastName`;

alter table x_fn_ln_matched
modify matched_path varchar(255);

update x_fn_ln_matched
set matched_path = 'first,last';

drop table `x_fn_ln_distint`, `x_fn_ln_cnt`, `x_fn_ln_unique`;

#map FirstName, Phone
create table x_fn_ph_distint
select distinct MRN, `FirstName`, PhoneNumber
from `x_pt_processed`;

create table x_fn_ph_cnt (primary key(FirstName, PhoneNumber))
select a.FirstName, a.PhoneNumber, count(distinct MRN) as cnt
from x_fn_ph_distint a
group by a.FirstName, a.PhoneNumber;

create table x_fn_ph_unique (primary key(FirstName, PhoneNumber))
select distinct a.MRN, a.`FirstName`, a.PhoneNumber
from `x_pt_processed` a
join x_fn_ph_cnt b on a.`FirstName` = b.`FirstName` and a.`PhoneNumber` = b.`PhoneNumber`
where b.cnt = 1 ;

create table x_fn_ph_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_fn_ph_unique b on a.`EC_FirstName` = b.`FirstName` and a.`EC_PhoneNumber` = b.`PhoneNumber`;

alter table x_fn_ph_matched
modify matched_path varchar(255);

update x_fn_ph_matched
set matched_path = 'first,phone';

drop table `x_fn_ph_distint`, `x_fn_ph_cnt`, `x_fn_ph_unique`;

#map FirstName, Zip
create table x_fn_zip_distint
select distinct MRN, `FirstName`,`Zipcode`
from `x_pt_processed`;

create table x_fn_zip_cnt (primary key(FirstName, Zipcode))
select a.FirstName, a.Zipcode, count(distinct MRN) as cnt
from x_fn_zip_distint a
group by a.FirstName, a.Zipcode;

create table x_fn_zip_unique (primary key(FirstName, Zipcode))
select distinct a.MRN, a.`FirstName`, a.`Zipcode`
from `x_pt_processed` a
join x_fn_zip_cnt b on a.`FirstName` = b.`FirstName` and a.`Zipcode` = b.`Zipcode`
where b.cnt = 1 ;

create table x_fn_zip_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_fn_zip_unique b on a.`EC_FirstName` = b.`FirstName` and a.`EC_Zipcode` = b.`Zipcode`;

alter table x_fn_zip_matched
modify matched_path varchar(255);

update x_fn_zip_matched
set matched_path = 'first,zip';

drop table `x_fn_zip_distint`, `x_fn_zip_cnt`, `x_fn_zip_unique`;

#map LastName, Phone
create table x_ln_ph_distint
select distinct MRN, LastName, PhoneNumber
from `x_pt_processed`;

create table x_ln_ph_cnt (primary key(LastName, PhoneNumber))
select a.LastName, a.PhoneNumber, count(distinct MRN) as cnt
from x_ln_ph_distint a
group by a.LastName, a.PhoneNumber;

create table x_ln_ph_unique (primary key(LastName, PhoneNumber))
select distinct a.MRN, a.LastName, a.PhoneNumber
from `x_pt_processed` a
join x_ln_ph_cnt b on a.`LastName` = b.`LastName` and a.`PhoneNumber` = b.`PhoneNumber`
where b.cnt = 1 ;

create table x_ln_ph_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_ln_ph_unique b on a.`EC_LastName` = b.`LastName` and a.`EC_PhoneNumber` = b.`PhoneNumber`;

alter table x_ln_ph_matched
modify matched_path varchar(255);

update x_ln_ph_matched
set matched_path = 'last,phone';

drop table `x_ln_ph_distint`, `x_ln_ph_cnt`, `x_ln_ph_unique`;

#map LastName, Zipcode
create table x_ln_zip_distint
select distinct MRN, LastName, `Zipcode`
from `x_pt_processed`;

create table x_ln_zip_cnt (primary key(LastName, Zipcode))
select a.LastName, a.Zipcode, count(distinct MRN) as cnt
from x_ln_zip_distint a
group by a.LastName, a.Zipcode;

create table x_ln_zip_unique (primary key(LastName, Zipcode))
select distinct a.MRN, a.LastName, a.`Zipcode`
from `x_pt_processed` a
join x_ln_zip_cnt b on a.`LastName` = b.`LastName` and a.`Zipcode` = b.`Zipcode`
where b.cnt = 1 ;

create table x_ln_zip_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_ln_zip_unique b on a.`EC_LastName` = b.`LastName` and a.`EC_Zipcode` = b.`Zipcode`;

alter table x_ln_zip_matched
modify matched_path varchar(255);

update x_ln_zip_matched
set matched_path = 'last,zip';

drop table `x_ln_zip_distint`, `x_ln_zip_cnt`, `x_ln_zip_unique`;

#map Phone, Zipcode
create table x_ph_zip_distint
select distinct MRN, PhoneNumber, `Zipcode`
from `x_pt_processed`;

create table x_ph_zip_cnt (primary key(PhoneNumber, Zipcode))
select a.PhoneNumber, a.Zipcode, count(distinct MRN) as cnt
from x_ph_zip_distint a
group by a.PhoneNumber, a.Zipcode;

create table x_ph_zip_unique (primary key(PhoneNumber, Zipcode))
select distinct a.MRN, a.PhoneNumber, a.`Zipcode`
from `x_pt_processed` a
join x_ph_zip_cnt b on a.`PhoneNumber` = b.`PhoneNumber` and a.`Zipcode` = b.`Zipcode`
where b.cnt = 1 ;

create table x_ph_zip_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_ph_zip_unique b on a.`EC_PhoneNumber` = b.`PhoneNumber` and a.`EC_Zipcode` = b.`Zipcode`;

alter table x_ph_zip_matched
modify matched_path varchar(255);

update x_ph_zip_matched
set matched_path = 'phone,zip';

drop table `x_ph_zip_distint`, `x_ph_zip_cnt`, `x_ph_zip_unique`;

#map FirstName,LastName,Phone
create table x_fn_ln_ph_distint
select distinct MRN, `FirstName`, LastName, PhoneNumber
from `x_pt_processed`;

create table x_fn_ln_ph_cnt (primary key(FirstName, LastName, PhoneNumber))
select a.FirstName, a.LastName, a.PhoneNumber, count(distinct MRN) as cnt
from x_fn_ln_ph_distint a
group by a.FirstName, a.LastName, a.PhoneNumber;

create table x_fn_ln_ph_unique (primary key(FirstName, LastName, PhoneNumber))
select distinct a.MRN, a.`FirstName`, a.LastName, a.PhoneNumber
from `x_pt_processed` a
join x_fn_ln_ph_cnt b on a.`FirstName` = b.`FirstName` and a.`LastName` = b.`LastName` and a.`PhoneNumber` = b.`PhoneNumber`
where b.cnt = 1 ;

create table x_fn_ln_ph_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_fn_ln_ph_unique b on a.`EC_FirstName` = b.`FirstName` and a.`EC_LastName` = b.`LastName` and a.`EC_PhoneNumber` = b.`PhoneNumber`;

alter table x_fn_ln_ph_matched
modify matched_path varchar(255);

update x_fn_ln_ph_matched
set matched_path = 'first,last,phone';

drop table `x_fn_ln_ph_distint`, `x_fn_ln_ph_cnt`, `x_fn_ln_ph_unique`;

#map FirstName,LastName,Zipcode
create table x_fn_ln_zip_distint
select distinct MRN, `FirstName`, LastName, `Zipcode`
from `x_pt_processed`;

create table x_fn_ln_zip_cnt (primary key(FirstName, LastName, Zipcode))
select a.FirstName, a.LastName, a.Zipcode, count(distinct MRN) as cnt
from x_fn_ln_zip_distint a
group by a.FirstName, a.LastName, a.Zipcode;

create table x_fn_ln_zip_unique (primary key(FirstName, LastName, Zipcode))
select distinct a.MRN, a.`FirstName`, a.LastName, a.`Zipcode`
from `x_pt_processed` a
join x_fn_ln_zip_cnt b on a.`FirstName` = b.`FirstName` and a.`LastName` = b.`LastName` and a.`Zipcode` = b.`Zipcode`
where b.cnt = 1 ;

create table x_fn_ln_zip_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_fn_ln_zip_unique b on a.`EC_FirstName` = b.`FirstName` and a.`EC_LastName` = b.`LastName` and a.`EC_Zipcode` = b.`Zipcode`;

alter table x_fn_ln_zip_matched
modify matched_path varchar(255);

update x_fn_ln_zip_matched
set matched_path = 'first,last,zip';

drop table `x_fn_ln_zip_distint`, `x_fn_ln_zip_cnt`, `x_fn_ln_zip_unique`;

#map FirstName,Phone,Zipcode
create table x_fn_ph_zip_distint
select distinct MRN, `FirstName`, PhoneNumber, `Zipcode`
from `x_pt_processed`;

create table x_fn_ph_zip_cnt (primary key(FirstName, PhoneNumber, Zipcode))
select a.FirstName, a.PhoneNumber, a.Zipcode, count(distinct MRN) as cnt
from x_fn_ph_zip_distint a
group by a.FirstName, a.PhoneNumber, a.Zipcode;

create table x_fn_ph_zip_unique (primary key(FirstName, PhoneNumber, Zipcode))
select distinct a.MRN, a.`FirstName`, a.PhoneNumber, a.`Zipcode`
from `x_pt_processed` a
join x_fn_ph_zip_cnt b on a.`FirstName` = b.`FirstName` and a.`PhoneNumber` = b.`PhoneNumber` and a.`Zipcode` = b.`Zipcode`
where b.cnt = 1 ;

create table x_fn_ph_zip_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_fn_ph_zip_unique b on a.`EC_FirstName` = b.`FirstName` and a.`EC_PhoneNumber` = b.`PhoneNumber` and a.`EC_Zipcode` = b.`Zipcode`;

alter table x_fn_ph_zip_matched
modify matched_path varchar(255);

update x_fn_ph_zip_matched
set matched_path = 'first,phone,zip';

drop table `x_fn_ph_zip_distint`, `x_fn_ph_zip_cnt`, `x_fn_ph_zip_unique`;

#map LastName,Phone,Zipcode
create table x_ln_ph_zip_distint
select distinct MRN, LastName, PhoneNumber, `Zipcode`
from `x_pt_processed`;

create table x_ln_ph_zip_cnt (primary key(LastName, PhoneNumber, Zipcode))
select a.LastName, a.PhoneNumber, a.Zipcode, count(distinct MRN) as cnt
from x_ln_ph_zip_distint a
group by a.LastName, a.PhoneNumber, a.Zipcode;

create table x_ln_ph_zip_unique (primary key(LastName, PhoneNumber, Zipcode))
select distinct a.MRN, a.LastName, a.PhoneNumber, a.`Zipcode`
from `x_pt_processed` a
join x_ln_ph_zip_cnt b on a.`LastName` = b.`LastName` and a.`PhoneNumber` = b.`PhoneNumber` and a.`Zipcode` = b.`Zipcode`
where b.cnt = 1 ;

create table x_ln_ph_zip_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_ln_ph_zip_unique b on a.`EC_LastName` = b.`LastName` and a.`EC_PhoneNumber` = b.`PhoneNumber` and a.`EC_Zipcode` = b.`Zipcode`;

alter table x_ln_ph_zip_matched
modify matched_path varchar(255);

update x_ln_ph_zip_matched
set matched_path = 'last,phone,zip';

drop table `x_ln_ph_zip_distint`, `x_ln_ph_zip_cnt`, `x_ln_ph_zip_unique`;

#map FirstName,LastName,Phone,Zipcode
create table x_fn_ln_ph_zip_distint
select distinct MRN, `FirstName`, LastName, PhoneNumber, `Zipcode`
from `x_pt_processed`;

create table x_fn_ln_ph_zip_cnt (primary key(FirstName, LastName, PhoneNumber, Zipcode))
select a.FirstName, a.LastName, a.PhoneNumber, a.Zipcode, count(distinct MRN) as cnt
from x_fn_ln_ph_zip_distint a
group by a.FirstName, a.LastName, a.PhoneNumber, a.Zipcode;

create table x_fn_ln_ph_zip_unique (primary key(FirstName, LastName, PhoneNumber, Zipcode))
select distinct a.MRN, a.`FirstName`, a.LastName, a.PhoneNumber, a.`Zipcode`
from `x_pt_processed` a
join x_fn_ln_ph_zip_cnt b on a.`FirstName` = b.`FirstName` and a.`LastName` = b.`LastName` and a.`PhoneNumber` = b.`PhoneNumber` and a.`Zipcode` = b.`Zipcode`
where b.cnt = 1 ;

create table x_fn_ln_ph_zip_matched
select distinct a.MRN_1 as empi_or_mrn, a.`EC_Relationship` as relationship, b.`MRN` as relation_empi_or_mrn, NULL as matched_path
from `x_ec_processed` a
join x_fn_ln_ph_zip_unique b on a.`EC_FirstName` = b.`FirstName` and a.`EC_LastName` = b.`LastName` and a.`EC_PhoneNumber` = b.`PhoneNumber` and a.`EC_Zipcode` = b.`Zipcode`;

alter table x_fn_ln_ph_zip_matched
modify matched_path varchar(255);

update x_fn_ln_ph_zip_matched
set matched_path = 'first,last,phone,zip';

drop table `x_fn_ln_ph_zip_distint`, `x_fn_ln_ph_zip_cnt`, `x_fn_ln_ph_zip_unique`;

create table x_cumc_patient_matched
select * from x_fn_matched
union all
select * from x_ln_matched
union all
select * from x_ph_matched
union all
select * from x_zip_matched
union all
select * from x_fn_ln_matched
union all
select * from x_fn_ph_matched
union all
select * from x_fn_zip_matched
union all
select * from x_ln_ph_matched
union all
select * from x_ln_zip_matched
union all
select * from x_ph_zip_matched
union all
select * from x_fn_ln_ph_matched
union all
select * from x_fn_ln_zip_matched
union all
select * from x_fn_ph_zip_matched
union all
select * from x_ln_ph_zip_matched
union all
select * from x_fn_ln_ph_zip_matched;
