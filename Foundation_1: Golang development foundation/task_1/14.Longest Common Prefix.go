func longestCommonPrefix(strs []string) string {
	prefix := strs[0]

	for _, str := range strs[1:] {
		for len(prefix) > len(str) || prefix != str[:len(prefix)] {
			prefix = prefix[:len(prefix)-1]
			if prefix == ""{
				return ""
			}
		}
	}
    return prefix
}