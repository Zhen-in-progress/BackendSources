func isPalindrome(x int) bool {
    if x < 0 {
        return false
    }
    s := strconv.Itoa(x)
    n := len(s)
    i, j := 0, n-1
    for i<j {
        if s[i] !=s[j] {
            return false
        } 
        i++
        j--
    }
    return true
}