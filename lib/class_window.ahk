class Window {
	SequenceID:=
	Name:=
	Profile:=
	Pattern:=
	Title:=
	Class:=
	Process:=
	XCoord:=
	YCoord:=
	Width:=
	Height:=
	MoveID:=
	AlwaysOnTop:=
	
	__New(s, pro, name, pat, t, c, p, x, y, w, h, m, aot) {
		this.SequenceID := s
		this.Profile := pro
		this.Name := name
		this.Pattern := pat
		this.Title := t
		this.Class := c
		this.Process := p
		this.XCoord := x
		this.YCoord := y
		this.Width := w
		this.Height := h
		this.MoveID := m
		this.AlwaysOnTop := aot
	}
}