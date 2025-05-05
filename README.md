# Programming, Ops, and Database Challenge

Welcome to my portfolio repository containing two hands-on technical projects that demonstrate practical skills in **Linux Automation**, **Cloud Databases**, and **API development** using **Flask** and **FastAPI**.

Each project is organized in its own folder, complete with documentation, code, and supporting assets.

---

## 1. Bash Scripting Challenge Lab

A Linux-based automation project to manage **IAM user accounts** using a custom Bash script.

### Key Features

- Automates creation of IAM users in a Linux environment.
- Reads user data from a `.csv` or a `.txt` file.
- Enforces password complexity and optional email notifications.
- Fully documented with LaTeX, screenshots, and inline comments.

### Folder: `bash-scripting-challenge-lab`

- `iam_setup.sh` — Main Bash script.
- `iam_setup.log` — Collect all logs when iam_setup.sh is executed.
- `users.txt` — Input file with user information.
- `documentation.pdf` — Contains LaTeX-written technical documentation.
- `screenshots/` — Visual proof of execution.
- [View README for Bash Lab ➜](./bash_scripting_challenge_lab/README.md)

---

## 2. Database Exercise with AWS RDS + APIs

This project demonstrates the deployment of a **MySQL database on Amazon RDS**, running analytical SQL queries, and exposing the results via two different Python APIs.

### Tools & Frameworks

- **AWS RDS** (MySQL)
- **SQL**
- **Flask** (REST API)
- **FastAPI** (Modern async API)
- **Postman** (API Testing)

### What It Covers

- Creating and connecting to an AWS RDS MySQL instance.
- Designing a sample schema and inserting test data.
- Writing analytical queries for insights.
- Building two separate APIs (Flask & FastAPI) to serve results.
- Postman documentation and test collections.

### Folder: `database-exercise`

- `create_orderdb_tables.sql`, `queries.sql` — Database setup scripts.
- `flask_api/`, `fastapi_api/` — Python-based APIs.
- `postman_collection.json` — Test collection.
- `screenshots/` — Execution proof and API results.
- [View README for Database Exercise ➜](./database_exercise/README.md)

---

## How to Use This Repository

 **Clone the repo**  
   ```bash
   git clone https://github.com/mangucletus/gtp_programming_ops_database_challenge.git
   cd gtp_programming_ops_database_challenge
   ```



