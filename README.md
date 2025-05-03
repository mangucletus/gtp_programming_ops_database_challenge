# gtp_programming_ops_database_challenge

## 🔐 IAM Automation with Bash on Linux

## 🧪 LAB OVERVIEW

This lab demonstrates how to **automate Identity and Access Management (IAM)** tasks on a Linux system using a Bash script. The lab simulates a real-world system administrator task of provisioning multiple users and groups with strong security practices.

### 🎯 Objectives

- Automate creation of users and groups from a CSV file.
- Assign full names and group memberships.
- Apply password policies and enforce password reset on first login.
- Secure home directories with strict permissions.
- Log all actions to a file.
- (Optional) Send user email notifications and enforce password complexity rules.
- Package the lab with screenshots, comments, and documentation for grading and review.

---

## 🖥️ ENVIRONMENT DETAILS

- **Operating System**: Ubuntu 22.04 LTS (or any modern Debian-based Linux)
- **Execution Mode**: Root or sudo privileges required
- **Tools Used**:
  - `bash` (scripting)
  - `useradd`, `groupadd`, `chage`, `passwd`, `chmod`, `mail`
  - `mailutils` for email (optional)

---

## 🗃️ INPUT FILE FORMAT (`users.txt`)

The script expects a `.csv` file (named `users.txt` or custom) with the following format:
  - username,fullname,group


This format ensures automation is done without user input during execution.

---

## 🧾 SCRIPT EXPLANATION (`iam_setup.sh`)

### Key Functionalities:

| Functionality              | Description |
|---------------------------|-------------|
| Group creation            | Creates group if it doesn’t exist |
| User creation             | Adds user with home directory and full name |
| Group assignment          | Assigns users to specified groups |
| Password setup            | Sets a temporary password (`ChangeMe123`) |
| Password policy           | Checks for complexity and enforces reset |
| Permission settings       | Home directories set to `chmod 700` |
| Logging                   | All actions written to `iam_setup.log` |
| CSV input support         | Accepts CSV file as command-line argument |
| Email notification (opt.) | Sends email to user after creation (if `mailutils` installed) |

---

## 📝 RUNNING THE SCRIPT

### ✅ 1. Make Script Executable

```bash
chmod +x iam_setup.sh

2. Install Optional Mail Dependency
  - sudo apt update
  - sudo apt install mailutils -y

3. Execute the Script
  - sudo ./iam_setup.sh users.txt


