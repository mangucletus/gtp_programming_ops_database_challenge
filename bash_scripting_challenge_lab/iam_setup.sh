#!/bin/bash

# IAM Setup Script
# Author: Cletus Nehinlalei Mangu
# Date: 2025-05-03
# Description: This script automates IAM user/group creation with logging, password policy, and email notification

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE="$SCRIPT_DIR/iam_setup.log"
TEMP_PASSWORD="ChangeMe123"

# Function to log messages with timestamp
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root."
    exit 1
fi

# Check for input file argument
if [[ -z "$1" ]]; then
    echo "Usage: $0 <users.csv or users.txt>"
    exit 1
fi

CSV_FILE="$1"

# Check file existence
if [[ ! -f "$CSV_FILE" ]]; then
    echo "Error: File '$CSV_FILE' not found."
    exit 1
fi

# Validate file format (must contain commas)
if ! grep -q ',' "$CSV_FILE"; then
    echo "Error: File '$CSV_FILE' does not appear to be in CSV format."
    exit 1
fi

# Optional: Normalize line endings (handles files edited on Windows)
dos2unix "$CSV_FILE" 2>/dev/null

# Check if mail command exists
if ! command -v mail &> /dev/null; then
    log_action " 'mail' command not found. Email notifications will be skipped."
    MAIL_ENABLED=false
else
    MAIL_ENABLED=true
fi

# Function to check password complexity
check_password_complexity() {
    local password="$1"
    if [[ ${#password} -lt 8 ]]; then return 1; fi
    [[ "$password" =~ [A-Z] ]] && [[ "$password" =~ [a-z] ]] && [[ "$password" =~ [0-9] ]]
    return $?
}

# Main processing loop
while IFS=',' read -r username fullname group; do
    # Skip blank or malformed lines
    [[ -z "$username" || -z "$fullname" || -z "$group" ]] && continue

    # Trim whitespace (just in case)
    username=$(echo "$username" | xargs)
    fullname=$(echo "$fullname" | xargs)
    group=$(echo "$group" | xargs)

    # Create group if it doesn't exist
    if ! getent group "$group" > /dev/null; then
        groupadd "$group"
        log_action "Created group: $group"
    else
        log_action "Group already exists: $group"
    fi

    # Create user if it doesn't exist
    if id "$username" &>/dev/null; then
        log_action "User '$username' already exists."
        continue
    fi

    # Create user with home, group, and full name
    useradd -m -c "$fullname" -g "$group" "$username"
    log_action "Created user: $username, Fullname: $fullname, Group: $group"

    # Set temporary password and check complexity
    if check_password_complexity "$TEMP_PASSWORD"; then
        echo "$username:$TEMP_PASSWORD" | chpasswd
        log_action "Password set for $username"
    else
        log_action "ERROR: Temporary password does not meet complexity requirements for $username"
        continue
    fi

    # Enforce password reset
    chage -d 0 "$username"
    log_action "Password reset on first login enforced for $username"

    # Set secure home directory permissions
    chmod 700 "/home/$username"
    log_action "Permissions set to 700 on /home/$username"

    # Send email (if mail is enabled)
    if [[ "$MAIL_ENABLED" == true ]]; then
        echo "Hello $fullname, your account has been created. Temporary password: $TEMP_PASSWORD" | \
        mail -s "Account Created" "$username@yourdomain.com"
        log_action "Email sent to $username@yourdomain.com"
    fi

# done < "$CSV_FILE"
