package main

import (
	"fmt"
	"time"
)

func main() {
	go func() {

		for i := 1; i <= 10; i++ {
			fmt.Println(i)
		}
	}()

	go func() {

		for i := 2; i <= 10; i += 2 {
			fmt.Println(i)
		}
	}()
	time.Sleep(100 * time.Millisecond)
}
