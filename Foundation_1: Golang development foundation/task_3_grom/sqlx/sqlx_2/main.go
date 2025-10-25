package main

import (
	"fmt"
	"log"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3" // SQLite driver
)

const schema = `
CREATE TABLE IF NOT EXISTS books (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	title VARCHAR(200),
	author VARCHAR(100),
	price REAL
);`

// Book struct - TODO: Define the Book struct with db tags that map to database column names
// Hint: Should include ID, Title, Author, Price fields
// 定义一个 Book 结构体，包含与 books 表对应的字段。
type Book struct {
	// TODO: Add your fields here
	ID     int     `db:"id"`
	Title  string  `db:"title"`
	Author string  `db:"author"`
	Price  float64 `db:"price"`
}

func main() {
	// Connect to SQLite database
	db, err := sqlx.Connect("sqlite3", "books.db")
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer db.Close()

	fmt.Println("Connected to database!")

	// Run the database operations
	Run(db)
}

func Run(db *sqlx.DB) {
	// Create books table
	db.MustExec(schema)
	fmt.Println("Table created!")

	// Clear existing data and insert sample data
	db.Exec("DELETE FROM books")

	// Sample books data with various prices
	sampleBooks := []Book{
		{ID: 1, Title: "The Go Programming Language", Author: "Alan Donovan", Price: 65.99},
		{ID: 2, Title: "Clean Code", Author: "Robert Martin", Price: 42.50},
		{ID: 3, Title: "Design Patterns", Author: "Gang of Four", Price: 58.00},
		{ID: 4, Title: "Learning Python", Author: "Mark Lutz", Price: 35.00},
		{ID: 5, Title: "Database Internals", Author: "Alex Petrov", Price: 72.50},
		{ID: 6, Title: "Head First Go", Author: "Jay McGavren", Price: 48.99},
		{ID: 7, Title: "Kubernetes in Action", Author: "Marko Luksa", Price: 55.00},
		{ID: 8, Title: "Effective Go", Author: "Go Team", Price: 29.99},
	}

	// Insert sample data
	for _, book := range sampleBooks {
		db.Exec(
			"INSERT INTO books (id, title, author, price) VALUES (?, ?, ?, ?)",
			book.ID, book.Title, book.Author, book.Price,
		)
	}
	fmt.Println("Sample data inserted!")

	// TODO: Query books with price > 50
	//编写Go代码，使用Sqlx执行一个复杂的查询，例如查询价格大于 50 元的书籍，并将结果映射到 Book 结构体切片中，确保类型安全。
	// Hint:
	// 1. Declare a slice of Book: var expensiveBooks []Book
	var somebooks []Book
	// 2. Use db.Select to query and map results to the slice
	// 3. SQL query should be: SELECT * FROM books WHERE price > ?
	// 4. Handle errors properly
	err := db.Select(&somebooks, `SELECT * FROM books WHERE price > 50`)
	if err != nil {
		log.Printf("Error querying book price greater than 50: %v", err)
	}
	// TODO: Print the results

	fmt.Println("\nbook price greater than 50:")
	for _, book := range somebooks {
		fmt.Printf("  %+v\n", book)
	}
}
