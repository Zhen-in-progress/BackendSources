package main

import (
	"fmt"
)

func main() {
	e := Employee{
		Person:     Person{Name: "Mike", Age: 40},
		EmployeeID: "AA",
	}
	e.Printinfo()
}

type Person struct {
	Name string
	Age  int
}

type Employee struct {
	Person
	EmployeeID string
}

func (e Employee) Printinfo() {
	fmt.Println("Name:", e.Name)
	fmt.Println("Age:", e.Age)
	fmt.Println("EmployeeID:", e.EmployeeID)
}
