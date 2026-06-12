# Daily Operations Runbook: Wave Data Engineering Workspace

Follow these **3 quick steps** whenever you restart your Windows 11 laptop to wake up your database container, activate your development sandbox, and verify your data pipelines.

---

## Step 1: Wake Up the Database Container
Your Docker container does not run automatically after a Windows reboot. 
1. Press the **Windows Key**, type **Docker Desktop**, and press **Enter**.
2. Wait roughly 30 seconds for the engine icon in the bottom-left corner to turn **Green** ("Engine Running").
3. Open your Windows Terminal and start your database container:
   ```powershell
   docker start wave-postgres-container
   ```

---

## Step 2: Activate Your Local Python Sandbox
To bypass Windows global path restrictions, you must step into your isolated virtual environment workspace before running any dbt commands.
1. Navigate to your root directory:
   ```powershell
   cd C:\mahnaz\Study_notes\Wave-assessment-data-modeling\dbt_project
   ```
2. Execute the environment activation script:
   ```powershell
   .\dbt-env\Scripts\Activate.ps1
   ```
* **Verification Check:** Ensure that the **`(dbt-env)`** prefix token is visibly prepended to your active terminal command line prompt.

---

## Step 3: Jump into the Project and Test Pipes
1. Step into your active dbt code repository subdirectory:
   ```powershell
   cd wave_dbt_prj
   ```
2. Execute the core system connection diagnostic test:
   ```powershell
   dbt debug
   ```
* **Success State:** The terminal must output a green **"All checks passed!"** message, confirming dbt is actively communicating with the PostgreSQL database.

---

## Core Maintenance Cheat-Sheet

* **Compile Code Changes Safely (No Database Writes):**
  ```powershell
  dbt compile
  ```
* **Ingest and Update Static CSV Files (Seeds):**
  ```powershell
  dbt seed
  ```
* **Run and Materialize All SQL Models:**
  ```powershell
  dbt run
  ```
* **Log Directly into the Database via Command Line (psql):**
  ```powershell
  docker exec -it wave-postgres-container psql -U postgres -d wave
  ```
* **Check Live Database Engine Processing Logs:**
  ```powershell
  docker logs wave-postgres-container
  ```
* **Deactivate Sandbox When Finished Working:**
  ```powershell
  deactivate
  ```
