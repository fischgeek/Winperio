;@Ahk2Exe-SetFileVersion 3.0.14
;@Ahk2Exe-SetProductVersion 1
;@Ahk2Exe-SetName Winperio
;@Ahk2Exe-SetProductName Winperio
;@Ahk2Exe-SetMainIcon assets\winperio.ico
;@Ahk2Exe-SetDescription Winperio
;@Ahk2Exe-SetCompanyName DevTech FM
;@Ahk2Exe-SetCopyright DevTech FM
;@Ahk2Exe-UpdateManifest RequireAdmin 1
; option to not show window on startup
; min,max
; only regex escape if desired
	; will need to change the matching logic in the timer
; option to skip if maximized

#SingleInstance, Force
#Persistent

fileVersion = 3.0.14

FileCreateDir, %A_ScriptDir%/assets
FileInstall, assets/new.png, assets/new.png, 1

#Include lib\class_log.ahk
#Include lib\class_utils.ahk
#Include lib\class_window.ahk
#Include lib\class_imagebutton.ahk
#Include lib\class_settings.ahk

SetBatchLines, -1
SetTitleMatchMode, 2
sets := new Settings()
config := sets.ConfigFile
SysGet, monCount, MonitorCount
WinArray := getSavedWindows()
ProfileWinArray := getProfileWinArray(sets.ActiveProfile)
; editBtn := new ImageButton("btnEdit", "Static2", "edit.png")
; remove := new ImageButton("btnRemove", "Static2", "remove.png")
addNew := new ImageButton("btnAddNew", "Static2", "new.png")
imgButtons := {"new":addNew, "remove":remove, "edit":editBtn}

{ ; main gui
	defaultWidth := 900
	Gui, _Main_:Default
	Gui, +Resize ; +ToolWindow +Resize
	Gui, Color, White
	Gui, Margin, 10, 10
	Gui, Font, s15, Segoe UI
	Gui, Add, Text, Section w855, Winperio
	Gui, Font, s9, Segoe UI
	; Gui, Add, Button, w50 ym gShowAddNew vbtnAddNew, Add
	; Gui, Add, Picture, w30 h30 ys gEdit vbtnEdit, % imgButtons["edit"].path
	; Gui, Add, Picture, w30 h30 ys gRemove vbtnRemove, % imgButtons["remove"].path
	Gui, Add, Picture, w30 h30 ys gShowAddNew vbtnAddNew, % imgButtons["new"].path
	Gui, Add, ListView, Section xm r15 AltSubmit gSelectedItem vListSelection w%defaultWidth%, ID|Pattern|X|Y|W|H
	Gui, Add, Text, xm vlblCurrentProfile w500, % "Current Profile: " sets.ActiveProfile
	; Gui, Add, Button, Section Disabled gRemove vbtnRemove, Remove
	; Gui, Add, Button, ys wp Disabled gEdit vbtnEdit, Edit
	; Gui, Add, Button, ys gSetAll vbtnSetWindows, % "Set Windows"
	populateListView()
}

{ ; add/edit gui
	Gui, _Edit_:Default
	Gui, +MinSize +Resize +AlwaysOnTop +Delimiter`n
	Gui, Color, White
	Gui, Margin, 10, 10
	Gui, Font, s15, Segoe UI
	Gui, Add, Text, vEditTitleLabel w400

	Gui, Font, s12, Segoe UI
	Gui, Add, Text,, % "Active Window"
	Gui, Font, s10, Segoe UI
	cbxW := 75
	Gui, Add, Checkbox, Section xm w%cbxW% Checked vcbxActiveTitle, Title
	Gui, Add, Text, ys w700 cgray vactiveTitle

	Gui, Add, Checkbox, Section xm w%cbxW% Checked vcbxActiveClass, Class
	Gui, Add, Text, ys w700 cgray vactiveClass

	Gui, Add, Checkbox, Section xm w%cbxW% Checked vcbxActiveProcess, Process
	Gui, Add, Text, ys w700 cgray vactiveProcess

	Gui, Add, Text, Section xm, % "Match Pattern (RegEx)"
	Gui, Add, Checkbox, ys Checked vcbxEscapeRegex, % "Escape RegEx"
	Gui, Font, s10, Consolas
	Gui, Add, Edit, xm w800 vcurrentWindowFullTitle
	Gui, Font, s10, Segoe UI
	
	Gui, Add, Edit, x400 y0 w100 vtxtCurrentSeqId
	
	Gui, Font, s12, Segoe UI
	Gui, Add, Text, xm, % "Coordinates"
	Gui, Font, s10, Segoe UI
	
	Gui, Add, Text, Section xm w20, X:
	Gui, Add, Edit, ys-4 w90 gEditWinXCoordChanged
	Gui, Add, UpDown, vEditdispX gEditWinXCoordChanged 0x80 Range-2147483648-2147483647
	
	Gui, Add, Text, Section xm w20, Y:
	Gui, Add, Edit, ys-4 w90 gEditWinYCoordChanged
	Gui, Add, UpDown, vEditdispY gEditWinYCoordChanged 0x80 Range-2147483648-2147483647
	
	Gui, Add, Text, Section xm w20, W:
	Gui, Add, Edit, ys-4 w90 gEditWinWCoordChanged
	Gui, Add, UpDown, vEditdispW gEditWinWCoordChanged 0x80 Range-2147483648-2147483647
	
	Gui, Add, Text, Section xm w20, H:
	Gui, Add, Edit, ys-4 w90 gEditWinHCoordChanged
	Gui, Add, UpDown, vEditdispH gEditWinHCoordChanged 0x80 Range-2147483648-2147483647

	Gui, Font, s12, Segoe UI
	Gui, Add, Text, xm, % "Options"
	Gui, Font, s10, Segoe UI

	Gui, Add, Checkbox, Section xm vcbxAlwaysOnTop, Always on top
	
	Gui, Add, Text, xm r2
	Gui, Add, Button, Section xm w60 gEditSave vbtnEditSave, Save
	Gui, Add, Button, ys wp gEditCancel vbtnEditCancel, Cancel
	Gui, Add, DDL, ys w250 Sort gCoordCloneDropdownItemChanged vddlCloneCoordinates
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
	for k, v in sets.Profiles
		Menu, ProfileMenu, Add, %v%, ProfileMenuItems	
	Menu, HelpMenu, Add, About, HelpAbout
	; Menu, HelpMenu, Add
	; Menu, HelpMenu, Add, Uninstall, HelpUninstall
	Menu, MenuBar, Add, File, :FileMenu
	Menu, MenuBar, Add, Profiles, :ProfileMenu
	Menu, MenuBar, Add, Help, :HelpMenu
	Gui, Menu, MenuBar
	
	Try
		Menu, ProfileMenu, Check, % sets.ActiveProfile
	
	IniRead, sync, %config%, Settings, ProfileSync, 0
	if (sync) {
		try 
			Menu, ProfileMenu, Check, % "Sync Profiles with number of Screens"
		selectActiveProfile(monCount "Screen")
		SetTimer, CheckScreenCount, 1000
	}
}

;~ if (trayTipCount < 3)
isAdminFlag := ""
if (A_IsAdmin) {
	isAdminFlag := " [Adminstrator]"
}
mainWindowTitle := "Winperio" isAdminFlag
Gui, Show, AutoSize Center, % mainWindowTitle
WinGet, winperioHwnd, ID, Winperio
SetTimer, GetActiveWin, 1000
SetTimer, WatchWin, 1000
SetTimer, WatchWin, Off
SetTimer, GetMouse, 100
;~ SetTimer, CheckVersion, 100
;~ gosub, DataFetch
RegRead, isRunningOnStartup, HKCU, % "Software\Microsoft\Windows\CurrentVersion\Run", % "Winperio"
if (isRunningOnStartup != "") {
	Menu, FileMenu, Check, Run on startup
}
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
		; FileDelete, %A_Startup%\Winperio.lnk
		RegDelete, HKCU, % "Software\Microsoft\Windows\CurrentVersion\Run", % "Winperio"
	}
	else,
	{	
		startToggle := "on"
		IniWrite, 1, %config%, Settings, RunOnStartup
		Menu, FileMenu, Check, Run on startup
		; FileCreateShortcut, %A_ScriptDir%\Winperio.exe, %A_Startup%\Winperio.lnk, %A_ScriptDir%,,,,, 7
		RegWrite, REG_SZ, HKCU, % "Software\Microsoft\Windows\CurrentVersion\Run", % "Winperio", % A_ScriptFullPath
	}
	return
}
FileExit:
{
	ExitApp
}

; profile-menu
ProfileMenuItems:
{
	Gui, _Main_:Default
	selectActiveProfile(A_ThisMenuItem)
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
	; IniRead, profileSync, %config%, Settings, ProfileSync, 0
	; if (profileSync) {
	; 	sync := 0
	; 	Menu, ProfileMenu, UnCheck, % "Sync Profiles with number of Screens"
	; 	IniWrite, 0, %config%, Settings, ProfileSync
	; 	StringReplace, sets.Profiles, sets.Profiles, % ",1Screen,2Screen,3Screen,4Screen"
	; } else {
	; 	sync := 1
	; 	Menu, ProfileMenu, Check, % "Sync Profiles with number of Screens"
	; 	IniWrite, 1, %config%, Settings, ProfileSync
	; 	if (sets.Profiles == "") {
	; 		sets.Profiles := "1Screen,2Screen,3Screen,4Screen"
	; 	} else {
	; 		StringReplace, sets.Profiles, sets.Profiles, % ",1Screen,2Screen,3Screen,4Screen",, All
	; 		sets.Profiles := sets.Profiles ",1Screen,2Screen,3Screen,4Screen"	
	; 	}
	; 	Loop, Parse, sets.Profiles, CSV
	; 		Menu, ProfileMenu, Add, %A_LoopField%, ProfileMenuItems
	; 	IniWrite, % sets.Profiles, %config%, Settings, Profiles
	; 	SysGet, monCount, MonitorCount
	; 	activeProfile := monCount "Screen"
	; 	IniWrite, % activeProfile, %config%, Settings, ActiveProfile
	; 	selectActiveProfile(activeProfile)
	; 	GuiControl,, lblCurrentProfile, % "Current Profile: " activeProfile
	; }
	return
}

; help-menu
HelpAbout:
{
	MsgBox, 64, Winperio, Version: %fileVersion%
	return
}
HelpUninstall:
{
	MsgBox, 35, Winperio, Are you sure you want to uninstall Winperio?
	IfMsgBox, Yes
	{
		URLDownloadToFile, %host%/WinperioUninstaller.exe, %A_Temp%\WinperioUninstaller.exe
		Run, %A_Temp%\WinperioUninstaller.exe
	}
	ExitApp
}

; tray-context-menu
MenuWinManage:
{
	Gui, _Main_:Default
	Gui, Show, AutoSize Center, Winperio
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

; main-ui
SelectedItem:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	if (A_GuiEvent != "DoubleClick")
		return
	; GuiControl, Enable, btnRemove
	; GuiControl, Enable, btnEdit
	selectedRow := A_EventInfo
	LV_ModifyCol(1, "Left")
	Gosub, Edit
	return
}
#IfWinActive, Winperio
Delete::
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	ControlGetFocus, ctl, A
	if (ctl == "SysListView321" and LV_GetCount("S") == 1) {
		row := LV_GetNext(0, "F")
		LV_GetText(itemId, row)
		item := findItemById(itemId)
		MsgBox, 4132, % "Winperio - Delete", % "Are you sure you want to delete the following entry?`n`n" item.Pattern 
		IfMsgBox, Yes
		{
			sets.DeleteWindow(item)
			populateGlobalArrays(profile)
			populateListView()
		}
	}
	return
}
#If

; add-edit
ShowAddNew:
{
	Gui, _Edit_:Default
	newId := Utils.SmallGuid()
	resetEditGui(newId)
	GuiControl,, EditTitleLabel, Add
	Gui, Show, AutoSize Center, Winperio - Add
	selectMode := 1
	SetTimer, GetActiveWin, Off
	SetTimer, WatchWin, On
	return
}
Edit:
{
	LV_GetText(EditSelectedRowText, selectedRow, 3)
	LV_GetText(EditSelectedEntry, selectedRow, 1)
	w := WinArray[EditSelectedEntry]
	Gui, _Edit_:Default
	resetEditGui(w.SequenceID)
	GuiControl,, EditTitleLabel, Edit
	; GuiControl,, EditDispWin, % w.Title
	; GuiControl,, EditDispClass, % w.Class
	; GuiControl,, EditDispProc, % w.Process
	GuiControl,, currentWindowFullTitle, % w.Pattern
	GuiControl,, EditDispX, % w.XCoord
	GuiControl,, EditDispY, % w.YCoord
	GuiControl,, EditDispW, % w.Width
	GuiControl,, EditDispH, % w.Height
	Gui, Show, AutoSize Center, Winperio - Edit
	selectMode := 1
	;~ SetTimer, WatchWinEdit, 100
	SetTimer, GetActiveWin, Off
	return
}
EditSave:
{
	Gui, _Edit_:Default
	Gui, Submit
	selectMode := 0
	IniRead, profile, %config%, Settings, ActiveProfile, % ""
	IniWrite, % profile, %config%, % txtCurrentSeqId, Profile
	IniWrite, % currentWindowFullTitle, %config%, % txtCurrentSeqId, Pattern
	IniWrite, % EditDispX, %config%, % txtCurrentSeqId, X 
	IniWrite, % EditDispY, %config%, % txtCurrentSeqId, Y 
	IniWrite, % EditDispW, %config%, % txtCurrentSeqId, W
	IniWrite, % EditDispH, %config%, % txtCurrentSeqId, H
	IniWrite, % cbxAlwaysOnTop, %config%, % txtCurrentSeqId, AlwaysOnTop
	GuiControl, Disable, btnRemove
	GuiControl, Disable, btnEdit
	populateGlobalArrays(profile)
	SetTimer, WatchWin, Off
	SetTimer, GetActiveWin, On
	populateListView()
	return
}
_Edit_GuiClose:
EditCancel:
{
	Gui, _Edit_:Hide
	selectMode := 0
	;~ SetTimer, WatchWinEdit, Off
	resetEditGui("")
	SetTimer, GetActiveWin, On
	return
}

SelectAWindow:
{
	selectMode := 1
	Gui, _Main_:Default
	GuiControl, Hide, btnSelectWin
	GuiControl, Show, btnCancelSelect
	GuiControl, Enable, btnSaveCoords
	SetTimer, GetActiveWin, Off
	SetTimer, WatchWin, On
	return
}

CancelSelectAWindow:
{
	selectMode := 0
	;~ SetTimer, WatchWin, Off
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
	SetTimer, GetActiveWin, Off
	return
}

EditWinXCoordChanged:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	;~ adjustWindow(selectMode, EditSelectedRowText, EditDispX, EditDispY, EditDispW, EditDispH)
	return
}

EditWinYCoordChanged:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	;~ adjustWindow(selectMode, EditSelectedRowText, EditDispX, EditDispY, EditDispW, EditDispH)
	return
}

EditWinWCoordChanged:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	;~ adjustWindow(selectMode, EditSelectedRowText, EditDispX, EditDispY, EditDispW, EditDispH)
	return
}

EditWinHCoordChanged:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	;~ adjustWindow(selectMode, EditSelectedRowText, EditDispX, EditDispY, EditDispW, EditDispH)
	return
}

CoordCloneDropdownItemChanged:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	cloneItem := findItemByTitle(ddlCloneCoordinates)
	if (cloneItem == 0) {
		m("ERROR: Item not found in global array.")
		ExitApp
	}
	currentItem := WinArray[txtCurrentSeqId]
	MsgBox, 4132, Winperio, % "Are you sure you want apply the new coordinates?`n`nx:  " cloneItem.XCoord "`ny:  " cloneItem.YCoord "`nw: " cloneItem.Width "`nh:  " cloneItem.Height
	IfMsgBox, Yes
	{
		GuiControl,, EditDispX, % cloneItem.XCoord
		GuiControl,, EditDispY, % cloneItem.YCoord
		GuiControl,, EditDispW, % cloneItem.Width
		GuiControl,, EditDispH, % cloneItem.Height
	}
	return
}



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

; profiles
AddProfile:
{
	Gui, _ManageProfile_:Default
	InputBox, newProfileName, Add a Profile, % "Enter a new profile name:"
	if (ErrorLevel)
		return
	sets.AddProfile(newProfileName)
	Menu, ProfileMenu, Add, %newProfileName%, ProfileMenuItems
	selectActiveProfile(newProfileName)
	gosub, BuildProfilesGui
	Gui, Show
	return
}
DeleteProfile:
{
	Gui, _ManageProfiles_:Default
	Gui, Submit, NoHide
	pro := sets.Profiles[radProfile]
	MsgBox, % "deleting profile " pro
	sets.DeleteProfileNumber(radProfile)
	Menu, ProfileMenu, Delete, % pro
	gosub, BuildProfilesGui
	return
}


SaveCoords:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	SetTimer, WatchWin, Off
	if (!sets.ActiveProfile) {
		MsgBox, 4144, Winperio 2.0, % "Please create a profile first before adding to Winperio.`n`nYou can create a profile by going to the Profiles menu and selecting ""Manage Profiles"""
		return
	}
	sequence := new Guid().Small
	if (sequence == "") {
		MsgBox, No sequence!
		ExitApp
	}
	IniWrite, % sets.ActiveProfile, %config%, % sequence, Profile
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
	WinArray[sequence] := new Window(sequence, sets.ActiveProfile, dispWin, dispClass, dispProc, dispX, dispY, dispW, dispH, RadMoveID)
	selectMode := 0
	return
}

saveNewCoords(win) {
	global
	sequence := win.SequenceID
	IniWrite, % win.XCoord, %config%, % sequence, X
	IniWrite, % win.YCoord, %config%, % sequence, Y
	IniWrite, % win.Width, %config%, % sequence, W
	IniWrite, % win.Height, %config%, % sequence, H
	IniRead, profile, %config%, Settings, ActiveProfile, % ""
	populateGlobalArrays(profile)
	populateListView()
}
; timers
GetActiveWin:
{
  wasShift := GetKeyState("LShift", "P")
	WinGet, allWins, List
	Loop, % allWins
	{
		id := allWins%A_Index%
		WinGet, p, ProcessName, % "ahk_id " id
		WinGetTitle, t, % "ahk_id " id
		WinGetClass, c, % "ahk_id " id
		WinGetPos, curX, curY, curW, curH, % "ahk_id " id
		fullyMatchableName := t " ahk_class " c " ahk_exe " p
		
		for k, v in ProfileWinArray { 
			r := RegExMatch(fullyMatchableName, "i)" v.Pattern)

			if (r > 0) {
				if (wasShift && WinActive("ahk_id " id)) {
					v.XCoord := curX
					v.YCoord := curY
					v.Width := curW
					v.Height := curH
					saveNewCoords(v)
					Log.Write("x: " curX " y: " curY)
				} else {
					; Log.Write("[" A_Index "] matched: " v.Pattern " with " fullyMatchableName)
					WinMove, % "ahk_id " id,, v.XCoord, v.YCoord, v.Width, v.Height
					; WinSet, AlwaysOnTop, % v.AlwaysOnTop, % "ahk_id " id
				}
			}
		}
	}
	return
}
WatchWin:
{
	Gui, _Edit_:Default
	Gui, Submit, NoHide
	WinGetTitle, watchingWindow, A
	WinGet, winProc, ProcessName, %watchingWindow%
	WinGetClass, winClass, %watchingWindow%
	WinGetPos, winX, winY, winW, winH, %watchingWindow%
	; regExEsc(watchingWindow " ahk_class " winClass " ahk_exe " winProc)
	if (watchingWindow != "Winperio" and watchingWindow != "Winperio - Add") {
		Log.Write("Active Window: " watchingWindow)
		t := ""
		Log.Write("cbxActiveTitle: " cbxActiveTitle)
		if (cbxActiveTitle) {
			t .= watchingWindow
		}
		if (cbxActiveClass) {
			t .= " ahk_class " winClass
		}
		if (cbxActiveProcess) {
			t .= " ahk_exe " winProc
		}
		t := Trim(t)
		if (cbxEscapeRegex) {
			t := regExEsc(t)
		}
		Log.Write("t: " t)
		GuiControl,, currentWindowFullTitle, % t
		GuiControl,, activeTitle, % watchingWindow
		GuiControl,, activeClass, % winClass
		GuiControl,, activeProcess, % winProc
		
		GuiControl,, EditdispX, % winX
		GuiControl,, EditdispY, % winY
		GuiControl,, EditdispW, % winW
		GuiControl,, EditdispH, % winH
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
		IfNotExist, %A_Startup%\Winperio.lnk
			FileCreateShortcut, %A_ScriptDir%\Winperio.exe, %A_Startup%\Winperio.lnk
	}
	return
}

BuildProfilesGui:
{
	Gui, _ManageProfiles_:New
	Gui, _ManageProfiles_:Default
	Gui, Color, White
	Gui, Font, s10, Segoe UI
	Gui, Add, Text,, Profiles:
	for k, v in sets.Profiles {
		if (A_Index = 1)
			Gui, Add, Radio, vradProfile, % v
		else
			Gui, Add, Radio,, % v
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

WinYCoordChanged:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, targetWindow, dispX, dispY, dispW, dispH)
	return
}

WinWCoordChanged:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, targetWindow, dispX, dispY, dispW, dispH)
	return
}

WinHCoordChanged:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	adjustWindow(selectMode, targetWindow, dispX, dispY, dispW, dispH)
	return
}

CheckScreenCount:
{
	SysGet, monCount, MonitorCount
	if (sync) {
		selectActiveProfile(monCount "Screen")
		if (monCount != lastMonCount) {
			lastMonCount := monCount
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
		MsgBox, 16, Winperio Update Error, Unable to establish internet connection to check for an update.
		return
	}
	URLDownloadToFile, %host%/WinperioConfig.ini, %cPath%\WinperioConfig.ini
	IniRead, currentVersion, %cPath%\WinperioConfig.ini, Settings, Version
	if (currentVersion = "ERROR")
		return
	FileDelete, %cPath%\WinperioConfig.ini
	if (currentVersion != fileVersion) 
	{
		IfExist, %cPath%\WinperioUpdate.exe
			FileDelete, %cPath%\WinperioUpdate.exe
		URLDownloadToFile, %host%/WinperioUpdate.exe, %cPath%\WinperioUpdate.exe
		Run, %cPath%\WinperioUpdate.exe
		ExitApp
	}
	return
}

 ; events
_Edit_GuiSize:
{
	Gui, _Edit_:Default
	Gui, +LastFound
	autoxywh("currentWindowFullTitle", "w")
	autoxywh("activeTitle", "w")
	autoxywh("EditdispWin", "w")
	autoxywh("EditdispClass", "w")
	autoxywh("EditdispProc", "w")
	autoxywh("EditDispRegEx", "w")
	autoxywh("btnEditSave", "y")
	autoxywh("btnEditCancel", "y")
	autoxywh("ddlCloneCoordinates", "y")
	return
}
_Main_GuiSize:
{
	Gui, _Main_:Default
	Gui, +LastFound
	autoxywh("grpBx1","wh")
	autoxywh("btnAddNew", "x")
	autoxywh("ListSelection","wh")
	autoxywh("btnRemove","x")
	autoxywh("btnEdit","x")
	autoxywh("btnSetWindows", "y")
	autoxywh("btnSelectWin","y")
	autoxywh("btnSaveCoords","y")
	autoxywh("lblCurrentProfile", "y")
	return
}
_Main_GuiClose:
{
	Gui, _Main_:Default
	Gui, Hide
	IniRead, trayTipCount, %config%, Settings, TrayTipCount, 0
	if (trayTipCount = 3)
		return
	TrayTip, Winperio, Winperio is still running. You can exit the program by right-clicking this icon and selecting Exit.
	Sleep, 3000
	trayTipCount++
	IniWrite, %trayTipCount%, %config%, Settings, TrayTipCount
	return
}

adjustWindow(sMode, win, x, y, w, h) {
	if (sMode) {
		;~ WinMove, %win%,, %x%, %y%, %w%, %h%
	}
}
resetEditGui(cSeqId) {
	Gui, _Edit_:Default
	GuiControl,, txtCurrentSeqId, % cSeqId
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
	populateCloneDropdown()
}
findItemById(itemId) {
	global WinArray
	for k, v in WinArray {
		if (v.SequenceID == itemId) {
			return v
		}
	}
	return 0
}
findItemByTitle(t) {
	global WinArray
	for k, v in WinArray {
		if (v.Title == t) {
			return v
		}
	}
	return 0
}
m(msg) {
	MsgBox, 4096,, %msg%
}
getProfileWinArray(profile) {
	global WinArray
	o := []
	for k, v in WinArray {
		if (v.Profile == profile) {
			o[v.SequenceID] := v
		}
	}
	return o
}
getSavedWindows() {
	global config, Window
	IniRead, sections, %config%
	wa := Object()
	Loop, Parse, sections, `n
	{
		seq := A_LoopField
		if (seq != "Settings") {
			IniRead, pro, %config%, %seq%, Profile, % ""
			IniRead, name, %config%, %seq%, Name, % ""
			IniRead, pat, %config%, %seq%, Pattern, % ""
			IniRead, x, %config%, 	%seq%, X
			IniRead, y, %config%, 	%seq%, Y
			IniRead, w, %config%, 	%seq%, W
			IniRead, h, %config%, 	%seq%, H
			IniRead, aot, %config%, %seq%, AlwaysOnTop, 0
			win := new Window(seq, pro, name, pat, t, c, p, x, y, w, h, m, aot)
			wa[win.SequenceID] := win
		}
	}
	return wa
}
moveWin(w, wo) {
	WinMove, % w,, % wo.XCoord, % wo.YCoord, % wo.Width, % wo.Height
}
populateGlobalArrays(profile) {
	global
	WinArray := getSavedWindows()
	ProfileWinArray := getProfileWinArray(profile)
}

; list view
populateListView() {
	global sets, config, WinArray
	Gui, _Main_:Default
	LV_Delete()
	for k, v in WinArray 
		if (v.Profile == sets.ActiveProfile)
			LV_Add("", v.SequenceID, v.Pattern, v.XCoord, v.YCoord, v.Width, v.Height)
	adjustColumnWidths()
}
adjustColumnWidths() {
	global
	Gui, _Main_:Default
	Loop, % LV_GetCount("Column")
		LV_ModifyCol(A_Index, "AutoHdr")
}

populateCloneDropdown() {
	global WinArray
	lst := "`nClone another window's position`n"
	for k, v in WinArray {
		lst .= v.Title "`n"
	}
	GuiControl, _Edit_:, ddlCloneCoordinates, % lst
	GuiControl, Choose, ddlCloneCoordinates, Clone another window's position
}
regExEsc(txt) {
	txt := RegExReplace(txt, "i)\.", "\.")
	txt := RegExReplace(txt, "i)\|", "\|")
	txt := RegExReplace(txt, "i)\*", "\*")
	txt := RegExReplace(txt, "i)\?", "\?")
	txt := RegExReplace(txt, "i)\[", "\[")
	txt := RegExReplace(txt, "i)\]", "\]")
	txt := RegExReplace(txt, "i)\(", "\(")
	txt := RegExReplace(txt, "i)\)", "\)")
	txt := RegExReplace(txt, "i)\+", "\+")
	txt := RegExReplace(txt, "i)\\", "\\")
	return txt
}
selectActiveProfile(item) {
	global
	Gui, _Main_:Default
	for k, v in sets.Profiles
		try
			Menu, ProfileMenu, Uncheck, %v%
	Menu, ProfileMenu, Check, %item%
	IniWrite, %item%, %config%, Settings, ActiveProfile
	sets.SetActiveProfile(item)
	GuiControl,, lblCurrentProfile, % "Current Profile: " sets.ActiveProfile
	ProfileWinArray := getProfileWinArray(sets.ActiveProfile)
	populateListView()
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
GetMouse:
{
	MouseGetPos, x, y, w, cid, 1
	if (w = winperioHwnd) {
		for k, v in imgButtons
			setHover(cid,v)
	}
	return
}
setHover(cid,h) {
	if (cid = h.ctlName and h.hover == false) {
			GuiControl,_Main_:, % h.name, % "*w32 *h32 " h.path
			h.hover := true
		} else if (cid != h.ctlName and h.hover == true) {
			GuiControl,_Main_:, % h.name, % "*w30 *h30 " h.path
			h.hover := false
		}
}