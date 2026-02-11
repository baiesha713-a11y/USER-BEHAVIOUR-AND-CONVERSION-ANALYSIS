# USER-BEHAVIOUR-AND-CONVERSION-ANALYSIS

End-to-End Experiment & Revenue Analytics Project

📌 Project Overview

This project analyzes user behaviour, session activity, and transactional performance to evaluate the business impact of an experimental change (Group A vs Group B).

The objective was to:

Analyze user engagement patterns

Measure revenue and conversion performance

Compare experiment groups statistically

Build a normalized database schema

Develop an executive-level BI dashboard

This project demonstrates end-to-end data analytics workflow using Excel, Python, SQL, and Power BI.

🎯 Problem Statement

A digital platform conducted an experiment to test whether a new variation (Group B) improved revenue and conversion performance compared to the existing version (Group A).

Key questions:

Does Group B significantly increase revenue?

Which traffic sources drive the highest conversions?

Which customer segments generate the most value?

How does user behaviour impact transactions?

Is the observed difference statistically significant?

📂 Dataset Summary

Total Records: 10,000 transactions

Experiment Groups: A & B

Customer Segments: New, Returning, VIP

Traffic Sources: Organic, Paid, Referral, Social

Devices: Desktop, Mobile, Tablet

Payment Methods: Credit, Debit, UPI, Wallet

Metrics:

Revenue

Conversion

Session Time

Items Viewed

🟢 Excel – Business Validation Layer
Purpose:

Quick metric validation and pivot-based business summaries.

Work Performed:

Revenue by Experiment Group

Revenue by Traffic Source

Conversions by Customer Segment

Transactions by Payment Method

Executive KPI summary pivots

Why Excel:

Fast validation

Business-friendly reporting

Sanity check before statistical modeling

🐍 Python – Exploratory Data Analysis & Statistics
Libraries Used:

Pandas

Matplotlib

Seaborn

Scipy

🔍 Exploratory Data Analysis (EDA)

Revenue distribution by group

Conversion comparison across devices

Traffic source revenue trends

Customer segment revenue analysis

Session behaviour impact

📈 Statistical Testing
Hypothesis Setup:

H₀ (Null Hypothesis): No significant revenue difference between Group A and Group B

H₁ (Alternative Hypothesis): Revenue differs between groups

Method Used:

Independent Two-Sample T-Test

Result:

p-value > 0.05

Failed to reject Null Hypothesis

No statistically significant difference between Group A and Group B revenue

Insight:

Observed revenue difference is likely due to random variation, not experimental impact.

🗄 SQL – Data Modeling & Analytical Querying
Database Design

Three-table normalized schema:

1️⃣ users_dim

user_id (Primary Key)

region

customer_segment

2️⃣ session_dim

session_id (Primary Key)

user_id (Foreign Key → users_dim)

experiment_group

device_type

traffic_source

session_time_sec

num_items_viewed

3️⃣ transaction_fact

transaction_id (Primary Key)

session_id (Foreign Key → session_dim)

revenue

conversion

payment_method

Schema Type:
⭐ Snowflake-style analytical schema

SQL Analysis Performed

Basic KPI aggregation queries

Group-wise revenue comparison

Conversion rate calculation

Funnel analysis (Sessions → Transactions → Conversions)

CTE-based analysis

Window functions

Ranking queries

Segment revenue comparison

📊 Power BI – Executive Dashboard
Dashboard Features:

KPI Cards:

Total Revenue

Total Transactions

Total Conversions

Conversion Rate

Revenue by Experiment Group

Conversion by Device

Traffic-wise Sessions

Payment Method Revenue

Segment Performance

Interactive slicers (Group, Region, Traffic Source)

Data Modeling:

One-to-many relationships

Snowflake-style structure

Fact table connected via session layer

📈 Key Business Insights

Group B generated slightly higher revenue but not statistically significant.

Paid traffic contributed the highest revenue.

VIP customers generated the highest total revenue.

Revenue distribution across traffic sources is relatively balanced.

Wallet and Credit methods showed strong revenue contribution.

Conversion volume is evenly distributed across customer segments.

📌 Business Recommendations

Optimize high-performing Paid traffic campaigns.

Focus on VIP retention strategies.

Improve mobile and session engagement experience.

Enhance payment flow for top-performing methods.

Conduct further testing before rolling out experimental changes.

🚀 Skills Demonstrated

Data Cleaning & Validation (Excel)

Statistical Hypothesis Testing (Python)

Data Modeling & Normalization (SQL)

Business Query Writing

Funnel Analytics

Snowflake Schema Design

Dashboard Development (Power BI)

Insight Communication & Business Storytelling

📁 Repository Structure Suggestion
📂 User-Behaviour-Conversion-Intelligence
 ├── 📁 Excel
 ├── 📁 Python_EDA_Statistics
 ├── 📁 SQL_Modeling_Queries
 ├── 📁 PowerBI_Dashboard
 ├── dataset.csv
 └── README.md

 gamma presentation video : "C:\Users\b aiesha\Downloads\User-Behaviour-and-Conversion-Intelligence.pptx"

🎯 Final Conclusion

This project demonstrates the ability to move from raw data exploration to statistical validation, structured database modeling, and executive-level dashboard reporting.

It reflects practical, business-focused analytical capability suitable for Data Analyst roles.
