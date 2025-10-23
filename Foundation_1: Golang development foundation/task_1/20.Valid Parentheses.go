func isValid(s string) bool {
    stack := []rune{}
    brackets := map[rune]rune{
        '(':')',
        '[':']',
        '{':'}',
    }
    for _,b := range s{
        if _, found := brackets[b]; found{
            stack = append(stack,b)
        }else{
            if len(stack)==0{
                return false
            }
            if brackets[stack[len(stack)-1]] != b{
                return false
            }
            stack = stack[:len(stack)-1] // pop

        }
    }
    return len(stack)==0
}