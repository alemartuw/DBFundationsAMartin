--*************************************************************************--
-- Title: Assignment06
-- Author: Alessandra Martin
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2025-03-01,AMartin,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_AMartin')
	 Begin 
	  Alter Database [Assignment06DB_AMartin] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_AMartin;
	 End
	Create Database Assignment06DB_AMartin;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_AMartin;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Select CategoryID, CategoryName
 --   From  Categories;  -- created select

-- go  -- add view. need to add go before create 
--Create
--View vCategories
--WITH Schemabinding
--AS
--  Select CategoryID, CategoryName
--    From  Categories;
--go

go
Create
View vCategories
WITH Schemabinding -- added after view worked
AS
  Select CategoryID, CategoryName
    From  dbo.Categories; -- added dbo. since it was retrurning two-part error
go
Select * From [dbo].[vCategories]
  -- Products view
go
Create
View vProducts
WITH Schemabinding 
AS
  Select ProductID, ProductName, CategoryID, UnitPrice
    From  dbo.Products; 
go
Select * From [dbo].[vProducts]

go
Create
View vInventories
WITH Schemabinding 
AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
    From  dbo.Inventories; 
go
Select * From [dbo].[vInventories];
--Select * from Employees;
go

-- Employees view
Create
View vEmployees
WITH Schemabinding 
AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
    From  dbo.Employees; 
go
Select * From [dbo].[vEmployees]

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select on Categories to Public;
-- Select * from Categories;
Deny Select on Products to Public; 
Deny Select on Employees to Public;
Deny Select on Inventories to Public;
Grant Select on vCategories to Public;
Grant Select on Products to Public; 
Grant Select on Employees to Public;
Grant Select on Inventories to Public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

go 
Create
View vProductsByCategories
WITH Schemabinding 
AS
  Select CategoryName, ProductName, UnitPrice
    From  dbo.Products as p
	  Join dbo.Categories as c 
	  On c.CategoryID = p.CategoryID;
go
Select * FROM vProductsByCategories
  Order by CategoryName,ProductName;
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
--Select * From Categories;
--Select * From Products;
--Select * From Employees;
--Select * From Inventories;
go 
Create
View vInventoriesByProductsByDates
WITH Schemabinding 
AS
  Select ProductName, InventoryDate, Count
    From  dbo.Products as p
	  inner Join dbo.Inventories as i
	  On i.ProductID = p.ProductID
go
Select * FROM vInventoriesByProductsByDates
Order by ProductName, InventoryDate, Count;
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
--Select * From Categories;
--Select * From Products;
--Select * From Employees;
--Select * From Inventories;
go 
Create
View vInventoriesByEmployeesByDates
WITH Schemabinding 
AS
  Select InventoryDate, EmployeeFirstName + ' '+ EmployeeLastName as EmployeeName
    From  dbo.Inventories as i
	  Join dbo.Employees as e
	  On e.EmployeeID = i.EmployeeID
	    group by i.InventoryDate, e.EmployeeFirstName, e.EmployeeLastName;
go
Select * FROM vInventoriesByEmployeesByDates;
--Select * FROM vInventoriesByEmployeesByDates -- test group the view group by.
--group by InventoryDate, EmployeeName;
--go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

go 
Create
View vInventoriesByProductsByCategories
WITH Schemabinding 
AS
  Select CategoryName, ProductName,InventoryDate, Count
    From  dbo.Products as p
	  Join dbo.Categories as c
	  On p.CategoryID = c.CategoryID
	  Join dbo.Inventories as i
	  On p.ProductID = i.ProductID;
go
Select * FROM vInventoriesByProductsByCategories
  Order by CategoryName, ProductName,InventoryDate, Count;
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
go 
Create
View vInventoriesByProductsByEmployees
WITH Schemabinding 
AS
  Select CategoryName, ProductName,InventoryDate, Count, EmployeeFirstName + ' '+ EmployeeLastName as Employee
 -- Select CategoryName, ProductName,InventoryDate, sum (Count) as tCount, EmployeeFirstName + ' '+ EmployeeLastName as Employee
    From  dbo.Products as p
	  Join dbo.Categories as c
	  On p.CategoryID = c.CategoryID
	  Join dbo.Inventories as i
	  On p.ProductID = i.ProductID
	  Join dbo.Employees as e
	  On i.EmployeeID = e.EmployeeID
	  group by c.CategoryName, p.ProductName, i.InventoryDate, e.EmployeeFirstName, e.EmployeeLastName,i.Count;
go
Select * FROM vInventoriesByProductsByEmployees
  Order by InventoryDate, CategoryName, ProductName, Employee;
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
go 
Create
View vInventoriesForChaiAndChangByEmployees
WITH Schemabinding 
AS
  Select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' '+ EmployeeLastName as EmployeeName
    From dbo.Inventories as i 
      inner join dbo.Products as p
      ON i.ProductID = p.ProductID
	  inner join dbo.Categories as c
	  ON c.CategoryID = p.CategoryID
      inner join dbo.Employees as e
	  ON i.EmployeeID = e.EmployeeID
	    -- Where ProductName = 'Chai' or ProductName = 'Chang'
		Where p.ProductId between 1 And 2;
go
Select * FROM vInventoriesForChaiAndChangByEmployees;
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

go 
Create
View vEmployeesByManager
WITH Schemabinding 
AS
  Select e.EmployeeFirstName + ' '+ e.EmployeeLastName as Manager, m.EmployeeFirstName + ' '+ m.EmployeeLastName as Employee
    From dbo.Employees as e
     inner JOIN dbo.Employees m ON e.EmployeeID = m.ManagerID
go
Select * FROM vEmployeesByManager
  Order by Manager, Employee;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--Select * From [dbo].[vCategories]
--Select * From [dbo].[vProducts]
--Select * From [dbo].[vInventories]
--Select * From [dbo].[vEmployees]
--Select * From [dbo].[vEmployeesByManager] -- not the basic view, it doesn't have employee ID

go 
Create
View vInventoriesByProductsByCategoriesByEmployees
WITH Schemabinding 
AS
  Select 
	vc.CategoryID
	,vc.CategoryName
	,vp.ProductID
	,vp.ProductName
	,vp.UnitPrice
	,vi.InventoryID
	,vi.InventoryDate
	,vi.Count
	,vi.EmployeeID
	,ve.EmployeeFirstName +' '+ve.EmployeeFirstName as Employee
	,vm.EmployeeFirstName +' '+vm.EmployeeFirstName as Manager

   From dbo.vCategories as vc
      inner join dbo.vProducts as vp
      On vc.categoryID = vp.CategoryID
      inner join dbo.vInventories as vi
      On vp.ProductID = vi.ProductID
      inner join dbo.vEmployees as ve
      On ve.EmployeeID = vi.EmployeeID
      inner JOIN dbo.vEmployees vm
      On vm.EmployeeID = ve.ManagerID
 go
 Select * FROM vInventoriesByProductsByCategoriesByEmployees
   Order by CategoryID, ProductName, InventoryID, Employee;
go
-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'

-- A.Martin: comment this portion and added the select in each exercise, since some of them have a select order by. 
--Select * From [dbo].[vCategories]
--Select * From [dbo].[vProducts]
--Select * From [dbo].[vInventories]
--Select * From [dbo].[vEmployees]
--Select * From [dbo].[vProductsByCategories]
--Select * From [dbo].[vInventoriesByProductsByDates]
--Select * From [dbo].[vInventoriesByEmployeesByDates]
--Select * From [dbo].[vInventoriesByProductsByCategories]
--Select * From [dbo].[vInventoriesByProductsByEmployees]
--Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
--Select * From [dbo].[vEmployeesByManager]
--Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/