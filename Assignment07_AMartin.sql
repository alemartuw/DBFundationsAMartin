--*************************************************************************--
-- Title: Assignment07
-- Author: A.Martin
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2025-03-08,YourNameHere,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_AMartin')
	 Begin 
	  Alter Database [Assignment07DB_AMartin] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_AMartin;
	 End
	Create Database Assignment07DB_AMartin;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_Amartin;

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
,[UnitPrice] [money] NOT NULL
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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --
Select ProductName, Format (UnitPrice,'C', 'en-us') as UnitPrice  from vProducts
  Order by ProductName;
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --
Select CategoryName, ProductName,Format (UnitPrice,'C', 'en-us') as UnitPrice
    From  dbo.vProducts as vp
	  Join dbo.vCategories as vc
	  On vp.CategoryID = vc.CategoryID
Order by CategoryName, ProductName;
go
--Create view (1)
--go
--Create or Alter View vCategoryByProductsByUnitPrice WITH Schemabinding 
--AS
--  Select CategoryName, ProductName,UnitPrice
--    From  dbo.Products as p
--	  Join dbo.Categories as c
--	  On p.CategoryID = c.CategoryID;
--go 
--Select * FROM vCategoryByProductsByUnitPrice;

-- --Create view (2) - Create function using views,  and add order by in the view
--go
-- Create or Alter View vCategoryByProductsByUnitPrice WITH Schemabinding 
--AS
--  Select TOP 1000000 CategoryName, ProductName,Format (UnitPrice,'C', 'en-us') as UnitPrice
--    From  dbo.vProducts as vp
--	  Join dbo.vCategories as vc
--	  On vp.CategoryID = vc.CategoryID
--Order by CategoryName, ProductName;
--go
--Select * FROM vCategoryByProductsByUnitPrice;

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

go
Select ProductName, Format (InventoryDate,'MMMM'+'", "'+ 'yyyy') as InventoryDate, Count as InventoryCount
 From  dbo.vProducts as vp
 Join dbo.vInventories as vi
On vp.ProductID = vi.ProductID
Order by ProductName, vi.InventoryDate;
go


-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
go
Create or Alter View vProductInventories WITH Schemabinding 
AS
  --Select TOP 1000000 ProductName, InventoryDate, Count as InventoryCount
  --Select TOP 1000000 ProductName, Format (InventoryDate,'MMMM')+', '+Format(InventoryDate,'yyyy') as InventoryDate, Count as InventoryCount
  Select TOP 1000000 ProductName, Format (InventoryDate,'MMMM'+'", "'+ 'yyyy') as InventoryDate, Count as InventoryCount
	From  dbo.vProducts as vp
	Join dbo.vInventories as vi
	On vp.ProductID = vi.ProductID
Order by ProductName, vi.InventoryDate;
go
-- Check that it works: Select * From vProductInventories;
Select * FROM vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
--Select TOP 3 * From vCategories;
--Select TOP 3 * From vProducts;
--Select TOP 3 * From vEmployees;
--Select TOP 3 * From vInventories;
go
Create or Alter View vCategoryInventories WITH Schemabinding 
AS
  Select TOP 1000000 CategoryName
    ,Format (InventoryDate,'MMMM'+'", "'+ 'yyyy') as InventoryDate
	,SUM (Count) as InventoryCountByCategory
	  From  dbo.vProducts as vp
	  Join dbo.vInventories as vi
	  On vp.ProductID = vi.ProductID
	  Join dbo.vCategories as vc
	  On vc.CategoryID = vp.CategoryID
	    group by vi.InventoryDate,CategoryName;
go
-- Check that it works: Select * From vCategoryInventories;
Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
--Select * from vProductInventories;
go
Create or Alter View vProductInventoriesWithPreviousMonthCounts WITH Schemabinding 
AS
  Select TOP 1000000 ProductName
    ,InventoryDate
  	,SUM (InventoryCount) as InventoryCount
	--,lag (Sum(InventoryCount)) Over(Partition by ProductName Order By Month(InventoryDate),0) as PreviousMonthCount
	,isnull(lag (Sum(InventoryCount),1,0) Over(Partition by ProductName Order By Month(InventoryDate)),0) as PreviousMonthCount 
	From  dbo.vProductInventories as vpi
	group by InventoryDate,ProductName,InventoryCount;
	--Order by ProductName, Month(InventoryDate);
go
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
go
Create or Alter View vProductInventoriesWithPreviousMonthCountsWithKPIs WITH Schemabinding 
AS
  Select TOP 1000000 ProductName
    ,InventoryDate
	,InventoryCount
	,PreviousMonthCount
	,Case 
	      When InventoryCount = PreviousMonthCount Then 0
	      when InventoryCount > PreviousMonthCount Then 1
		  when InventoryCount < PreviousMonthCount Then -1
     End as CountVsPreviousCountKPI
  	--,SUM (InventoryCount) as InventoryCount
	--,isnull(lag (Sum(InventoryCount),1,0) Over(Partition by ProductName Order By Month(InventoryDate)),0) as PreviousMonthCount 
	From  dbo.vProductInventoriesWithPreviousMonthCounts
	Order by ProductName, Month(InventoryDate);
go
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
go
Create function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs
(
  @KPI as float
)
Returns table 
AS
Return 
	--Begin -- begin function
	  Select TOP 1000 ProductName
		,InventoryDate
		,InventoryCount
		,PreviousMonthCount
		,CountVsPreviousCountKPI
  	  From  dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
	  where CountVsPreviousCountKPI = @KPI
	  Order by ProductName, Month(InventoryDate);
	--End
go

-- Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
--*/
go

/***************************************************************************************/