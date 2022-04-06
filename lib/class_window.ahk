class Window {
	SequenceID:=
	Profile:=
	Title:=
	Class:=
	Process:=
	XCoord:=
	YCoord:=
	Width:=
	Height:=
	MoveID:=
	AlwaysOnTop:=
	
	__New(s, pro, t, c, p, x, y, w, h, m, aot) {
		this.SequenceID := s
		this.Profile := pro
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