{
	#SingleInstance, Force
	#Persistent
	#Include lib\class_log.ahk
	#Include lib\class_utils.ahk
	#Include lib\class_window.ahk
	SetTitleMatchMode, 2
	fileVersion = 3.0.8
	cPath := A_AppData "\Winperio"
	config := cPath "\winperio.ini"
	host := "http://fischgeek.com/winperio"
	;~ gosub, CheckForUpdates
	IfNotExist, %cPath%
		FileCreateDir, %cPath%
	IfNotExist, %config%
	{
		IniWrite, 0, %config%, Settings, ProfileSync
	}
	;~ IfNotExist, %cPath%\winperio.ico
		;~ URLDownloadToFile, % host "/assets/winperio.ico", %cPath%\winperio.ico
	;~ IfNotExist, %cPath%\winperiop.ico
		;~ URLDownloadToFile, % host "/assets/winperiop.ico", %cPath%\winperiop.ico
	Try
		Menu, tray, Icon, %cPath%\winperio.ico
	SysGet, monCount, MonitorCount
	IniRead, currentProfiles, %config%, Settings, Profiles, %A_Space%
	IniRead, currentActiveProfile, %config%, Settings, ActiveProfile, %A_Space%
	WinArray := getSavedWindows()
	ProfileWinArray := getProfileWinArray(currentActiveProfile)
	ProfileTitleMatchArray := getMatchArray(1, currentActiveProfile)
	ProfileClassMatchArray := getMatchArray(2, currentActiveProfile)
	ProfileProcessMatchArray := getMatchArray(3, currentActiveProfile)
	Log.Write("WinArray Length: " WinArray.Count())
	Log.Write("ProfileWinArray Length: " ProfileWinArray.Count())
	Log.Write("TitleMatchArray Length: " TitleMatchArray.Count())
	Log.Write("ClassMatchArray Length: " ClassMatchArray.Count())
	Log.Write("ProcessMatchArray Length: " ProcessMatchArray.Count())
}

{ ; main gui
	defaultWidth := 1000
	Gui, _Main_:Default
	Gui, +Resize ; +ToolWindow +Resize
	Gui, Color, White
	Gui, Margin, 10, 10
	Gui, Font, s15, Segoe UI
	Gui, Add, Text, Section w940, Winperio
	Gui, Font, s9, Segoe UI
	Gui, Add, Button, w50 ym gShowAddNew vbtnAddNew, Add
	Gui, Add, ListView, Section xm r15 AltSubmit gSelectedItem vListSelection w%defaultWidth%, ID|Identify By|Title|Class|Process|X|Y|W|H
	Gui, Add, Text, xm vlblCurrentProfile w500, % "Current Profile: " currentActiveProfile
	Gui, Add, Button, Section Disabled gRemove vbtnRemove, Remove
	Gui, Add, Button, ys wp Disabled gEdit vbtnEdit, Edit
	Gui, Add, Button, ys gSetAll vbtnSetWindows, % "Set Windows"
	populateListView()
}

{ ; add/edit gui
	Gui, _Edit_:Default
	Gui, +MinSize +Resize +AlwaysOnTop +Delimiter`n
	Gui, Color, White
	Gui, Margin, 10, 10
	Gui, Font, s15, Segoe UI
	Gui, Add, Text, vEditTitleLabel w400
	
	Gui, Font, s9, Segoe UI
	
	Gui, Add, Button, Section xm gSelectAWindow vbtnSelectWin, Select a Window
	
	Gui, Add, Radio, Section vEditRadMoveID, Window:
	Gui, Add, Radio, yp+35, Class:
	Gui, Add, Radio, yp+35, Process:
	Gui, Add, Radio, yp+35 Disabled, RegEx:
	Gui, Add, Edit, ys w300 vEditdispWin
	Gui, Add, Edit, wp vEditdispClass
	Gui, Add, Edit, wp vEditdispProc
	Gui, Add, Edit, wp vEditDispRegEx Disabled
	
	Gui, Add, Edit, xm w200 vtxtCurrentSeqId
	
	Gui, Add, Text, Section xm w70, X:
	Gui, Add, Edit, ys w90 gEditWinXCoordChanged
	Gui, Add, UpDown, vEditdispX gEditWinXCoordChanged 0x80 Range-2147483648-2147483647
	
	Gui, Add, Text, Section xm w70, Y:
	Gui, Add, Edit, ys w90 gEditWinYCoordChanged
	Gui, Add, UpDown, vEditdispY gEditWinYCoordChanged 0x80 Range-2147483648-2147483647
	
	Gui, Add, Text, Section xm w70, W:
	Gui, Add, Edit, ys w90 gEditWinWCoordChanged
	Gui, Add, UpDown, vEditdispW gEditWinWCoordChanged 0x80 Range-2147483648-2147483647
	
	Gui, Add, Text, Section xm w70, H:
	Gui, Add, Edit, ys w90 gEditWinHCoordChanged
	Gui, Add, UpDown, vEditdispH gEditWinHCoordChanged 0x80 Range-2147483648-2147483647

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
Gui, Show, AutoSize Center, Winperio
SetTimer, GetActiveWin, 1000
;~ SetTimer, CheckVersion, 100
;~ gosub, DataFetch
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
		FileDelete, %A_Startup%\Winperio.lnk
	}
	else,
	{	
		startToggle := "on"
		IniWrite, 1, %config%, Settings, RunOnStartup
		Menu, FileMenu, Check, Run on startup
		FileCreateShortcut, %A_ScriptDir%\Winperio.exe, %A_Startup%\Winperio.lnk, %A_ScriptDir%,,,,, 7
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
	return
}

; help-menu

HelpAbout:
{
	MsgBox, 64, Winperio, Version: %fileVersion%`nCreated by: FischGeek
	return
}

HelpContact:
{
	Run, Mailto:fischgeek@gmail.com
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
	if (A_GuiEvent != "Normal")
		return
	GuiControl, Enable, btnRemove
	GuiControl, Enable, btnEdit
	selectedRow := A_EventInfo
	LV_ModifyCol(1, "Left")
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
		populateGlobalArrays()
		; lazy, I know, but just for now.
		populateListView()
	}
	return
}

; add-edit

ShowAddNew:
{
	Gui, _Edit_:Default
	newId := Utils.SmallGuid()
	resetEditGui(newId)
	GuiControl,, EditTitleLabel, Add
	Gui, Show, AutoSize Center, Winperio
	selectMode := 1
	SetTimer, GetActiveWin, Off
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
	GuiControl,, EditDispWin, % w.Title
	GuiControl,, EditDispClass, % w.Class
	GuiControl,, EditDispProc, % w.Process
	GuiControl,, EditDispX, % w.XCoord
	GuiControl,, EditDispY, % w.YCoord
	GuiControl,, EditDispW, % w.Width
	GuiControl,, EditDispH, % w.Height
	if (w.MoveID = 1)
		GuiControl,, EditRadMoveID, 1
	else if (w.MoveID = 2)
		GuiControl,, Class, 1
	else if (w.MoveID = 3)
		GuiControl,, Process, 1
	IniRead, currentProfile, %config%, Settings, ActiveProfile
	;~ existingEntries := ""
	Gui, Show, AutoSize Center, Winperio 2.0 - Edit
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
	;~ SetTimer, WatchWinEdit, Off

	if (EditRadMoveID = 0)
	{
		MsgBox, 4144, Window Management, Please select a radio button for the MoveID. This will determine how the program will identify the window.
		return
	}
	IniRead, currentActiveProfile, %config%, Settings, ActiveProfile, 0
	IniWrite, % currentActiveProfile, %config%, % txtCurrentSeqId, Profile
	IniWrite, % EditRadMoveID, %config%, % txtCurrentSeqId, MoveID
	IniWrite, % EditDispWin, %config%, % txtCurrentSeqId, Title
	IniWrite, % EditDispClass, %config%, % txtCurrentSeqId, Class 
	IniWrite, % EditDispProc, %config%, % txtCurrentSeqId, Process
	IniWrite, % EditDispX, %config%, % txtCurrentSeqId, X 
	IniWrite, % EditDispY, %config%, % txtCurrentSeqId, Y 
	IniWrite, % EditDispW, %config%, % txtCurrentSeqId, W
	IniWrite, % EditDispH, %config%, % txtCurrentSeqId, H
	IniWrite, % cbxAlwaysOnTop, %config%, % txtCurrentSeqId, AlwaysOnTop
	GuiControl, Disable, btnRemove
	GuiControl, Disable, btnEdit
	populateGlobalArrays()
	; WinArray[txtCurrentSeqId].XCoord := EditDispWin
	; WinArray[txtCurrentSeqId].XCoord := EditDispX
	; WinArray[txtCurrentSeqId].YCoord := EditDispY
	; WinArray[txtCurrentSeqId].Width := EditDispW
	; WinArray[txtCurrentSeqId].Height := EditDispH
	; WinArray[txtCurrentSeqId].Class := EditDispClass
	; WinArray[txtCurrentSeqId].Process := EditDispProc
	; WinArray[txtCurrentSeqId].MoveID := EditRadMoveID
	SetTimer, GetActiveWin, On
	; lazy, I know, but just for now.
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
	SetTimer, WatchWin, 100
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

WatchWin:
{
	Gui, _Edit_:Default
	WinGetTitle, watchingWindow, A
	if (watchingWindow != "Winperio") {
		;~ MsgBox, 4096,,  % watchingWindow
		targetWindow := watchingWindow
		WinGet, winProc, ProcessName, %watchingWindow%
		WinGetClass, winClass, %watchingWindow%
		WinGetPos, winX, winY, winW, winH, %watchingWindow%
		GuiControl,, EditdispWin, % watchingWindow
		GuiControl,, EditdispClass, % winClass
		GuiControl,, EditdispProc, % winProc
		GuiControl,, EditdispX, % winX
		GuiControl,, EditdispY, % winY
		GuiControl,, EditdispW, % winW
		GuiControl,, EditdispH, % winH
	}
	return
}

SaveCoords:
{
	Gui, _Main_:Default
	Gui, Submit, NoHide
	SetTimer, WatchWin, Off
	IniRead, currentActiveProfile, %config%, Settings, ActiveProfile, 0
	if (!currentActiveProfile) {
		MsgBox, 4144, Winperio 2.0, % "Please create a profile first before adding to Winperio.`n`nYou can create a profile by going to the Profiles menu and selecting ""Manage Profiles"""
		return
	}
	if (RadMoveID = 0) {
		MsgBox, 4144, Window Management, Please select a radio button for the MoveID. This will determine how the program will identify the window.
		return
	}
	;~ else if (RadMoveID = 2)
	;~ {
		;~ MsgBox, 4164, Winperio 2.0, By selecting "Class" as the MoveID`, any other windows that have the same Class will affected.`n`nAre you sure you want to select "Class" as the MoveID?
		;~ IfMsgBox, No
			;~ return
	;~ }
	;~ else if (RadMoveID = 3)
	;~ {
		;~ MsgBox, 4164, Winperio 2.0, By selecting "Process" as the MoveID`, any other windows that have the same Process will affected.`n`nAre you sure you want to select "Process" as the MoveID?
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
	return
}

GetActiveWin:
{
	; WinGetActiveTitle, thisActiveTitle
	; WinGetClass, thisActiveClass, A
	; WinGet, thisActiveProcess, ProcessName, A
	; WinGet, id, id, A

	WinGet, allWins, List
	Loop, % allWins
	{
		id := allWins%A_Index%
		WinGet, p, ProcessName, % "ahk_id " id
		WinGetTitle, t, % "ahk_id " id
		WinGetClass, c, % "ahk_id " id
		; fullyMatchableName := t " ahk_class " c " ahk_exe" p
		
		for k, v in ProfileTitleMatchArray { 
			Log.Write("t: " t " ||| v.Title: " v.Title)
			if (t = v.Title) {
				WinMove, % "ahk_id " id,, v.XCoord, v.YCoord, v.Width, v.Height
				WinSet, AlwaysOnTop, % v.AlwaysOnTop, % "ahk_id " id
			}
		}
		for k, v in ProfileClassMatchArray {
			Log.Write("c: " c " ||| v.Class: " v.Class)
			; regex match
			if (c = v.Class) {
				WinMove, % "ahk_id " id,, v.XCoord, v.YCoord, v.Width, v.Height
				WinSet, AlwaysOnTop, % v.AlwaysOnTop, % "ahk_id " id
			}
		}
		for k, v in ProfileProcessMatchArray {
			Log.Write("p: " p "||| v.Process: " v.Process)
			WinGetTitle, tt, % "ahk_id " id
			WinGetActiveTitle, t
			if (p = v.Process) {
				WinMove, % "ahk_id " id,, v.XCoord, v.YCoord, v.Width, v.Height
				WinSet, AlwaysOnTop, % v.AlwaysOnTop, % "ahk_id " id
			}
		}
	}
	return
	; for k, v in ProfileTitleMatchArray {
	; 	if (v.MatchMode = "Contains") {
	; 		WinMove, 
	; 		WinMove,,, v.XCoord, v.YCoord, v.Width, v.Height
	; 	}
	; 	; if (v.Title = thisActiveTitle) {
	; 	; 	Log.Write("Moving " v.Title)
	; 	; 	moveWin(thisActiveTitle, v)
	; 	; }
	; }
	; for k, v in ProfileClassMatchArray {
	; 	if (v.MatchMode = "Contains") {
	; 		WinMove, ahk_id %id%
	; 		WinMove,,, v.XCoord, v.YCoord, v.Width, v.Height
	; 	}
	; 	; if (v.Class = thisActiveClass) {
	; 	; 	Log.Write("Moving " v.Title)
	; 	; 	moveWin("ahk_class " thisActiveClass, v)
	; 	; }
	; }
	; for k, v in ProfileProcessMatchArray {
	; 	; if (v.Process = thisActiveProcess) {
	; 	; 	Log.Write("Moving " v.Title)
	; 	; 	moveWin("ahk_exe " thisActiveProcess, v)
	; 	; }
	; }
	; for k, v in ProfileFullCusomMatchArray {
	; 	; if (winactive(v.CustomString)) {
	; 	; 	Log.Write("Moving " v.Title)
	; 	; 	moveWin(id, v)
	; 	; }
	; }
	; ;~ for k, v in ProfileRegExMatchArray {
	; 	;~ if (v.Process == thisActiveProcess) {
	; 		;~ Log.Write("Moving " v.Title)
	; 		;~ moveWin("ahk_exe " thisActiveProcess, v)
	; 	;~ }
	; ;~ }
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

_Edit_GuiSize:
{
	Gui, _Edit_:Default
	Gui, +LastFound
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
	autoxywh("btnRemove","y")
	autoxywh("btnEdit","y")
	autoxywh("btnSetWindows", "y")
	autoxywh("btnSelectWin","y")
	autoxywh("btnSaveCoords","y")
	autoxywh("lblCurrentProfile", "y")
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
	TrayTip, Winperio, Winperio is still running. You can exit the program by right-clicking this icon and selecting Exit.
	Sleep, 3000
	trayTipCount++
	IniWrite, %trayTipCount%, %config%, Settings, TrayTipCount
	return
}

adjustColumnWidths() {
	global
	Gui, _Main_:Default
	Loop, % LV_GetCount("Column")
		LV_ModifyCol(A_Index, "AutoHdr")
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
getMatchArray(matchTypeId, currentActiveProfile) {
	global WinArray
	x := []
	for k, v in WinArray {
		if (v.Profile == currentActiveProfile and v.MoveID == matchTypeId) {
			x[v.SequenceID] := v
		}
	}
	return x
}
getProfileWinArray(currentActiveProfile) {
	global WinArray
	o := []
	for k, v in WinArray {
		if (v.Profile == currentActiveProfile) {
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
		if (seq == "Settings")
			continue
		IniRead, pro, %config%, %seq%, Profile
		IniRead, t, %config%, 	%seq%, Title
		IniRead, c, %config%, 	%seq%, Class
		IniRead, p, %config%, 	%seq%, Process
		IniRead, x, %config%, 	%seq%, X
		IniRead, y, %config%, 	%seq%, Y
		IniRead, w, %config%, 	%seq%, W
		IniRead, h, %config%, 	%seq%, H
		IniRead, m, %config%, 	%seq%, MoveID
		IniRead, aot, %config%, %seq%, AlwaysOnTop, 0
		win := new Window(seq, pro, t, c, p, x, y, w, h, m, aot)
		;~ Log.Write("Getting " win.Title)
		wa[win.SequenceID] := win
	}
	return wa
}
moveWin(w, wo) {
	WinMove, % w,, % wo.XCoord, % wo.YCoord, % wo.Width, % wo.Height
}
populateGlobalArrays() {
	global
	WinArray := getSavedWindows()
	ProfileWinArray := getProfileWinArray(currentActiveProfile)
	ProfileTitleMatchArray := getMatchArray(1, currentActiveProfile)
	ProfileClassMatchArray := getMatchArray(2, currentActiveProfile)
	ProfileProcessMatchArray := getMatchArray(3, currentActiveProfile)
}
populateListView() {
	global config, WinArray
	Log.Write("Populate ListView start")
	Gui, _Main_:Default
	LV_Delete()
	IniRead, currentActiveProfile, %config%, Settings, ActiveProfile
	Log.Write("currentActiveProfile: " currentActiveProfile)
	Log.Write(WinArray.Length())
	for k, v in WinArray 
	{
		;~ Log.Write("k: " k)
		;~ Log.Write("v: " v.SequenceID)
		if (v.Profile == currentActiveProfile)
		{
			thisMoveID := v.MoveID
			thisDisplayWin := v.Title
			thisDisplayClass := v.Class
			thisDisplayProc := v.Process
			thisMoveID_string := (thisMoveID = 1 ? "Title" : thisMoveID = 2 ? "Class" : thisMoveID = 3 ? "Process" : "ERROR")
			LV_Add(""
			, v.SequenceID
			, thisMoveID_string
			, thisDisplayWin
			, thisDisplayClass
			, thisDisplayProc
			, v.XCoord
			, v.YCoord
			, v.Width
			, v.Height)
		}
	}
	adjustColumnWidths()
	Log.Write("Populate list view end")
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
