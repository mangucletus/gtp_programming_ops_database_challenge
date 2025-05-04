from flask import Flask, jsonify  # Importing necessary modules from Flask
import mysql.connector  # Importing the MySQL connector to interact with the database

# Initialize the Flask application
app = Flask(__name__)

# Database configuration: connection details to connect to the RDS database
db_config = {
    "host": "orderdb.c3a80e8ckbp4.eu-west-1.rds.amazonaws.com",  # Database host
    "user": "admin",  # Database username
    "password": "StrongPassword123!",  # Database password
    "database": "orderdb"  # The specific database to use
}

# Function to run queries on the MySQL database
def run_query(query):
    # Establish a connection to the MySQL database using the config
    conn = mysql.connector.connect(**db_config)
    # Create a cursor object to interact with the database
    cursor = conn.cursor(dictionary=True)
    # Execute the SQL query passed as a parameter
    cursor.execute(query)
    # Fetch all results from the executed query
    result = cursor.fetchall()
    # Close the cursor and connection after the query is executed
    cursor.close()
    conn.close()
    return result  # Return the result of the query

# Route for Top Customers by Spending
@app.route('/top-customers')
def top_customers():
    # SQL query to fetch the top customers based on total spending
    query = """SELECT c.customer_id, c.name, SUM(oi.unit_price * oi.quantity) AS total_spent
               FROM customers c
               JOIN orders o ON c.customer_id = o.customer_id
               JOIN order_items oi ON o.order_id = oi.order_id
               GROUP BY c.customer_id, c.name
               ORDER BY total_spent DESC;"""
    return jsonify(run_query(query))  # Return the result of the query in JSON format

# Route for Monthly Sales Report (Only Shipped/Delivered)
@app.route('/monthly-sales')
def monthly_sales():
    # SQL query to fetch the monthly sales for shipped or delivered orders
    query = """SELECT 
                  DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
                  SUM(oi.unit_price * oi.quantity) AS total_sales
               FROM orders o
               JOIN order_items oi ON o.order_id = oi.order_id
               WHERE o.status IN ('Shipped', 'Delivered')
               GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
               ORDER BY sales_month;"""
    return jsonify(run_query(query))  # Return the result of the query in JSON format

# Route for Products Never Ordered
@app.route('/products-never-ordered')
def products_never_ordered():
    # SQL query to fetch products that have never been ordered
    query = """SELECT p.name
               FROM products p
               LEFT JOIN order_items oi ON p.product_id = oi.product_id
               WHERE oi.product_id IS NULL;"""
    return jsonify(run_query(query))  # Return the result of the query in JSON format

# Route for Average Order Value by Country
@app.route('/avg-order-value-by-country')
def avg_order_value_by_country():
    # SQL query to fetch the average order value grouped by country
    query = """SELECT country, AVG(order_total) AS avg_order_value
               FROM (
                   SELECT c.country, o.order_id,
                          SUM(oi.unit_price * oi.quantity) AS order_total
                   FROM customers c
                   JOIN orders o ON c.customer_id = o.customer_id
                   JOIN order_items oi ON o.order_id = oi.order_id
                   GROUP BY o.order_id, c.country
               ) AS sub
               GROUP BY country;"""
    return jsonify(run_query(query))  # Return the result of the query in JSON format

# Route for Frequent Buyers (More Than One Order)
@app.route('/frequent-buyers')
def frequent_buyers():
    # SQL query to fetch customers with more than one order
    query = """SELECT c.name, COUNT(o.order_id) AS total_orders
               FROM customers c
               JOIN orders o ON c.customer_id = o.customer_id
               GROUP BY c.customer_id
               HAVING COUNT(o.order_id) > 1;"""
    return jsonify(run_query(query))  # Return the result of the query in JSON format

# Start the Flask app if the script is executed directly
if __name__ == '__main__':
    app.run(debug=True)  # Run the app in debug mode for development purposes
