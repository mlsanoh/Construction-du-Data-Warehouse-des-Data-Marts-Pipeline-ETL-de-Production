-- Etape 5: Data Mart - Création de data mart sur les de rôles prioritaires

DROP SCHEMA IF EXISTS priority_mart CASCADE;

CREATE SCHEMA priority_mart;

-- Création table priority_roles
CREATE TABLE priority_mart.priority_roles (
    role_id         INTEGER     PRIMARY KEY,
    role_name       VARCHAR,
    priority_lvl    VARCHAR
);

INSERT INTO priority_mart.priority_roles (role_id, role_name, priority_lvl) 
VALUES 
    (1, 'Data Engineer', 2),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3);

SELECT * FROM priority_mart.priority_roles;

-- Création table priority_jobs_snapshot

CREATE TABLE priority_mart.priority_jobs_snapshot (
    job_id              INTEGER     PRIMARY KEY,
    job_title_short     VARCHAR,
    name                VARCHAR,
    job_posted_date     TIMESTAMP,
    salary_year_avg     DOUBLE,
    priority_lvl        INTEGER,
    updated_at          TIMESTAMP
);

INSERT INTO priority_mart.priority_jobs_snapshot (
   job_id, job_title_short, name, job_posted_date, salary_year_avg, priority_lvl, updated_at
)
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    cd.name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    pr.priority_lvl,
    CURRENT_TIMESTAMP
FROM job_postings_fact AS jpf 
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles AS pr
ON jpf.job_title_short = pr.role_name;


-- Validation table priority roles
SELECT 
    job_title_short, priority_lvl, updated_at,
    COUNT (*) AS job_count
FROM priority_mart.priority_jobs_snapshot
GROUP BY ALL;


