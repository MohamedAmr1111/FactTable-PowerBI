Use [Fact and Dim Tables];
--Employee Dimension
create table EmployeeDim(
EmployeeID int,
FirstName varchar(100),
LastName varchar(100),
DepartmentID Int,
JobTitle varchar(100),
HireDate Date,
Gender varchar(100),
MaritalStatus varchar(100)
primary key(EmployeeID,DepartmentID)
)
-- Fill Data Of EmployeeDim Table
Use AdventureWorks2022;
Insert into [Fact and Dim Tables]..EmployeeDim(
EmployeeID,
FirstName,
LastName,
DepartmentID,
JobTitle,
HireDate,
Gender,
MaritalStatus
)
select
E.BusinessEntityID,
P.FirstName,
P.LastName,
ED.DepartmentID,
E.JobTitle,
E.HireDate,
E.Gender,
E.MaritalStatus
from HumanResources.Employee E
join Person.Person P
on E.BusinessEntityID = P.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory ED
on E.BusinessEntityID = ED.BusinessEntityID 
join HumanResources.Department D
on D.DepartmentID = ED.DepartmentID
where E.JobTitle !='Buyer'


--ManagerDim
Use [Fact and Dim Tables];
Create table ManagerDim(
ManagerID int,
ManagerName varchar(100),
DepartmentID Int,
ManagerJobTitle varchar(100),
managerHireDate Date,
Primary key(ManagerID,DepartmentID)
)

Use AdventureWorks2022;

insert into [Fact and Dim Tables]..ManagerDim(
ManagerID,
ManagerName,
DepartmentID,
ManagerJobTitle,
managerHireDate
)
select 
E.BusinessEntityID,
CONCAT(p.FirstName ,' ',p.LastName),
D.DepartmentID,
E.JobTitle,
E.HireDate
from HumanResources.Employee E 
join Person.Person P on P.BusinessEntityID = E.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory DH on DH.BusinessEntityID = E.BusinessEntityID
join HumanResources.Department D on DH.DepartmentID = D.DepartmentID
where E.JobTitle like '%Manager%'

-- Department Dim
use [Fact and Dim Tables];
create table DepartmentDim(
DepartmentID int Primary Key,
DepartmentName varchar(100),
NumberOfEmployees int
)

use AdventureWorks2022;

insert into [Fact and Dim Tables]..DepartmentDim(
DepartmentID,
DepartmentName,
NumberOfEmployees
)
select 
D.DepartmentID,
D.Name,
COUNT(E.BusinessEntityID)
from HumanResources.Department D
join HumanResources.EmployeeDepartmentHistory ED on ED.DepartmentID = D.DepartmentID
join HumanResources.Employee E on E.BusinessEntityID = ED.BusinessEntityID
group by D.Name,D.DepartmentID

-- JobRole Dimension
use [Fact and Dim Tables];
create table JobRoleDim(
JobRoleID int primary key,
DempartmentID int,
jobtitle nvarchar(100),
EmployeeCount int
)

use AdventureWorks2022;

insert into [Fact and Dim Tables]..JobRoleDim(
JobRoleID,
DempartmentID,
jobtitle,
EmployeeCount
)
select
ROW_NUMBER() over (order by E.jobTitle) AS jobRoleID,
D.DepartmentID,
E.jobTitle,
COUNT(*) AS EmployeeCount
from HumanResources.Employee E
join HumanResources.EmployeeDepartmentHistory ED on ED.BusinessEntityID = E.BusinessEntityID
join HumanResources.Department D on D.DepartmentID = ED.DepartmentID
group by D.DepartmentID , E.JobTitle

-- ManPower Fact Table
use [Fact and Dim Tables];
create table ManPowerFactTable(
ManPowerID int Primary Key,
DepartmentID int,
DepartmentName nvarchar(100),
ManagerID int,
ManagerName nvarchar(100),
JobRoleID int,
JobTitle Nvarchar(100),
NumberOfEmployees int
Constraint FK_DepartmentDim FOREIGN key(DepartmentID) references DepartmentDim(DepartmentID),
CONSTRAINT FK_ManagerDim FOREIGN KEY (ManagerID,DepartmentID) REFERENCES ManagerDim(ManagerID,DepartmentID),
Constraint FK_JobRoleDim FOREIGN key(JobRoleID) references JobRoleDim(JobRoleID),
Constraint FK_EmployeeDim FOREIGN KEY (ManagerID, DepartmentID) REFERENCES EmployeeDim(EmployeeID, DepartmentID)
)

use [Fact and Dim Tables]
insert into [Fact and Dim Tables]..ManPowerFactTable(
ManPowerID,
DepartmentID,
DepartmentName,
ManagerID,
ManagerName,
JobRoleID,
JobTitle,
NumberOfEmployees 
)
select 
ROW_NUMBER() Over(ORDER BY D.DepartmentID, M.ManagerID, JR.JobRoleID) as ManPowerID,
D.DepartmentID,
D.DepartmentName,
M.ManagerID,
M.ManagerName,
JR.JobRoleID,
E.JobTitle,
Count(*)
from DepartmentDim D
join ManagerDim M on M.DepartmentID = D.DepartmentID
join EmployeeDim E on E.DepartmentID = D.DepartmentID
join JobRoleDim JR on JR.DempartmentID = D.DepartmentID
group by 
	D.DepartmentID,
    D.DepartmentName,
    M.ManagerID,
    M.ManagerName,
    JR.JobRoleID,
    E.JobTitle


-- Product Sales Dimension
use [Fact and Dim Tables];
create table ProductSalesDim(
ProductID int,
ProductName varchar(100),
StandardCost float,
ListPrice float,
SalesOrderID int,
ProductSubCategory varchar(100),
ProductCategory varchar(100),
OnlineOrderFlag varchar(20),
primary key(ProductID , SalesOrderID)
)

use AdventureWorks2022
insert into [Fact and Dim Tables]..ProductSalesDim(
ProductID,
ProductName,
StandardCost,
ListPrice,
SalesOrderID,
ProductSubCategory,
ProductCategory,
OnlineOrderFlag
)
select
P.ProductID,
P.Name,
P.StandardCost,
P.ListPrice,
SOH.SalesOrderID,
PSC.Name,
PC.Name,
SOH.OnlineOrderFlag
from Production.Product P
join Sales.SalesOrderDetail SOD on SOD.ProductID = P.ProductID
join Sales.SalesOrderHeader SOH on SOH.SalesOrderID = SOD.SalesOrderID
join Production.ProductSubcategory PSC on PSC.ProductSubcategoryID = P.ProductSubcategoryID
join Production.ProductCategory PC on PC.ProductCategoryID = PSC.ProductCategoryID
order by ProductID , SalesOrderID asc

--Customer Dimension
use [Fact and Dim Tables];
create table CustomerDim(
CustomerID int,
CustomerName varchar(100),
TerritoryID int,
SalesOrderID int,
AccountNumber varchar(50),
TotalDue Float,
AddressID int,
EmailAddress varchar(100),
MobileNumber varchar(20),
Primary Key(CustomerID,AddressID,SalesOrderID)
)

use AdventureWorks2022;

insert into [Fact and Dim Tables]..CustomerDim(
CustomerID,
CustomerName,
TerritoryID,
SalesOrderID,
AccountNumber,
TotalDue,
AddressID,
EmailAddress,
MobileNumber
)
select 
C.CustomerID,
CONCAT(P.FirstName,' ',P.LastName) as FullName,
C.TerritoryID,
SOH.SalesOrderID,
C.AccountNumber,
SOH.TotalDue,
BEA.AddressID,
EA.EmailAddress,
PP.PhoneNumber
from Sales.Customer C
join Person.Person P on P.BusinessEntityID = C.CustomerID
join Person.BusinessEntityAddress BEA on BEA.BusinessEntityID = P.BusinessEntityID
join Person.EmailAddress EA on EA.BusinessEntityID = P.BusinessEntityID
join Person.PersonPhone PP on PP.BusinessEntityID = P.BusinessEntityID
join Sales.SalesOrderHeader SOH on SOH.CustomerID = C.CustomerID

-- Internet Sales Fact Table
use [Fact and Dim Tables];
create table InternetSalesFact(
CustomerID int,
AddressID int,
ProductID int,
ProductName varchar(100),
ProductCategory varchar(100),
ProductSubCategory varchar(100),
SalesOrderID int,
ListPrice float,
TotalDue float,
primary key(CustomerID,AddressID,SalesOrderID,ProductID),
Constraint FK_customerDim FOREIGN KEY (CustomerID , AddressID,SalesOrderID) references CustomerDim(CustomerID , AddressID,SalesOrderID),
Constraint Fk_ProductDim FOREIGN KEY (ProductID,SalesOrderID) references ProductSalesDim(ProductID,SalesOrderID)
)

insert into InternetSalesFact(
CustomerID,
AddressID,
ProductID,
ProductName,
ProductCategory,
ProductSubCategory,
SalesOrderID,
ListPrice,
TotalDue
)
select 
C.CustomerID,
C.AddressID,
P.ProductID,
P.ProductName,
P.ProductCategory,
P.ProductSubCategory,
C.SalesOrderID,
P.ListPrice,
C.TotalDue
from CustomerDim C 
join ProductSalesDim P on P.SalesOrderID = C.SalesOrderID
where OnlineOrderFlag = 1









