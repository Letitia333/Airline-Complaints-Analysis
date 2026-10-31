-- The database
USE airtravel_complaint_decisions;

-- Columns in the dataset
SHOW COLUMNS FROM airtravel_complaint_decisions_cleaned;

-- Display air travel dataset
SELECT * FROM airtravel_complaint_decisions_cleaned;

-- Describe our main table airtravel_complaint_decisions_cleaned
DESCRIBE decisions;

-- Data Normalization( We create multiples tables from the dataset

CREATE TABLE airlines (
    airlineCode VARCHAR(50) PRIMARY KEY,
    AirlinesNames VARCHAR(50)
);


-- NOTE: We have many cases with same decision numbers,so we have to create an auto increment ID
CREATE TABLE decisions (
    decision_id INT AUTO_INCREMENT PRIMARY KEY,
    decisionNumber VARCHAR(50),
    flightNumber VARCHAR(50),
    airlineCode VARCHAR(50),
    flightdate DATE,
    issueTierId bigint,
    carrierControlId VARCHAR(100),
   orderStatementId INT,
    completeDate DATE,
	itinerary VARCHAR(50)
);

CREATE TABLE issuesCategory (
    issueTierId bigint  PRIMARY KEY,
    issue VARCHAR(50)
);

CREATE TABLE orderCategory (
    orderStatementId INT  PRIMARY KEY,
    orderStatement VARCHAR(50)
);

CREATE TABLE carrier_responsibility (
    carrierControlId  VARCHAR(50) PRIMARY KEY,
   carrierControl VARCHAR(50)
);

CREATE TABLE flightdate_table (
    flightDate DATE PRIMARY KEY
);


CREATE TABLE itinerary_table (
    itinerary VARCHAR(50)  PRIMARY KEY
);


-- We insert datas in the airlines table:
INSERT INTO airlines
SELECT DISTINCT(A.airlineCode), Ai.AirlinesNames  
FROM airtravel_complaint_decisions_cleaned AS A
LEFT JOIN airlines_names AS Ai
ON A.airlineCode = Ai.AirlinesCode
WHERE A.airlineCode IS NOT NULL AND Ai.AirlinesCode IS NOT NULL
GROUP BY A.airlineCode, Ai.AirlinesNames;

SELECT * FROM airlines;

--  We need to replace 'Ã©' and 'Ã' inside the airlines table
SELECT  AirlinesNames
FROM airlines
WHERE AirlinesNames LIKE '%Ã©%';

-- Update of the airlines tables

SET SQL_SAFE_UPDATES = 0; /*Turn off Safe Update mode*/

UPDATE airlines
SET AirlinesNames = REPLACE(
REPLACE(AirlinesNames,
'Ã©','é'),
'Ã', 'i')
WHERE AirlinesNames REGEXP 'Ã';

SET SQL_SAFE_UPDATES = 1; /*Turn on back Safe Update mode*/

-- We insert datas in table  : decisions
INSERT INTO decisions(decisionNumber, flightNumber, flightDate, 
issueTierId,carrierControlId, airlineCode, orderStatementId, completeDate, itinerary)
SELECT decisionNumber, flightNumber, flightDate, 
issueTierId,carrierControlId, airlineCode, orderStatementId, completeDate, itinerary
FROM airtravel_complaint_decisions_cleaned
WHERE decisionNumber IS NOT NULL;

SELECT * FROM decisions;

-- We insert datas in table  : issuesCategory
INSERT INTO issuesCategory
SELECT DISTINCT (issueTierId), issue 
FROM airtravel_complaint_decisions_cleaned
WHERE issueTierId IS NOT NULL;

SELECT * FROM issuesCategory;

-- We insert datas the orderCategory in table:
INSERT INTO ordercategory
SELECT DISTINCT (orderStatementId), orderStatement 
FROM airtravel_complaint_decisions_cleaned
WHERE orderStatementId IS NOT NULL;

SELECT * FROM ordercategory;

-- We insert datas in table  : flightdate_table
INSERT INTO flightdate_table
SELECT DISTINCT (flightDate)
FROM airtravel_complaint_decisions_cleaned
WHERE flightDate IS NOT NULL;

SELECT * FROM flightdate_table;

-- We insert datas in table  : Itinerary_table
INSERT INTO itinerary_table
SELECT DISTINCT(itinerary)
FROM airtravel_complaint_decisions_cleaned
WHERE itinerary IS NOT NULL
group by itinerary;

SELECT * FROM itinerary_table;

-- We insert datas in table  : carrier_responsability
INSERT INTO carrier_responsibility
SELECT DISTINCT (carrierControlId), carrierControl 
FROM airtravel_complaint_decisions_cleaned;

SELECT * FROM carrier_responsibility;

-- Create columns year and month in flightdate
ALTER TABLE flightdate_table
ADD month_name VARCHAR(50),
ADD year INT;

SET SQL_SAFE_UPDATES = 0; /*Turn off Safe Update mode*/

UPDATE flightdate_table
SET month_name = MONTHNAME(flightDate),
year = YEAR(flightDate);

SET SQL_SAFE_UPDATES = 1; /*Turn on back Safe Update mode*/

-- Let's verify our modification
SELECT * FROM flightdate_table
ORDER BY flightDate DESC;


/*==================================================
BUSINESS QUESTION 1:
Total issues encountered by Month by passengers
==================================================
OBJECTIVE:
Identify the month with the highest complaint volumes.

SQL APPROACH:
Use COUNT(),JOIN, GROUP BY, and ORDER BY.

Query:*/

SELECT COUNT(d.issueTierId) AS Total_issues, f.month_name
FROM decisions AS d 
JOIN flightdate_table AS f
ON d.flightdate = f.flightDate
GROUP BY month_name
ORDER BY Total_issues DESC;

/*
ANALYSIS:
The query identifies the months with highest issues and lowest issues 
recorded from 2018 to 2026.

RESULTS:
1. December: 10773 complaints
2. January: 7338 complaints
3. October:  complaints

KEY INSIGHT:
In general, flights that departed in December received the highest number of complaints; 
this could be explained by the weather and the fact that December encompasses 
the Christmas and New Year holiday period. Conversely, airlines received fewer complaints in October.

RECOMMENDATION:
Airlines need to take more precaution for the month of December.
*/

/*==================================================
BUSINESS QUESTION 2:
Top 3 Airlines that had the more issues in 2025
==================================================
OBJECTIVE:
Identify the airlines with the highest complaint volumes.

SQL APPROACH:
Use COUNT(),JOIN, GROUP BY, WHERE, ORDER BY, LIMIT.

Query:*/

SELECT airlineCode, COUNT(issueTierId) AS Total_issues
FROM decisions AS d
JOIN flightdate_table AS f
ON d.flightdate = f.flightDate
WHERE f.year = 2025
GROUP BY airlineCode
ORDER BY Total_issues DESC
LIMIT 3;

/*
ANALYSIS:
The query identifies the three airlines with the
highest number of recorded complaints in 2025.

RESULTS:
1. Air Canade (AC): 12 complaints
2. WESTJET (WS): 4 complaints
3. PORTER(PD): 1 complaints

KEY INSIGHT:
Air Canada received the most complaints in 2025 followed by WestJet and Porter Airlines.

RECOMMENDATION:
Further investigation could focus on the main
complaint categories associated with these airlines
to identify areas requiring improvement
*/


/*==================================================
BUSINESS QUESTION 3:
Which period in the year the issues was mostly out the airlines control in 2024
==================================================
OBJECTIVE:
Identify in which period the airlines are out of control of the issues.

SQL APPROACH:
Use COUNT(),JOIN, CTE, GROUP BY, WHERE, ORDER BY.

Query:*/

WITH issues_out_of_control AS
   (SELECT c.carrierControl AS Carrier_responsibility, MONTHNAME(d.flightdate) AS Month_issue, 
   COUNT(d.issueTierId) AS Total_issues, YEAR(d.flightdate) AS year
    FROM decisions AS d
	JOIN carrier_responsibility AS c ON d.carrierControlId = c.carrierControlId
    WHERE c.carrierControlId= "1"
    GROUP BY Carrier_responsibility, Month_issue, year
    ORDER BY Total_issues DESC)
    
    SELECT  Month_issue, Carrier_responsibility, Total_issues
    FROM issues_out_of_control
    WHERE year = 2024;
    
/*
ANALYSIS:
Identify in which period in 2024 the airlines could not control the source of the issues that occured.

RESULTS:
1. January: 658 complaints
2. April: 360 complaints
3. March: 284 complaints

KEY INSIGHT:
The month of January 2024 was the month when airlines received the highest volume of complaints namely 658.
Followed by April 2024 and March 2024.

RECOMMENDATION:
Airlines need to take more precaution to prepape the months of January, April and March for unexpected issues.
*/


/*==================================================
BUSINESS QUESTION 4:
How many issues were out of control of the airlines compared to the 
issues caused by the airlinesfrom 2018-2026.
==================================================
OBJECTIVE:
Compare the number of issues attributed to airlines
with those considered outside airline control and
identify changes over the years

SQL APPROACH:
Use INNER JOIN, SUM(), CASE WHEN, GROUP BY and YEAR().

Query:*/

SELECT
    YEAR(d.flightdate) AS year,

    SUM(CASE
        WHEN cc.carrierControl = "Outside of carrier's control"
        THEN 1 ELSE 0
    END) AS outside_airline_control,

    SUM(CASE
        WHEN cc.carrierControl = "Within carrier's control"
        THEN 1 ELSE 0
    END) AS within_airline_control,

    COUNT(*) AS total_issues

FROM decisions AS d

INNER JOIN carrier_responsibility AS cc
    ON d.carrierControlId = cc.carrierControlId

GROUP BY year
ORDER BY year ASC;

/*
ANALYSIS:
Identify the change over the years on the airlines responsibilities.

RESULTS:
1. 2021: 289 issues outside carrier control Vs 1257 issues within carrier control
2. 2022: 4369 issues outside carrier control Vs 13884 issues within carrier control
3. 2023: 3908 issues outside carrier control Vs 12217 issues within carrier control
4. 2024: 1729 issues outside carrier control Vs 6782 issues within carrier control

KEY INSIGHT:
Complaints truly began to rise in 2021, with 289 issues beyond the airlines control, 
compared to 1257 issues attributed to the airlines themselves. In 2022, 
we observed that the vast majority of issues—reaching as many as 13884 were caused by the airlines.
After From 2023 issues atribuated to airlines started to dropped.

RECOMMENDATION:
Airlines must maintain their performance to ensure they continue to receive as few complaints as possible.
*/


/*==================================================
BUSINESS QUESTION 5:
Type of complaint the airlines received the most between 2018 - 2025
==================================================
OBJECTIVE:
See the issues that occured the most.

SQL APPROACH:
Use JOIN, COUNT(), WHERE, GROUP BY, ORDER BY and YEAR().

Query:*/

SELECT i.issue, COUNT(d.issueTierId) AS Total_issues, YEAR(d.flightdate) 
FROM decisions AS d
JOIN issuescategory AS i
ON d.issueTierId = i.issueTierId
WHERE YEAR(d.flightdate) < 2026
GROUP BY i.issue, YEAR(d.flightdate)
ORDER BY Total_issues DESC;

/*
ANALYSIS:
Identify the issues that passengers encontered the most between 2018 to 2025

RESULTS:
1. 2022: Flight Disruption
2. 2023: Flight Disruption
3. 2024: Flight Disruption

KEY INSIGHT:
Flight disruption has been the most common issues 
from 2022 to 2025 with the maximum complaints of 20303 alterbetween 2018 to 2025.

RECOMMENDATION:
Airlines should provide passengers with timely updates about delays, 
cancellations, rescheduling, and alternative travel arrangements 
through SMS, email, and mobile applications.
*/


/*==================================================
BUSINESS QUESTION 6:
Which itinerary has the most baggage issues?
==================================================
OBJECTIVE:
See the route that has the most baggage related issue.

SQL APPROACH:
Use JOIN, COUNT(), WHERE, GROUP BY, and ORDER BY.

Query:*/

SELECT it.itinerary, COUNT(d.issueTierId) AS Total_issues 
FROM decisions AS d
JOIN itinerary_table AS it
ON d.itinerary = it.itinerary
WHERE d.issueTierId = "2"
GROUP BY it.itinerary
ORDER BY Total_issues DESC;

/*
ANALYSIS:
Identify the itinerary which has the most baggages issues.

RESULTS:
1. YYZ-YVR: 63 baggages issues

KEY INSIGHT:
The itinerary from YYZ(Toronto Pearson Airport) to YVR(International Airport of Vancouver) 
received the most baggages related issues.

RECOMMENDATION:
- Airlines should implement real-time baggage tracking technology using barcode scanning.
- Airlines should improve staff training and establish 
standardized procedures for loading, unloading, sorting, and transferring baggage.
*/


/*==================================================
BUSINESS QUESTION 7:
Which type of complaint received the most reject?
==================================================
OBJECTIVE:
See the complaint with that has been mostly rejected by the airlines

SQL APPROACH:
Use , JOIN, WHERE, GROUP BY.

Query:*/

SELECT i.issue AS complaint, COUNT(d.orderStatementId) AS Total_statements, o.orderStatement AS statement
FROM issuescategory AS i
JOIN decisions AS d
ON d.issueTierId = i.issueTierId
JOIN ordercategory AS o
ON d.orderStatementId = o.orderStatementId
WHERE o.orderStatement = "Dismissed"
GROUP BY complaint, statement;

/*
ANALYSIS:
Identify the most rejected complaint type

RESULTS:
1. Flight Disruption: 25987 rejected complaints

KEY INSIGHT:
The complaint type which receved the most reject was : Flight Disruption.

RECOMMENDATION:
-Airlines should improve crew scheduling, 
aircraft maintenance, and operational contingency planning to 
minimize preventable delays and cancellations.

- Also airlines need to educate the passengers with non refundable tickets flights, 
about their ticket flight policies, especially 
in case of cancellation, flight delay or disruption.
*/


/*==================================================
BUSINESS QUESTION 8:
Which flight had the most issues?
==================================================
OBJECTIVE:
See the flight with the most complaints between 2018 to 2026

SQL APPROACH:
Use ,COUNT(), GROUP BY, ORDER BY, LIMIT.

Query:*/

SELECT flightNumber, COUNT(issueTierId) AS Total_issues
FROM decisions AS d
GROUP BY flightNumber
ORDER BY Total_issues DESC
LIMIT 5;

/*
ANALYSIS:
Identify the flight with the most issues to resolve.

RESULTS:
1. AT209: 180 complaints

KEY INSIGHT:
The flight AT209 operated by Morroco Airlines, which departs from the city of Montreal to Casablanca 
have the highest number of complaints and issues with 180.

RECOMMENDATION:
Morroco ailines need to:
- Strengthen customer service operations
- Improve baggages handling
*/


/*==================================================
BUSINESS QUESTION 9:
How did the volume of passenger complaints evolve by issue category between 2018 and 2026?
==================================================
OBJECTIVE:
Analyze trends over time.

SQL APPROACH:
Use ,COUNT(), CTE, JOIN, GROUP BY, ORDER BY.

Query:*/

WITH Total_issues_per_year AS
(
SELECT COUNT(d.issueTierId) AS Total_issues, f.year AS year, d.issueTierId as Id
FROM decisions AS d 
JOIN flightdate_table AS f
ON d.flightdate = f.flightDate
GROUP BY year, id)

SELECT year, i.issue, Total_issues
FROM Total_issues_per_year AS T
JOIN issuescategory AS i
ON T.id = i.issueTierId
GROUP BY year, i.issue, Total_issues
ORDER BY year ASC;

/*
ANALYSIS:
Identify how each complaint category increased or decreased from year to year.
Especially the most impactfull.

RESULTS:
Year        Baggage   Flight Disruption   Ticket, Reservation and Loyalty Program    Refusal to Transport  
2019            4                 30                         17                                 3
2020           11                415                        239                                22
2021          192               1668                        241                               267
2022         1629              19977                        978                               715
2023         1495              20303                        889                               724
2024          446              11700                        259                               185
2025            1                 17                          1                                 0

KEY INSIGHT:
- In 2019 ailines eceiveed 30 complaints related to flight disruption. 
The number of flight disruptions issues incredibily increased from 2020 with 
415 complaints to 2023 with 20303 complaints when 
it experienced a peak, to drop down from 2024 with 11700 complaints to 2025 with 17 complaints.

- Baggages issues increased from 2021 with 192 complaints to 2022 with 1629 complaints 
and drecreased from 2023 with 1495 to 2025 with 1 complaint.

- Ticket, Reservation and Loyalty Program related complaints from 2020 with 239 complaints 
to 2022 with 978 complaints, and decreased from 2023 with 889 complaints to 2025 with 1 complaint.

- Refusal to Transport increased from 2022 with 22 complaints to 2023 with 724 complaints 
and drecreased from 2024 with 185 to 2025 with no complaint.

Overall the issues in general inscreased from 2020 to 2024 and we can see a decrease from 2025. 
This indicates that the companies have put mechanisms in place to minimize complaints as much as possible. 
*/


/*Create relationships between decisions and issuescategory tables to build our model*/
ALTER TABLE decisions
ADD CONSTRAINT fk_issuescategory
FOREIGN KEY (issueTierId)
REFERENCES issuescategory(issueTierId);
describe decisions;

/*Create relationships between decisions and ordercategory tables*/
ALTER TABLE decisions
ADD CONSTRAINT fk_ordercategory
FOREIGN KEY (orderStatementId)
REFERENCES ordercategory(orderStatementId);

/*Create relationships between decisions and airlines tables*/
SET foreign_key_checks = 0;
ALTER TABLE decisions
ADD CONSTRAINT fk_airlines
FOREIGN KEY (airlineCode)
REFERENCES airlines(airlineCode);
SET foreign_key_checks = 1;

/*Create relationships between decisions and carrier_responsibility tables*/
ALTER TABLE decisions
ADD CONSTRAINT fk_carrier_responsibility
FOREIGN KEY (carrierControlId)
REFERENCES carrier_responsibility(carrierControlId);

/*Create relationships between decisions and itinerary_table tables*/
ALTER TABLE decisions
ADD CONSTRAINT fk_itinerary_table
FOREIGN KEY (itinerary)
REFERENCES itinerary_table(itinerary);

/*Create relationships between decisions and flightdate_table tables*/
ALTER TABLE decisions
ADD CONSTRAINT fk_flightdate_table
FOREIGN KEY (flightDate)
REFERENCES flightdate_table(flightDate);

/*Change of the column's data types in the table: airlines_names.*/
ALTER TABLE airlines_names MODIFY airlinesCode varchar(50);
ALTER TABLE airlines_names MODIFY AirlinesNames varchar(50);

/*We set a primary key on the table airlines_names that we added*/
ALTER TABLE airlines_names
ADD PRIMARY KEY (AirlinesNames);

/*Create relationships between airlines and airlines_names tables*/
ALTER TABLE airlines
ADD CONSTRAINT fk_airlines_names
FOREIGN KEY (AirlinesNames)
REFERENCES airlines_names(AirlinesNames);