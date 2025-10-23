package main

import (
	"fmt"
	"time"
)

// 定义任务类型：每个任务是一个函数
type Task func()

// 调度器函数：接收一组任务并发执行
func RunTasks(tasks []Task) {

	for i, task := range tasks {
		go func(i int, task Task) {

			start := time.Now()
			task()
			fmt.Printf("Task %d completed，duration: %v\n", i, time.Since(start))
		}(i, task)
	}
	time.Sleep(1000 * time.Millisecond)
}

func main() {
	// 定义一些示例任务
	tasks := []Task{
		func() {
			time.Sleep(200 * time.Millisecond)
			fmt.Println("Task 0 completed")
		},
		func() {
			time.Sleep(100 * time.Millisecond)
			fmt.Println("Task 1 completed")
		},
		func() {
			time.Sleep(300 * time.Millisecond)
			fmt.Println("Task 2 completed")
		},
	}

	RunTasks(tasks)
}
