Welcome to your new dbt project!

# Data Engineering Workspace Setup & Runbook

This document details the configuration layout of our local data modeling environment on Windows 11 and outlines the operations workflow required to spin up the stack after a system reboot.

## Part 1: Environment Architecture (What We Built)

Our environment isolates data storage, application dependencies, and analytics logic to bypass global Windows permission restrictions.

### 1. Database Layer (Docker Container)
* Engine: PostgreSQL (Latest stable official image).
* Isolation: Hosted inside an isolated Docker container (`dbt-postgres-container`).
* Port Mapping: Exposes internal port 5432 to host loopback `localhost:5432`.
* Database Name: `wave`
* Default Superuser: `postgres`

### 2. Application Layer (Python Virtual Environment)
* Framework: Python 3.13 Virtual Environment (`dbt-env`).
* Scope: Localizes the execution paths for libraries so they do not conflict with system paths.
* Core Engine: `dbt-core==1.8.2` (Locked to the stable Python-native execution engine to bypass v2.0-alpha Rust Fusion requirements).
* Adapter Plugin: `dbt-postgres==1.8.2`

### 3. Analytics Layer (dbt Project Architecture)
* Global Profiles Folder: `C:\Users\mahna\.dbt\`
* Profile Credentials Mapping (`profiles.yml`): Implements strict schema name binding mapping directly to your specific custom project name token.

---

## Part 2: Daily Operations Runbook (Reboot Recovery)

Whenever you restart your Windows 11 laptop, follow these 3 quick steps in order to wake up your database, activate your programming sandbox, and start writing code.

### Step 1: Wake Up the Database
Your Docker container stays asleep after a Windows reboot. Let's turn it back on.
1. Press the Windows Key, type Docker Desktop, and press Enter.
2. Wait 30 seconds for the bottom-left corner of Docker Desktop to turn Green ("Engine Running").
3. Open your Terminal and wake up your database container:
   `docker start wave-postgres-container`

### Step 2: Step Into Your Sandbox Workspace
Windows needs to step into the virtual environment to unlock access to the local `dbt` installation package.
1. In your terminal, navigate to your root project development space:
   `cd C:\mahnaz\Study_notes\Wave-assessment-data-modeling\dbt_project`
2. Run the activation script:
   `.\dbt-env\Scripts\Activate.ps1`
* Verify: Look for the `(dbt-env)` text block at the start of your terminal command prompt line.

### Step 3: Jump into the Project and Test
1. Move inside your specific dbt code repository folder:
   `cd wave_dbt_prj`
2. Verify the underlying network pipes and configuration metrics are alive:
   `dbt debug`

---

## Useful Maintenance Commands

* To see active tables and models running in Docker: `docker ps`
* To check database processing logs or execution errors: `docker logs dbt-postgres-container`
* To shut down the database without deleting data: `docker stop dbt-postgres-container`
* To deactivate the Python sandbox session when you are finished working: `deactivate`


### Using the starter project

Try running the following commands:
- `dbt run`
- `dbt test`


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
