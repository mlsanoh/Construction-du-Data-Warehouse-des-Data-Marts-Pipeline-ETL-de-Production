# 🏗️ Construction du Data Warehouse & des Data Marts : Pipeline ETL de Production

Un pipeline d'ingénierie des données de bout en bout qui transforme des fichiers CSV bruts provenant de Google Cloud Storage en un entrepôt de données (Data Warehouse) normalisé en schéma en étoile, puis construit des magasins de données (Data Marts) analytiques.

![Architecture du Pipeline](Image/Project2_Data_Pipeline.png)

## 🧾 Résumé Exécutif (Pour les recruteurs)
- ✅ **Portée du pipeline** : Construction d'un pipeline ETL complet, du CSV brut au schéma en étoile, jusqu'aux data marts analytiques.

- ✅ **Modélisation des données** : Conception d'un schéma en étoile avec tables de faits, dimensions et tables de liaison (bridge tables) pour les relations plusieurs-à-plusieurs.

- ✅ **Développement ETL** : Mise en œuvre de processus Extract, Transform, Load avec des opérations idempotentes et des contrôles de qualité des données.

- ✅ **Architecture des Marts** : Création de data marts spécialisés (flat, compétences, priorité) avec mesures additives et modèles de mise à jour incrémentielle.

## 🧩 Problématique & Contexte
Les données brutes sur les offres d'emploi arrivent sous forme de fichiers CSV plats dans Google Cloud Storage, ce qui n'est pas structuré pour des requêtes analytiques. Les analystes doivent répondre à :

- Quelles sont les compétences les plus demandées au fil du temps ?

- Quelles sont les tendances de recrutement par entreprise et par lieu ?

- Comment les salaires varient-ils selon le rôle et les compétences ?

**Défi** : Les équipes de données ont besoin d'une source unique de vérité — un Data Warehouse — pour permettre des analyses cohérentes. De plus, des Data Marts spécialisés sont nécessaires pour optimiser les ressources en pré-agrégeant les données pour des cas d'utilisation métier spécifiques.

**Solution** : Un pipeline ETL qui extrait les CSV, les normalise dans un schéma en étoile et crée des data marts optimisés pour des analyses spécifiques (demande de compétences, suivi des rôles prioritaires, etc.).

## 🧰 Stack Technique
- 🐤 Base de données : DuckDB (base OLAP orientée fichier avec intégration GCS via httpfs)

- 🧮 Langage : SQL (DDL pour le schéma, DML pour le chargement et la transformation)

- 📊 Modèle de données : Schéma en étoile (Faits + Dimensions + Tables de liaison)

- 🛠️ Développement : VS Code (édition SQL) + Terminal (CLI DuckDB)

- 🔧 Automatisation : Script SQL maître pour l'orchestration du pipeline

- 📦 Gestion de version : Git/GitHub

- ☁️ Stockage : Google Cloud Storage (fichiers sources)

## 📂 Structure du Répertoire
```Plaintext
Elaboration_dw
├── 01_Creation_Tables_dw.sql           # DDL du schéma en étoile
├── 02_Insertion_donnees_dw.sql         # Extraction GCS & Chargement initial
├── 03_Flat_Data_Mart.sql               # Mart dénormalisé (vue plate)
├── 04_Creation_DMart_Competence.sql    # Mart de la demande de compétences
├── 05_Creation_DMart_role_prioritaire.sql # Mart des rôles prioritaires
├── 06_Update_Dmart_role_prioritaire.sql # Mise à jour incrémentielle (MERGE)
├── 07_Creation_DMart_Entreprise.sql    # Mart du recrutement par entreprise
├── Elaboration_dw.sql                  # Script maître d'orchestration
└── README.md                           # Vous êtes ici
```

# 🏗️ Architecture du Pipeline
![Architecture du Pipeline](Image/Project2_Data_Pipeline.png)

Le pipeline transforme les fichiers CSV d'offres d'emploi provenant de Google Cloud Storage en un entrepôt de données (Data Warehouse) normalisé selon un schéma en étoile, puis construit des magasins de données (Data Marts) analytiques spécialisés. Les outils de BI (Excel, Power BI, Tableau, Python) consomment les données aussi bien à partir de l'entrepôt que des marts.

### Exécution globale
```Bash
duckdb dw_marts.duckdb -c ".read Elaboration_dw.sql"
```
### Data Warehouse
Implémente un schéma en étoile servant de source unique de vérité.

![Schéma du Data Warehouse](Image/Data_Warehouse.png)

- **Fichiers :** [01_Creation_Tables_dw.sql](01_Creation_Tables_dw.sql)  et [02_Insertion_donnees_dw.sql](02_Insertion_donnees_dw.sql).

- **Grain :** Une ligne par offre d'emploi dans la table de faits (``job_postings_fact``).

### Data Marts Spécialisés
**1. Flat Mart** ( [03_Flat_Data_Mart.sql](03_Flat_Data_Mart.sql) ) **:** Table dénormalisée pour les requêtes ad-hoc rapides. 

![Schéma du Flat Mart](Image/Flat_Mart.png)

**2. Skills Mart** ( [04_Creation_DMart_Competence.sql](04_Creation_DMart_Competence.sql) ) **:** Analyse temporelle de la demande de compétences. Grain : ``skill_id + month_start_date + job_title_short``.

![Schéma du Skills Mart](Image/Skills_Mart.png)

**3. Priority Mart**   ( [05_Creation_DMart_role_prioritaire.sql](05_Creation_DMart_role_prioritaire.sql) ) et  ( [06_Update_Dmart_role_prioritaire.sql](06_Update_Dmart_role_prioritaire.sql) )  **:** Suivi des rôles prioritaires. Utilise des opérations MERGE pour démontrer des modèles d'upsert prêts pour la production.

![Schéma du Priority Mart](Image/Priority_Mart.png)

**4. Company Mart**        ( [07_Creation_DMart_Entreprise.sql](07_Creation_DMart_Entreprise.sql) ) **:** Tendances de recrutement par entreprise, lieu et mois.

![Schéma du Company Mart](Image/Company_Mart.png)

## 💻 Compétences en Ingénierie des Données Démontrées

#### Développement de Pipeline ETL
- **Extraction :** Chargement direct depuis GCS via DuckDB ``httpfs``.

- **Transformation :** Normalisation, conversion de types ``(CAST, DATE_TRUNC)`` et filtrage qualité.

- **Chargement :** Création de tables idempotentes avec les patterns ``DROP TABLE IF EXISTS``.

- **Mises à jour incrémentielles :** Opérations MERGE ``(INSERT, UPDATE, DELETE en une instruction)``.

#### Modélisation Dimensionnelle
- **Schéma en Étoile :** Table de faits entourée de tables de dimensions.

- **Tables de Liaison (Bridge) :** Gestion des relations plusieurs-à-plusieurs (compétences-emplois).

- **Mesures Additives :** Comptes et sommes pouvant être ré-agrégés en toute sécurité.

#### Techniques SQL Avancées
- **Opérations DDL/DML :** Gestion rigoureuse des schémas et mappage explicite des colonnes.

- **MERGE :** Utilisation des clauses ``WHEN MATCHED`` et ``WHEN NOT MATCHED`` pour la production.

- **CTEs :** Expressions de table communes pour les transformations complexes.

- **Fonctions Temporelles & Chaînes :** ``DATE_TRUNC``, ``EXTRACT``, ``STRING_AGG``, ``REPLACE``.

- **Logique Booléenne :** Utilisation de ``CASE WHEN`` pour agréger des indicateurs (télétravail, assurance, etc.).

#### Qualité des Données & Pratiques de Production
- **Idempotence :** Tous les scripts sont rejouables sans effets secondaires indésirables.

- **Validation :** Requêtes de vérification à chaque étape du pipeline pour assurer l'intégrité.

- **Sécurité des Types :** Définitions de types de données appropriées (``VARCHAR``, ``INTEGER``, ``BOOLEAN``, etc.).

- **Organisation des Schémas :** Séparation logique des marts (flat, skills, priority, company).