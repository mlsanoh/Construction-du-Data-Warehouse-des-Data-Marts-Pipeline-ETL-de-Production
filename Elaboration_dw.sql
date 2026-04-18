-- duckdb dw_marts.duckdb -c ".read Elaboration_dw.sql"

-- Etape 1: Data Warehouse - Création des tables de schéma étoile
.read 01_Creation_Tables_dw.sql

-- Etape 2: Data Warehouse - Chargée nos données CSV dans les tables
.read 02_Insertion_donnees_dw.sql

--Etape 3: Data Mart - Création table de données denormalisées
.read 03_Flat_Data_Mart.sql

-- Etape 4: Data Mart - Création de data mart sur la demande de comptence
.read 04_Creation_DMart_Competence.sql

-- Etape 5: Data Mart - Création de data mart sur les de rôles prioritaires
.read 05_Creation_DMart_role_prioritaire.sql

-- Etapes 6: Data Mart - Mise à jour data mart sur les de rôles prioritaires
.read 06_Update_Dmart_role_prioritaire.sql