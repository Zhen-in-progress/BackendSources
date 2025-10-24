package main

import (
	"fmt"
	"time"
)

func main() {
	ch := make(chan int, 100)
	go maker(ch)
	go consumer(ch)
	time.Sleep(1000 * time.Millisecond)

}

func maker(ch chan int) {
	for num := 1; num <= 100; num++ {
		ch <- num
	}
	close(ch)
}

func consumer(ch chan int) {
	for num := range ch {
		fmt.Println(num)
	}
}
