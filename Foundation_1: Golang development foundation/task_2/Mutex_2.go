package main

import (
	"fmt"
	"sync/atomic"
	"time"
)

func main() {
	var count int64 // use int64 for atomic operations

	for range 10 {
		go func() {
			for range 1000 {
				atomic.AddInt64(&count, 1)
			}
		}()
	}

	time.Sleep(1000 * time.Millisecond)
	fmt.Println(count)
}
