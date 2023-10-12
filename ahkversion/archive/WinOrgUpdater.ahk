#SingleInstance, Force
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
host := "http://fischgeek.com/winorg"
formalName := "WinOrg"
programName := "WinOrg"
steps := 6 * 10
inc = 10
sleep = 500
IfNotExist, %A_AppData%\WinOrg\update.ico
	URLDownloadToFile, %host%/update.ico, %A_AppData%\WinOrg\update.ico
Try
	Menu, Tray, Icon, %A_AppData%\WinOrg\update.ico

Gui, +LastFound +ToolWindow +AlwaysOnTop -Caption +Border
Gui, Color, White
Gui, Font, s17, Segoe UI Light
Gui, Add, Text, w350, %formalName% update
Gui, Add, Progress, wp vprog h20 range0-%steps%
Gui, Font, s11, Segoe UI Light
Gui, Add, Text, wps9 vstep
Gui, Show,, %formalName% Update

; STEP 1 Initializing
{
	GuiControl,, step, Initializing...
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
}

; STEP 2 Closing running instances
{
	GuiControl,, step, Closing running instances...
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
	Process, Close, %programName%.exe
}

; STEP 3 Removing old versions
{
	GuiControl,, step, Removing old versions...
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
	FileDelete, %A_ProgramFiles%\%programName%.exe
}

; STEP 4 Downloading updates
{
	GuiControl,, step, Downloading updates...
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
	URLDownloadToFile, %host%/WinOrg.exe, %A_ProgramFiles%\WinOrg\WinOrg.exe
}

; STEP 5 Finishing up
{
	GuiControl,, step, Finishing up...
	GuiControl,, prog, +%inc%
	sleep, %sleep%
}

; STEP 6 Done
{
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
	GuiControl,, step, Done!
	Gui, Hide
	Run, %A_ProgramFiles%\WinOrg\%programName%.exe
}

ExitApp