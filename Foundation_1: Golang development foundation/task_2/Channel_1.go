package main

import (
	"fmt"
	"time"
)

func main() {
	ch := make(chan int)
	go sendTen(ch)
	go receiveTen(ch)
	time.Sleep(1000 * time.Millisecond)

}

func sendTen(ch chan int) {
	for num := 1; num <= 10; num++ {
		ch <- num
	}
	close(ch)
}

func receiveTen(ch chan int) {
	for num := range ch {
		fmt.Println(num)
	}
}
