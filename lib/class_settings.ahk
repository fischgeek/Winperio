class Settings {
  static ConfigPath := A_AppData "\Winperio"
  static ConfigFile := A_AppData "\Winperio\winperio.ini"
  static TrayIcon := A_AppData "\Winperio\winperio.ico"
  
  ProfileSync := 0
  Profiles := ""
  ActiveProfile := ""
  TrayTipCount := 0

  Init() {
    this.FileInstalls()
    IfNotExist, % Settings.ConfigPath
      FileCreateDir, % Settings.ConfigPath
    IfNotExist, % Settings.ConfigFile
    {
      IniWrite, 0, % Settings.ConfigFile, Settings, ProfileSync
      IniWrite, % "Default", % Settings.ConfigFile, Settings, Profiles
      IniWrite, % "Default", % Settings.ConfigFile, Settings, ActiveProfile
      IniWrite, 0, % Settings.ConfigFile, Settings, TrayTipCount
    }
    Menu, tray, Icon, % Settings.TrayIcon
  }
  FileInstalls() {
    FileInstall, assets\winperio.ico, % A_AppData "Winperio\winperio.ico", 1
  }
}