/*
PROJECT 1 - CREAT DATA BASE
TOPIC: RESTAURANTS
NAME: ROE CASPI 
*/

USE master
GO

CREATE DATABASE Restaurants
GO
USE Restaurants
GO

CREATE TABLE Category
(
 CategoryID INT IDENTITY,
 Cat_name VARCHAR(25) NOT NULL,

 CONSTRAINT CAT_ID_PK PRIMARY KEY (CategoryID),  -- SET ID COLUMN AS PK
 CONSTRAINT CAT_NAME_UQ UNIQUE (Cat_name)
 )

 GO

 CREATE TABLE Chefs
 (
 ChefID INT IDENTITY,
 [NAME] VARCHAR(30) NOT NULL,
 Culinary_Institution VARCHAR(30),
 Gender VARCHAR(10),
 BirthDate DATE,
 Specialization INT, -- INT TO MAKE FK FROM CATEGORY TABLE

CONSTRAINT CHEF_ID_PK PRIMARY KEY (ChefID),  -- SET ID COLUMN AS PK
CONSTRAINT CHEF_NAME_UQ UNIQUE ([NAME]),
CONSTRAINT CHEF_SPZ_FK FOREIGN KEY (Specialization) REFERENCES Category(CategoryID) --SET THE Specialization BASE ON CATEGORY 
)

GO

CREATE TABLE Suppliers
(
SupplierID INT IDENTITY,
[Name] VARCHAR(30)NOT NULL,
[TYPE] VARCHAR(50) NOT NULL,

CONSTRAINT SUP_NAME_PK PRIMARY KEY ([Name])
)

GO

CREATE TABLE Restaurants
(
RestaurantID INT IDENTITY,
R_Name VARCHAR(30),
chef_id INT, -- BASED ON CHEFS TABLE AS FK
Delivery BIT NOT NULL, -- 1-YES 0-NO
Michelin INT NOT NULL DEFAULT 0, --ALWAYS BETWEEN 0-3
OpenDate DATE,
Cuisine INT, -- BASED ON CATEGORY ID
Contact_Det VARCHAR(50), --EMAIL

CONSTRAINT R_NAME_PK PRIMARY KEY (R_Name),
CONSTRAINT chef_id_FK FOREIGN KEY (chef_id) REFERENCES Chefs(ChefID),
CONSTRAINT Michelin_CK CHECK (Michelin BETWEEN 0 AND 3),
CONSTRAINT R_Cuisine_FK FOREIGN KEY (Cuisine) REFERENCES Category(CategoryID),
CONSTRAINT Contact_Det_UQ UNIQUE (Contact_Det),
CONSTRAINT Contact_Det_CK CHECK (Contact_Det LIKE '%@%')
)

GO

CREATE TABLE SUPPLY_ORDER  -- TO MAKE 'MANY TO MANY' RELATIONSHIP BETWEEN RESTAURANTS AND SUPPLIERS TABELS
(
OrderID INT IDENTITY,
Supplier_Name VARCHAR (30) NOT NULL,
Rname VARCHAR (30) NOT NULL,
OrderDate DATE NOT NULL,
SupplyDate DATE NOT NULL,
OrderAmount MONEY,

CONSTRAINT ORDER_ID_PK PRIMARY KEY (OrderID),
CONSTRAINT Supplier_Name_FK FOREIGN KEY (Supplier_Name) REFERENCES Suppliers([NAME]),
CONSTRAINT Restaurant_Name_FK FOREIGN KEY (Rname) REFERENCES Restaurants(R_Name),
CONSTRAINT Order_Amount_CK CHECK (OrderAmount > 1500) -- MIN PER ORDER
)

GO



INSERT INTO Category
VALUES 
('French'),
('Italian'),
('American'),
('Middle Eastern'),
('Persian'),
('Chinese'),
('Japanese'),
('Spanish')

GO

/* CHECKING TABLE
SELECT *
FROM Category
ORDER BY CATEGORYID
*/

GO

INSERT INTO Chefs
VALUES
('David Munoz', 'Catering College Madrid', 'Male', '1980-01-15', 8),
('Gordon Ramsay', 'North Oxon College', 'Male', '1966-11-08', 1),
('Assaf Granit', NULL, 'Male', '1978-08-20', 4),
('Shirel Berger', 'CIA NEW-YORK','Female', '1990-03-02', 4),
('Dominique Crenn', NULL, 'Female', '1965-04-07', 1),
('Yoshihiro Murata', 'Ritsumeikan University', 'Male', '1951-12-15', 7),
('Yisrael Aharoni', 'Taiwan', 'Male', '1950-07-13', 6),
('Massimo Bottura',  NULL, 'Male', '1962-09-30', 2),
('Tamar Cohen Tzedek', 'Castel San Fietro Bolonia', 'Female', '1973-09-07', 7),
('Bobby Flay', NULL, 'Male', '1964-12-10', 3),
('Ariana Bundy', 'La Cordon Blue', 'Female', '1974-05-14', 5)

GO

/* CHECKING TABLE
SELECT *
FROM CHEFS
*/

GO

-- CORECCTION OF SPECIALIZATION FOR CHEF ID 9 FROM CATEGORY 7 >>> 2
UPDATE Chefs
SET Specialization=2
WHERE ChefID=9

GO

INSERT INTO Suppliers
VALUES
('LA PETIT', 'Vegetables'),
('Ginat Yarak', 'fruits & Vegetables'),
('Meat Market', 'Meat'),
('Havat Tzuk', 'meat'),
('Jino', 'Fish'),
('YAMA', 'Fish'),
('Germy', 'Kitchen Equipment'),
('Shisho','Flour & Spices')

GO

/* CHECKING TABLE
SELECT *
FROM SUPPLIERS
ORDER BY SUPPLIERID
*/

GO

-- ADDING CITY COLUMN TO TABLE BEFPRE INSERT VALUES
ALTER TABLE Restaurants
ADD CITY VARCHAR(20)


GO

INSERT INTO Restaurants
VALUES
('DiverXO', 1, 0, 3, '2021-01-07', 8, 'DIxo@gmail.com', 'Madrid'),
('StreetXO', 1, 0, DEFAULT, '2012-03-17', 8, 'STxo@gmail.com', 'Madrid'),
('Le Pressoir dArgent', 2, 0, 2, '2015-07-18', 1, 'LPDA@gmail.COM', 'Bordeaux'),
('Mahne Yhuda', 3, 1, DEFAULT, '2009-07-11', 4, 'MAHNEgroup1@gmail.com', 'Jerusalem'),
('GG Kubala', 3, 1, DEFAULT, '2019-03-26', 4, 'MAHNEgroup2@gmail.com', 'Tel Aviv'),
('OPA', 4, 0, DEFAULT, '2022-04-19', 4, 'contactOPA@gmail.com', 'Tel Aviv'),
('Atelier Crenn', 5, 0, 3, '2013-08-02', 1, 'ARTCRENN@gmail.com', 'San Francisco'),
('Kikunoi Honten', 6, 0, 3, '2012-11-27', 7, 'Khonten@gmail.com', 'Kyoto'),
('SILLY KID', 7, 1, DEFAULT, '2023-09-20', 3, 'SK@gmail.com', 'Tel Aviv'),
('yin yeng', 7, 0, DEFAULT, '1987-12-04', 6, NULL, 'Tel Aviv'),
('Osteria Francescana', 8, 0, 3, '1995-06-10',2,'OsFran@gmail.com', 'Modena'),
('Cucina Hess', 9, 1, DEFAULT, '2009-11-08', 2, 'Chess@gmail.com', 'Tel Aviv'),
('Mesa Grill', 10, 0, 1, '2004-02-22', 3, 'MessaGrill@gmail.com', 'Las Vegas'),
('Bobby Flay steak', 10, 1, DEFAULT, '2018-04-08', 3, 'BFsteak@gmail.com', 'New York'),
('Arianas Persian Kitchen', 11, 0, DEFAULT, '2016-07-16', 5, 'APK@gmail.com', 'Dubai'),
('BARAFINA', 1, 0, 1, '2012-05-16', 8, 'BARFINA@gmail.com', 'London'),
('SHABUR', 3, 0, 1, '2018-09-06', 1, 'SHABURrest@gmail.com', 'Paris'),
('MISS Kaplan', 4, 1, DEFAULT, '2014-01-28', 4, 'MKpopup@gmail.com', 'Tel Aviv'),
('Five Guys', NULL, 1, DEFAULT, '2007-05-20', 3, '5GUYS@mail.com', 'world wide'),
('DEKEL', 3, 0, DEFAULT, '2020-08-22', 4, 'MAHNEgroup3@gmail.com', 'Jerusalem'),
('SAVOY', 2, 0, 2, '2010-11-09', 1, 'HotelSavoy@gmail.com', 'London')

GO

/* CHECKING TABLE
SELECT *
FROM RESTAURANTS
ORDER BY RestaurantID
*/




/* CHECKING TABLE
SELECT *
FROM RESTAURANTS
ORDER BY RestaurantID
*/


GO

-- INSERT AN EXTRA VALUE TO SUPPLIERS TABLE
INSERT INTO Suppliers
VALUES ('ADINA','Beverages')


GO


INSERT INTO SUPPLY_ORDER
VALUES
('Meat Market', 'StreetXO', '2024-02-05', '2024-02-07', 2500),
('Ginat Yarak', 'OPA', '2024-01-10', '2024-01-12', 3000),
('YAMA', 'Kikunoi Honten', '2024-01-15', '2024-01-17', 3000),
('LA PETIT', 'Mahne Yhuda', '2024-05-08', '2024-05-10', 1850),
('Havat Tzuk', 'DiverXO', '2024-03-21', '2024-03-24', 5825),
('Jino', 'BARAFINA', '2024-10-24', '2024-10-27', 4932),
('Germy', 'Bobby Flay steak', '2024-11-01', '2024-11-05', 11502),
('Shisho', 'Cucina Hess', '2024-06-07', '2024-06-13', 8610),
('ADINA', 'Le Pressoir dArgent', '2024-04-10', '2024-04-11', 2870),
('Shisho', 'Arianas Persian Kitchen', '2024-10-11', '2024-10-14', 4360),
('Meat Market', 'Five Guys', '2024-08-21', '2024-08-28', 9720),
('LA PETIT', 'DEKEL', '2024-07-21', '2024-07-23', 3450),
('ADINA', 'SHABUR', '2024-09-27', '2024-10-01', 5098),
('Havat Tzuk', 'Osteria Francescana', '2024-03-10', '2024-03-15', 11890),
('Shisho', 'SAVOY', '2024-12-01', '2024-12-08', 2980),
('Jino', 'yin yeng', '2024-06-11', '2024-06-12', 9320),
('Meat Market', 'SILLY KID', '2024-03-17', '2024-03-19', 14980),
('Ginat Yarak', 'MISS Kaplan', '2024-02-01', '2024-02-04', 2700),
('Havat Tzuk', 'Mesa Grill', '2024-09-13', '2024-09-16', 13970),
('YAMA', 'Atelier Crenn', '2024-08-11', '2024-08-12', 10750),
('ADINA', 'GG Kubala', '2024-03-05', '2024-03-08', 3590),
('Meat Market', 'GG Kubala', '2024-04-01', '2024-04-05', 3320),
('Shisho', 'yin yeng', '2024-10-10', '2024-10-14', 9760),
('Germy', 'Osteria Francescana', '2024-12-20', '2024-12-23', 5690),
('Ginat Yarak', 'Kikunoi Honten', '2024-09-09', '2024-09-11', 7598),
('Havat Tzuk', 'Bobby Flay steak', '2024-02-07', '2024-02-10', 2450),
('YAMA', 'Arianas Persian Kitchen', '2024-03-11', '2024-03-12', 9763),
('ADINA', 'SHABUR', '2024-09-19', '2024-09-21', 18342),
('Jino', 'DiverXO', '2024-05-08', '2024-05-11', 12876),
('LA PETIT', 'Le Pressoir dArgent', '2024-07-14', '2024-07-17', 8230),
('Shisho', 'OPA', '2024-08-02', '2024-08-04', 2590),
('Meat Market', 'Atelier Crenn', '2024-12-14', '2024-12-15', 3580),
('ADINA', 'SAVOY', '2024-11-08', '2024-11-10', 5840),
('Jino', 'Cucina Hess', '2024-04-09', '2024-04-12', 8430),
('Germy', 'SHABUR', '2024-01-12', '2024-01-13', 14760)

GO


/* CHECKING TABLE
SELECT *
FROM SUPPLY_ORDER
ORDER BY OrderID
*/
