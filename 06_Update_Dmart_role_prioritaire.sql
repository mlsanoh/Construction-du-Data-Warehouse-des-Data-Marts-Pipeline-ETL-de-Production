-- Etapes 6: Data Mart - Mise à jour data mart sur les de rôles prioritaires

-- Mise à jour
 UPDATE priority_mart.priority_roles
 SET priority_lvl = 1
 WHERE role_name = 'Data Engineer';

-- Insertion 
INSERT INTO priority_mart.priority_roles (role_id, role_name, priority_lvl) 
VALUES 
    (4, 'Data Scientist', 3),
    (5, 'Data Analyst', 4);


MERGE INTO priority_mart.priority_jobs_snapshot AS tgt
USING (
    SELECT 
    jpf.job_id,
    jpf.job_title_short,
    cd.name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    pr.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM job_postings_fact AS jpf 
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles AS pr
ON jpf.job_title_short = pr.role_name
) AS src
ON tgt.job_id = src.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
    UPDATE SET 
        priority_lvl = src.priority_lvl,
        updated_at = src.updated_at

WHEN NOT MATCHED THEN
    INSERT (
        job_id, 
        job_title_short, 
        name, 
        job_posted_date, 
        salary_year_avg, 
        priority_lvl, 
        updated_at
    )      
    VALUES (
        src.job_id, 
        src.job_title_short, 
        src.name, 
        src.job_posted_date, 
        src.salary_year_avg, 
        src.priority_lvl, 
        src.updated_at
    );


-- Validation table priority roles
SELECT 
    job_title_short, priority_lvl, COUNT (*) AS job_count, updated_at
FROM priority_mart.priority_jobs_snapshot
GROUP BY job_title_short, priority_lvl, updated_at
ORDER BY priority_lvl DESC;