# E-Commerce Returns & Sustainability Analytics

An end-to-end Business Intelligence project analyzing e-commerce sales, product returns, customer behavior, financial impact, and sustainability metrics using PostgreSQL and Tableau Public.

## Project Overview

The project aims to identify patterns in e-commerce returns, understand sales performance, evaluate return-related costs, and provide actionable business recommendations through SQL analysis and interactive visualization.

## Business Objectives

- Analyze sales and order performance.
- Identify product categories with high return rates.
- Understand the major reasons behind product returns.
- Evaluate the financial impact of returns.
- Analyze monthly sales trends.
- Compare environmental metrics across product categories.

## Technology Stack

| Tool | Purpose |
|---|---|
| PostgreSQL | Data validation and business analysis |
| Tableau Public | Interactive dashboard and visualization |

## Dataset Overview

- Original records: 5,000
- Analyzed records: 4,986
- Analysis period: January 2022 – August 2025
- Excluded records: 14 incomplete September 2025 orders
- Dataset source: [Insert original dataset link]

## Dashboard Preview

**Tableau Public Dashboard:** (https://public.tableau.com/views/E-CommerceReturnsSustainabilityAnalyticsBusinessIntelligenceDashboard/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

## Key Findings

- Clothing recorded the highest category return rate at approximately 37.3%.
- Defective products were the most frequent return reason, with 382 orders.
- Changed Mind accounted for 379 returns.
- Wrong Item accounted for 348 returns.
- The project evaluates return-related financial costs and category-level environmental metrics.

## Project Structure

```text
E-Commerce-Returns-Analytics/
│
├── data/
├── sql/
│   └── ecommerce_analysis.sql
│
├── tableau/
│   ├── Ecommerce_Returns_Business_Intelligence.twbx
│   └── screenshots/
│
├── documentation/
│   ├── data_dictionary.md
│   ├── business_insights.md
│   └── business_recommendations.md
│
└── README.md
```

## SQL Analysis

The PostgreSQL analysis covers:
- Data quality validation
- Sales performance
- Product return analysis
- Customer behavior
- Financial impact
- Business insights

## Business Recommendations

1. Improve clothing sizing information and product quality.
2. Strengthen supplier and product quality control.
3. Improve product listing accuracy and order verification.
4. Monitor return-related financial costs.
5. Track environmental impact and packaging efficiency.

See [Business Recommendations](documentation/business_recommendations.md).

## Conclusion
This project demonstrates practival sql and tableau-to-end business intelligence workflow, transforming e-commerce data into actionable insights for business decision-making.