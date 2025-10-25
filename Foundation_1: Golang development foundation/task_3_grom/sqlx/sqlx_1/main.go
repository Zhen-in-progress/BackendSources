package main

import (
	"fmt"
	"log"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3" // SQLite driver
)

const schema = `
CREATE TABLE IF NOT EXISTS employees (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name VARCHAR(100),
	department VARCHAR(100),
	salary REAL
);`

// Employee struct - the `db` tags map to database column names
type Employee struct {
	ID         int     `db:"id"`
	Name       string  `db:"name"`
	Department string  `db:"department"`
	Salary     float64 `db:"salary"`
}

func main() {
	// Connect to SQLite database
	db, err := sqlx.Connect("sqlite3", "test.db")
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer db.Close()

	fmt.Println("Connected to database!")

	// Run the database operations
	Run(db)
}

func Run(db *sqlx.DB) {
	// Create employees table
	db.MustExec(schema)
	fmt.Println("Table created!")

	// Clear existing data and insert sample data
	db.Exec("DELETE FROM employees")

	employees := []Employee{
		{Name: "Alice", Department: "Engineering", Salary: 8000.00},
		{Name: "Bob", Department: "Engineering", Salary: 9500.00},
		{Name: "Charlie", Department: "Sales", Salary: 7000.00},
		{Name: "David", Department: "Engineering", Salary: 12000.00},
		{Name: "Eve", Department: "HR", Salary: 6500.00},
	}

	for _, emp := range employees {
		db.Exec(
			"INSERT INTO employees (name, department, salary) VALUES (?, ?, ?)",
			emp.Name, emp.Department, emp.Salary,
		)
	}
	fmt.Println("Sample data inserted!")

	// Requirement 1: Query all employees in "Engineering" department
	var engineeringEmployees []Employee
	err := db.Select(&engineeringEmployees, `SELECT * FROM employees WHERE department = "Engineering"`)
	if err != nil {
		log.Printf("Error querying Engineering employees: %v", err)
	}
	fmt.Println("\nEngineering Department Employees:")
	for _, emp := range engineeringEmployees {
		fmt.Printf("  %+v\n", emp)
	}

	// Requirement 2: Query employee with highest salary (use db.Get for single row)
	var topEmployee Employee
	err = db.Get(&topEmployee, `SELECT * FROM employees ORDER BY salary DESC LIMIT 1`)
	if err != nil {
		log.Printf("Error querying top employee: %v", err)
	}
	fmt.Println("\nHighest Paid Employee:")
	fmt.Printf("  %+v\n", topEmployee)
}
