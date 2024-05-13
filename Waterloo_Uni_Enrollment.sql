Use waterloo_enrollment;
-- total no of rows 61953 --
Select count(*) from enrollment;
-- Show column name --
Show columns from enrollment;

-- Verify the presence of NULL value in any column --
Select count(*) from enrollment where `ï»¿Fiscal Year` IS NULL;
Select count(*) from enrollment where `Term Type` IS NULL;
Select count(*) from enrollment where career IS NULL;
Select count(*) from enrollment where `Program Level` IS NULL;
Select count(*) from enrollment where `Study Year` IS NULL;
Select count(*) from enrollment where `Faculty (group)` IS NULL;
Select count(*) from enrollment where `Program Grouping` IS NULL;
Select count(*) from enrollment where `Coop Regular` IS NULL;
Select count(*) from enrollment where `Work Term` IS NULL;
Select count(*) from enrollment where Attendance IS NULL;
Select count(*) from enrollment where `Visa Status` IS NULL;
Select count(*) from enrollment where `Student Headcount` IS NULL;
-- there is no null value or row presented --

-- Verify the presented data belongs to/ represents the value of a particular column -- Data Validation --
Select distinct `ï»¿Fiscal Year` from enrollment;
Select distinct `Term Type` from enrollment;
Select distinct `Career` from enrollment;
Select distinct `Program Level` from enrollment;
Select distinct `Study Year` from enrollment; -- N D M not suitable year--
Select distinct Campus from enrollment;
Select distinct `Faculty (group)` from enrollment;
Select distinct `Program Grouping` from enrollment;
Select distinct `Coop Regular` from enrollment;
Select distinct `Work Term` from enrollment;
Select distinct `Attendance` from enrollment;
Select distinct `Visa Status` from enrollment;
Select distinct `Student Headcounts` from enrollment;

-- after running the above queries we came to knwo that Study Year column contains data with N D M - which is not suitable to year --

Select count(*) from enrollment where `Study Year`="M";
-- N=1598 D=4085 M=6760 --
-- After running above query we can see that N D M contains large number of data which may be a type of  input from the users end.--


-- Verify duplicate row --
SELECT `enrollment`.`ï»¿Fiscal Year`,`enrollment`.`Term Type`,`enrollment`.`Career`,`enrollment`.`Program Level`,`enrollment`.`Study Year`,`enrollment`.`Campus`,
    `enrollment`.`Faculty (group)`,`enrollment`.`Program Grouping`,`enrollment`.`Coop Regular`,`enrollment`.`Work Term`,`enrollment`.`Attendance`,`enrollment`.`Visa Status`,`enrollment`.`Student Headcounts`
FROM `waterloo_enrollment`.`enrollment`
GROUP by `enrollment`.`ï»¿Fiscal Year`,
    `enrollment`.`Term Type`,`enrollment`.`Career`,`enrollment`.`Program Level`, `enrollment`.`Study Year`,`enrollment`.`Campus`,`enrollment`.`Faculty (group)`,
    `enrollment`.`Program Grouping`,`enrollment`.`Coop Regular`,`enrollment`.`Work Term`,`enrollment`.`Attendance`,`enrollment`.`Visa Status`,`enrollment`.`Student Headcounts`
having count(*)>1;
-- There is no duplicate row --

-- Let's do some cleaning -- Update column name --
Alter table enrollment rename column `ï»¿Fiscal Year` to FiscalYear;
Alter table enrollment rename column `Faculty (group)` to Faculty;
Alter table enrollment rename column `Program Grouping` to Program;
Alter table enrollment rename column `Student Headcounts` to Stu_Headcount;

Select distinct `FiscalYear` from enrollment;
SET SQL_SAFE_UPDATES = 0; 

savepoint sp1;

-- Let's add new column FYear to get only enrolled year --
Alter table enrollment add column FYear Date;
Alter table enrollment modify column FYear Text; -- Need to update adata type as Text can't be copied in Date data type 

-- New column contains the first 4 digitsl of FIscalYear column --
Update enrollment
  set FYear = Left(FiscalYear,4);

-- Time to verify our updated table --
Select * from enrollment where Fyear="2017" limit 10;

savepoint sp2;

-- Delete column Fiscal Year from the eonrollment table --
Alter table enrollment 
Drop column FiscalYear;

-- Let's run some queries that we can showcase on our dashboard -- cross verification

-- Card and measures --
Select sum(Stu_headcount) from enrollment;
Select count(distinct(Program)) from enrollment;
Select count(distinct(Faculty)) from enrollment;

-- Let's delve deep into graphs --
Select sum(Stu_Headcount) from enrollment where `Term Type`='Fall term'; -- enrollment by term type
Select sum(Stu_Headcount) from enrollment where `Program level`='Bachelors'; -- enrollment by Program level
Select sum(Stu_Headcount), `FYear` from enrollment Group by FYear; -- Enrollment Trend

-- Lets apply filter -- enrollment trend with Visa Status as Canadian 
Select sum(Stu_Headcount),`FYear` from enrollment where `Visa Status`= 'Canadian' Group by (FYear) order by sum(Stu_Headcount); 
 -- Enrollment by Faculty
Select sum(Stu_Headcount) from enrollment where `Coop Regular`= 'Co-op' AND `Program`= 'Computer Science';
-- Student by Faculty and coop regular
Select sum(Stu_Headcount), Faculty from enrollment where `Coop Regular`= 'Co-op' group by Faculty order by Sum(stu_headcount) desc limit 7;
-- Student by campus and program level
Select sum(Stu_Headcount), Campus from enrollment group by Campus having sum(Stu_Headcount)>8000 order by `program level`; 

savepoint sp3;




