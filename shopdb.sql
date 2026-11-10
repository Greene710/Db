-- ShopDB: создание базы данных, таблиц и решение практических задач
-- СУБД: MySQL 8.0+

CREATE DATABASE IF NOT EXISTS ShopDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE ShopDB;

-- 1. Клиенты
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL
);

-- 2. Категории товаров
CREATE TABLE IF NOT EXISTS Categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL
);

-- 3. Товары
CREATE TABLE IF NOT EXISTS Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT,
    Price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_products_category
      FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT chk_products_price CHECK (Price >= 0)
);

-- 4. Заказы
CREATE TABLE IF NOT EXISTS Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_orders_customer
      FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT chk_orders_total CHECK (TotalAmount >= 0)
);

-- 5. Состав заказов
CREATE TABLE IF NOT EXISTS OrderDetails (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT fk_orderdetails_order
      FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT fk_orderdetails_product
      FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT chk_orderdetails_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_orderdetails_price CHECK (Price >= 0)
);

-- Задача 1. ТОП-5 клиентов по сумме покупок за последние 30 дней
-- включая текущую дату
SELECT
    c.CustomerID,
    c.FullName,
    SUM(o.TotalAmount) AS TotalPurchases
FROM Customers AS c
INNER JOIN Orders AS o
    ON o.CustomerID = c.CustomerID
WHERE o.OrderDate >= CURRENT_DATE - INTERVAL 30 DAY
  AND o.OrderDate <= CURRENT_DATE
GROUP BY c.CustomerID, c.FullName
ORDER BY TotalPurchases DESC
LIMIT 5;

-- Задача 2. Количество клиентов и средний чек по городам.
-- В выборку попадают города со средним чеком строго больше 5000.
SELECT
    c.City,
    COUNT(DISTINCT c.CustomerID) AS CustomerCount,
    AVG(o.TotalAmount) AS AverageCheck
FROM Customers AS c
INNER JOIN Orders AS o
    ON o.CustomerID = c.CustomerID
GROUP BY c.City
HAVING AVG(o.TotalAmount) > 5000
ORDER BY c.City DESC;

-- Задача 3. Проданные единицы и выручка по категориям.
-- Цена берётся из Products.Price, как требует задание.
SELECT
    cat.CategoryName,
    SUM(od.Quantity) AS TotalQuantity,
    SUM(od.Quantity * p.Price) AS TotalRevenue
FROM Categories AS cat
INNER JOIN Products AS p
    ON p.CategoryID = cat.CategoryID
INNER JOIN OrderDetails AS od
    ON od.ProductID = p.ProductID
GROUP BY cat.CategoryID, cat.CategoryName
ORDER BY TotalRevenue DESC;

-- Задача 4а. Клиенты без заказов: вариант с NOT IN
SELECT
    c.CustomerID,
    c.FullName,
    c.City
FROM Customers AS c
WHERE c.CustomerID NOT IN (
    SELECT o.CustomerID
    FROM Orders AS o
);

-- Задача 4б. Клиенты без заказов: вариант с LEFT JOIN
SELECT
    c.CustomerID,
    c.FullName,
    c.City
FROM Customers AS c
LEFT JOIN Orders AS o
    ON o.CustomerID = c.CustomerID
WHERE o.OrderID IS NULL;
