USE Northwind;
-- Point a: Display information about the order OrderId = 10255
SELECT O.OrderID, O.OrderDate, C.CompanyName, C.ContactName
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID AND O.OrderID='10255';

-- Point b:	Modify the statement from point a by adding to it a list of items that are included in that order
SELECT O.OrderID, O.OrderDate, C.CompanyName, D.ProductID, D.UnitPrice,D.Quantity 
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID AND O.OrderID='10255'
INNER JOIN [Order Details] D ON O.OrderID = D.OrderID;

-- Point c: Modify the statement from point b in order to replace the Product Id with the product name, and add a column with a calculated value of each order line value
SELECT O.OrderID, O.OrderDate, C.CompanyName, P.ProductName, D.UnitPrice,D.Quantity, D.Quantity*D.UnitPrice AS [Order Detail Value']
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID AND O.OrderID='10255'
INNER JOIN [Order Details] D ON O.OrderID = D.OrderID
INNER JOIN Products P ON P.ProductID = D.ProductID;

--Point d: To the statement from the point c add a column with a calculated value of a whole order
-- Version 1: From performance point of view Window Functions are better than Nested querys
SELECT O.OrderID, O.OrderDate, C.CompanyName, P.ProductName, D.UnitPrice,D.Quantity, D.Quantity*D.UnitPrice AS [Order Detail Value], SUM(D.Quantity*D.UnitPrice) OVER()
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID AND O.OrderID='10255'
INNER JOIN [Order Details] D ON O.OrderID = D.OrderID
INNER JOIN Products P ON P.ProductID = D.ProductID

-- Version 2
SELECT O.OrderID, O.OrderDate, C.CompanyName, P.ProductName, D.UnitPrice,D.Quantity, D.Quantity*D.UnitPrice AS [Order Detail Value], (SELECT SUM(D.Quantity*D.UnitPrice) FROM [Order Details] D WHERE D.OrderID = '10255')
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID AND O.OrderID='10255'
INNER JOIN [Order Details] D ON O.OrderID = D.OrderID
INNER JOIN Products P ON P.ProductID = D.ProductID


--Point e: Display suppliers and number of unique orders that contain their products

-- An order having X(ex. 2) different products from the same supplier will be counted X time
-- Example: 10865 Order contains 2 products from Aux joyeux ecclésiastiques company. So the order will be counted 2 time
SELECT S.CompanyName, COUNT(*) AS [Number Of Unique Orders]
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
INNER JOIN [Order Details] D ON O.OrderID = D.OrderID
INNER JOIN Products P ON P.ProductID = D.ProductID
INNER JOIN Suppliers S ON P.SupplierID = S.SupplierID
GROUP BY S.CompanyName
ORDER BY S.CompanyName;


-- An order having X(ex. 2) different products from the same supplier will be counted only once
-- Example: 10865 Order contains 2 products from Aux joyeux ecclésiastiques company. So the order will be counted 1 time
SELECT E.CompanyName,COUNT(*) AS [Number Of Unique Orders]
FROM (
	SELECT S.CompanyName,O.OrderID
	FROM Orders O
	INNER JOIN Customers C ON O.CustomerID = C.CustomerID
	INNER JOIN [Order Details] D ON O.OrderID = D.OrderID
	INNER JOIN Products P ON P.ProductID = D.ProductID
	INNER JOIN Suppliers S ON P.SupplierID = S.SupplierID
	GROUP BY S.CompanyName,O.OrderID
	) AS E
GROUP BY E.CompanyName
ORDER BY E.CompanyName;

