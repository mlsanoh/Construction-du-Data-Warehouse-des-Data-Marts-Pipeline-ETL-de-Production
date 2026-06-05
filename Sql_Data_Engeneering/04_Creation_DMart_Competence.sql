-- Etape 4: Data Mart - Création de data mart sur la demande de comptence
  
DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA skills_mart;

-- Création table dim_skill

CREATE TABLE skills_mart.dim_skill (
    skill_id    INTEGER     PRIMARY KEY,
    skills      VARCHAR,
    type        VARCHAR
);

INSERT INTO skills_mart.dim_skill ( skill_id, skills, type) 
SELECT 
    skill_id, 
    skills,
    type
FROM skills_dim;

-- Validation table dim_skill

SELECT *
FROM skills_mart.dim_skill
LIMIT 5;

-- Création table dim_date_month
CREATE TABLE skills_mart.dim_date_month (
    month_start_date    DATE    PRIMARY KEY,
    year                INTEGER,
    month               INTEGER,
    quarter             INTEGER,
    quarter_name        VARCHAR,
    year_quarter        VARCHAR
);

INSERT INTO skills_mart.dim_date_month (month_start_date, year, month, quarter, quarter_name, year_quarter)
SELECT DISTINCT
    DATE_TRUNC ('month', job_posted_date) AS month_start_date,
    EXTRACT (YEAR FROM job_posted_date) AS year,
    EXTRACT (MONTH FROM job_posted_date) AS month,
    EXTRACT (QUARTER FROM job_posted_date) AS quarter,
    CONCAT ('Q', '-', EXTRACT (QUARTER FROM job_posted_date)) AS quarter_name,
    CONCAT (EXTRACT (YEAR FROM job_posted_date), '-Q', EXTRACT (QUARTER FROM job_posted_date)) AS year_quarter
FROM job_postings_fact;

-- Validation table dim_date_month
SELECT *
FROM skills_mart.dim_date_month
LIMIT 5;

-- Création table fact_skill_demand_monthly

CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id                            INTEGER,     
    month_start_date                    DATE,
    job_title_short                     VARCHAR,
    postings_count                      INTEGER,
    health_insurance_postings_count     INTEGER,
    remote_postings_count               INTEGER,
    no_degree_mention_count             INTEGER,
    PRIMARY KEY ( skill_id, month_start_date,job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skill(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
);

INSERT INTO skills_mart.fact_skill_demand_monthly (
    skill_id   ,     
    month_start_date,                    
    job_title_short,                     
    postings_count,                      
    health_insurance_postings_count,   
    remote_postings_count,
    no_degree_mention_count
)
WITH job_postings_monthy_prep AS (
SELECT
    sjd.skill_id,
    DATE (DATE_TRUNC ('month', jpf.job_posted_date)) AS month_start_date,
    jpf.job_title_short,
    CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS health_insurance_postings,
    CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS remote_postings,
    CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mention,
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd 
    ON jpf.job_id = sjd.job_id
)

SELECT 
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS postings_count,
    SUM(health_insurance_postings) AS health_insurance_postings_count,
    SUM(remote_postings) AS remote_postings_count,
    SUM(no_degree_mention) AS no_degree_mention_count
FROM job_postings_monthy_prep
GROUP BY ALL;

-- Validation table fact_skill_demand_monthly
SELECT *
FROM skills_mart.fact_skill_demand_monthly
LIMIT 5;