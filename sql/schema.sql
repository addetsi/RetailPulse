-- dim_customers - customer_id is the natural key
CREATE TABLE dim_customers (
    customer_id     NVARCHAR(20)    NOT NULL PRIMARY KEY,
    country         NVARCHAR(50)    NOT NULL,
    is_guest        BIT             NOT NULL DEFAULT 0
);

-- dim_products - stock_code is the natural key
CREATE TABLE dim_products (
    stock_code      NVARCHAR(20)    NOT NULL PRIMARY KEY,
    description     NVARCHAR(255)   NULL
);

-- dim_date - date_key is the natural key (YYYYMMDD integer)
CREATE TABLE dim_date (
    date_key        INT             PRIMARY KEY,
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

-- fact_transactions - uses natural keys directly
CREATE TABLE fact_transactions (
    transaction_id  BIGINT IDENTITY(1,1) PRIMARY KEY,
    invoice         NVARCHAR(20)    NOT NULL,
    customer_id     NVARCHAR(20)    NOT NULL,
    stock_code      NVARCHAR(20)    NOT NULL,
    date_key        INT             NOT NULL,
    invoice_date    DATETIME2       NOT NULL,
    quantity        INT             NOT NULL,
    unit_price      DECIMAL(10,2)   NOT NULL,
    total_amount    DECIMAL(10,2)   NOT NULL,
    country         NVARCHAR(50)    NOT NULL
);

-- agg_daily_sales
CREATE TABLE agg_daily_sales (
    agg_id          INT IDENTITY(1,1) PRIMARY KEY,
    date_key        INT             NOT NULL,
    country         NVARCHAR(50)    NOT NULL,
    total_revenue   DECIMAL(12,2)   NOT NULL,
    total_orders    INT             NOT NULL,
    total_quantity  INT             NOT NULL,
    avg_order_value DECIMAL(10,2)   NOT NULL
);

-- agg_customer_metrics - customer_id is the key
CREATE TABLE agg_customer_metrics (
    customer_id         NVARCHAR(20)    NOT NULL PRIMARY KEY,
    total_spent         DECIMAL(12,2)   NOT NULL,
    total_orders        INT             NOT NULL,
    total_items         INT             NOT NULL,
    avg_order_value     DECIMAL(10,2)   NOT NULL,
    first_purchase_date DATE            NOT NULL,
    last_purchase_date  DATE            NOT NULL,
    days_since_last     INT             NOT NULL,
    recency_score       INT             NOT NULL,
    frequency_score     INT             NOT NULL,
    monetary_score      INT             NOT NULL,
    rfm_segment         NVARCHAR(20)    NOT NULL
);

-- indexes
CREATE INDEX ix_fact_date         ON fact_transactions(date_key);
CREATE INDEX ix_fact_customer     ON fact_transactions(customer_id);
CREATE INDEX ix_fact_product      ON fact_transactions(stock_code);
CREATE INDEX ix_fact_invoice      ON fact_transactions(invoice);
CREATE INDEX ix_fact_country      ON fact_transactions(country);
CREATE INDEX ix_agg_daily_date    ON agg_daily_sales(date_key);
CREATE INDEX ix_agg_daily_country ON agg_daily_sales(country);