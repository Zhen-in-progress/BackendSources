func merge(intervals [][]int) [][]int {
    if len(intervals) == 1 {
        return intervals
    }    
    sort.Slice(intervals, func(a, b int) bool {
        return intervals[a][0] < intervals[b][0]
    })

    i:=0
    j:=1
    res := [][]int{} 
    for j< len(intervals){
        if intervals[i][1] >= intervals[j][0] && intervals[i][1]< intervals[j][1] {
            intervals[i][1]=intervals[j][1]
        } else if intervals[i][1]<intervals[j][0]{
            res= append(res,intervals[i])
            i=j
        }
        j++
    }
    res= append(res,intervals[i])

    return res
}