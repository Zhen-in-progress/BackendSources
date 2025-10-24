package main

import (
	"fmt"
	"sync"
	"time"
)

func main() {

	count := 0
	mu := sync.Mutex{}
	for range 10 {
		go func() {
			for range 1000 {
				mu.Lock()
				count++
				mu.Unlock()
			}
		}()
	}

	time.Sleep(1000 * time.Millisecond)
	fmt.Println(count)

}
