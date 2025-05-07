#!/bin/bash

# IAM Setup Script - Extended with login-time password policy enforcement
# This script automates user/group creation and enforces secure password reset on first login

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

# Validate argument (CSV input file)
if [[ -z "$1" ]]; then
    echo "Usage: $0 <users.csv or users.txt>"
    exit 1
fi

CSV_FILE="$1"

# Check if file exists
if [[ ! -f "$CSV_FILE" ]]; then
    echo "Error: File '$CSV_FILE' not found."
    exit 1
fi

# Normalize DOS line endings if needed
dos2unix "$CSV_FILE" 2>/dev/null

# Email notification check
if ! command -v mail &> /dev/null; then
    log_action "'mail' command not found. Email notifications will be skipped."
    MAIL_ENABLED=false
else
    MAIL_ENABLED=true
fi

# Add system-wide login banner for all users
BANNER_MSG="
⚠️ Linux Account Notice 

On your first login:
- You must enter the correct temporary password: $TEMP_PASSWORD
- You will be required to set a new password immediately.

Password requirements:
- At least 8 characters
- One uppercase letter
- One lowercase letter
- One digit

Failure to enter the correct temporary password will result in login failure.
"
echo "$BANNER_MSG" > /etc/motd

# Password complexity check function (optional)
check_password_complexity() {
    local password="$1"
    [[ ${#password} -ge 8 ]] &&
    [[ "$password" =~ [A-Z] ]] &&
    [[ "$password" =~ [a-z] ]] &&
    [[ "$password" =~ [0-9] ]]
}

# Main user creation loop
while IFS=',' read -r username fullname group; do
    [[ -z "$username" || -z "$fullname" || -z "$group" ]] && continue

    username=$(echo "$username" | xargs)
    fullname=$(echo "$fullname" | xargs)
    group=$(echo "$group" | xargs)

    # Create group if not exists
    if ! getent group "$group" > /dev/null; then
        groupadd "$group"
        log_action "Created group: $group"
    fi

    # Skip if user exists
    if id "$username" &>/dev/null; then
        log_action "User '$username' already exists."
        continue
    fi

    # Create user
    useradd -m -c "$fullname" -g "$group" "$username"
    log_action "Created user: $username, Fullname: $fullname, Group: $group"

    # Set temporary password
    echo "$username:$TEMP_PASSWORD" | chpasswd
    log_action "Temporary password set for $username"

    # Force password change
    chage -d 0 "$username"
    log_action "Password reset on first login enforced"

    # Secure home directory
    chmod 700 "/home/$username"
    log_action "Set /home/$username permissions to 700"

    # Email notification
    if [[ "$MAIL_ENABLED" == true ]]; then
        echo "Hello $fullname,

Your Linux account has been created.
Username: $username
Temporary Password: $TEMP_PASSWORD

⚠️ On your first login, you must enter the temporary password correctly.
You will then be asked to change your password.

Your new password must be at least 8 characters long and contain:
- At least one uppercase letter
- At least one lowercase letter
- At least one digit

If you enter the wrong temporary password, login will fail.

Regards,
IT Admin" | mail -s "Account Created" "$username@gmail.com"
        log_action "Email sent to $username@gmail.com"
    fi

done < "$CSV_FILE"
