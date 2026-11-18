USE ecomm;
SHOW TABLES;
select * FROM customer_churn;
DESCRIBE customer_churn;
SELECT SUM(WarehouseToHome IS NULL) AS Missing_WarehouseToHome,
       SUM(HourSpendOnApp IS NULL) AS Missing_HourSpendOnApp,
       SUM(OrderAmountHikeFromlastYear IS NULL) AS Missing_OrderAmountHike,
       SUM(DaySinceLastOrder IS NULL) AS Missing_DaySinceLastOrder,
       SUM(Tenure IS NULL) AS Missing_Tenure,
       SUM(CouponUsed IS NULL) AS Missing_CouponUsed,
       SUM(OrderCount IS NULL) AS Missing_OrderCount FROM customer_churn;     -- FOR KNOWING NULL VALUES 


-- Data Cleaning:       
-- Handling Missing Values and Outliers:
/* 1 Impute mean  for the following columns, and round off to the nearest integer if required: WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, DaySinceLastOrder.  
-- CALCULATING THE MEAN OF WarehouseToHome */

SELECT ROUND(AVG(WarehouseToHome), 2) AS Mean_WarehouseToHome FROM customer_churn;

-- FILL MISSING VALUES IN WarehouseToHome USING MEAN

set sql_Safe_updates=0;
UPDATE customer_churn SET WarehouseToHome = 16 WHERE WarehouseToHome IS NULL;      -- ROUNDED

-- CALCULATING THE MEAN OF HourSpendOnApp 

SELECT ROUND(AVG(HourSpendOnApp), 2) AS Mean_HourSpendOnApp FROM customer_churn;

-- -- FILL MISSING VALUES IN  HourSpendOnApp USING MEAN

UPDATE customer_churn SET HourSpendOnApp = 3 WHERE HourSpendOnApp IS NULL;     -- ROUNDED

-- CALCULATING THE MEAN OF OrderAmountHikeFromlastYear 

SELECT ROUND(AVG(OrderAmountHikeFromlastYear), 2) AS Mean_OrderAmountHikeFromlastYear FROM customer_churn;

-- -- FILL MISSING VALUES IN  OrderAmountHikeFromlastYear

UPDATE customer_churn SET OrderAmountHikeFromlastYear = 16 WHERE OrderAmountHikeFromlastYear IS NULL;      -- ROUNDED

-- CALCULATING THE MEAN OF DaySinceLastOrder 

SELECT ROUND(AVG(DaySinceLastOrder), 2) AS Mean_DaySinceLastOrder FROM customer_churn;

-- -- FILL MISSING VALUES IN  DaySinceLastOrder USING MEAN

UPDATE customer_churn SET DaySinceLastOrder = 5 WHERE DaySinceLastOrder IS NULL;        -- ROUNDED

-- 2   Impute mode for the following columns: Tenure, CouponUsed, OrderCount. 
-- Mode imputation – Tenure

SELECT Tenure, COUNT(*) AS Frequency FROM customer_churn WHERE Tenure IS NOT NULL GROUP BY Tenure ORDER BY Frequency DESC LIMIT 1;    -- TO FIND THE MOST FREQUENT values
UPDATE customer_churn SET Tenure = 1 WHERE Tenure IS NULL;
SELECT COUNT(*) AS RemainingMissing FROM customer_churn WHERE Tenure IS NULL;

-- Mode imputation – CouponUsed

SELECT CouponUsed, COUNT(*) AS Frequency FROM customer_churn WHERE CouponUsed IS NOT NULL GROUP BY CouponUsed ORDER BY Frequency DESC LIMIT 1;
UPDATE customer_churn SET CouponUsed = 1 WHERE CouponUsed IS NULL;
SELECT COUNT(*) AS RemainingMissing FROM customer_churn WHERE CouponUsed IS NULL;

-- Mode imputation – OrderCount

SELECT OrderCount, COUNT(*) AS Frequency FROM customer_churn WHERE OrderCount IS NOT NULL GROUP BY OrderCount ORDER BY Frequency DESC LIMIT 1;
UPDATE customer_churn SET OrderCount = 2 WHERE OrderCount IS NULL;
SELECT COUNT(*) AS RemainingMissing FROM customer_churn WHERE OrderCount IS NULL;

-- 3 Handle outliers in the 'WarehouseToHome' column by deleting rows where the values are greater than 100.

DELETE FROM customer_churn WHERE WarehouseToHome > 100;


/* Dealing with Inconsistencies: 
-- 1 Replace occurrences of “Phone” in the 'PreferredLoginDevice' column and “Mobile” in the 'PreferedOrderCat' column with “Mobile Phone” to ensure 
uniformity. */

UPDATE customer_churn SET PreferredLoginDevice = 'Mobile Phone' WHERE PreferredLoginDevice = 'Phone';

/* 2 Standardize payment mode values: Replace "COD" with "Cash on Delivery" and 
"CC" with "Credit Card" in the PreferredPaymentMode column. 
*/

UPDATE customer_churn SET PreferredPaymentMode = 'Cash on Delivery' WHERE PreferredPaymentMode = 'COD';
UPDATE customer_churn SET PreferredPaymentMode = 'Credit Card' WHERE PreferredPaymentMode = 'CC';
SELECT DISTINCT PreferredPaymentMode FROM customer_churn;

-- Data Transformation:  
-- Column Renaming: 
-- 1 Rename the column "PreferedOrderCat" to "PreferredOrderCat".


ALTER TABLE customer_churn RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;
select * FROM customer_churn;

-- 2 Rename the column "HourSpendOnApp" to "HoursSpentOnApp". 

ALTER TABLE customer_churn RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;
select * FROM customer_churn;

-- Creating New Columns: 
-- 1 Create a new column named ‘ComplaintReceived’ with values "Yes" if the  corresponding value in the ‘Complain’ is 1, and "No" otherwise.

ALTER TABLE customer_churn ADD COLUMN ComplaintReceived VARCHAR(3);
UPDATE customer_churn 
 SET ComplaintReceived = 
    CASE
        WHEN Complain = 1 THEN 'Yes'
        ELSE 'No'
    END;
select * FROM customer_churn;

-- 2 Create a new column named 'ChurnStatus'. Set its value to “Churned” if the  corresponding value in the 'Churn' column is 1, else assign “Active”. 

ALTER TABLE customer_churn ADD COLUMN ChurnStatus VARCHAR(10);
UPDATE customer_churn
  SET ChurnStatus =
    CASE
        WHEN Churn = 1 THEN 'Churned'
        ELSE 'Active'
    END;
select * FROM customer_churn;

-- Column Dropping: 
-- 1 Drop the columns "Churn" and "Complain" from the table.

ALTER TABLE customer_churn DROP COLUMN Churn, DROP COLUMN Complain;
select * FROM customer_churn;

-- Data Exploration and Analysis: 
  -- 1 Retrieve the count of churned and active customers from the dataset. 
  
SELECT ChurnStatus, COUNT(*) AS CustomerCount FROM customer_churn GROUP BY ChurnStatus;

 -- 2  Display the average tenure and total cashback amount of customers who churned. 
SELECT AVG(Tenure) AS AverageTenure,
         SUM(CashbackAmount) AS TotalCashback FROM customer_churn WHERE ChurnStatus = 'Churned';
         
 -- 3 Determine the percentage of churned customers who complained. 
SELECT
    ROUND(SUM(CASE WHEN ComplaintReceived = 'Yes' THEN 1 ELSE 0 END)* 100.0 / COUNT(*), 2)
    AS ComplaintPercentage FROM customer_churn WHERE ChurnStatus = 'Churned';
    
 -- 4 Identify the city tier with the highest number of churned customers whose  preferred order category is Laptop & Accessory. 
 
 SELECT CityTier, COUNT(*) AS CustomerCount FROM customer_churn WHERE ChurnStatus = 'Churned'
                                                                AND PreferredOrderCat = 'Laptop & Accessory'
                                                                GROUP BY CityTier
																ORDER BY CustomerCount DESC;
																
                                                                
 -- 5 Identify the most preferred payment mode among active customers. 
 
 SELECT PreferredPaymentMode, COUNT(*) AS CustomerCount FROM customer_churn  WHERE ChurnStatus = 'Active'
                                                                             GROUP BY PreferredPaymentMode
                                                                             ORDER BY CustomerCount DESC;
                                                                             
-- 6 Calculate the total order amount hike from last year for customers who are single and prefer mobile phones for ordering. 

SELECT SUM(OrderAmountHikeFromlastYear) AS TotalOrderAmountHike FROM customer_churn WHERE MaritalStatus = 'Single'
                                                                                    AND PreferredOrderCat = 'Mobile Phone';
                                                                                    
-- 7 Find the average number of devices registered among customers who used UPI as  their preferred payment mode. 

SELECT AVG(NumberOfDeviceRegistered) AS AverageDevicesRegistered FROM customer_churn WHERE PreferredPaymentMode = 'UPI';

-- 8 Determine the city tier with the highest number of customers.

SELECT CityTier, COUNT(*) AS CustomerCount FROM customer_churn GROUP BY CityTier
                                                               ORDER BY CustomerCount DESC;
                                                               
                                                               
 -- 9 Identify the gender that utilized the highest number of coupons.
 
 SELECT Gender, SUM(CouponUsed) AS TotalCoupons FROM customer_churn GROUP BY Gender
                                                                    ORDER BY TotalCoupons DESC;
																	

-- 10 List the number of customers and the maximum hours spent on the app in each preferred order category.

SELECT PreferredOrderCat, COUNT(*) AS CustomerCount,MAX(HoursSpentOnApp) AS MaximumAppHours
                                                                        FROM customer_churn
																		GROUP BY PreferredOrderCat;
                                                                        
-- 11 Calculate the total order count for customers who prefer using credit cards and have the maximum satisfaction score. 

SELECT SUM(OrderCount) AS TotalOrderCount FROM customer_churn WHERE PreferredPaymentMode = 'Credit Card'
															  AND SatisfactionScore = (
															  SELECT MAX(SatisfactionScore)
                                                              FROM customer_churn);
  
-- 12 What is the average satisfaction score of customers who have complained?
 
SELECT AVG(SatisfactionScore) AS AverageSatisfaction FROM customer_churn WHERE ComplaintReceived = 'Yes';

 -- 13 List the preferred order category among customers who used more than 5 coupons. 
 
SELECT DISTINCT PreferredOrderCat FROM customer_churn WHERE CouponUsed > 5;

-- 14 List the top 3 preferred order categories with the highest average cashback amount. 

SELECT PreferredOrderCat,AVG(CashbackAmount) AS AverageCashback FROM customer_churn
                                                                GROUP BY PreferredOrderCat
                                                                ORDER BY AverageCashback DESC;
																
-- 15 Find the preferred payment modes of customers whose average tenure is 10 months and have placed more than 500 orders. 

SELECT PreferredPaymentMode FROM customer_churn GROUP BY PreferredPaymentMode
                                                HAVING AVG(Tenure) > 10
                                                AND SUM(OrderCount) > 500;
-- 16 
/*  Categorize customers based on their distance from the warehouse to home such as 'Very Close Distance' for distances <=5km, 'Close Distance'
 for <=10km, 'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the churn status breakdown for each distance category. */
 
 SELECT
    CASE
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS DistanceCategory,
    ChurnStatus,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory;

-- 17 
/*List the customer’s order details who are married, live in City Tier-1, and their 
order counts are more than the average number of orders placed by all 
customers.*/

SELECT * FROM customer_churn WHERE MaritalStatus = 'Married'
                             AND CityTier = 1
                             AND OrderCount > (
                             SELECT AVG(OrderCount)
							 FROM customer_churn);
      
-- a) Create a ‘customer_returns’ table in the ‘ecomm’ database and insert the data

CREATE TABLE customer_returns (ReturnID INT PRIMARY KEY,CustomerID INT,ReturnDate DATE,RefundAmount INT);
INSERT INTO customer_returns(ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
                                                (1001, 50022, '2023-01-01', 2130),
                                                (1002, 50316, '2023-01-23', 2000),
                                                (1003, 51099, '2023-02-14', 2290),
                                                (1004, 52321, '2023-03-08', 2510),
                                                (1005, 52928, '2023-03-20', 3000),
                                                (1006, 53749, '2023-04-17', 1740),
												(1007, 54206, '2023-04-21', 3250),
                                                (1008, 54838, '2023-04-30', 1990);
SELECT * FROM customer_returns;

-- b) Display the return details along with the customer details of those who have churned and have made complaints.

SELECT
    r.ReturnID,
    r.CustomerID,
    r.ReturnDate,
    r.RefundAmount,
    c.*
FROM customer_returns r INNER JOIN customer_churn c ON r.CustomerID = c.CustomerID WHERE c.ChurnStatus = 'Churned' AND c.ComplaintReceived = 'Yes';
      