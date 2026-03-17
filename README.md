# RetailPulse 🛒📊
> Cloud-native Business Intelligence platform for e-commerce analytics, built on Microsoft Azure.

![Azure](https://img.shields.io/badge/Azure-Databricks%20%7C%20SQL%20%7C%20ADF%20%7C%20Blob-0078D4?logo=microsoftazure)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboards-F2C811?logo=powerbi)
![Python](https://img.shields.io/badge/Python-PySpark-3776AB?logo=python)
![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)

---

## Overview

RetailPulse is an end-to-end Azure analytics platform that ingests raw e-commerce transaction data, transforms it through a medallion architecture (Bronze → Silver → Gold), loads it into a star schema data warehouse, and surfaces business insights through interactive Power BI dashboards.

**Dataset:** [UCI Online Retail II](https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci) — ~1 million real UK e-commerce transactions (2009–2011)

---

## Architecture

```
UCI Online Retail II (CSV)
         │
         ▼
┌─────────────────────┐
│  Azure Blob Storage  │  ← Raw data landing zone
│    (raw-data/)       │
└─────────────────────┘
         │
         ▼
┌─────────────────────┐
│ Azure Data Factory   │  ← Pipeline orchestration & scheduling
└─────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│           Azure Databricks               │
│                                          │
│  Bronze  →  Silver  →  Gold             │
│  (raw)     (clean)    (aggregated)      │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│         Azure SQL Database               │
│                                          │
│  fact_transactions   dim_customers       │
│  dim_products        dim_date            │
│  agg_daily_sales     agg_customer_metrics│
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────┐
│      Power BI        │  ← 5 interactive dashboards
└─────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Cloud Platform | Microsoft Azure |
| Data Storage | Azure Blob Storage |
| Data Processing | Azure Databricks (PySpark) |
| Data Warehouse | Azure SQL Database |
| Orchestration | Azure Data Factory |
| Visualisation | Power BI Desktop + Service |
| Language | Python, SQL |
| Version Control | Git + GitHub |

---

## Project Structure

```
retailpulse/
├── notebooks/
│   ├── 01_bronze_data_exploration.py   # Raw data profiling & quality assessment
│   ├── 02_silver_data_cleaning.py      # Cleaning, validation, deduplication
│   ├── 03_gold_dimensions.py           # dim_customers, dim_products, dim_date
│   ├── 04_gold_fact_table.py           # fact_transactions with FK resolution
│   └── 05_gold_aggregations.py         # Daily sales & customer metrics
├── sql/
│   └── schema.sql                      # Star schema DDL + indexes
├── adf/
│   └── pipeline_definition.json        # Data Factory pipeline export
├── docs/
│   └── architecture.png                # Architecture diagram
├── .gitignore
└── README.md
```

---

## Data Model

### Star Schema

```
                    ┌──────────────┐
                    │  dim_date    │
                    └──────┬───────┘
                           │
┌──────────────┐    ┌──────┴────────────┐    ┌──────────────────┐
│ dim_customers │────│ fact_transactions  │────│  dim_products    │
└──────────────┘    └───────────────────┘    └──────────────────┘
```

| Table | Description |
|---|---|
| `fact_transactions` | One row per transaction line item |
| `dim_customers` | Unique customers with country |
| `dim_products` | Unique products with descriptions |
| `dim_date` | Date dimension with year/month/quarter/weekday |
| `agg_daily_sales` | Pre-aggregated daily revenue by country |
| `agg_customer_metrics` | RFM scores and lifetime value per customer |

---

## Dashboards

| # | Dashboard | Key Visuals |
|---|---|---|
| 1 | Sales Overview | Revenue trend, revenue by country (map), top 10 products |
| 2 | Customer Analytics | CLV distribution, RFM segmentation, new vs returning |
| 3 | Product Performance | Best sellers by qty & revenue, declining products |
| 4 | Operational Metrics | Daily order volume, basket size, peak day/hour analysis |
| 5 | Executive Summary | MoM/YoY growth KPIs, top 5 countries, revenue forecast |

---

## Business Questions Answered

1. What is total revenue and how has it trended over time?
2. Which countries generate the most revenue?
3. Who are the top 10 customers by total spending?
4. What are the best-selling products by quantity and revenue?
5. What is the average order value and how does it vary by country?
6. What is the customer retention rate (repeat purchase %)?
7. What days/times see the highest order volumes?
8. Which products have declining sales trends?
9. What is customer lifetime value distribution?
10. What is month-over-month revenue growth?

---

## Setup & Reproduction

### Prerequisites

- Azure subscription (free tier sufficient)
- Power BI Desktop (free)
- Python 3.8+
- Databricks CLI

### 1. Clone the repo

```bash
git clone https://github.com/addetsi/RetailPulse.git
cd retailpulse
```

### 2. Provision Azure Resources

In the Azure Portal, inside a Resource Group (`retailpulse-rg`, region: West Europe):

- Azure Blob Storage — Standard, LRS
- Azure Databricks — Standard tier
- Azure SQL Database — Basic tier (5 DTU)
- Azure Data Factory

### 3. Upload Dataset

Download the [UCI Online Retail II dataset](https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci) and upload to your Blob Storage container `raw-data/`.

### 4. Configure Secrets

Store credentials in Databricks Secret Scope — never hardcode keys:

```bash
databricks secrets create-scope --scope retailpulse-scope
databricks secrets put --scope retailpulse-scope --key storage-account-key
databricks secrets put --scope retailpulse-scope --key sql-connection-string
```

### 5. Run Notebooks in Order

Execute notebooks `01` through `05` in sequence via Databricks or trigger the Data Factory pipeline.

### 6. Connect Power BI

Open Power BI Desktop → Get Data → Azure SQL Database → connect using your server and database credentials → load the dashboards.

---

## Cost Management

This project is designed to run under **$20/month** on Azure:

- SQL Database: Basic tier (~$5/month)
- Databricks: Single-node cluster, auto-terminates after 30 min idle
- Blob Storage: < $1/month for ~50MB dataset
- Data Factory: Pay-per-run (minimal cost for dev usage)

> ⚠️ Always terminate your Databricks cluster when not in use.

---

## Dataset

| Field | Detail |
|---|---|
| Source | UCI Machine Learning Repository via Kaggle |
| Records | ~1,067,371 transactions |
| Period | December 2009 – December 2011 |
| Columns | Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer ID, Country |
| Known Issues | ~25% missing Customer IDs, cancelled invoices (prefix 'C'), negative quantities (returns) |

---

## Status

- [x] Azure environment setup
- [x] Dataset uploaded to Blob Storage
- [x] Databricks workspace + secure secret scope
- [x] GitHub integration via Databricks Repos
- [ ] Bronze layer exploration
- [ ] Silver layer cleaning
- [ ] Gold layer transformations
- [ ] Azure SQL star schema
- [ ] Data Factory pipeline
- [ ] Power BI dashboards
- [ ] Final documentation + architecture diagram

---


