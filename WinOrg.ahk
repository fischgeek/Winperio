/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\WinOrg.exe
Compression=0
No_UPX=1
[VERSION]
Set_Version_Info=1
Company_Name=SoftFisch
File_Description=A window organization program
File_Version=2.0.5.169
Inc_File_Version=0
Internal_Name=WinOrg
Legal_Copyright=All rights reserved.
Original_Filename=WinOrg
Product_Name=WinOrg
Product_Version=1.1.9.3
Set_AHK_Version=1
[ICONS]
Icon_1=%In_Dir%\custom assets\winorg_idle64x64.ico
Icon_2=%In_Dir%\custom assets\winorg_idle64x64.ico
Icon_3=0
Icon_4=%In_Dir%\custom assets\winorg_pause64x64.ico
Icon_5=0
Icon_6=0
Icon_7=0

* * * Compile_AHK SETTINGS END * * *
*/

full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
	try
	{
		if A_IsCompiled
			Run *RunAs "%A_ScriptFullPath%" /restart
		else
			Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	}
	ExitApp
}

; classes
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
	
	__New(s, pro, t, c, p, x, y, w, h, m) {
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
	}
}
class Guid {
	CharList := ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]
	Small {
		get {
			guid := ""
			Loop, 8
			{
				Random, var, 1, 16
				guid := guid . this.CharList[var]
			}
			return guid
		}
	}
}
{ ; housekeeping
	#SingleInstance, Force
	#Persistent
	SetTitleMatchMode, 2
	fileVersion = 3.0.8
	cPath := A_AppData "\WinOrg"
	config := cPath "\WinOrg.ini"
	host := "http://fischgeek.com/winorg"
	;~ gosub, CheckForUpdates
	IfNotExist, %cPath%
		FileCreateDir, %cPath%
	IfNotExist, %config%
	{
		IniWrite, 0, %config%, Settings, ProfileSync
	}
	;~ IfNotExist, %cPath%\winorg.ico
		;~ URLDownloadToFile, % host "/assets/winorg.ico", %cPath%\winorg.ico
	;~ IfNotExist, %cPath%\winorgp.ico
		;~ URLDownloadToFile, % host "/assets/winorgp.ico", %cPath%\winorgp.ico
	Try
		Menu, tray, Icon, %cPath%\winorg.ico
	SysGet, monCount, MonitorCount
	
	IniRead, currentProfiles, %config%, Settings, Profiles, %A_Space%
	IniRead, currentActiveProfile, %config%, Settings, ActiveProfile, %A_Space%
	;~ IniRead, seqno, %config%, Settings, Sequence
	IniRead, sections, %config%
	WinArray := Object()
	;~ Loop, %seqno%
	Loop, Parse, sections, `n
	{
		seq := A_LoopField
		if (seq == "Settings")
			continue
		;~ seq := A_Index
		IniRead, pro, %config%, %seq%, Profile
		IniRead, t, %config%, 	%seq%, Title
		IniRead, c, %config%, 	%seq%, Class
		IniRead, p, %config%, 	%seq%, Process
		IniRead, x, %config%, 	%seq%, X
		IniRead, y, %config%, 	%seq%, Y
		IniRead, w, %config%, 	%seq%, W
		IniRead, h, %config%, 	%seq%, H
		IniRead, m, %config%, 	%seq%, MoveID
		win := new Window(seq, pro, t, c, p, x, y, w, h, m)
		WinArray[win.SequenceID] := win
	}
}

{ ; main gui
	defaultWidth := 1000
	Gui, _Main_:Default
	Gui, +MinSize +Resize ; +ToolWindow +Resize
	#Include lib\class_log.ahk
	#Include lib\class_utils.ahk
	Gui, Color, White
	Gui, Margin, 10, 10
	Gui, Font, s15, Segoe UI
	Gui, Add, Text, Section w940, WinOrg
	Gui, Font, s9, Segoe UI
	Gui, Add, Button, w50 ym gShowAddNew, Add
	Gui, Add, ListView, Section xm r15 AltSubmit gSelectedItem vListSelection w%defaultWidth%, ID|Identify By|Title|Class|Process|X|Y|W|H
	Gui, Add, Button, Section Disabled gRemove vbtnRemove, Remove
	Gui, Add, Button, ys wp Disabled gEdit vbtnEdit, Edit
	Gui, Add, Button, ys gSetAll vbtnSetWindows, % "Set Windows"
	Gui, Add, Text, ys vlblCurrentProfile w775 right, % "Current Profile: " currentActiveProfile
	;~ Gui, Add, Groupbox, xm w500 r10 vgrpBx2, Window Information
	;~ Gui, Add, Radio, Section xp+15 yp+25 vRadMoveID, Window:
	;~ Gui, Add, Radio, yp+30, Class:
	;~ Gui, Add, Radio, yp+30, Process:
	;~ Gui, Add, Text, yp+28 vlblXCoord, X:
	;~ Gui, Add, Text, vlblYCoord, Y:
	;~ Gui, Add, Text, vlblWCoord, W:
	;~ Gui, Add, Text, vlblHCoord, H:
	;~ Gui, Add, Edit, ys w395 vdispWin
	;~ Gui, Add, Edit, wp vdispClass
	;~ Gui, Add, Edit, wp vdispProc
	;~ Gui, Add, Edit, Section w200 vdispXEdit gWinXCoordChanged
	;~ Gui, Add, UpDown, vdispX gWinXCoordChanged 0x80 Range-2147483648-2147483647
	;~ Gui, Add, Edit, wp vdispYEdit gWinYCoordChanged
	;~ Gui, Add, UpDown, vdispY gWinYCoordChanged 0x80 Range-2147483648-2147483647
	;~ Gui, Add, Edit, wp vdispWEdit gWinWCoordChanged 
	;~ Gui, Add, UpDown, vdispW gWinWCoordChanged 0x80 Range-2147483648-2147483647
	;~ Gui, Add, Edit, wp vdispHEdit gWinHCoordChanged
	;~ Gui, Add, UpDown, vdispH gWinHCoordChanged 0x80 Range-2147483648-2147483647
	;~ Gui, Add, Button, ys w184 h52 gSelect vbtnSelectWin, Select a Window
	;~ Gui, Add, Button, xp yp wp hp gCancelSelect vbtnCancelSelect hidden, Cancel
	;~ Gui, Add, Button, wp hp Disabled gSaveCoords vbtnSaveCoords, Save Coordinates
}

{ ; add/edit gui
	Gui, _Edit_:Default
	Gui, +AlwaysOnTop +ToolWindow
	Gui, Color, White
	Gui, Font, s9, Segoe UI
	Gui, Add, Text, vEditTitleLabel w400
	Gui, Add, Radio, section xp+15 yp+25 vEditRadMoveID, Window:
	Gui, Add, Radio, yp+30, Class:
	Gui, Add, Radio, yp+30, Process:
	Gui, Add, Text, yp+28, X:
	Gui, Add, Text,, Y:
	Gui, Add, Text,, W:
	Gui, Add, Text,, H:
	Gui, Add, Edit, ys w300 vEditdispWin
	Gui, Add, Edit, wp vEditdispClass
	Gui, Add, Edit, wp vEditdispProc
	Gui, Add, Edit, wp gEditWinXCoordChanged
	Gui, Add, UpDown, vEditdispX gEditWinXCoordChanged 0x80 Range-2147483648-2147483647
	Gui, Add, Edit, wp gEditWinYCoordChanged
	Gui, Add, UpDown, vEditdispY gEditWinYCoordChanged 0x80 Range-2147483648-2147483647
	Gui, Add, Edit, wp gEditWinWCoordChanged
	Gui, Add, UpDown, vEditdispW gEditWinWCoordChanged 0x80 Range-2147483648-2147483647
	Gui, Add, Edit, wp gEditWinHCoordChanged
	Gui, Add, UpDown, vEditdispH gEditWinHCoordChanged 0x80 Range-2147483648-2147483647
	Gui, Add, Text
	Gui, Add, Button, Section xm w60 gEditSave vbtnEditSave, Save
	Gui, Add, Button, ys wp gEditCancel vbtnEditCancel, Cancel
	Gui, Add, DDL, ys w250 Sort gCoordClone vDDLClone, Clone attributes of another window||
}

{ ; menus
	Gui, _Main_:Default
	Menu, Tray, NoStandard
	Menu, Tray, Add, Window Management, MenuWinManage
	Menu, Tray, Add, Pause, MenuPause
	Menu, Tray, Add, Reload, MenuReload
	Menu, Tray, Add, Exit, MenuExit
	Menu, Tray, Default, Window Management
	Menu, FileMenu, Add, Reload, FileReload
	Menu, FileMenu, Add, Run on startup, FileRunOnStartup
	Menu, FileMenu, Add
	Menu, FileMenu, Add, Exit, FileExit
	Menu, ProfileMenu, Add, Manage Profiles, ProfileMenuManage
	Menu, ProfileMenu, Add, % "Sync Profiles with number of Screens", ProfileMenuSync
	Menu, ProfileMenu, Add
	Loop, Parse, currentProfiles, CSV
		Menu, ProfileMenu, Add, %A_LoopField%, ProfileMenuItems	
	Menu, HelpMenu, Add, About, HelpAbout
	Menu, HelpMenu, Add, Contact Author, HelpContact
	Menu, HelpMenu, Add
	Menu, HelpMenu, Add, Uninstall, HelpUninstall
	Menu, MenuBar, Add, File, :FileMenu
	Menu, MenuBar, Add, Profiles, :ProfileMenu
	Menu, MenuBar, Add, Help, :HelpMenu
	Gui, Menu, MenuBar
	
	Try
		Menu, ProfileMenu, Check, %currentActiveProfile%
	
	IniRead, sync, %config%, Settings, ProfileSync, 0
	if (sync) {
		try 
			Menu, ProfileMenu, Check, % "Sync Profiles with number of Screens"
		selectActiveProfile(monCount "Screen")
		SetTimer, CheckScreenCount, 1000
	}
}

;~ if (trayTipCount < 3)
Gui, Show, AutoSize Center, WinOrg

SetTimer, GetActiveWin, 100
;~ SetTimer, CheckVersion, 100
gosub, DataFetch


return ; end of auto-execution section

; file-menu

FileReload:
{
	Reload
	return
}

FileRunOnStartup:
{
	if (startToggle = "on")
	{
		startToggle := "off"
		IniWrite, 0, %config%, Settings, RunOnStartup
		Menu, FileMenu, UnCheck, Run on startup
		FileDelete, %A_Startup%\WinOrg.lnk
	}
	else,
	{	
		startToggle := "on"
		IniWrite, 1, %config%, Settings, RunOnStartup
		Menu, FileMenu, Check, Run on startup
		FileCreateShortcut, %A_ScriptDir%\WinOrg.exe, %A_Startup%\WinOrg.lnk, %A_ScriptDir%,,,,, 7
	}
	return
}

FileExit:
{
	ExitApp
}

; /file-menu
; profile-menu

ProfileMenuItems:
{
	Gui, _Main_:Default
	selectActiveProfile(A_ThisMenuItem)
	gosub, GetWinCoords
	return
}

ProfileMenuManage:
{
	Gui, _ManageProfiles_:Default
	gosub, BuildProfilesGui
	return
}

ProfileMenuSync:
{
	Gui, _Main_:Default
	IniRead, profileSync, %config%, Settings, ProfileSync, 0
	if (profileSync) {
		sync := 0
		Menu, ProfileMenu, UnCheck, % "Sync Profiles with number of Screens"
		IniWrite, 0, %config%, Settings, ProfileSync
		StringReplace, currentProfiles, currentProfiles, % ",1Screen,2Screen,3Screen,4Screen"
	} else {
		sync := 1
		Menu, ProfileMenu, Check, % "Sync Profiles with number of Screens"
		IniWrite, 1, %config%, Settings, ProfileSync
		if (currentProfiles == "") {
			currentProfiles := "1Screen,2Screen,3Screen,4Screen"
		} else {
			StringReplace, currentProfiles, currentProfiles, % ",1Screen,2Screen,3Screen,4Screen",, All
			currentProfiles := currentProfiles ",1Screen,2Screen,3Screen,4Screen"	
		}
		Loop, Parse, currentProfiles, CSV
			Menu, ProfileMenu, Add, %A_LoopField%, ProfileMenuItems
		IniWrite, % currentProfiles, %config%, Settings, Profiles
		SysGet, monCount, MonitorCount
		activeProfile := monCount "Screen"
		IniWrite, % activeProfile, %config%, Settings, ActiveProfile
		selectActiveProfile(activeProfile)
		GuiControl,, lblCurrentProfile, % "Current Profile: " activeProfile
	}
	gosub, GetWinCoords
	return
}

; /profile-menu
; help-menu

HelpAbout:
{
	MsgBox, 64, WinOrg, Version: %fileVersion%`nCreated by: FischGeek
	return
}

HelpContact:
{
	Run, Mailto:fischgeek@gmail.com
	return
}

HelpUninstall:
{
	MsgBox, 35, WinOrg, Are you sure you want to uninstall WinOrg?
	IfMsgBox, Yes
	{
		URLDownloadToFile, %host%/WinOrgUninstaller.exe, %A_Temp%\WinOrgUninstaller.exe
		Run, %A_Temp%\WinOrgUninstaller.exe
	}
	ExitApp
}

; /help-menu
; tray-context-menu

MenuWinManage:
{
	Gui, _Main_:Default
	gosub, GetWinCoords
	Gui, Show, AutoSize Center, WinOrg
	return
}

MenuPause:
{
	Menu, Tray, ToggleCheck, Pause
	Pause
	return
}

MenuReload:
{
	Reload
	return
}

MenuExit:
{
	ExitApp
}

; /tray-context-menu

SelectedItem:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	if (A_GuiEvent != "Normal")
		return
	GuiControl, Enable, btnRemove
	GuiControl, Enable, btnEdit
	selectedRow := A_EventInfo
	return
}

Remove:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	LV_GetText(selectedRowText, selectedRow, 3)
	LV_GetText(selectedEntry, selectedRow, 1)
	MsgBox, 4131, Window Management, Are you sure you want to delete the %selectedRowText% management?
	IfMsgBox, Yes
	{
		GuiControl, Disable, btnRemove
		GuiControl, Disable, btnEdit
		IniDelete, %config%, % selectedEntry
		WinArray.Delete(WinArray[selectedEntry].SequenceID)
		gosub, GetWinCoords
	}
	return
}

; add-edit

ShowAddNew:
{
	Gui, _Edit_:Default
	ClearGui2()
	Gui, Show, AutoSize Center, WinOrg
	selectMode := 1
	SetTimer, WatchWinEdit, 100
	SetTimer, GetActiveWin, Off
	return
}

Edit:
{
	LV_GetText(EditSelectedRowText, selectedRow, 3)
	LV_GetText(EditSelectedEntry, selectedRow, 1)
	Gui, _Edit_:Default
	ClearGui2()
	IniRead, EditthisMoveID, %config%, % EditSelectedEntry, MoveID ; get moveID
	IniRead, EditthisDispWin, %config%, % EditSelectedEntry, Title ; get title
	IniRead, EditthisDispClass, %config%, % EditSelectedEntry, Class ; get class
	IniRead, EditthisDispProc, %config%, % EditSelectedEntry, Process ; get process
	IniRead, EditthisDispX, %config%, % EditSelectedEntry, X ; get x
	IniRead, EditthisDispY, %config%, % EditSelectedEntry, Y ; get y
	IniRead, EditthisDispW, %config%, % EditSelectedEntry, W ; get w
	IniRead, EditthisDispH, %config%, % EditSelectedEntry, H ; get h
	GuiControl,, EditTitleLabel, % "You are editing: " EditSelectedRowText
	GuiControl,, EditDispWin, % EditThisDispWin
	GuiControl,, EditDispClass, % EditThisDispClass
	GuiControl,, EditDispProc, % EditThisDispProc
	GuiControl,, EditDispX, % EditThisDispX
	GuiControl,, EditDispY, % EditThisDispY
	GuiControl,, EditDispW, % EditThisDispW
	GuiControl,, EditDispH, % EditThisDispH
	if (EditthisMoveID = 1)
		GuiControl,, EditRadMoveID, 1
	else if (EditthisMoveID = 2)
		GuiControl,, Class, 1
	else if (EditthisMoveID = 3)
		GuiControl,, Process, 1
	IniRead, currentProfile, %config%, Settings, ActiveProfile
	IniRead, sections, %config%
	Loop, Parse, sections, `n
	{
		CloneSeq := A_LoopField
		if (CloneSeq = "Settings") ; skip the settings section
			continue
		IniRead, thisProfile, %config%, % CloneSeq, Profile
		if (thisProfile != currentProfile)
			continue
		IniRead, CloneThisDispWin, %config%, % CloneSeq, Title ; get title
		IniRead, CloneThisDispClass, %config%, % CloneSeq, Class ; get class
		IniRead, CloneThisDispProc, %config%, % CloneSeq, Process ; get process
		IniRead, CloneThisDispX, %config%, % CloneSeq, X ; get x
		IniRead, CloneThisDispY, %config%, % CloneSeq, Y ; get y
		IniRead, CloneThisDispW, %config%, % CloneSeq, W ; get w
		IniRead, CloneThisDispH, %config%, % CloneSeq, H ; get h
		existingEntries .= CloneThisDispWin "|"
		GuiControl,, DDLClone, % "|Clone another window's position||" existingEntries
	}
	existingEntries := ""
	Gui, Show, AutoSize Center, WinOrg 2.0 - Edit
	selectMode := 1
	SetTimer, WatchWinEdit, 100
	SetTimer, GetActiveWin, Off
	return
}

EditSave:
{
	Gui, _Edit_:Default
	Gui, Submit
	selectMode := 0
	SetTimer, WatchWinEdit, Off
	if (EditRadMoveID = 0)
	{
		MsgBox, 4144, Window Management, Please select a radio button for the MoveID. This will determine how the program will identify the window.
		return
	}
	else if (EditRadMoveID = 2)
	{
		MsgBox, 4164, WinOrg 2.0, By selecting "Class" as the MoveID`, any other windows that have the same Class will affected.`n`nAre you sure you want to select "Class" as the MoveID?
		IfMsgBox, No
			return
	}
	else if (EditRadMoveID = 3)
	{
		MsgBox, 4164, WinOrg 2.0, By selecting "Process" as the MoveID`, any other windows that have the same Process will affected.`n`nAre you sure you want to select "Process" as the MoveID?
		IfMsgBox, No
			return
	}
	IniRead, currentActiveProfile, %config%, Settings, ActiveProfile, 0
	IniWrite, % EditRadMoveID, %config%, % EditSelectedEntry, MoveID
	IniWrite, % EditDispWin, %config%, % EditSelectedEntry, Title
	IniWrite, % EditDispClass, %config%, % EditSelectedEntry, Class 
	IniWrite, % EditDispProc, %config%, % EditSelectedEntry, Process
	IniWrite, % EditDispX, %config%, % EditSelectedEntry, X 
	IniWrite, % EditDispY, %config%, % EditSelectedEntry, Y 
	IniWrite, % EditDispW, %config%, % EditSelectedEntry, W
	IniWrite, % EditDispH, %config%, % EditSelectedEntry, H
	GuiControl, Disable, btnRemove
	GuiControl, Disable, btnEdit
	WinArray[EditSelectedEntry].XCoord := EditDispWin
	WinArray[EditSelectedEntry].XCoord := EditDispX
	WinArray[EditSelectedEntry].YCoord := EditDispY
	WinArray[EditSelectedEntry].Width := EditDispW
	WinArray[EditSelectedEntry].Height := EditDispH
	WinArray[EditSelectedEntry].Class := EditDispClass
	WinArray[EditSelectedEntry].Process := EditDispProc
	WinArray[EditSelectedEntry].MoveID := EditRadMoveID
	gosub, GetWinCoords
	SetTimer, GetActiveWin, On
	return
}

_Edit_GuiClose:
EditCancel:
{
	Gui, _Edit_:Hide
	selectMode := 0
	SetTimer, WatchWinEdit, Off
	ClearGui2()
	SetTimer, GetActiveWin, On
	return
}

; /add-edit

SetAll:
{
	Gui, _Main_:Default
	WinGetActiveTitle, activeWin
	Loop, % LV_GetCount()
	{
		LV_GetText(identity, A_Index, 2)
		LV_GetText(winTitle, A_Index, 3)
		LV_GetText(winClass, A_Index, 4)
		LV_GetText(winProc, A_Index, 5)
		if (identity == "Process" || identity == "Title") {
			WinGet, winList, List, ahk_exe %winProc%
			Loop, % winList
				WinActivate, % "ahk_id" winList%A_Index%
		} else if (identity == "Class") {
			WinGet, winList, List, ahk_class %winClass%
			Loop, % winList
				WinActivate, % "ahk_class" winList%A_Index%
		}
	}
	WinActivate, % activeWin
	return
}

CoordClone:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	Loop, 
	{
		IniRead, CloneThisTitle, %config%, %A_Index%, Title
		if (CloneThisTitle != DDLClone)
			continue
		IniRead, CloneThisX, %config%, % A_Index, X
		IniRead, CloneThisY, %config%, % A_Index, Y
		IniRead, CloneThisW, %config%, % A_Index, W
		IniRead, CloneThisH, %config%, % A_Index, H
		break
	}
	GuiControl,, EditDispX, % CloneThisX
	GuiControl,, EditDispY, % CloneThisY
	GuiControl,, EditDispW, % CloneThisW
	GuiControl,, EditDispH, % CloneThisH
	return
}

AddProfile:
{
	Gui, _ManageProfile_:Default
	InputBox, newProfileName, Add a Profile, % "Enter a new profile name:"
	if (ErrorLevel)
		return
	IniRead, existingProfiles, %config%, Settings, Profiles, 0
	if (!existingProfiles)
		IniWrite, %newProfileName%, %config%, Settings, Profiles
	else
		IniWrite, %existingProfiles%`,%newProfileName%, %config%, Settings, Profiles
	Menu, ProfileMenu, Add, %newProfileName%, ProfileMenuItems
	selectActiveProfile(newProfileName)
	gosub, BuildProfilesGui
	Gui, Show
	gosub, GetWinCoords
	return
}

DeleteProfile:
{
	Gui, _ManageProfiles_:Default
	Gui, Submit, NoHide
	IniRead, currentProfiles, %config%, Settings, Profiles, %A_Space%
	Loop, Parse, currentProfiles, CSV
	{
		if (A_Index = radProfile)
		{
			StringReplace, newProfiles, currentProfiles, %A_LoopField%
			newProfiles := cleanString(newProfiles)
			IniWrite, %newProfiles%, %config%, Settings, Profiles
			Menu, ProfileMenu, Delete, %A_LoopField%
			gosub, BuildProfilesGui
			break
		}
	}
	return
}

Select:
{
	selectMode := 1
	Gui, _Main_:Default
	GuiControl, Hide, btnSelectWin
	GuiControl, Show, btnCancelSelect
	GuiControl, Enable, btnSaveCoords
	SetTimer, WatchWin, 100
	return
}

CancelSelect:
{
	selectMode := 0
	SetTimer, WatchWin, Off
	targetWindow := watchingWindow := 
	Gui, _Main_:Default
	GuiControl, Show, btnSelectWin
	GuiControl, Hide, btnCancelSelect
	GuiControl, Disable, btnSaveCoords
	GuiControl,, dispWin
	GuiControl,, dispClass
	GuiControl,, dispProc
	GuiControl,, dispX
	GuiControl,, dispY
	GuiControl,, dispW
	GuiControl,, dispH
	GuiControl,, RadMoveID, 1 ; select the first radio to unselect others
	GuiControl,, RadMoveID, 0 ; unselect the first radio to make all unselected
	return
}

WatchWin:
{
	Gui, _Main_:Default
	WinGetTitle, watchingWindow, A
	if (watchingWindow == "WinOrg")
		return
	targetWindow := watchingWindow
	WinGet, winProc, ProcessName, %watchingWindow%
	WinGetClass, winClass, %watchingWindow%
	WinGetPos, winX, winY, winW, winH, %watchingWindow%
	GuiControl,, dispWin, % watchingWindow
	GuiControl,, dispClass, % winClass
	GuiControl,, dispProc, % winProc
	GuiControl,, dispX, % winX
	GuiControl,, dispY, % winY
	GuiControl,, dispW, % winW
	GuiControl,, dispH, % winH
	return
}

WatchWinEdit:
{
	Gui, _Edit_:Default
	WinGetTitle, watchingWindow, A
	if (watchingWindow == "WinOrg" || watchingWindow == "WinOrg 2.0 - Edit")
		return
	targetWindow := watchingWindow
	WinGetPos, winX, winY, winW, winH, %watchingWindow%
	GuiControl,, EditdispX, % winX
	GuiControl,, EditdispY, % winY
	GuiControl,, EditdispW, % winW
	GuiControl,, EditdispH, % winH
	debug(winH)
	return
}

SaveCoords:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	SetTimer, WatchWin, Off
	IniRead, currentActiveProfile, %config%, Settings, ActiveProfile, 0
	if (!currentActiveProfile) {
		MsgBox, 4144, WinOrg 2.0, % "Please create a profile first before adding to WinOrg.`n`nYou can create a profile by going to the Profiles menu and selecting ""Manage Profiles"""
		return
	}
	if (RadMoveID = 0) {
		MsgBox, 4144, Window Management, Please select a radio button for the MoveID. This will determine how the program will identify the window.
		return
	}
	;~ else if (RadMoveID = 2)
	;~ {
		;~ MsgBox, 4164, WinOrg 2.0, By selecting "Class" as the MoveID`, any other windows that have the same Class will affected.`n`nAre you sure you want to select "Class" as the MoveID?
		;~ IfMsgBox, No
			;~ return
	;~ }
	;~ else if (RadMoveID = 3)
	;~ {
		;~ MsgBox, 4164, WinOrg 2.0, By selecting "Process" as the MoveID`, any other windows that have the same Process will affected.`n`nAre you sure you want to select "Process" as the MoveID?
		;~ IfMsgBox, No
		;~ return
	;~ }
	;~ IniRead, sequence, %config%, Settings, Sequence
	;~ sequence++
	sequence := new Guid().Small
	;~ MsgBox, % sequence
	;~ IniWrite, % sequence, %config%, Settings, Sequence
	;~ IniWrite, % sequence, %config%, % sequence, SequenceID
	if (sequence == "") {
		MsgBox, No sequence!
		ExitApp
	}
	IniWrite, % currentActiveProfile, %config%, % sequence, Profile
	IniWrite, % dispWin, %config%, % sequence, Title
	IniWrite, % dispClass, %config%, % sequence, Class
	IniWrite, % dispProc, %config%,  % sequence, Process
	IniWrite, % dispX, %config%, % sequence, X
	IniWrite, % dispY, %config%, % sequence, Y
	IniWrite, % dispW, %config%, % sequence, W
	IniWrite, % dispH, %config%, % sequence, H
	IniWrite, % RadMoveID, %config%, % sequence, MoveID
	GuiControl,, dispWin
	GuiControl,, dispClass
	GuiControl,, dispProc
	GuiControl,, dispX
	GuiControl,, dispY
	GuiControl,, dispW
	GuiControl,, dispH
	GuiControl,, RadMoveID, 1 ; select the first radio to unselect others
	GuiControl,, RadMoveID, 0 ; unselect the first radio to make all unselected
	GuiControl, Disable, btnSaveCoords
	GuiControl, Show, btnSelectWin
	GuiControl, Hide, btnCancelSelect
	WinArray[sequence] := new Window(sequence, currentActiveProfile, dispWin, dispClass, dispProc, dispX, dispY, dispW, dispH, RadMoveID)
	selectMode := 0
	gosub, GetWinCoords
	return
}

GetWinCoords:
{
	Gui, _Main_:Default
	GuiControl, Focus, btnSelect
	LV_Delete()
	TitleMatchList := ClassMatchList := ProcessMatchList := ""
	IniRead, currentActiveProfile, %config%, Settings, ActiveProfile
	;~ IniRead, sections, %config%
	for k, v in WinArray 
	{
		if (WinArray[k].Profile != currentActiveProfile)
			continue
		thisMoveID := WinArray[k].MoveID
		thisDisplayWin := WinArray[k].Title
		thisDisplayClass := WinArray[k].Class
		thisDisplayProc := WinArray[k].Process
		if (thisMoveID = 1) ; if moveID is based on title
		{
			TitleMatchList .= thisDisplayWin "," ; add it to the matchlist
		}
		else if (thisMoveID = 2) ; if moveID is based on ahk_class
		{
			ClassMatchList .= thisDisplayClass "," ; add it to the matchlist
		}
		else if (thisMoveID = 3) ; if moveID is based on process
		{
			ProcessMatchList .= thisDisplayProc "," ; add it to the matchlist
		}
		thisMoveID_string := (thisMoveID = 1 ? "Title" : thisMoveID = 2 ? "Class" : thisMoveID = 3 ? "Process" : "ERROR")
		;~ MsgBox, % thisMoveID_string "`n" thisMoveID "`n"WinArray[k].MoveID
		LV_Add(""
		, WinArray[k].SequenceID
		, thisMoveID_string
		, thisDisplayWin
		, thisDisplayClass
		, thisDisplayProc
		, WinArray[k].XCoord
		, WinArray[k].YCoord
		, WinArray[k].Width
		, WinArray[k].Height) ; display in listview
	}
	;~ Loop, Parse, sections, `n
	;~ {
		;~ checkSeqID := A_LoopField
		;~ if (checkSeqID = "Settings") ; skip the settings section
			;~ continue
		;~ IniRead, thisProfile, %config%, % checkSeqID, Profile
		;~ if (thisProfile != currentProfile)
			;~ continue
		;~ IniRead, Seq, %config%, % checkSeqID, SequenceID ; get the sequence number
		;~ if (Seq = "ERROR") ; if no sequence exists,
			;~ continue ; continue to next iteration
		;~ IniRead, thisMoveID, %config%, % checkSeqID, MoveID ; get moveID
		;~ IniRead, thisDispWin, %config%, % checkSeqID, Title ; get title
		;~ IniRead, thisDispClass, %config%, % checkSeqID, Class ; get class
		;~ IniRead, thisDispProc, %config%, % checkSeqID, Process ; get process
		;~ IniRead, thisDispX, %config%, % checkSeqID, X ; get x
		;~ IniRead, thisDispY, %config%, % checkSeqID, Y ; get y
		;~ IniRead, thisDispW, %config%, % checkSeqID, W ; get w
		;~ IniRead, thisDispH, %config%, % checkSeqID, H ; get h
		;~ if (thisMoveID = 1) ; if moveID is based on title
		;~ {
			;~ TitleMatchList .= thisDispWin "," ; add it to the matchlist
			;~ TitleSequenceList .= Seq "," ; add it to the sequence matchlist
		;~ }
		;~ else if (thisMoveID = 2) ; if moveID is based on ahk_class
		;~ {
			;~ ClassMatchList .= thisDispClass "," ; add it to the matchlist
			;~ ClassSequenceList .= Seq "," ; add it to the sequence matchlist
		;~ }
		;~ else if (thisMoveID = 3) ; if moveID is based on process
		;~ {
			;~ ProcessMatchList .= thisDispProc "," ; add it to the matchlist
			;~ ProcessSequenceList .= Seq "," ; add it to the sequence matchlist
		;~ }
		;~ thisMoveID := (thisMoveID = 1 ? "Title" : thisMoveID = 2 ? "Class" : thisMoveID = 3 ? "Process" : "ERROR")
		;~ LV_Add("", Seq, thisMoveID, thisDispWin, thisDispClass, thisDispProc, thisdispX, thisDispY, thisDispW, thisDispH) ; display in listview
	;~ }
	Loop, % LV_GetCount("Col") ; get number of columns
		LV_ModifyCol(A_Index, "autohdr") ; auto adjust header columns
	LV_ModifyCol(1, "Integer")
	return
}

GetActiveWin:
{
	WinGetActiveTitle, thisActiveTitle
	WinGetClass, thisActiveClass, A
	WinGet, thisActiveProcess, ProcessName, A
	if thisActiveTitle in %TitleMatchList%
	{
		For k, v in WinArray
		{
			if (WinArray[k].Profile == currentActiveProfile and WinArray[k].Title == thisActiveTitle) {
				WinMove, % thisActiveTitle,, % WinArray[k].XCoord, % WinArray[k].YCoord, % WinArray[k].Width, % WinArray[k].Height
			}
		}
	}
	else if thisActiveClass in %ClassMatchList%
	{
		For k, v in WinArray
		{
			if (WinArray[k].Profile == currentActiveProfile and WinArray[k].Class == thisActiveClass) {
				WinMove, % "ahk_class " thisActiveClass,, % WinArray[k].XCoord, % WinArray[k].YCoord, % WinArray[k].Width, % WinArray[k].Height
			}
		}
	}
	else if thisActiveProcess in %ProcessMatchList%
	{
		For k, v in WinArray
		{
			if (WinArray[k].Profile == currentActiveProfile and WinArray[k].Process == thisActiveProcess) {
				WinMove, % thisActiveTitle,, % WinArray[k].XCoord, % WinArray[k].YCoord, % WinArray[k].Width, % WinArray[k].Height
			}
		}
	}
	return
}

DataFetch:
{
	IniRead, trayTipCount, %config%, Settings, TrayTipCount, 0
	IniRead, runOnStartupState, %config%, Settings, RunOnStartup
	if (runOnStartupState)
	{
		Menu, FileMenu, Check, Run on startup
		IfNotExist, %A_Startup%\WinOrg.lnk
			FileCreateShortcut, %A_ScriptDir%\WinOrg.exe, %A_Startup%\WinOrg.lnk
	}
	gosub, GetWinCoords
	return
}

BuildProfilesGui:
{
	Gui, _ManageProfiles_:New
	Gui, _ManageProfiles_:Default
	IniRead, currentProfiles, %config%, Settings, Profiles, %A_Space%
	Gui, Color, White
	Gui, Font, s10, Segoe UI
	Gui, Add, Text,, Profiles:
	Loop, Parse, currentProfiles, CSV
	{
		if (A_Index = 1)
			Gui, Add, Radio, vradProfile, %A_LoopField%
		else
			Gui, Add, Radio,, %A_LoopField%
	}
	Gui, Add, Text, 0x10 w185
	Gui, Add, Button, Section yp+15 gAddProfile, Add Profile
	Gui, Add, Button, ys gDeleteProfile, Delete Profile
	Gui, Show
	return
}

WinXCoordChanged:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, targetWindow, dispX, dispY, dispW, dispH)
	return
}

EditWinXCoordChanged:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, EditSelectedRowText, EditDispX, EditDispY, EditDispW, EditDispH)
	return
}

WinYCoordChanged:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, targetWindow, dispX, dispY, dispW, dispH)
	return
}

EditWinYCoordChanged:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, EditSelectedRowText, EditDispX, EditDispY, EditDispW, EditDispH)
	return
}

WinWCoordChanged:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, targetWindow, dispX, dispY, dispW, dispH)
	return
}

EditWinWCoordChanged:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, EditSelectedRowText, EditDispX, EditDispY, EditDispW, EditDispH)
	return
}

WinHCoordChanged:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, targetWindow, dispX, dispY, dispW, dispH)
	return
}

EditWinHCoordChanged:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, EditSelectedRowText, EditDispX, EditDispY, EditDispW, EditDispH)
	return
}

CheckScreenCount:
{
	SysGet, monCount, MonitorCount
	if (sync) {
		selectActiveProfile(monCount "Screen")
		if (monCount != lastMonCount) {
			lastMonCount := monCount
			gosub, GetWinCoords
		}
	}
	return
}

CheckForUpdates:
{
	;~ IniRead, lastCheckForUpdate, %config%, Settings, LastUpdateCheck, 0
	;~ if (lastCheckForUpdate < 30) 
	;~ {
		;~ lastCheckForUpdate++
		;~ IniWrite, %lastCheckForUpdate%, %config%, Settings, LastUpdateCheck
		;~ return
	;~ }
	;~ attempt = 0
	Loop, 5
	{
		ieConnect := DllCall("Wininet.dll\InternetGetConnectedState", Str, 0x43, Int, 0)
		if (ieConnect != 1)
		{
			attempt ++
			Sleep, 60000
			continue
		}
		break
	}
	if (attempt = 5)
	{
		MsgBox, 16, WinOrg Update Error, Unable to establish internet connection to check for an update.
		return
	}
	URLDownloadToFile, %host%/WinOrgConfig.ini, %cPath%\WinOrgConfig.ini
	IniRead, currentVersion, %cPath%\WinOrgConfig.ini, Settings, Version
	if (currentVersion = "ERROR")
		return
	FileDelete, %cPath%\WinOrgConfig.ini
	if (currentVersion != fileVersion) 
	{
		IfExist, %cPath%\WinOrgUpdate.exe
			FileDelete, %cPath%\WinOrgUpdate.exe
		URLDownloadToFile, %host%/WinOrgUpdate.exe, %cPath%\WinOrgUpdate.exe
		Run, %cPath%\WinOrgUpdate.exe
		ExitApp
	}
	return
}

_Main_GuiSize:
{
	Gui, _Main_:Default
	Gui, +LastFound
	autoxywh("grpBx1","wh")
	autoxywh("ListSelection","wh")
	autoxywh("btnRemove","y")
	autoxywh("btnEdit","y")
	autoxywh("btnSetWindows", "y")
	autoxywh("grpBx2","wy")
	autoxywh("dispWin","yw")
	autoxywh("dispClass","yw")
	autoxywh("dispProc","yw")
	autoxywh("dispX","y")
	autoxywh("dispXEdit","y")
	autoxywh("dispY","y")
	autoxywh("dispYEdit","y")
	autoxywh("dispW","y")
	autoxywh("dispWEdit","y")
	autoxywh("dispH","y")
	autoxywh("dispHEdit","y")
	autoxywh("radMoveId","y", true)
	autoxywh("Class:","y", true)
	autoxywh("Process:","y", true)
	autoxywh("lblXCoord","y")
	autoxywh("lblYCoord","y")
	autoxywh("lblWCoord","y")
	autoxywh("lblHCoord","y")
	autoxywh("btnSelectWin","y")
	autoxywh("btnSaveCoords","y")
	autoxywh("lblCurrentProfile", "xy")
	return
}

Esc::
	ExitApp
_Main_GuiClose:
{
	Gui, _Main_:Default
	Gui, Hide
	IniRead, trayTipCount, %config%, Settings, TrayTipCount, 0
	if (trayTipCount = 3)
		return
	TrayTip, WinOrg, WinOrg is still running. You can exit the program by right-clicking this icon and selecting Exit.
	Sleep, 3000
	trayTipCount++
	IniWrite, %trayTipCount%, %config%, Settings, TrayTipCount
	return
}

adjustWindow(sMode, win, x, y, w, h) {
	if (sMode) {
		WinMove, %win%,, %x%, %y%, %w%, %h%
	}
}
ClearGui2() {
	Gui, _Edit_:Default
	GuiControl,, EditTitleLabel
	GuiControl,, EditDispWin
	GuiControl,, EditDispClass
	GuiControl,, EditDispProc
	GuiControl,, EditDispX
	GuiControl,, EditDispY
	GuiControl,, EditDispW
	GuiControl,, EditDispH
	GuiControl,, EditRadMoveID, 1
	GuiControl,, EditRadMoveID, 0
}
cleanString(list) {
	Loop, 
	{
		StringLeft, lChar, list, 1
		if (lChar = ",")
			StringTrimLeft, list, list, 1
		else
			break
	}
	Loop,
	{
		StringRight, rChar, list, 1
		if (rChar = ",")
			StringTrimRight, list, list, 1
		else
			break
	}
	StringReplace, list, list, `,`,, `,, All
	return, list
}
selectActiveProfile(item) {
	global config
	Gui, _Main_:Default
	IniRead, cp, %config%, Settings, Profiles, 0
	if (!cp)
		return
	Loop, Parse, cp, CSV
		try
			Menu, ProfileMenu, Uncheck, %A_LoopField%
	Menu, ProfileMenu, Check, %item%
	IniWrite, %item%, %config%, Settings, ActiveProfile
	GuiControl,, lblCurrentProfile, % "Current Profile: " item
}
CheckVersion:
{
	FileGetAttrib, attribs, %A_ScriptFullPath%
	IfInString, attribs, A
	{
		FileSetAttrib, -A, %A_ScriptFullPath%
		Reload
	}
	return
}