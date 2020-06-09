#Include, VoiceMeeter.ahk
#InstallKeybdHook 
#Persistent
#Warn

SendMode Input
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode 2

GroupAdd, Browsers, ahk_class MozillaWindowClass
; GroupAdd, Browsers, ahk_class Chrome_WidgetWin_1

;;; Prefixes:
;;; ! Alt
;;; ^ Ctrl
;;; + Shift
;;; # Windows

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                VS Code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive, Wavelength - Visual Studio Code
  !r::
    Send ^s
    if WinExist("ahk_exe Unity.exe")
      WinActivate, ahk_exe Unity.exe
      Sleep, 10
      WinActivate, ahk_exe Code.exe
  return

  !+r::
    Send ^s
    if WinExist("ahk_exe Unity.exe")
      WinActivate, ahk_exe Unity.exe
      Sleep, 200
      Send, ^p

  return
#IfWinActive, .ahk - AHK - Visual Studio Code
  !r::Send, ^+{F5}
#IfWinActive, ahk_exe Code.exe
  !+p::Send, ^+p
  !w::Send ^w
  !p::Send ^p
  !f::Send ^f
  !+f::Send ^+f
  ![::Send ^{PgUp}
  !]::Send ^{PgDn}
#IfWinActive


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                Browsers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#IfWinActive ahk_group Browsers
  !1::Send ^1
  !2::Send ^2
  !3::Send ^3
  !4::Send ^4
  !5::Send ^5
  !6::Send ^6
  !7::Send ^7
  !t::Send ^t
  +!t::Send +^t
  !w::Send ^w
  !l::Send ^l
  !r::Send ^r
  !f::Send ^f
  !n::Send ^n

  ![::Send ^{PgUp}
  !]::Send ^{PgDn}
  !+[::Send ^{PgUp}
  !+]::Send ^{PgDn}

  ^[::Send ^{PgUp}
  ^]::Send ^{PgDn}
  ^+[::Send ^{PgUp}
  ^+]::Send ^{PgDn}

;   !Left::SendInput !{Left}
;   !Right::SendInput !{Right}
;   !LButton::SendInput ^{LButton}
;   !\::Send ^\
#IfWinActive


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Function keys
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Volume_Mute::Send, {F1}
!Volume_Down::Send, {F2}
!Volume_Up::Send, {F3}
!Media_Play_Pause::Send, {F4}
!Media_Prev::Send, {F5}
^+Media_Prev::Send, ^+{F5}
!Media_Next::Send, {F6}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               MAC Magnet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; !^Left::SendInput #{Left}
; !^Right::SendInput #{Right}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               MAC-STUFF 🍎
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

altTabGroup(windowGroup) {
  WinGetTitle, currentWindow, A
  WinGet windows, List
  Loop %windows%
  {
    id := windows%A_Index%
    WinGetTitle window, ahk_id %id%
    WinGet exe, ProcessName, ahk_id %id%
    
    if (window != currentWindow && exe == windowGroup) {
      SetTitleMatchMode 1
      ; MsgBox, %window%
      WinActivate, %window%
      Break
    }
  }
}

; Recreate Alt-` to alt-tab between windows of the same group. 
!`::
  IfWinActive, ahk_exe Code.exe
  {
    altTabGroup("Code.exe")
  }
  
  IfWinActive, ahk_exe firefox.exe 
  {
    altTabGroup("firefox.exe")
  }
return

!c::Send, ^c
!x::Send, ^x
!v::Send, ^v
!s::Send, ^s
!z::Send, ^z
!/::Send, ^/
!a::Send, ^a

;; Alt+H To Minimize
!h::WinMinimize,a

;; Alt-q to Quit
!q::Send !{F4}

;; Undo
!+z::Send ^y

; #Left::SendInput ^{Left}
; #Right::SendInput ^{Right}
; #+Left::SendInput ^+{Left}
; #+Right::SendInput ^+{Right}

!+Left::Send, +{Home}
!+Right::Send, +{End}
!Right::Send, {End}
!Left::Send, {Home}

!Down::Send,^{End}
!+Down::Send, ^+{End}
!Up::Send,^{Home}
!+Up::Send, ^+{Home}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            VOICEMEETER 🍌
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Global Audio
Volume_Mute::
  mute := vmRead("Bus[2].Mute")
  if (mute == 1)
      mute := 0
  else
      mute := 1
  vmSet("Bus[2].Mute", mute)
  vmSet("Bus[1].Mute", mute)
  vmSet("Bus[0].Mute", mute)
return

Volume_Down::
  volume := vmRead("Bus[2].Gain")
  volume -= 2
  vmSet("Bus[0].Gain", volume)
  vmSet("Bus[1].Gain", volume)
  vmSet("Bus[2].Gain", volume)
return

Volume_Up::
  volume := Round(vmRead("Bus[2].Gain"))
  volume += 2
  vmSet("Bus[0].Gain", volume)
  vmSet("Bus[1].Gain", volume)
  vmSet("Bus[2].Gain", volume)
return

+Volume_Up::
  volume = 0
  vmSet("Bus[2].Gain", 0)
  vmSet("Bus[1].Gain", 0)
  vmSet("Bus[0].Gain", 0)
return


; Game Audio 
+F13::
    vmSet("Strip[3].Gain", 0)
return 
F13::
    volume := Round(vmRead("Strip[3].Gain"))
    volume += 2
    vmSet("Strip[3].Gain", volume)
return
F14::
    volume := Round(vmRead("Strip[3].Gain"))
    volume -= 2
    vmSet("Strip[3].Gain", volume)
return
F15::vmToggle("Strip[3].Mute")

; Join discord chat
+F11::
  if WinExist("ahk_exe Discord.exe")
      WinActivate, ahk_exe Discord.exe

  Send, ^t{!}root beer 
  Sleep, 100  
  Send, {Enter}
return


; Discord / Music Audio 
+F17::vmSet("Strip[4].Gain", 0)
F17::
  volume := Round(vmRead("Strip[4].Gain"))
  volume += 2
  vmSet("Strip[4].Gain", volume)
return
F18::
    volume := Round(vmRead("Strip[4].Gain"))
    volume -= 2
    vmSet("Strip[4].Gain", volume)
return
F19::vmToggle("Strip[4].Mute")


; Speakers Mode
F20::
    vmSet("Bus[1].Mute", 0)
    vmSet("Bus[0].Mute", 0)
    vmSet("Bus[2].Mute", 1)
    vmSet("Strip[0].Mute", 1)
    vmSet("Strip[3].A2", 1)
    vmSet("Strip[1].Mute", 1)
    vmSet("Command.Restart", 1)
return
+F20:: ; Pass-thru mode webcam mic
    vmSet("Strip[3].A2", 0)
    vmSet("Strip[1].Mute", 0)
return


; Headphones Mode
F16::
    vmSet("Bus[1].Mute", 1)
    vmSet("Bus[0].Mute", 0)
    vmSet("Strip[1].Mute", 1)
    vmSet("Strip[0].Mute", 0)
    vmSet("Strip[3].A2", 1)
return
+F16::vmSet("Strip[0].Mute", 1)

; Alt headphones
^F16::
    vmSet("Bus[2].Mute", 0)
    vmSet("Bus[1].Mute", 1)
    vmSet("Bus[0].Mute", 1)
    vmSet("Command.Restart", 1)
return


; vmToggle mic off when 
; #IfWinActive ahk_exe ModernWarfare.exe
; v::
;     Send {v down}
;     vmSet("Strip[0].Mute", 1)
;     KeyWait, v
;     Send {/ up}
;     vmSet("Strip[0].Mute", 0)
; return