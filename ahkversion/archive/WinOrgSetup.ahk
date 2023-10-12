#SingleInstance, Force
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
host := "http://fischgeek.com/winorg"
targetDir := A_ProgramFiles "\WinOrg"
formalName := "WinOrg"
programName := "WinOrg"
steps := 6 * 10 ; (# of steps * 10)
inc = 10
sleep = 500
IfNotExist, %targetDir%
	FileCreateDir, %targetDir%
IfNotExist, %A_AppData%\WinOrg
	FileCreateDir, %A_AppData%\WinOrg
IfNotExist, %A_AppData%\WinOrg\setup.ico
	URLDownloadToFile, %host%/setup.ico, %A_AppData%\WinOrg\setup.ico
Try
	Menu, Tray, Icon, %A_AppData%\WinOrg\setup.ico

Gui, _Main_:Default
Gui, +LastFound +ToolWindow +AlwaysOnTop -Caption +Border
Gui, Color, White
Gui, Font, s17, Segoe UI Light
Gui, Add, Text, w350, Installing %formalName%
Gui, Add, Progress, wp vprog h20 range0-%steps%
Gui, Font, s11, Segoe UI Light
Gui, Add, Text, wps9 vstep
Gui, Show,, %formalName% Install

Gui, _Shortcuts_:Default
Gui, +ToolWindow +AlwaysOnTop -Caption +Border
Gui, Color, White
Gui, Font, s17, Segoe UI Light
Gui, Add, Text,, WinOrg Setup
Gui, Font, s12, Segoe UI Light
Gui, Add, Text,, Create the following shortcuts:
Gui, Add, Checkbox, vcbxDesktop, Desktop
Gui, Add, Checkbox, vcbxStartMenu, Start Menu
Gui, Add, Checkbox, vcbxStartup, Startup
Gui, Add, Text, w400 0x10
Gui, Add, Button, gNext w60, Next

; STEP 1 Initializing
{
	Gui, _Main_:Default
	GuiControl,, step, Initializing...
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
}

; STEP 2 Uninstalling previous versions
{
	Gui, _Main_:Default
	GuiControl,, step, Uninstalling previous versions...
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
	IfExist, %targetDir%\%programName%.exe
		FileDelete, %targetDir%\%programName%.exe
}

; STEP 3 Creating directories
{
	Gui, _Main_:Default
	GuiControl,, step, Creating directories...
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
	IfNotExist, %targetDir%
		FileCreateDir, %targetDir%
}

; STEP 4 Downloading files
{
	Gui, _Main_:Default
	GuiControl,, step, Downloading program...
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
	URLDownloadToFile, %host%/WinOrg.exe, %targetDir%\WinOrg.exe
}

; STEP 5 Creating Shortcut
{
	Gui, _Main_:Default
	Gui, Hide
	Gui, _Shortcuts_:Default
	Gui, Show
	return
}
	
Next:
{
	Gui, _Shortcuts_:Default
	Gui, Submit
	Gui, _Main_:Default
	Gui, Show
	GuiControl,, step, Creating shortcuts...
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
	if (cbxDeskTop)
		FileCreateShortcut, %targetDir%\WinOrg.exe, %A_Desktop%\WinOrg.lnk, %targetDir%
	if (cbxStartMenu)
		FileCreateShortcut, %targetDir%\WinOrg.exe, %A_StartMenu%\Programs\WinOrg.lnk, %targetDir%
	if (cbxStartup)
		FileCreateShortcut, %targetDir%\WinOrg.exe, %A_Startup%\WinOrg.lnk, %targetDir%
; STEP 6 Done
	Gui, _Main_:Default
	GuiControl,, prog, +%inc%
	Sleep, %sleep%
	GuiControl,, step, Done!
	MsgBox, 4164, Installer, % "The installation has finished. Enjoy!`n`nWould you like to open " . formalName . " now?"
	IfMsgBox, Yes
		Run, %targetDir%\%programName%.exe
	ExitApp
}