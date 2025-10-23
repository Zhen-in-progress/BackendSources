package main

import "fmt"


func main() {
	num := 42
	pointer := &num
	addTen(pointer)
	fmt.Println(num)
}

func addTen(pointer *int) {
	*pointer += 10
}
