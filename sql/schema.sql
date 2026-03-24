-- ============================================================
-- RetailPulse - Star Schema DDL
-- Azure SQL Database
-- ============================================================

-- ── DIMENSION: Customers ────────────────────────────────────
CREATE TABLE dim_customers (
    customer_key    INT IDENTITY(1,1) PRIMARY KEY,
    customer_id     NVARCHAR(20)    NOT NULL,
    country         NVARCHAR(50)    NOT NULL,
    is_guest        BIT             NOT NULL DEFAULT 0,
    CONSTRAINT uq_customer_id UNIQUE (customer_id)
);

-- ── DIMENSION: Products ─────────────────────────────────────
CREATE TABLE dim_products (
    product_key     INT IDENTITY(1,1) PRIMARY KEY,
    stock_code      NVARCHAR(20)    NOT NULL,
    description     NVARCHAR(255)   NULL,
    CONSTRAINT uq_stock_code UNIQUE (stock_code)
);

-- ── DIMENSION: Date ─────────────────────────────────────────
CREATE TABLE dim_date (
    date_key        INT             PRIMARY KEY,  -- format: YYYYMMDD
    full_date       DATE            NOT NULL,
    year            INT             NOT NULL,
    quarter         INT             NOT NULL,
    month           INT             NOT NULL,
    month_name      NVARCHAR(10)    NOT NULL,
    week            INT             NOT NULL,
    day_of_month    INT             NOT NULL,
    day_of_week     INT             NOT NULL,
    day_name        NVARCHAR(10)    NOT NULL,
    is_weekend      BIT             NOT NULL
);

-- ── FACT: Transactions ──────────────────────────────────────
CREATE TABLE fact_transactions (
    transaction_id  BIGINT IDENTITY(1,1) PRIMARY KEY,
    invoice         NVARCHAR(20)    NOT NULL,
    customer_key    INT             NOT NULL,
    product_key     INT             NOT NULL,
    date_key        INT             NOT NULL,
    invoice_date    DATETIME2       NOT NULL,
    quantity        INT             NOT NULL,
    unit_price      DECIMAL(10,2)   NOT NULL,
    total_amount    DECIMAL(10,2)   NOT NULL,
    country         NVARCHAR(50)    NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (customer_key) REFERENCES dim_customers(customer_key),
    CONSTRAINT fk_product  FOREIGN KEY (product_key)  REFERENCES dim_products(product_key),
    CONSTRAINT fk_date     FOREIGN KEY (date_key)     REFERENCES dim_date(date_key)
);

-- ── AGGREGATE: Daily Sales ──────────────────────────────────
CREATE TABLE agg_daily_sales (
    agg_id          INT IDENTITY(1,1) PRIMARY KEY,
    date_key        INT             NOT NULL,
    country         NVARCHAR(50)    NOT NULL,
    total_revenue   DECIMAL(12,2)   NOT NULL,
    total_orders    INT             NOT NULL,
    total_quantity  INT             NOT NULL,
    avg_order_value DECIMAL(10,2)   NOT NULL
);

-- ── AGGREGATE: Customer Metrics ─────────────────────────────
CREATE TABLE agg_customer_metrics (
    customer_key        INT             PRIMARY KEY,
    total_spent         DECIMAL(12,2)   NOT NULL,
    total_orders        INT             NOT NULL,
    total_items         INT             NOT NULL,
    avg_order_value     DECIMAL(10,2)   NOT NULL,
    first_purchase_date DATE            NOT NULL,
    last_purchase_date  DATE            NOT NULL,
    days_since_last     INT             NOT NULL,
    recency_score       INT             NOT NULL,  -- 1-5 RFM score
    frequency_score     INT             NOT NULL,
    monetary_score      INT             NOT NULL,
    rfm_segment         NVARCHAR(20)    NOT NULL
);

-- ── INDEXES ─────────────────────────────────────────────────
-- Fact table - most queried columns
CREATE INDEX ix_fact_date        ON fact_transactions(date_key);
CREATE INDEX ix_fact_customer    ON fact_transactions(customer_key);
CREATE INDEX ix_fact_product     ON fact_transactions(product_key);
CREATE INDEX ix_fact_invoice     ON fact_transactions(invoice);
CREATE INDEX ix_fact_country     ON fact_transactions(country);

-- Aggregates
CREATE INDEX ix_agg_daily_date    ON agg_daily_sales(date_key);
CREATE INDEX ix_agg_daily_country ON agg_daily_sales(country);