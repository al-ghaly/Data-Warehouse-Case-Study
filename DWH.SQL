create database SalesDM;
use SalesDM;

-- Create and populate the Dimension Tables
SELECT 
    C.CustomerID as CustomerID, 
    T.Name as Region,
    T.CountryRegionCode as Country
    INTO DimCustomer
FROM [AdventureWorks2019].[Sales].[Customer] C
JOIN [AdventureWorks2019].[Sales].[SalesTerritory] T ON C.TerritoryID = T.TerritoryID;

ALTER TABLE DimCustomer
ADD CONSTRAINT PK_1 PRIMARY KEY (CustomerID);
----------------------------------------------------
SELECT 
    StoreID = IDENTITY(INT, 1, 1),
    S.name as name
INTO DimStore
FROM [AdventureWorks2019].[Sales].[store] S;

ALTER TABLE DimStore
ADD CONSTRAINT PK_2 PRIMARY KEY (StoreID);
-----------------------------------------------------
SELECT 
    *
INTO DimProduct
FROM [AdventureWorks2019].[Production].[Product];

ALTER TABLE DimProduct
ADD CONSTRAINT PK_3 PRIMARY KEY (ProductID);
----------------------------------------------------
SELECT 
    EmployeeID = IDENTITY(INT, 1, 1),
    E.*
INTO DimSalesPerson
FROM [AdventureWorks2019].[HumanResources].[Employee] E;

ALTER TABLE DimSalesPerson
ADD CONSTRAINT PK_4 PRIMARY KEY (EmployeeID);
-----------------------------------------------------
CREATE TABLE DimDate
(
  DateID INT NOT NULL,
  minute INT NOT NULL,
  hour INT NOT NULL,
  week INT NOT NULL,
  month INT NOT NULL,
  quarter INT NOT NULL,
  year INT NOT NULL,
  Day INT NOT NULL,
  PRIMARY KEY (DateID)
);
-------------------------------------------------------
SELECT 
    *
INTO DimSalesReason
FROM [AdventureWorks2019].[Sales].[SalesReason];

EXEC sp_rename 'dimsalesreason.SalesReasonID', 'ReasonKey', 'COLUMN';

ALTER TABLE DimSalesReason
ADD CONSTRAINT PK_5 PRIMARY KEY (ReasonKey);
--------------------------------------------------------
SELECT 
    *
INTO DimSpecialOffer
FROM [AdventureWorks2019].[Sales].SpecialOffer;

EXEC sp_rename 'DimSpecialOffer.SpecialOfferID', 'OfferID', 'COLUMN';

ALTER TABLE DimSpecialOffer
ADD CONSTRAINT PK_6 PRIMARY KEY (OfferID);
--------------------------------------------------------
CREATE TABLE DimPromotion
(
  PromotionKey INT NOT NULL,
  PRIMARY KEY (PromotionKey)
);
---------------------------------------------------------
SELECT 
    *
INTO DimSalesTerritory
FROM [AdventureWorks2019].[Sales].SalesTerritory;

EXEC sp_rename 'DimSalesTerritory.TerritoryID', 'SalesTerrKey', 'COLUMN';

ALTER TABLE DimSalesTerritory
ADD CONSTRAINT PK_7 PRIMARY KEY (SalesTerrKey);
---------------------------------------------------------
SELECT 
    *
INTO DimLocation
FROM [AdventureWorks2019].Person.Address;

EXEC sp_rename 'DimLocation.AddressID', 'LocationID', 'COLUMN';

ALTER TABLE DimLocation
ADD CONSTRAINT PK_8 PRIMARY KEY (LocationID);
---------------------------------------------------------
SELECT 
    c.CurrencyCode CurCode, C.name Currency,
    s.name as shipmentMethod, s.ShipBase, s.ShipRate,
    'Credit' as PamentMethod
    into DimShip_Pay_CurMethod
    from [AdventureWorks2019].[Sales].[Currency] c,
    [AdventureWorks2019].[Purchasing].[ShipMethod] s;

INSERT INTO DimShip_Pay_CurMethod (CurCode, Currency, shipmentMethod, ShipBase, ShipRate, PamentMethod)
SELECT 
    c.CurrencyCode CurCode, C.name Currency,
    s.name as shipmentMethod, s.ShipBase as ShipBase, s.ShipRate as ShipRate,
    'Credit' as PamentMethod
    from [AdventureWorks2019].[Sales].[Currency] c,
    [AdventureWorks2019].[Purchasing].[ShipMethod] s;

ALTER TABLE DimShip_Pay_CurMethod
ADD OrderDetailID INT IDENTITY(1,1) PRIMARY KEY;
------------------------------------------------------------
-- Creating the fact table--
CREATE TABLE FactSales
(
    SalesKey            INT,
    SalesAmount         FLOAT,
    Items               INT,
    Price               FLOAT,
    Cost                FLOAT,
    Discount            FLOAT,
    Profit              FLOAT,
    TotalProfit         FLOAT,
    TaxAmount           FLOAT,
    Fright              FLOAT,
    TotalTax            FLOAT,
    DiscountAmount      FLOAT,
    DimOrderStatus      INT,
    ShipmentNumber      VARCHAR (200),
    CustomerID          INT,
    ProductID           INT,
    OrderDateKey        INT,
    EmployeeID          INT,
    ShipToAddressKey    INT,
    OrderDetailID       INT,
    PromotionKey        INT,
    OfferID             INT,
    ReasonKey           INT,
    ShipDateKey         INT,
    DueDateKey          INT,
    BillToAddessKey     INT,
    StoreKey            INT,
    SalesTerrKey        INT,
    PRIMARY KEY (SalesKey),
    FOREIGN KEY (CustomerID) REFERENCES DimCustomer (CustomerID),
    FOREIGN KEY (ProductID) REFERENCES DimProduct (ProductID),
    FOREIGN KEY (OrderDateKey) REFERENCES DimDate (DateID),
    FOREIGN KEY (EmployeeID) REFERENCES DimSalesPerson (EmployeeID),
    FOREIGN KEY (ShipToAddressKey) REFERENCES DimLocation (LocationID),
    FOREIGN KEY
        (OrderDetailID)
        REFERENCES DimShip_Pay_CurMethod (OrderDetailID),
    FOREIGN KEY (PromotionKey) REFERENCES DimPromotion (PromotionKey),
    FOREIGN KEY (OfferID) REFERENCES DimSpecialOffer (OfferID),
    FOREIGN KEY (ReasonKey) REFERENCES DimSalesReason (ReasonKey),
    FOREIGN KEY (ShipDateKey) REFERENCES DimDate (DateID),
    FOREIGN KEY (DueDateKey) REFERENCES DimDate (DateID),
    FOREIGN KEY (BillToAddessKey) REFERENCES DimLocation (LocationID),
    FOREIGN KEY (StoreKey) REFERENCES DimStore (StoreID),
    FOREIGN KEY (SalesTerrKey) REFERENCES DimSalesTerritory (SalesTerrKey)
);
--------------------------------------------------------------------------
--POPULATE THE DWH --
INSERT INTO  FactSales(SalesKey, CustomerID, BillToAddessKey, EmployeeID, SalesTerrKey, ShipToAddressKey,
DimOrderStatus, ShipmentNumber, TotalTax, fright, SalesAmount, Items, Price, Discount, DiscountAmount, 
OfferID, ProductID, ReasonKey, Cost, Profit, TotalProfit)
SELECT 
DWH.SalesOrderID as SalesKey,
DWH.CustomerID as CustomerID, DWH.BillToAddressID as BillToAddressKey,
DWH.SalesPersonID as EmployeeID, DWH.TerritoryID as SalesTerrKey, 
DWH.ShipToAddressID as ShipToAddressKey, DWH.Status as DimOrderStatus,
DWH.SalesOrderNumber as ShipmentNumber, 
DWH.TaxAmt as TotalTax, DWH.Freight as fright, 
DWH.TotalDue as SalesAmount,
OD.OrderQty as Items, OD.UnitPrice as Price, OD.UnitPriceDiscount as Discount, 
OD.UnitPriceDiscount * OD.UnitPrice * OD.OrderQty as DiscountAmount,
od.SpecialOfferID as OfferID, od.ProductID as ProductID,
SR.SalesReasonID as ReasonKey,
SP.StandardCost as Cost, 
OD.UnitPrice - SP.StandardCost as Profit,
(OD.UnitPrice - SP.StandardCost) * OD.OrderQty - (OD.UnitPriceDiscount * OD.UnitPrice * OD.OrderQty)  as TotalProfit
from [AdventureWorks2019].[Sales].[SalesOrderHeader] DWH 
inner join [AdventureWorks2019].[Sales].SalesOrderDetail OD on od.SalesOrderID = dwh.SalesOrderID
left join
[AdventureWorks2019].[Sales].[SalesOrderHeaderSalesReason] SR on DWH.SalesOrderID = SR.SalesOrderID
left join [AdventureWorks2019].[Production].[Product] SP on SP.ProductID = OD.ProductID ;
---------------------------------------------------------------------------------------------------------------