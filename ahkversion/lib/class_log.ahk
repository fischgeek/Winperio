class Log {
	LastWriteTime := A_Now
	LogWindowPID := 0
	
	Clear() {
		FileDelete, % Settings.LogFile
		FileAppend, % "", % Settings.LogFile
	}
	StartTail() {
		t := "Report Automation Log"
		logFile := Settings.LogFile
		cmd := "powershell.exe -noprofile -command """ A_ScriptDir "\assets\tail.ps1 " logFile """"
		Run, % cmd, % A_ScriptDir,, pwPid
		this.LogWindowPID := pwPid
		Log.Write("Running log window with pid: " this.LogWindowPID)
		;~ WinWait, % t
		;~ cntr := A_ScreenWidth/2
		;~ WinMove, % t,, cntr-500, 0, 1000, 200
		;~ WinSet AlwaysOnTop, On, % t
	}
	StopTail() {
		Log.Write("Killing log window with process id: " this.LogWindowPID)
		Process, Close, % this.LogWindowPID
		;~ WinKill, "Report Automation Log ahk_class ConsoleWindowClass ahk_exe powershell.exe"
	}
	Start(name, fn, a ="", b="") {
		Log.Write(name " started")
		ret := Func(fn).Call(a,b)
		Log.Write(name " finished")
		return ret
	}
	StartMethodOnClass(cls, name, lvl=2) {
		start := A_TickCount
		Log.Write("STARTED " name, lvl)
		ret := cls[name]()
		Log.Write("FINISHED " name " " A_TickCount-start "ms", lvl)
		return ret
	}
	Write(m,lvl=2) {
		;~ win := Utils.GetActiveWin()
		prepend := ""
		;~ writeNow := A_Now - Log.LastWriteTime
		;~ Log.LastWriteTime := A_Now
		Loop, % lvl
			prepend .= "| "
		val := Utils.Stamp() prepend m
		;~ FileAppend, % val "`n", % Settings.LogFile
		FileAppend, % val "`n", *
		;~ MsgBox % "done writing`n`n" val "`n`n" Settings.LogFile
	}
}