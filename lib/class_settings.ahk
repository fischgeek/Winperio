class Settings {
  static ConfigPath := A_AppData "\Winperio"
  static ConfigFile := A_AppData "\Winperio\winperio.ini"
  static TrayIcon := A_ScriptDir "\assets\winperio.ico"
  
  ProfileSync := 0
  Profiles := []
  ActiveProfile := ""
  TrayTipCount := 0

  __New() {
    this.Init()
    this.ActiveProfile := this.GetActiveProfile()
    this.Profiles := this.GetProfiles()
  }
  AddProfile(newProfile) {
    this.Profiles.Push(newProfile)
    this.SaveProfiles()
  }
  DeleteProfileNumber(profileNumber) {
    this.Profiles.RemoveAt(profileNumber)
    this.SaveProfiles()
  }
  DeleteWindow(window) {
    IniDelete, % this.ConfigFile, % window.SequenceID
  }
  GetActiveProfile() {
    IniRead, p, % this.ConfigFile, Settings, ActiveProfile, %A_Space%
    return p
  }
  GetProfiles() {
    IniRead, p, % this.ConfigFile, Settings, Profiles, %A_Space%
    pros := []
    Loop, parse, % p, CSV
      pros.Push(A_LoopField)
    return pros
  }
  Init() {
    IfNotExist, % this.ConfigPath
      FileCreateDir, % this.ConfigPath
    IfNotExist, % this.ConfigFile
    {
      IniWrite, 0, % this.ConfigFile, Settings, ProfileSync
      IniWrite, % "Default", % this.ConfigFile, Settings, Profiles
      IniWrite, % "Default", % this.ConfigFile, Settings, ActiveProfile
      IniWrite, 0, % this.ConfigFile, Settings, TrayTipCount
    }
    Try
      Menu, tray, Icon, % this.TrayIcon
  }
  SaveProfiles() {
    for k, v in this.Profiles
      saveString .= v ","
    StringTrimRight, saveString, saveString, 1
    IniWrite, % saveString, % this.ConfigFile, Settings, Profiles
  }
  SetActiveProfile(profile) {
    ; TODO check if exists
    this.ActiveProfile := profile
  }
  TogglePauseWindow(win) {
    Log.Write("win.IsPaused Before" win.IsPaused)
		win.IsPaused := !win.IsPaused
    Log.Write("win.IsPaused After" win.IsPaused)
		IniWrite, % win.IsPaused, % this.ConfigFile, % win.SequenceID, IsPaused
	}

  ; internal
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
}