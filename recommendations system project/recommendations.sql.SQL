CREATE TABLE Customers (
	CustomerID int Primary Key,
	Name varchar (100),
	Email varchar (100),
	SignupDate DATE,
);

CREATE TABLE Products (
	ProductID int primary key,
	ProductName varchar (250),
	Catagory varchar (100),
	Price decimal (10,2),
);

CREATE TABLE Orders (
	OrderID int primary key,
	CustomerID int,
	OrderDate DATE,
	OrderAmount decimal (10,2),
	foreign key (CustomerID) references Customers(CustomerID)
);
EXEC sp_rename 'Orders.OrderAmount', 'TotalAmount', 'COLUMN';


CREATE TABLE OrderDetails (
	OrderDetailID int primary key,
	OrderID int,
	ProductID int,
	QuantityID int,
	foreign key (OrderID) references Orders(OrderID),
	foreign key (ProductID) references Products(ProductID),
);
EXEC sp_rename 'OrderDetails.QuantityID', 'Quantity', 'COLUMN';

CREATE TABLE Ratings (
	RatingID int primary key,
	CustomerID int,
	ProductID int, 
	Rating int check (Rating between 1 and 5),
	ReviewText varchar (500),
	foreign key (CustomerID) references Customers(CustomerID),
	foreign key (ProductID) references Products(ProductID),
);

CREATE TABLE Recommendations (
    RecommendationID INT IDENTITY(1,1) PRIMARY KEY, 
    CustomerID INT,
    ProductID INT,
    RecommendationReason NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE()
);


insert into Customers (CustomerID, Name, Email, SignupDate)
values 
(1, 'David Cohen', 'david1@gmail.com', '2024-06-20'),
(2, 'Sarah Levi', 'sarah2@gmail.com', '2024-11-02'),
(3, 'Tom Aviv', 'tom3@gmail.com', '2023-08-24'),
(4, 'Avi Doe', 'avi4@gmail.com', '2025-01-02');

INSERT INTO Products (ProductID, ProductName, Catagory, Price)
VALUES 
(1, 'Laptop Dell XPS', 'Electronics', 4500.00),
(2, 'Apple iPhone 13', 'Electronics', 3500.00),
(3, 'AirPods Pro', 'Accessories', 799.00);
INSERT INTO Products (ProductID, ProductName, Catagory, Price)
VALUES (5, 'Some Product', 'Electronics', 100.00);



INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES 
(9, 3, '2024-02-20', 5300.00), -- הזמנה חדשה ללקוח 3
(5, 4, '2024-02-22', 3800.00), -- הזמנה חדשה ללקוח 4
(6, 1, '2024-02-18', 2999.99), -- הזמנה נוספת ללקוח 1
(7, 2, '2024-02-18', 1500.00); -- הזמנה נוספת ללקוח 2
INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES 
(10, 1, '2024-02-25', 2500.00), -- הזמנה נוספת ללקוח 1
(11, 2, '2024-02-26', 1800.00); -- הזמנה נוספת ללקוח 2
INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES (13, 3, '2024-02-18', 2500.00);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES 
(12,4, '2023-05-12', 2000.00),
(14,1, '2023-12-12', 2300.00),
(15,3, '2023-10-03', 1500.00),
(16,4, '2023-07-22', 2100.00),
(17,2, '2023-08-10', 2000.00);



INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity)
VALUES 
(10, 4, 1, 1), -- לקוח 3 קנה MacBook Pro
(11, 4, 3, 1), -- לקוח 3 קנה גם AirPods Pro
(12, 5, 2, 1), -- לקוח 4 קנה iPhone 13
(13, 5, 3, 1); -- לקוח 4 קנה גם AirPods Pro



INSERT INTO Ratings (RatingID, CustomerID, ProductID, Rating, ReviewText)
VALUES 
(1, 1, 1, 5, 'Amazing laptop!'),
(2, 2, 2, 4, 'Good phone but expensive.');

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;
SELECT * FROM Ratings;


-- הצגת מוצרים פופולריים לפי כמות הזמנות
SELECT P.ProductName, COUNT(O.OrderID) AS TotalOrders
FROM OrderDetails OD
JOIN Products P ON OD.ProductID = P.ProductID
JOIN Orders O ON OD.OrderID = O.OrderID
GROUP BY P.ProductName
ORDER BY TotalOrders DESC;

--המוצרים הכי נמכרים במערכת
SELECT P.ProductName, COUNT(OD.ProductID) AS TotalSold
FROM OrderDetails OD
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY TotalSold DESC;

--המוצרים עם הדירוג הגבוה ביותר 
SELECT P.ProductName, AVG(R.Rating) AS AvgRating, COUNT(R.RatingID) AS TotalRatings
FROM Ratings R
JOIN Products P ON R.ProductID = P.ProductID
GROUP BY P.ProductName
HAVING COUNT(R.RatingID) >= 1 -- מציג רק מוצרים עם יותר מדירוג אחד
ORDER BY AvgRating DESC, TotalRatings DESC;

--אילו מוצרים רכש כל לקוח 
SELECT C.Name, P.ProductName, O.OrderDate
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN OrderDetails OD ON O.OrderID = OD.OrderID
JOIN Products P ON OD.ProductID = P.ProductID
ORDER BY C.Name, O.OrderDate DESC;

--מוצרים שלקוחות קנו ביחד 
SELECT P1.ProductName AS Product_A, P2.ProductName AS Product_B, COUNT(*) AS PairCount
FROM OrderDetails OD1
JOIN OrderDetails OD2 ON OD1.OrderID = OD2.OrderID AND OD1.ProductID <> OD2.ProductID
JOIN Products P1 ON OD1.ProductID = P1.ProductID
JOIN Products P2 ON OD2.ProductID = P2.ProductID
GROUP BY P1.ProductName, P2.ProductName
ORDER BY PairCount DESC;

--לקוחות שחוזרים לקנות
SELECT C.Name, COUNT(O.OrderID) AS TotalOrders
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
GROUP BY C.Name
HAVING COUNT(O.OrderID) > 1
ORDER BY TotalOrders DESC;

--זיהוי לקוחות שאולי עומדים לנטוש 
SELECT C.Name, MAX(O.OrderDate) AS LastOrderDate
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
GROUP BY C.Name
HAVING MAX(O.OrderDate) < DATEADD(MONTH, -6, GETDATE()) -- לא הזמינו ב-6 חודשים אחרונים
ORDER BY LastOrderDate ASC;

--המלצת מוצרים ללקוחות לפי רכישות דומות 
SELECT DISTINCT C1.Name AS Customer_A, C2.Name AS Customer_B, COUNT(OD1.ProductID) AS CommonPurchases
FROM Orders O1
JOIN Customers C1 ON O1.CustomerID = C1.CustomerID
JOIN OrderDetails OD1 ON O1.OrderID = OD1.OrderID
JOIN Orders O2 ON OD1.ProductID = OD1.ProductID AND O1.CustomerID <> O2.CustomerID
JOIN Customers C2 ON O2.CustomerID = C2.CustomerID
GROUP BY C1.Name, C2.Name
ORDER BY CommonPurchases DESC;

--הוספת המלצה אוטומטית על מוצר ברגע שלקוח מבצע רכישה
CREATE TRIGGER RecommendProduct
ON OrderDetails
AFTER INSERT
AS
BEGIN
    INSERT INTO Recommendations (CustomerID, ProductID, RecommendationReason)
    SELECT I.OrderID, P.ProductID, 'Similar product purchased by others'
    FROM inserted I
    JOIN Products P ON P.Catagory = (SELECT Catagory FROM Products WHERE ProductID = I.ProductID)
    WHERE P.ProductID <> I.ProductID;
END;

DROP TRIGGER IF EXISTS RecommendProduct;

CREATE TRIGGER RecommendProduct
ON OrderDetails
AFTER INSERT
AS
BEGIN
    INSERT INTO Recommendations (CustomerID, ProductID, RecommendationReason)
    SELECT I.OrderID, P.ProductID, 'Similar product purchased by others'
    FROM inserted I
    JOIN Products P ON P.Catagory = (SELECT Catagory FROM Products WHERE ProductID = I.ProductID)
    WHERE P.ProductID <> I.ProductID;
END;

SELECT * FROM Recommendations;

INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity)
VALUES 
(16, 10, 3, 1); -- הוספת מוצר חדש כדי להפעיל את ה-TRIGGER

INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity)
VALUES 
(17, 11, 2, 1); -- הוספת מוצר נוסף להזמנה חדשה

INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity)
VALUES 
(19, 13, 5, 1); -- הוספת מוצר חדש להזמנה חדשה

SELECT name, type_desc, parent_id 
FROM sys.triggers 
WHERE name = 'RecommendProduct';

ALTER TRIGGER RecommendProduct
ON OrderDetails
AFTER INSERT
AS
BEGIN
    PRINT ' Trigger Activated!';
    
    INSERT INTO Recommendations (CustomerID, ProductID, RecommendationReason)
    SELECT I.OrderID, P.ProductID, 'Similar product purchased by others'
    FROM inserted I
    JOIN Products P ON P.Catagory = (SELECT Catagory FROM Products WHERE ProductID = I.ProductID)
    WHERE P.ProductID <> I.ProductID;
END;

SELECT OBJECT_DEFINITION (OBJECT_ID('RecommendProduct')) AS TriggerDefinition;

--יצירת אינדקסים לשיפור ביצוע השאילתות
CREATE INDEX idx_Orders_CustomerID ON Orders (CustomerID);
CREATE INDEX idx_OrderDetails_ProductID ON OrderDetails (ProductID);
CREATE INDEX idx_Products_Category ON Products (Catagory);

--יצירת Stored Procedure להחזרת המלצות מותאמות אישית
CREATE PROCEDURE GetRecommendations 
    @CustomerID INT
AS
BEGIN
    SELECT DISTINCT P.ProductID, P.ProductName, 'Recommended for you' AS Reason
    FROM Orders O
    JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    JOIN Products P ON P.Catagory = (
        SELECT TOP 1 Catagory FROM Products WHERE ProductID = OD.ProductID
    )
    WHERE O.CustomerID = @CustomerID;
END;

EXEC GetRecommendations @CustomerID = 1;

--יצירת view לתצוגת נתונים מהירה יותר 
CREATE VIEW MostPopularProducts AS
SELECT P.ProductID, P.ProductName, COUNT(OD.OrderID) AS TotalOrders
FROM OrderDetails OD
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName;

SELECT * FROM MostPopularProducts;

SELECT name, database_id, owner_sid FROM sys.databases WHERE name = 'Recommendations';
SELECT name FROM sys.databases;

select * from Recommendations;











