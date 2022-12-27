select * from HumanResources.EmployeePayHistory
select * from HumanResources.Department
select * from HumanResources.Employee
select * from HumanResources.EmployeeDepartmentHistory
 
select x.* into EmpDet from(select 
eph.BusinessEntityID,
p.FirstName Name,
d.Name as Dept,
eph.Rate
from HumanResources.EmployeePayHistory eph
join Person.Person p on eph.BusinessEntityID = p.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory edh on p.BusinessEntityID = edh.BusinessEntityID
join HumanResources.Department d on edh.DepartmentID = d.DepartmentID
where edh.ModifiedDate not in (select distinct ModifiedDate from HumanResources.EmployeePayHistory eph)
)x;

select * from EmpDet;

select ed.*,max (ed.rate) over(partition by ed.dept) as max_rate
from EmpDet ed;

---row number,rank,dense rank,lead and lag

--ROW_NUMBER
--To implement the row num (order by is must)
select ed.*,
ROW_NUMBER() OVER(Partition by dept order by BusinessEntityID) AS Row_num
from EmpDet ED;

--to take top two employees
select z.* from(select ed.*,
ROW_NUMBER() OVER(Partition by dept order by BusinessEntityID) AS Row_num
from EmpDet ED)z
where z.Row_num < 3 ;

--RANK
--to fetch the rank by rate
select ed.*,
rank () over (partition by ed.dept order by ed.Rate desc) as rank
from EmpDet ed;

--to fetch the no 1 rank by rate from each dept
select z.* from
(select ed.*,
rank () over (partition by ed.dept order by ed.Rate desc) as rank
from EmpDet ed)z
where z.rank = 1;

--DENSE_RANK
select ed.*,
rank () over (partition by ed.dept order by ed.Rate desc) as rank,
dense_rank() over (partition by ed.dept order by ed.Rate desc) as d_rank
from EmpDet ed;

--LAG()
--to compare with the previous record
select ed.*,
lag(Rate,1,0) over (partition by dept order by BusinessEntityID) as p_emp_rate
from EmpDet ed;

select ed.*,
lag(Rate) over (partition by dept order by BusinessEntityID) as p_emp_rate,
	case 
	when ed.Rate > lag(Rate) over (partition by dept order by BusinessEntityID) then 'Higher than Previous Emp'
	when ed.Rate < lag(Rate) over (partition by dept order by BusinessEntityID) then 'Lower than Previous Emp'
	when ed.Rate = lag(Rate) over (partition by dept order by BusinessEntityID) then 'Equal to the Previous Emp'
	End Comparission
from EmpDet ed;

--LEAD
--to compare with the nxt record
select ed.*,
lead(Rate) over (partition by dept order by BusinessEntityID) as nx_emp_rate
from EmpDet ed;