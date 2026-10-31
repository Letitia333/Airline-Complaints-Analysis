# Transportation Passengers Complaints Data Analytics

## 1. Project Overview

This project focuses on analyzing decisions published by the Canadian Transportation Agency (CTA) to identify trends and patterns in airline-related passenger complaints.The objective is to transform raw transportation data into meaningful insights that can help understand passenger concerns, airline performance, complaint trends.

Using SQL, Python, MySQL, and Power BI, this project demonstrates the complete data analytics process, from data cleaning and database organization to exploratory analysis and interactive visualization.

## 2. Business Objectives

The main objectives of this project are to:

Identify the most frequent passenger complaint categories.

Analyze complaint trends over time.

Identify airlines with the highest number of recorded complaints.

Examine issues considered within and outside airline control.

Identify seasonal patterns in passenger complaints.

Investigate baggage-related complaints and other common passenger issues.

Understand complaint outcomes and order statements.


## 3. Tools and Technologies


Python : Data cleaning, transformation and preparation

MySQL: Database creation, storage and management

SQL:     Data querying, aggregation and analysis

Power BI:   Data visualization and interactive dashboards

GitHub:   Project documentation and version control

## 4. Dataset

Source: Canadian Transportation Agency (CTA)
https://portail-portal.otc-cta.gc.ca/fr/liste-decisions-8514

The dataset contains published CTA decisions related to air travel complaints.
The information includes fields relating to:

Decision numbers, Airlines and airline codes, Flight dates, Itineraries, Complaint categories, Airline control classifications;
Order statements and decision outcomes.

The original dataset contains approximately 63,841 records and 48,877 unique decision numbers.

Note: A decision number may appear across multiple records because one decision can contain multiple issues and order statements.

## 5. Project Methodology

Step 1: Data Cleaning and Preparation – Python

Python was used to: 

Inspect the original dataset

Identify and handle missing values

Correct data types and formatting 

Clean airline names and airline codes

Extract relevant information from dates and itineraries,Prepare the dataset for database import.

Step 2: Database Creation and Organization – MySQL

MySQL was used to:

Create the project database.

Import the cleaned dataset.

Organize information into relational tables.

Establish primary and foreign key relationships where appropriate.

Maintain associations between decisions, issues, airlines, and order statements.

Step 3: Data Analysis – SQL

SQL was used to answer business questions through:

Filtering and sorting.

Aggregate functions.

Joins.

Common Table Expressions (CTEs).

Subqueries.

Date functions.

Grouping and ranking.

Step 4: Data Visualization – Power BI

Power BI was used to develop interactive dashboards presenting:

Complaint trends over time.

Airline complaint comparisons.

Most frequent complaint categories.

Airline control classifications.

Baggage-related issues.

Complaint outcomes.

## 6. Business Questions

The analysis addresses the following questions:

How many passenger complaints were recorded each year?

Which three airlines had the highest number of complaints in 2025?

During which period of 2024 were issues most frequently classified as outside airline control?

How have issues within and outside airline control evolved from 2018 to 2026?

What is the most frequent passenger complaint category since 2018?

Which itinerary recorded the highest number of baggage-related issues?

Which complaint category had the highest number of rejected claims?

Which issue categories were most frequently attributed to airline control?

How have complaint categories evolved over time?

## 7. Key Findings and Insights

This section will be updated after completing the SQL analysis and Power BI dashboard.

For each business question, the findings will include:

Analysis results.

Important trends and patterns.

Key business insights.

Potential recommendations.

## 8. Power BI Dashboard

<img width="1331" height="750" alt="Dashboard" src="https://github.com/user-attachments/assets/066c635a-5ad3-4b0a-bb0d-b2ed2e351043" />



## 9. Database Schema

<img width="1290" height="875" alt="Airtravel_complaints_shema" src="https://github.com/user-attachments/assets/9460e06d-022e-461d-bcd5-2d416562144e" />




## 10. Project Structure


Canadian-Transportation-Data-Analytics/
│
├── README.md
├── data/
├── python/
├── sql/
├── powerbi/
├── images/
└── documentation/


## 11. Skills Demonstrated

Data cleaning and preprocessing

Relational database design

SQL querying and data analysis

Data transformation

Exploratory data analysis

Data visualization

Business intelligence

Analytical thinking and problem-solving

## 12. Disclaimer

This project is an independent data analytics portfolio project using publicly available Canadian Transportation Agency decision information. The analysis reflects the available dataset and does not necessarily represent the overall performance of individual airlines or the entire Canadian aviation industry.
