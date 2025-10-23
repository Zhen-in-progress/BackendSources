func twoSum(nums []int, target int) []int {
    set :=make(map[int]int)
    for i, num := range nums{
        if _, found := set[target-num]; found{
            return []int{i, set[target-num]}
        } 
        set[num]=i
    }
    return nil
}