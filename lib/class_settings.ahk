class Settings {
  static ConfigPath := A_AppData "\Winperio"
  static ConfigFile := A_AppData "\Winperio\winperio.ini"
  static TrayIcon := A_AppData "\Winperio\winperio.ico"
  
  ProfileSync := 0
  Profiles := ""
  ActiveProfile := ""
  TrayTipCount := 0

  Init() {
    IfNotExist, % Settings.ConfigPath
      FileCreateDir, % Settings.ConfigPath
    IfNotExist, % Settings.ConfigFile
    {
      IniWrite, 0, % Settings.ConfigFile, Settings, ProfileSync
      IniWrite, % "Default", % Settings.ConfigFile, Settings, Profiles
      IniWrite, % "Default", % Settings.ConfigFile, Settings, ActiveProfile
      IniWrite, 0, % Settings.ConfigFile, Settings, TrayTipCount
    }
    Try
		  Menu, tray, Icon, % Settings.TrayIconFile
  }
}