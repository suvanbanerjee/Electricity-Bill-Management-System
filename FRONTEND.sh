#!/bin/bash

# Database credentials
DB_USER="root"
DB_PASS="P@ssw0rd"
DB_NAME="dbms"

# Function to execute a custom SQL query
execute_query() {
    QUERY=$(whiptail --inputbox "Enter your SQL query" 10 60 3>&1 1>&2 2>&3)
    RESULT=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "$QUERY")
    whiptail --title "Query Result" --msgbox "$RESULT" 20 60
}

# Function to add a customer
add_customer() {
    NAME=$(whiptail --inputbox "Enter customer name:" 10 60 3>&1 1>&2 2>&3)
    PHONE=$(whiptail --inputbox "Enter customer phone:" 10 60 3>&1 1>&2 2>&3)
    ADDRESS=$(whiptail --inputbox "Enter customer address:" 10 60 3>&1 1>&2 2>&3)
    TYPE=$(whiptail --inputbox "Enter customer type:" 10 60 3>&1 1>&2 2>&3)
    STATUS=$(whiptail --inputbox "Enter account status:" 10 60 3>&1 1>&2 2>&3)
    LAST_PAYMENT_DATE=$(whiptail --inputbox "Enter last payment date (YYYY-MM-DD):" 10 60 3>&1 1>&2 2>&3)

    if [ -n "$NAME" ] && [ -n "$PHONE" ] && [ -n "$ADDRESS" ] && [ -n "$TYPE" ]; then
        mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "INSERT INTO customer (name, phone, address, type) VALUES ('$NAME', '$PHONE', '$ADDRESS', '$TYPE');" 2>/tmp/mysql_error.log
        if [ $? -ne 0 ]; then
            whiptail --msgbox "Failed to insert customer. Check /tmp/mysql_error.log for details." 10 60
            return
        fi
        CUSTOMER_ID=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SELECT id FROM customer WHERE name = '$NAME' AND phone = '$PHONE';" -s -N)
        mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "INSERT INTO accounts (customer_id, status, last_payment_date) VALUES ('$CUSTOMER_ID', '$STATUS', '$LAST_PAYMENT_DATE');" 2>/tmp/mysql_error.log
        mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "INSERT INTO \`usage\` (customer_id, units_used) VALUES ('$CUSTOMER_ID', 0);" 2>/tmp/mysql_error.log
        whiptail --msgbox "Customer and account added successfully!" 10 60
    else
        whiptail --msgbox "Please fill in all fields." 10 60
    fi
}


# Function to delete a customer
delete_customer() {
    CUSTOMER_ID=$(whiptail --inputbox "Enter customer ID to delete:" 10 60 3>&1 1>&2 2>&3)
    if [ -n "$CUSTOMER_ID" ]; then
        mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "DELETE FROM customer WHERE id = $CUSTOMER_ID;"
        whiptail --msgbox "Customer deleted successfully!" 10 60
    else
        whiptail --msgbox "Customer ID cannot be empty. Please enter a valid customer ID." 10 60
    fi
}

# Function to generate bill for a customer
generate_bill() {
    CUSTOMER_ID=$(whiptail --inputbox "Enter customer ID to generate bill:" 10 60 3>&1 1>&2 2>&3)
    if [ -n "$CUSTOMER_ID" ]; then
        CUSTOMER_TYPE=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT type FROM customer WHERE id = $CUSTOMER_ID;" -s -N)
        TARRIF_RATE=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT rate FROM tariffs WHERE type = '$CUSTOMER_TYPE';" -s -N)
        UNITS_USED=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT units_used FROM \`usage\` WHERE customer_id = $CUSTOMER_ID;" -s -N)
        DUE_DATE=$(date -d "+15 days" +"%Y-%m-%d")
        BILL_AMOUNT=$(echo "$TARRIF_RATE * $UNITS_USED" | bc)
        mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "INSERT INTO billing (customer_id, amount, due_date) VALUES ($CUSTOMER_ID, $BILL_AMOUNT, '$DUE_DATE');"

        if [ -z "$TARRIF_RATE" ]; then
            TARRIF_RATE=8
        fi

        BILL="
        Customer ID: $CUSTOMER_ID
        Tariff Rate: $TARRIF_RATE
        Units Used: $UNITS_USED
        Bill Amount: $BILL_AMOUNT
        Due Date: $DUE_DATE
        "
        whiptail --title "Bill Generated" --msgbox "$BILL" 20 60

    else
        whiptail --msgbox "Customer ID cannot be empty. Please enter a valid customer ID." 10 60
    fi
}
# Function to show customers details
show_customers() {
    CUSTOMERS=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT * FROM customer;")
    CUSTOMER_DETAILS+=$(echo "$CUSTOMERS" | awk -F'\t' '{printf "%-12s %-20s %-15s %-30s %-10s\n", $1, $2, $3, $4, $5}')
    whiptail --title "Customers Details" --msgbox "$CUSTOMER_DETAILS" 20 120
    CUSTOMERS=""
    CUSTOMER_DETAILS=""
}
show_tables() {
    TABLES=("customer" ""
            "accounts" ""
            "billing" ""
            "tariffs" ""
            "usage" "")
    SELECTED_TABLE=$(whiptail --title "Select a table" --menu "Choose a table" 20 80 10 "${TABLES[@]}" 3>&1 1>&2 2>&3)
    if [ -n "$SELECTED_TABLE" ]; then
        TABLE_DATA=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SELECT * FROM \`$SELECTED_TABLE\`;")
        if [ -n "$TABLE_DATA" ]; then
            whiptail --title "Table: $SELECTED_TABLE" --msgbox "$(echo "$TABLE_DATA" | sed 's/\t/ /g')" 20 120
        else
            whiptail --msgbox "No data available in the selected table." 10 60
        fi
    else
        whiptail --msgbox "No table selected." 10 60
    fi
}

# Function to update usage for a customer
update_usage() {
    CUSTOMER_ID=$(whiptail --inputbox "Enter customer ID to update usage:" 10 60 3>&1 1>&2 2>&3)
    if [ -n "$CUSTOMER_ID" ]; then
        USAGE=$(whiptail --inputbox "Enter new usage:" 10 60 3>&1 1>&2 2>&3)
        if [ -n "$USAGE" ]; then
            mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "UPDATE \`usage\` SET units_used = $USAGE WHERE customer_id = $CUSTOMER_ID;"
            whiptail --msgbox "Usage updated successfully!" 10 60
        else
            whiptail --msgbox "Usage cannot be empty. Please enter a valid usage." 10 60
        fi
    else
        whiptail --msgbox "Customer ID cannot be empty. Please enter a valid customer ID." 10 60
    fi
}

# Function to pay bill for a customer
pay_bill() {
    CUSTOMER_ID=$(whiptail --inputbox "Enter customer ID to pay bill:" 10 60 3>&1 1>&2 2>&3)
    if [ -n "$CUSTOMER_ID" ]; then
        BILL_AMOUNT=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT amount FROM billing WHERE customer_id = $CUSTOMER_ID;" -s -N)
        if [ -z "$BILL_AMOUNT" ]; then
            whiptail --msgbox "No bill found for the customer." 10 60
            return
        fi
        MESSAGE="
        Bill amount: $BILL_AMOUNT\n
        Pay on Following QR Code\n
        ██████████████████████████████████████
        ██          ████      ████          ██
        ██  ██████  ██  ██  ██  ██  ██████  ██
        ██  ██  ██  ██        ████  ██  ██  ██
        ██  ██████  ████████  ████  ██████  ██
        ██          ██  ██      ██          ██
        ██████████████          ██████████████
        ██  ██████  ██  ██    ██    ███   ████
        ██  ███   ██    ████      ████    ████
        ██  ██  ██  ██████                  ██
        ██████████████  ██  ██  ██████████████
        ██          ████████    ██  ██  ██  ██
        ██  ██████  ██████      ██████      ██
        ██  ██  ██  ████        ████    ██  ██
        ██  ██████  ████    ██  ██████  ██  ██
        ██          ██  ██████    ████████  ██
        ██████████████████████████████████████
        "
        mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "DELETE FROM billing WHERE customer_id = $CUSTOMER_ID;"
        mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "UPDATE accounts SET last_payment_date = CURDATE() WHERE customer_id = $CUSTOMER_ID;"
        whiptail --title "Pay Bill" --msgbox "$MESSAGE" 30 120
        whiptail --msgbox "Bill paid successfully!" 10 60
    else
        whiptail --msgbox "No Bill Found!" 10 60
    fi
}

# Bash script for interactive menu
while true; do
    CHOICE=$(whiptail --title "Electricity Bill Management System" --menu "Choose an option" 20 60 10 \
    "1" "Add Customer" \
    "2" "Delete Customer" \
    "3" "Show Customers Details" \
    "4" "Generate Bill" \
    "8" "Update Usage" \
    "9" "Pay Bill" \
    "5" "View Tables" \
    "6" "Execute Custom Query" \
    "7" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1)
            add_customer
            ;;
        2)
            delete_customer
            ;;
        3)
            show_customers
            ;;
        4)
            generate_bill
            ;;
        5)
            show_tables
            ;;
        6)
            execute_query
            ;;
        7)
            exit
            ;;
        8)
            update_usage
            ;;
        9)
            pay_bill
            ;;
        *)
            whiptail --msgbox "Invalid option, please try again." 10 60
            ;;
    esac
done