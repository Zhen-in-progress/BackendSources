package main

import (
	"fmt"
)

func main() {
	nums := []int{1, 2, 3}
	pointer := &nums
	timesTwoSlice(pointer)
	fmt.Println(nums)

}

func timesTwoSlice(pointer *[]int) {
	for i := range *pointer {
		(*pointer)[i] *= 2
	}
}
