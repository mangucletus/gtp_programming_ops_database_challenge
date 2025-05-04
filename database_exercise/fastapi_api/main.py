from fastapi import FastAPI              # FastAPI for building the API
import mysql.connector                   # MySQL connector to interact with the database
from typing import List                  # Importing List for type annotations
from pydantic import BaseModel           # Importing BaseModel for request validation (if needed)

# Initialize the FastAPI application
app = FastAPI()

# Database configuration dictionary to store connection details
db_config = {
    "host": "orderdb.c3a80e8ckbp4.eu-west-1.rds.amazonaws.com",  # AWS RDS hostname
    "user": "admin",                                             # Database username
    "password": "StrongPassword123!",                            # Database password
    "database": "orderdb"                                        # Name of the database to connect to
}

# Function to run a query against the MySQL database and return results
def run_query(query):
    """
    Function to execute a given SQL query and return the results.

    Args:
        query (str): SQL query to be executed.

    Returns:
        list: List of results fetched from the database.
    """
    conn = mysql.connector.connect(**db_config)  # Establish connection to the database
    cursor = conn.cursor(dictionary=True)  # Create a cursor that returns rows as dictionaries
    cursor.execute(query)  # Execute the query
    results = cursor.fetchall()  # Fetch all results
    cursor.close()  # Close the cursor
    conn.close()  # Close the database connection
    return results  # Return the results

# Endpoint for Top Customers by Spending
@app.get("/top-customers")
def top_customers():
    """
    Endpoint to get top customers based on their total spending.

    Returns:
        JSON: A JSON response containing customer names and their total spending.
    """
    query = """
        SELECT c.customer_id, c.name, SUM(oi.unit_price * oi.quantity) AS total_spent
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        JOIN order_items oi ON o.order_id = oi.order_id
        GROUP BY c.customer_id, c.name
        ORDER BY total_spent DESC;
    """
    return run_query(query)  # Execute the query and return the results

# Endpoint for Monthly Sales Report (Only Shipped/Delivered)
@app.get("/monthly-sales")
def monthly_sales():
    """
    Endpoint to get monthly sales data for shipped and delivered orders.

    Returns:
        JSON: A JSON response containing total sales for each month.
    """
    query = """
        SELECT 
            DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
            SUM(oi.unit_price * oi.quantity) AS total_sales
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.status IN ('Shipped', 'Delivered')
        GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
        ORDER BY sales_month;
    """
    return run_query(query)  # Execute the query and return the results

# Endpoint for Products Never Ordered
@app.get("/products-never-ordered")
def products_never_ordered():
    """
    Endpoint to get a list of products that have never been ordered.

    Returns:
        JSON: A JSON response containing product names that have never been ordered.
    """
    query = """
        SELECT p.name
        FROM products p
        LEFT JOIN order_items oi ON p.product_id = oi.product_id
        WHERE oi.product_id IS NULL;
    """
    return run_query(query)  # Execute the query and return the results

# Endpoint for Average Order Value by Country
@app.get("/avg-order-value-by-country")
def avg_order_value_by_country():
    """
    Endpoint to get the average order value for each country.

    Returns:
        JSON: A JSON response containing average order values by country.
    """
    query = """
        SELECT country, AVG(order_total) AS avg_order_value
        FROM (
            SELECT c.country, o.order_id,
                   SUM(oi.unit_price * oi.quantity) AS order_total
            FROM customers c
            JOIN orders o ON c.customer_id = o.customer_id
            JOIN order_items oi ON o.order_id = oi.order_id
            GROUP BY o.order_id, c.country
        ) AS sub
        GROUP BY country;
    """
    return run_query(query)  # Execute the query and return the results

# Endpoint for Frequent Buyers (More Than One Order)
@app.get("/frequent-buyers")
def frequent_buyers():
    """
    Endpoint to get a list of customers who have placed more than one order.

    Returns:
        JSON: A JSON response containing customer names and the total number of orders.
    """
    query = """
        SELECT c.name, COUNT(o.order_id) AS total_orders
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        GROUP BY c.customer_id
        HAVING COUNT(o.order_id) > 1;
    """
    return run_query(query)  # Execute the query and return the results

# Run the FastAPI app (Only needed for running locally, not for production)
if __name__ == '__main__':
    app.run(debug=True)  # Run the application in debug mode for development purposes
