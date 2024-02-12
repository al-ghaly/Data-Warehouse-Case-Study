# Data-Warehouse-Case-Study - AdventureWorks Data Warehouse Project
## Overview
A complete case study showcasing data mart modeling, warehouse design, integration, and insights gained for comprehensive analytics.<br>
This project focuses on analyzing the sales business process of a company with the aim of enhancing overall business performance. By leveraging a comprehensive data warehouse approach, we delve into various steps to uncover insights and support strategic decision-making.

# DWH MODELING

## **Sales Analysis**

**Sales Business Process:**

- Our objective is to analyze the company sales and find out ways to improve the business by increasing sales and improving net profit.

## **STEPS**

1. Defining Business Processes
2. Defining Business KPIs (Data Warehouse Objectives)
3. Defining Granularity for the Analysis Scope
4. Defining Dimensions, Facts, and measurements
5. Data Warehouse Modeling (Defining the Schema)
6. Defining the Physical Model
7. Data Integration
8. Data Warehouse Indexing and Partitioning
9. Extracting insights to support the Management Decisions

## **STEP1**

**Defining Business Process**

We will only focus on the Sales Business Process to support the Finance team.

**SALES**

>The sales business process involves the end-to-end journey of converting customer interest into revenue. In our data warehouse modeling, we'll capture and optimize this process by modeling key entities such as customers, products, orders, and inventory. Through detailed schema design and relationships, we aim to represent customer interactions, order creation, and fulfillment seamlessly. Our focus is on ensuring accurate inventory management, precise pricing calculations, and comprehensive reporting for insights into sales performance. By modeling the sales business process, we strive to enhance efficiency, provide valuable analytics, and support informed decision-making within the retail company.

## **STEP2**

**Defining Business KPIs**

In this step, we want to extract the KPIs that will help the finance team to improve the business.
  1. Top customers (Customer segmentation)
  2. Top Sales reason
  3. Effect of special offers on sale
  4. Best-selling product category
  5. Best-selling store/city/state
  6. What payment method is more profitable
  7. The effect of customer demographics on sales
  8. Effect of special offers on revenue
  9. Salesperson performance
  10. The most effective shipment method
  11. The effect of changing the price on sales
  12. Most profitable product/category


## **STEP3**

**Defining Granularity**

In this step, we want to define the level of detail that we will use to calculate KPIs for each business process.

**SALES Fact Table**

  - The most detailed grain is the combination of individual Customer, Product, Order Date, Shipping Date, Salesperson, Shipping Address, Billing Address, Promotion Code, Offer applied, Sales Reason, Order Due Date, Store, Currency, Payment Method, Shipment Method, Sales Territory, Shipment, and Order Status.
  - In a single word we will accumulate from each item a customer orders.
  - A Customer Orders a 25-item order of 6 different products at a specific moment will be represented in 6 rows in the sales Fact Table.

The next step is typically estimating the fact table size as follows:

- We have c Customers, p Products, s Shipment methods, m Payment Method, …
- So, we will have at most n \* m \* p \* s \* m \* …. Rows, by estimating each record's size we can estimate the maximum data warehouse size.
- We still need a deep overview of the business to estimate an accurate value for the Sparsity (The ratio of non-existing rows) to calculate the estimated DWH size to complete the design.
- By estimating the size of each fact table, we could estimate the size of the DWH besides designing the optimal table partitioning model.

## **STEP4**

**Defining Dimensions, Facts, and Measurements**

In this step, we want to define each fact table, which dimensions will be connected to it, and the measurements that will help the analysis.

## Sales Fact
  1. What?
     - This is a fact table to keep track of each sales transaction, we will use it to help the finance team improve their operations.
  2. Measurements:
     - Number of Items **(additive)**.
     - Item's Price **(additive)**.
     - Sales Amount **(additive)**.
     - Item's Cost ( **semi-additive** as it is pointless to sum it up over some dimensions).
     - Discount ( **non-additive** as it is pointless, to sum it up over any dimension).
     - Profit **(additive)**.
     - Total Profit **(additive)**.
     - Tax Amount **(non-additive)**.
     - Total Tax **(semi-additive)**.
     - Fright ( **semi-additive** as it is pointless to sum it up over some dimensions like the Employee -salesperson-).
     - Total Discount **(semi-additive)**.

**Dimensions:**

1. CUSTOMER

    - Conformed Dimension
    - A typical dimension holding data about each Customer.
2. PRODUCT

    - Hierarchical Dimension
    - A typical dimension holding data about each Product.
3. DATE

    - Role-Playing Dimension
    - The typical data warehouse DATE DIMENSION, which ensures that the DWH is time-variant.
4. EMPLOYEE

    - Conformed Dimension
    - A typical dimension holding data about each Employee.
5. LOCATION

    - Role-Playing Dimension
    - This dimension will be used to represent location details and will be used to represent both billing and shipping locations.
6. ORDER DETAIL

    - Junk Dimension
    - A Junk Dimension holding data about three pieces of information:
      a. Shipment Method, Payment Method, and Currency.
7. PROMOTION

    - Conformed Dimension
    - A typical Dimension holding data about the promotions offered by the marketing team.
8. STORE

    - Conformed Dimension
    - A typical dimension holding data about each Store.
9. SPECIAL OFFERS

    - Conformed Dimension
    - A typical Dimension holding data about the Special Offers offered by the marketing team.
10. SALES REASONS

    - Conformed Dimension
    - A typical Dimension holding data about the Sales Reason which involves categorical data (10 possible sales reasons)
11. ORDER STATUS

    - Degenerated Dimension
    - Fact table Attribute that holds the status of the order which can be canceled (0) or completed (1).
12. SHIPMENT NUMBER

    - Degenerated Dimension
    - Fact table Attribute that holds the shipment number of the order to keep track of the order delivery status.
13. Sales Territory

    - Conformed Dimension
    - A typical dimension holding geographical data that we will use to analyze our sales over different locations/areas/countries/etc.

## **STEP5**
 **DWH Modeling** 
 
 In this step, we will define the DWH Schema, and we will use a Star Schema.

## NOTE
>Just for simplicity, we won't include the Dimensions attributes on the Diagram, and we will create the tables using the ER Diagram of the relational Database.

![Schema](https://github.com/al-ghaly/Data-Warehouse-Case-Study/assets/61648960/e5e9712c-3062-4eab-8199-90a40dafb232)

## **STEP6,7**
 **DWH Physical Model** 
 
 In this step, we will create the Database tables on SQL Server. **Data Integration** In this step, we will populate the data into the tables.

**BOTH Table Creation and Data Population Scripts are in a file named **DWH.SQL**.**
- Population Code for The Fact Table:
  
```sql
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
```
## **STEP8**
 **DWH Performance** 
 
 In this step, we will create the Database Indexes and partition the fact table to ensure optimum query performance.
 
 **We will Skip This Step for now!**<hr>

## ACTUAL DATABASE SCHEMA

![Actual Schema](https://github.com/al-ghaly/Data-Warehouse-Case-Study/assets/61648960/1d5a13a0-0932-40c7-85be-b9437ccbece7)

<hr>

## **STEP9**
 **Gaining Insights** 
 
In this step we will write sample SQL Queries to extract some insights from DWH.<br><br> **We could extract hundreds of insights and I will only list a sample of those here.**<br>
## Top customers (Customer segmentation)
```sql
WITH
    sales (customerid, sales)
    AS
        (  SELECT customerid, SUM (SalesAmount)
             FROM FactSales
         GROUP BY customerid)
SELECT customerid, sales, NTILE (3) OVER (ORDER BY sales DESC)
  FROM sales;
```

## Effect of special offers on sale
```sql
SELECT Description, SUM (SalesAmount) sales
    FROM DimSpecialOffer o INNER JOIN factsales s ON s.OfferID = o.OfferID
GROUP BY Description
ORDER BY sales DESC;
```
![image](https://github.com/al-ghaly/Data-Warehouse-Case-Study/assets/61648960/09808efa-295a-4177-a803-8c94a90763fd)

## Best-selling product category
```sql
SELECT top 10 name, SUM (salesamount) sales
    FROM DimProduct P INNER JOIN FactSales s ON s.ProductID = p.ProductID
GROUP BY name
ORDER BY sales DESC;
```
![image](https://github.com/al-ghaly/Data-Warehouse-Case-Study/assets/61648960/f728e156-81e4-4637-aa28-c6a6da768982)

## Best-selling store/city/state
```sql
SELECT CountryRegionCode, SUM (salesamount) sales
    FROM DimSalesTerritory T
         INNER JOIN factsales s ON s.SalesTerrKey = t.SalesTerrKey
GROUP BY CountryRegionCode
ORDER BY sales DESC;
```
![image](https://github.com/al-ghaly/Data-Warehouse-Case-Study/assets/61648960/9469bbfb-9fcf-4b27-b871-10dada51719f)

```sql
SELECT NAME AS REGION, SUM (salesamount) sales
    FROM DimSalesTerritory T
         INNER JOIN factsales s ON s.SalesTerrKey = t.SalesTerrKey
GROUP BY NAME
ORDER BY sales DESC;
```
![image](https://github.com/al-ghaly/Data-Warehouse-Case-Study/assets/61648960/5c6712eb-b391-46a4-b144-bd82d9b818f7)

## Effect of special offers (Discount) on revenue
```sql
   SELECT DiscountPct, ROUND (SUM (TotalProfit), 0) AS profit
    FROM DimSpecialOffer O INNER JOIN FactSales S ON s.OfferID = o.OfferID
GROUP BY DiscountPct;
```
![image](https://github.com/al-ghaly/Data-Warehouse-Case-Study/assets/61648960/3fd9882a-dd2b-48c5-9d16-15b704e64dc2)

## 6-	Employees Performance
```sql
SELECT JobTitle, ROUND (SUM (SalesAmount), 0) sales
    FROM DimSalesPerson E INNER JOIN FactSales S ON S.EmployeeID = E.EmployeeID
GROUP BY JobTitle
ORDER BY sales DESC;
```
![image](https://github.com/al-ghaly/Data-Warehouse-Case-Study/assets/61648960/0149a964-a07e-4e4c-b549-f118dee31e95)

**Those were just a sample of hundreds of other insights/KPIs that we can extract from the DWH.**

## Repository Structure

- **SQL Scripts (DWH.SQL-DateDimensions.SQL):** Contains SQL scripts used for data warehouse table creation and data population.
- **Documentation(Sales Fact.pdf):** Includes detailed documentation on the project, covering business processes, KPI definitions, modeling decisions, and insights gained.
- **Schema (Actual Schema.png):** The schema for the DWH model.

---

*AdventureWorks Data Warehouse Project - [alghaly]*
