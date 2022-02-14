#SingleInstance, Force
#NoTrayIcon
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
SetTimer, AutoClose, -60000
targetDir := A_ProgramFiles "\WinOrg"
cPath := A_AppData "\WinOrg"
FileDelete, %A_Desktop%\WinOrg.lnk
FileDelete, %A_Startup%\WinOrg.lnk
FileDelete, %A_StartMenu%\Programs\WinOrg.lnk
FileRemoveDir, %targetDir%, 1
MsgBox, 4132, WinOrg Uninstaller, Would you like to retain your window layouts and profiles?
IfMsgBox, Yes
{
	Loop, %cPath%\*.*
	{
		if (A_LoopFileExt = ".ini")
			continue
		FileDelete, %A_LoopFileFullPath%
	}
}
IfMsgBox, No
	FileRemoveDir, %cPath%, 1
MsgBox, 64, WinOrg Uninstaller, % "Uninstall complete.`n`nWinOrg stored files in the following directories. Feel free to ensure they are removed manually if this unistaller does not work properly for some reason.`n`n..\Program Files\WinOrg`n..\AppData\Roaming\WinOrg`n`nYou can also make sure the shortcuts are removed as well. You selected them when you installed WinOrg. There are three possible locations for a WinOrg shortcut that you can remove manually should the installer fail.`n`n..\Desktop`n..\AppData\Roaming\Microsoft\Windows\Start Menu\Programs`n..\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`n`nThank you and have a nice day."
FileDelete, %A_Temp%\WinOrgUninstaller.exe
ExitApp

AutoClose:
MsgBox, 64, WinOrg Uninstaller, % "Uninstall failed.`n`nWinOrg Uninstaller has been running for an extended period of time. It will now close."
FileDelete, %A_Temp%\WinOrgUninstaller.exe
ExitApp