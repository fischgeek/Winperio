class Utils {
	static lvl := 2
	JiggleHandle() {
		WinActivate, ahk_exe Explorer.EXE
		RQ.Throttle()
		RQ.Activate()
	}
	; windows
	ActivateWin(win) {
		Log.Write("Activating " win "...", 3)
		IfWinActive, % win
		{
			Log.Write("Window " win " was already the active window.")
			return
		}
		WinActivate, % win
		WinWaitActive, % win
		IfWinNotActive % win 
		{
			WinGet, activePid, PID, A
			WinGetClass, activeClass, A
			Log.Write("A Current acitve PID: " activePid)
			Log.Write("A Current active Class: " activeClass)
			Log.Write("A RQ PID: " RQ.getRqExePid())
			;~ MsgBox, 4112, % "Report Automation", % "Empty window: " win
			;~ Utils.AlertCallStack("Failed in Utils.ActivateWin for window: " win)
			Log.Write("FATAL ERROR TRYING AGAIN")
			Utils.JiggleHandle()
			ExitApp
		}
		Log.Write(win " is active.")
	}
	GetActiveWin() {
		WinGetActiveTitle, activeWin
		WinGet, activePid, PID, A
		WinGetClass, activeClass, A
		;~ if (activeWin == "") {
			;~ FileAppend, % "U Current acitve PID: " activePid "`n", *
			;~ FileAppend, % "U Current active Class: " activeClass "`n", *
			;~ FileAppend, % "U RQ PID: " RQ.getRqExePid() "`n", *
		;~ }
		obj := {}
		obj.Title := activeWin
		obj.Class := activeClass
		obj.PID := activePID
		return obj
	}
	Wait(win,to=30) {
		Log.Write("Waiting for " win "...")
		WinWait, % win,, % to
		if (ErrorLevel) {
			MsgBox, 4112, % "Report Automation", % "Timed out while waiting for " win
			return 0
		}
		return 1
	}
	
	; clicks
	ClickSleep(x, y, ms=500) {
		Click, %x%, %y%
		Sleep, %ms%
	}
	
	; sleeps
	SSleep(s) {
		ss := s*1000
		;~ Log.Write("Sleeping for " s " seconds (" ss " miliseconds)")
		Sleep, %ss%
	}
	MSleep(m) {
		this.SSleep(m*1000*60)
	}
	
	; misc
	FormatSeconds(NumberOfSeconds) {
		time := 19990101
		time += NumberOfSeconds, seconds
		FormatTime, mmss, %time%, mm:ss
		StringReplace, mmss, mmss, % ":", % "m "
		mmss := mmss "s"
		return mmss
	}
	Stamp(brackets=1) {
		FormatTime, stamp,, yyyy-MM-dd HH:mm:ss
		if (brackets) {
			stamp := "[" stamp "] "
		}
		return stamp
	}
	WaitForPixel(clr, xy, timeOut=30) {
		Log.Write("Waiting for pixel: " clr, 3)
		foundClr := 0
		while(!foundClr) {
			PixelSearch, fx, fy, % xy[1], % xy[2], % xy[3], % xy[4], % clr, 5, Fast RGB
			if (ErrorLevel == 0) {
				Log.Write("Pixel found.", 4)
				foundClr := 1
			}
			if (ErrorLevel == 1) {
				Log.Write("Pixel not found.", 4)
			}
			if (ErrorLevel == 2) {
				MsgBox, Unable to search
				ExitApp
			}
			Sleep, 500
			if ((A_Index/2) >= timeOut) {
				return 0
			}
		}
		return [fx, fy]
	}
	DoesErrorPixelExist(clr) {
		Log.Write("Searching for pixel " clr, 3)
		PixelSearch, foundx, foundy, 0, 40, 1800, 750, % clr,, Fast RGB
		res := ErrorLevel
		;~ Log.Write("Search results: " res " x" foundx " y" foundy, 4)
		if (res == 0) {
			Log.Write("Pixel found.", 4)
			MouseMove, foundx, foundy
		} else if (res == 1) {
			Log.Write("Color not found.", 4)
		} else if (res == 2) {
			Log.Write("There was a problem searching for the pixel.", 4)
		}
		ret := (res == 0 ? 1 : 0)
		return ret
	}
	Test() {
		MsgBox, % "Utils says 'Hello'"
	}
	AlertCallStack(reason="No specified reason", depth = 10, printLines = 1){
		msgbox % reason "`n" Utils.GetCallStack(depth, printLines)
	}
	GetCallStack(depth = 5, printLines = 1){
		loop % depth
		{
			lvl := -1 - depth + A_Index
			oEx := Exception("", lvl)
			oExPrev := Exception("", lvl - 1)
			FileReadLine, line, % oEx.file, % oEx.line
			if(oEx.What = lvl)
				continue
			stack .= (stack ? "`n" : "") "File '" oEx.file "', Line " oEx.line (oExPrev.What = lvl-1 ? "" : ", in " oExPrev.What) (printLines ? ":`n" line : "") "`n"
		}
		return stack
	}
}