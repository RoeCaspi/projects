/*
PROJECT 3 - Roe Caspi
[AdventureWorks2022]
creating view to use in python
*/

USE AdventureWorks2022

---Q1
GO

CREATE VIEW UnsoldProducts AS
SELECT P.ProductID, P.[Name], P.Color, P.ListPrice, P.Size
FROM Production.Product P LEFT JOIN Sales.SalesOrderDetail OD 
     ON P.ProductID = OD.ProductID
WHERE OD.ProductID IS NULL

GO

--Q2


CREATE VIEW NonOrderingCustomers AS
SELECT 
    C.CustomerID, 
    P.FirstName, 
    P.LastName,
    CASE
        WHEN P.FirstName IS NULL THEN 'UNKNOWN' 
        ELSE P.FirstName
    END AS FirstNameOrUnknown,
    CASE
        WHEN P.LastName IS NULL THEN 'UNKNOWN' 
        ELSE P.LastName
    END AS LastNameOrUnknown
FROM 
    Sales.Customer C 
LEFT JOIN 
    Sales.SalesOrderHeader OH ON C.CustomerID = OH.CustomerID
LEFT JOIN 
    Person.Person P ON C.PersonID = P.BusinessEntityID
WHERE 
    OH.CustomerID IS NULL;



GO
--Q3

CREATE VIEW MOST_PAYING_CUSTOMERS AS
SELECT TOP 10
C.CustomerID, P.FirstName, P.LastName,
COUNT(OH.CustomerID) AS NumOfOrders
FROM Sales.Customer C LEFT JOIN Sales.SalesOrderHeader OH
     ON C.CustomerID = OH.CustomerID
	 LEFT JOIN Person.Person P
	 ON C.PersonID = P.BusinessEntityID
WHERE OH.CustomerID IS NOT NULL
group by C.CustomerID,
         P.FirstName, 
		 P.LastName
GO

--Q4

CREATE VIEW HumanResources AS
SELECT PP.FirstName, PP.LastName,
       HE.JobTitle, HE.HireDate,
	   COUNT(JobTitle)OVER(PARTITION BY  HE.JobTitle) AS CountOfTitle
FROM HumanResources.Employee HE JOIN Person.Person PP
     ON HE.BusinessEntityID = PP.BusinessEntityID

GO

--Q5


CREATE VIEW LastOrders AS

WITH RankOrders AS
(
SELECT OH.SalesOrderID, C.CustomerID, 
       MAX(OH.OrderDate) AS 'LAST ORDER',
	   LAG(MAX(OH.OrderDate)) OVER (PARTITION BY C.CustomerID ORDER BY OH.OrderDate ASC) AS 'PREV ORDER',
       DENSE_RANK() OVER (PARTITION BY C.CustomerID ORDER BY MAX(OH.OrderDate) DESC) AS DR,
	   PP.FirstName, PP.LastName
FROM Sales.Customer C INNER JOIN Person.Person PP
     ON C.PersonID = PP.BusinessEntityID
	 INNER JOIN Sales.SalesOrderHeader OH
	 ON OH.CustomerID = C.CustomerID
GROUP BY
OH.SalesOrderID, OH.OrderDate,
PP.FirstName, PP.LastName,
C.CustomerID
)
SELECT 
SalesOrderID,
CustomerID,
FirstName,
LastName,
[LAST ORDER],
[PREV ORDER]
FROM RankOrders 
WHERE DR = 1

GO

--Q6

CREATE VIEW BiggestOrderOfTheYear AS
SELECT [YEAR], SorderID, [First name], [last name], Total
FROM
(
SELECT YEAR(SOH.OrderDate) AS [YEAR] , SOH.SalesOrderID AS SorderID, 
       PP.FirstName AS "First name" , PP.LastName AS "last name",
	   SUM(SOD.OrderQty * SOD.UnitPrice * (1-SOD.UnitPriceDiscount)) AS Total,
	   ROW_NUMBER() OVER (PARTITION BY YEAR(SOH.OrderDate) 
	   ORDER BY SUM(SOD.OrderQty * (SOD.UnitPrice - SOD.UnitPriceDiscount)) DESC) AS RowNum
FROM Sales.SalesOrderHeader SOH INNER JOIN Sales.SalesOrderDetail SOD
     ON SOH.SalesOrderID = SOD.SalesOrderID
	 INNER JOIN Sales.Customer C
	 ON C.CustomerID = SOH.CustomerID
	 INNER JOIN Person.Person PP
	 ON PP.BusinessEntityID = C.PersonID
GROUP BY YEAR(SOH.OrderDate),
         SOH.SalesOrderID, 
         PP.FirstName, PP.LastName
) AS SUB
WHERE RowNum = 1

GO

--Q7

CREATE VIEW OrdersByMonthOfTheYear AS
SELECT 
    OrderMonth AS 'Month',
    ISNULL([2011], 0) AS [2011],
    ISNULL([2012], 0) AS [2012],
    ISNULL([2013], 0) AS [2013],
	ISNULL([2014], 0) AS [2014]
FROM 
(
 SELECT 
       YEAR(OrderDate) AS OrderYear,
       MONTH(OrderDate) AS OrderMonth,
       COUNT(*) AS TotalOrders 
 FROM 
       Sales.SalesOrderHeader
 GROUP BY 
       YEAR(OrderDate), 
       MONTH(OrderDate)
  ) AS SourceTable
PIVOT
  (
    SUM(TotalOrders)
    FOR OrderYear IN ( [2011], [2012], [2013], [2014]) 
  ) AS PivotTable

GO

--Q8

CREATE VIEW TotalOrdersPriceByYear AS
WITH TBL
AS
(
SELECT
    YEAR(soh.OrderDate) AS [Year], 
    MONTH(soh.OrderDate) AS [Month],
    CAST(ROUND(SUM(sod.LineTotal),2) AS DECIMAL (10,2)) AS Sum_price,
    CAST(ROUND(SUM(SUM(sod.LineTotal)) OVER(PARTITION BY YEAR(soh.OrderDate) ORDER BY MONTH(soh.OrderDate)),2)AS DECIMAL (10,2)) AS Cum_SUM,
	0 AS 'A'
FROM
    Sales.SalesOrderHeader soh INNER JOIN Sales.SalesOrderDetail sod 
	ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY
YEAR(soh.OrderDate),MONTH(soh.OrderDate)
),
TBL2 AS
(
SELECT 
    [Year],
	[Month],
	Sum_price,
	Cum_SUM,
	A
FROM TBL
)
SELECT [YEAR], CAST([MONTH] AS VARCHAR) AS [MONTH],
       Sum_price, Cum_SUM,A
FROM TBL
----------
UNION ALL
----------
SELECT
YEAR(soh.OrderDate) AS [YEAR],
'GRAND TOTAL',
NULL,-- SUM PRICE NULL GRAND TOTAL ROW
SUM(sod.LineTotal) AS Sum_price,
1 AS 'A'
FROM
    Sales.SalesOrderHeader soh INNER JOIN Sales.SalesOrderDetail sod 
	ON soh.SalesOrderID = sod.SalesOrderID
group by YEAR(soh.OrderDate)

GO



--Q9
CREATE VIEW EmployeesSenoiority AS
SELECT HD.[Name] AS DepartmentName,
       HRE.BusinessEntityID AS EmployeeID,
	   PP.FirstName+' '+PP.LastName AS "Employee'sFullName",
	   HRE.HireDate, DATEDIFF(MONTH,HireDate,GETDATE()) AS Seniority,
	   ROW_NUMBER() OVER(PARTITION BY HD.[Name] 
	   ORDER BY HRE.HireDate DESC) AS DepartmentSeniority,
	  
	  LAG(PP.FirstName + ' ' + PP.LastName) OVER(PARTITION BY HD.[Name]
	   ORDER BY HRE.HireDate) AS PreviousEmployeeName,
      
	  LAG(HRE.HireDate) OVER(PARTITION BY HD.[Name] 
	   ORDER BY HRE.HireDate) AS PreviousHireDate,
      
	  DATEDIFF(DAY, LAG(HRE.HireDate) OVER(PARTITION BY HD.[Name] 
	   ORDER BY HRE.HireDate), HRE.HireDate) AS DaysDifference

FROM HumanResources.Employee HRE INNER JOIN Person.Person PP
     ON HRE.BusinessEntityID = PP.BusinessEntityID
	 INNER JOIN HumanResources.EmployeeDepartmentHistory EDH
	 ON EDH.BusinessEntityID = HRE.BusinessEntityID
	 INNER JOIN HumanResources.Department HD
	 ON HD.DepartmentID = EDH.DepartmentID

	GO

--Q10 	

CREATE VIEW MostPaying AS
SELECT 
C.CustomerID, P.FirstName, P.LastName,
COUNT(OH.CustomerID) AS NumOfOrders,
SUM(OH.SubTotal) AS SUM_TATAL
FROM Sales.Customer C LEFT JOIN Sales.SalesOrderHeader OH
     ON C.CustomerID = OH.CustomerID
	 LEFT JOIN Person.Person P
	 ON C.PersonID = P.BusinessEntityID
WHERE OH.CustomerID IS NOT NULL
group by C.CustomerID,
         P.FirstName, 
		 P.LastName

go

