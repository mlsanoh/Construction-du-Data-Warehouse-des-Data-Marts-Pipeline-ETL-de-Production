--Etape 3: Data Mart - Création table de données denormalisées
DROP SCHEMA IF EXISTS flat_data_Mart CASCADE;

CREATE SCHEMA flat_data_Mart;

CREATE OR REPLACE TABLE flat_dm_job_postings AS
SELECT 
    jpf.job_id,
    jpf.company_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name,
    STRUCT_PACK (sd.skills, sd.type) AS skills_and_type
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
LEFT JOIN skills_job_dim  AS sjd 
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id;

-- Validation de données

SELECT COUNT(*) FROM flat_dm_job_postings;

SELECT job_title_short, COUNT(*)
FROM flat_dm_job_postings
GROUP BY job_title_short;