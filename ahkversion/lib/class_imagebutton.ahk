class ImageButton {
	name := ""
	hover := false
	path := ""
	ctlName := ""
	__New(name,cn,fileName) {
		this.name := name
		this.ctlName := cn
		this.path := A_ScriptDir "\assets\" fileName
	}
}