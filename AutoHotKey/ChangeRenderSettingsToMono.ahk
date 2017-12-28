#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; #IfWinActive ahk_class REAPERwnd
	WinActivate ahk_class REAPERwnd
	WinMenuSelectItem, ahk_class REAPERwnd, , File, Render...
	Sleep,500
	ControlGet, OutputVar, Choice,, ComboBox2, ahk_class #32770
	;MsgBox, %OutputVar% ;odstampaj sta je trenutno izabrano

	ControlSetText, ComboBox2, Mono, ahk_class #32770
	ControlFocus Button19, ahk_class #32770
	ControlClick Button19, ahk_class #32770,,Left,2
; return