package main

import (
	"fmt"
	"math"
)

type Shape interface {
	Area() float64
	Perimeter() float64
}

type Rectangle struct {
	length float64
	width  float64
}

func (r Rectangle) Area() float64 {
	return r.length * r.width
}

func (r Rectangle) Perimeter() float64 {
	return 2 * (r.length + r.width)
}

type Circle struct {
	radius float64
}

func (c Circle) Area() float64 {
	return math.Pi * c.radius * c.radius
}

func (c Circle) Perimeter() float64 {
	return 2 * math.Pi * c.radius
}

func main() {
	r := Rectangle{length: 3, width: 2}
	fmt.Println("Area:", r.Area())
	fmt.Println("Area:", r.Perimeter())

	c := Circle{radius: 3}
	fmt.Println("Area:", c.Area())
	fmt.Println("Area:", c.Perimeter())
}
