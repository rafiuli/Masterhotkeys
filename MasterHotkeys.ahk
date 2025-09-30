#Requires AutoHotkey v2.0+
; ====================================================
; HOTKEY QUICK REFERENCE
; ====================================================
; Win + Shift + C → Calculator
; Win + Shift + P → Paint
; Win + Shift + N → Notepad
; Win + Shift + O → Outlook
; Win + Shift + B → Brave
; Win + Shift + Y → Yandex
; Win + Shift + Esc → System Informer
; Ctrl + Alt + D → Toggle Display Mode
; Ctrl + Alt + B → Toggle Default Browser
; Ctrl + Alt + S → Toggle between EDIFIER and TOSHIBA-TV output
; Ctrl + Shift + ` → Launch ColorHotkeys UI
; Ctrl + Alt + Space → Alt+Space remap ONLY for ChatGPT Companion
; ====================================================
; LAUNCH APPLICATIONS
; ====================================================
#+c:: Run("calc.exe")
#+p:: Run("mspaint.exe")
#+o:: Run("outlook.exe")
#+b:: Run("C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe")
#+y:: Run("C:\Users\rafiu\AppData\Local\Yandex\YandexBrowser\Application\browser.exe")
#+Esc:: Run("C:\Program Files\SystemInformer\SystemInformer.exe")
^+`:: Run("C:\Users\rafiu\Documents\ColorHotkeys\LaunchHotkeys.bat")

; ====================================================
; ⚙️ SYSTEM TOGGLES
; ====================================================
toggle := false
browserToggle := false

; Ctrl + Alt + D → Toggle between clone and internal display
^!d:: {
    global toggle
    toggle := !toggle
    mode := toggle ? "/clone" : "/internal"
    Run("DisplaySwitch.exe " mode)
}

; Ctrl + Alt + B → Toggle default browser between Brave and Yandex
^!b:: {
    global browserToggle
    browserToggle := !browserToggle
    toggleCommand := browserToggle
        ? 'assoc .html=BraveHTML & assoc .htm=BraveHTML & assoc http=BraveHTML & assoc https=BraveHTML & ftype BraveHTML="C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" "%1"'
        : 'assoc .html=YandexHTML & assoc .htm=YandexHTML & assoc http=YandexHTML & assoc https=YandexHTML & ftype YandexHTML="C:\Users\rafiu\AppData\Local\Yandex\YandexBrowser\Application\browser.exe" "%1"'
    Run(A_ComSpec " /c " toggleCommand, , "Hide")
    TrayTip("Default Browser Toggled", "Now using: " (browserToggle ? "Brave" : "Yandex"), 2)
}

; ─────────────────────────────────────────────
; AUDIO TOGGLE: EDIFIER R1700BT ↔ TOSHIBA-TV
; ─────────────────────────────────────────────
; Ctrl + Alt + S → Switch between TV and Edifier speakers silently
^!s:: {
    edifierIndex := 13
    toshibaIndex := 2
    current := GetCurrentAudioDevice()
    newIndex := InStr(current, "EDIFIER") ? toshibaIndex : edifierIndex
    RunWait("powershell.exe -Command Set-AudioDevice -Index " . newIndex, , "Hide")
}

GetCurrentAudioDevice() {
    ps := "((Get-AudioDevice -Playback).Name)"
    RunWait("powershell.exe -Command " Chr(34) ps " > $env:TEMP\current_audio.txt" Chr(34), , "Hide")
    return FileRead(A_Temp "\current_audio.txt")
}

; ================================
; OPEN NOTEPAD IN ACTIVE FOLDER OR DOWNLOADS
; ================================
#+n:: {
    ; Win + Shift + N
    try {
        explorerHwnd := WinActive("ahk_class CabinetWClass")
        if explorerHwnd {
            for window in ComObject("Shell.Application").Windows {
                if (window.HWND = explorerHwnd) {
                    folder := window.Document.Folder.Self.Path
                    break
                }
            }
        }
        if !IsSet(folder) || !folder {
            folder := EnvGet("USERPROFILE") "\Downloads"
        }

        ; Generate unique filename
        baseName := "New Text Document"
        file := baseName ".txt"
        counter := 1
        while FileExist(folder "\" file) {
            file := baseName " (" counter ").txt"
            counter += 1
        }

        fullPath := folder "\" file
        FileAppend "", fullPath
        Run fullPath
    } catch as e {
        MsgBox "Error: " e.Message
    }
}

; ─────────────────────────────────────────────
; CHATGPT COMPANION HOTKEY FIX (Scoped Alt+Space)
; ─────────────────────────────────────────────
; Alt + Space → Only triggers Companion inside ChatGPT
#IfWinActive ahk_exe ChatGPT.exe
!Space::Send("!{Space}")
#IfWinActive

; ─────────────────────────────────────────────
; LAUNCH AUDIO ROUTER
; ─────────────────────────────────────────────
^!a:: Run("C:\Users\rafiu\Documents\Software\Audio\AudioRouter-0.10.2 [dual audio output]\Audio Router.exe")
