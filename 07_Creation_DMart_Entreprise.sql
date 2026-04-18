-- Etape 7: Data Mart - Création de data mart sur les Entreprises
DROP SCHEMA IF EXISTS company_mart CASCADE;

CREATE SCHEMA company_mart;

SELECT '=== Création table dim_job_title_short ===' AS info;

-- Création table dim_job_title_short
CREATE TABLE company_mart.dim_job_title_short (
    job_title_short_id      INTEGER     PRIMARY KEY,
    job_title_short         VARCHAR
);

INSERT INTO company_mart.dim_job_title_short (job_title_short_id, job_title_short)
SELECT DISTINCT
    DENSE_RANK() OVER(ORDER BY job_title_short) AS job_title_short_id, 
    job_title_short
FROM job_postings_fact
WHERE job_title_short IS NOT NULL;

-- Validation de donnée dim_job_title_short
SELECT *
FROM company_mart.dim_job_title_short
ORDER BY job_title_short_id ASC;

SELECT '=== Création table dim_job_title ===' AS info;

-- Création table dim_job_title
CREATE TABLE company_mart.dim_job_title (
    job_title_id        INTEGER     PRIMARY KEY,
    job_title           VARCHAR
);
INSERT INTO company_mart.dim_job_title(job_title_id, job_title)
SELECT DISTINCT
    DENSE_RANK() OVER(ORDER BY job_title) AS job_title_id,
    job_title
FROM job_postings_fact
WHERE job_title IS NOT NULL;

-- Validation de donnée dim_job_title_short
SELECT *
FROM company_mart.dim_job_title
ORDER BY job_title ASC;

SELECT '=== Création table bridge_job_title ===' AS info;

-- Création table bridge_job_title
CREATE TABLE company_mart.bridge_job_title (
   job_title_short_id   INTEGER,
   job_title_id         INTEGER,
   PRIMARY KEY (job_title_short_id, job_title_id),
   FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
   FOREIGN KEY (job_title_id) REFERENCES company_mart.dim_job_title(job_title_id)
);
INSERT INTO company_mart.bridge_job_title (job_title_short_id, job_title_id) 
SELECT DISTINCT
jts.job_title_short_id,
jt.job_title_id 
FROM job_postings_fact AS jpf 
INNER JOIN company_mart.dim_job_title_short AS jts
    ON jpf.job_title_short = jts.job_title_short
INNER JOIN company_mart.dim_job_title AS jt
    ON jpf.job_title = jt.job_title
WHERE jts.job_title_short IS NOT NULL 
    AND
    jt.job_title IS NOT NULL;

-- Validation de donnée dim_job_title_short
SELECT *
FROM company_mart.bridge_job_title;

SELECT '=== Création table dim_company ===' AS info;

-- Création table dim_company
CREATE TABLE company_mart.dim_company(
    company_id      INTEGER     PRIMARY KEY,
    name            VARCHAR
);

INSERT INTO company_mart.dim_company (company_id, name)
SELECT DISTINCT company_id, name
FROM company_dim; 

-- Validation de donnée dim_job_title_short
SELECT *
FROM company_mart.dim_company;

SELECT '=== Création table dim_location ===' AS info;

-- Création table dim_location
CREATE TABLE company_mart.dim_location (
    location_id     INTEGER     PRIMARY KEY,
    job_country     VARCHAR,
    job_location    VARCHAR
);

INSERT INTO company_mart.dim_location (location_id, job_country, job_location)
 SELECT DISTINCT
    DENSE_RANK() OVER(ORDER BY job_location, job_country) AS location_id,
    job_country,
    job_location
FROM job_postings_fact
WHERE job_location IS NOT NULL;

-- Validation de donnée dim_job_title_short
SELECT *
FROM company_mart.dim_location;


SELECT '=== Création table bridge_company_location ===' AS info;

-- Création table bridge_company_location
CREATE TABLE company_mart.bridge_company_location (
    company_id      INTEGER,
    location_id     INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_mart.dim_location(location_id)
);

INSERT INTO company_mart.bridge_company_location (company_id, location_id)
SELECT DISTINCT dc.company_id, dl.location_id
FROM job_postings_fact AS jpf
INNER JOIN company_mart.dim_company AS dc
    ON jpf.company_id = dc.company_id
INNER JOIN company_mart.dim_location AS dl
    ON jpf.job_location = dl.job_location
WHERE dc.company_id IS NOT NULL 
    AND
    dl.location_id IS NOT NULL;

-- Validation de donnée dim_job_title_short
SELECT *
FROM company_mart.bridge_company_location;

SELECT '=== Création table dim_date_month ===' AS info;

-- Création table dim_date_month
CREATE TABLE company_mart.dim_date_month (
    month_start_date        DATE    PRIMARY KEY,
    year                    INTEGER,
    month                   INTEGER
);

INSERT INTO company_mart.dim_date_month (month_start_date, year, month)
SELECT DISTINCT 
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT (YEAR FROM job_posted_date) AS year,
    EXTRACT (MONTH FROM job_posted_date) AS month
FROM job_postings_fact;

-- Validation de donnée dim_job_title_short
SELECT *
FROM company_mart.dim_date_month;

SELECT '=== Création fact_company_hiring_monthly ===' AS info;

-- Création table fact_company_hiring_monthly
CREATE TABLE company_mart.fact_company_hiring_monthly (
    company_id                  INTEGER,
    job_title_short_id          INTEGER,
    month_start_date            DATE,
    job_country                 VARCHAR,
    postings_count              INTEGER,
    median_salary_year          DOUBLE,
    min_salary_year             DOUBLE,
    max_salary_year             DOUBLE,
    remote_share                DOUBLE,
    health_insurance_share      DOUBLE,
    no_degree_mention_share     DOUBLE,
    PRIMARY KEY (company_id, job_title_short_id, month_start_date, job_country),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (month_start_date) REFERENCES company_mart.dim_date_month(month_start_date)

);

INSERT INTO company_mart.fact_company_hiring_monthly (
     company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    postings_count,
    median_salary_year,
    min_salary_year,
    max_salary_year,
    remote_share,
    health_insurance_share,
    no_degree_mention_share
)
WITH fact_company_monthly_pre AS (
SELECT
    dc.company_id,
    jts.job_title_short_id,
    DATE_TRUNC('month', jpf.job_posted_date) AS month_start_date,
    jpf.job_country, 
    jpf.salary_year_avg,
    CASE WHEN job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
    CASE WHEN job_health_insurance = TRUE THEN 1 ELSE 0 END AS health_insurance,
    CASE WHEN job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mention
FROM job_postings_fact AS jpf
INNER JOIN company_mart.dim_company AS dc
    ON jpf.company_id = dc.company_id
INNER JOIN company_mart.dim_job_title_short AS jts
    ON jpf.job_title_short = jts.job_title_short
WHERE jpf.job_country IS NOT NULL
)
SELECT company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    COUNT(*) AS postings_count,
    MEDIAN(salary_year_avg) AS median_salary_year,
    MIN(salary_year_avg) AS min_salary_year,
    MAX(salary_year_avg) AS max_salary_year,
    AVG(is_remote) AS remote_share,
    AVG(health_insurance) AS health_insurance_share,
    AVG(no_degree_mention) AS no_degree_mention_share
FROM fact_company_monthly_pre,
GROUP BY company_id, job_title_short_id, month_start_date, job_country;

-- Validation de donnée dim_job_title_short
SELECT *
FROM company_mart.fact_company_hiring_monthly;
