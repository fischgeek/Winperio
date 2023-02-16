class Guid {
	SmallGuid() {
		charList := ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]
		g := ""
		Loop, 8
		{
			Random, var, 1, 16
			g .= charList[var]
		}
		return g
	}
}