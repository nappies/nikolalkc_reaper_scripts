#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;GUI SHIT
gui_width = MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM ;odredjuje sirinu status texta
;Gui, +AlwaysOnTop
Gui,Add,Text,text, MOVING SOUNDS:
Gui,Add,Text,vStatus, %gui_width%
Gui, Add, ListBox, vMyListBox gMyListBox w1000 r25
Gui, Add, Button, Default, Close

;VARIABLES SHIT
global bounced_sounds_folder := "D:\BouncedSounds\"
global current_export_folder = ""
global previous_export_path = ""
global first_field := ""
global second_field := ""
global sound_file_name := ""


;SCRIPT SHIT
Loop Files, %bounced_sounds_folder%*.ogg	;protrci kroz zadati folder
{
	if A_LoopFileAttrib contains H,R,S  ; Skip any file that is either H (Hidden), R (Read-only), or S (System). Note: No spaces in "H,R,S".
		continue  ; Skip this file and move on to the next one.
	;MsgBox %A_LoopFileName%
	sound_file_name = %A_LoopFileName%
	SeparateFolderAndFileName()
	MoveSoundToGameFolder()	
}



;KRAJ
GuiControl,,Status, DONE!
Gui, Show
return






;FUNKCIJE========================================================================================================================================


;RAZDVAJANJE IMENA FAJLA NA FOLDER I IME
SeparateFolderAndFileName()
{
	first_field := ""
	second_field := ""
	Loop, parse, sound_file_name, `-
	{
			if (A_Index = 1) {
				first_field = %A_LoopField%
			}
			if (A_index = 2) {
				second_field = %A_LoopField%
			}
	}
	;MsgBox Prvo polje: %first_field% `n` Drugo polje: %second_field%
}


;MRDANJE U ODGOVARAJUCI FOLDER
MoveSoundToGameFolder() {
	if (second_field != "") {
		;MsgBox Drugo polje nije prazno!
		if (first_field = "game") {
			;MOVEIT u INTERFACE
			FileMove, %bounced_sounds_folder%%sound_file_name%, P:\data\_interface\_sounds\%second_field%, 1
			
			GuiControl,, MyListBox,Move           %sound_file_name%     *%second_field%
			GuiControl,, MyListBox,To scene:    INTERFACE FOLDER
			GuiControl,, MyListBox,By path:     P:\data\_interface\_sounds\
			GuiControl,, MyListBox,====================================================================
			Gui, Show
		}
		else {
			folder_found :=0
			game_project_folder := "P:\data\"
			
			if (current_export_folder = first_field)	;ako je folder isti kao prosli put kad je nadjen
			{
					GuiControl,,Status, Folder %first_field% found!
					Gui,Show	
					Gui Hide
					;MOVEIT u PRETHODNI FOLDER
					FileMove, %bounced_sounds_folder%%sound_file_name%, %previous_export_path%%second_field%, 1
					
					GuiControl,, MyListBox,Move           %sound_file_name%     *%second_field%
					GuiControl,, MyListBox,To scene:    %A_LoopFileName%
					GuiControl,, MyListBox,By path:       %A_LoopFileFullPath%\_sounds\
					GuiControl,, MyListBox,====================================================================
					Gui, Show
			}
			else	;ako treba da trazi folder
			{
				;provera dal je ho folder
				isHo := 0
				StringRight, EndOfPath, first_field, 3  ; Stores the string "test." in OutputVar.
				;MsgBox, %EndOfPath%
				ho := "_ho"
				if (EndOfPath = ho)
				{
					isHo := 1
					StringTrimRight, first_field, first_field, 3
					;MsgBox %first_field%
				}
				
				Loop Files,%game_project_folder%*.*, DR
				{
					if A_LoopFileAttrib contains H,R,S  ; Skip any file that is either H (Hidden), R (Read-only), or S (System). Note: No spaces in "H,R,S".
						continue  ; Skip this file and move on to the next one.
					GuiControl,,Status, Currently searching in: %A_LoopFileName%     %A_LoopFileFullPath%
					Gui,Show
					if (A_LoopFileName = first_field) {
						GuiControl,,Status, Currently searching in: %current_foler%
						Gui, Show
						previous_export_path = %A_LoopFileFullPath%\_sounds\				; da ne trazi stalno sacuvaj adresu
						current_export_folder := first_field									;da vidi dal je isti folder
						
						if (isHo = 1) 
						{
							;MOVEIT U HO FOLDERs
							FileMove, %bounced_sounds_folder%%sound_file_name%, %A_LoopFileFullPath%\ho\_sounds\%second_field%, 1
							
							GuiControl,, MyListBox,Move           %sound_file_name%     *%second_field%
							GuiControl,, MyListBox,To scene:    %A_LoopFileName%_ho
							GuiControl,, MyListBox,By path:       %A_LoopFileFullPath%\ho\_sounds\
							GuiControl,, MyListBox,====================================================================
							Gui, Show
						}
						else 
						{
							;MOVEIT NORMALNO
							FileMove, %bounced_sounds_folder%%sound_file_name%, %A_LoopFileFullPath%\_sounds\%second_field%, 1
							
							GuiControl,, MyListBox,Move           %sound_file_name%     *%second_field%
							GuiControl,, MyListBox,To scene:    %A_LoopFileName%
							GuiControl,, MyListBox,By path:       %A_LoopFileFullPath%\_sounds\
							GuiControl,, MyListBox,====================================================================
							Gui, Show
						}
						folder_found :=1
						break
					}
					
				}
				Sleep, 100
				if (folder_found = 0) {	;kad ne nadje folder	
					GuiControl,, MyListBox,Move           %sound_file_name%     *%second_field%
					GuiControl,, MyListBox,ERROR:       FOLDER %first_field% NOT FOUND! RENAME THE SOUND PROPERLY
					GuiControl,, MyListBox,====================================================================
					Gui, Show
					Gui,Show
				}
			}
		}
	}
}




;NECCESSARY BULLSHIT ZONE===============================================================
;dugme
ButtonClose:
GuiControlGet, MyListBox  ; Retrieve the ListBox's current selection.
ExitApp
if ErrorLevel = ERROR
   MsgBox Could not launch the specified folder. Perhaps it is not associated with anything.
ExitApp


;za listu (ukradeno)
MyListBox:
if A_GuiEvent <> DoubleClick
    return
; Otherwise, the user double-clicked a list item, so treat that the same as pressing OK.
; So fall through to the next label.

;MsgBox, 4,, Would you like to launch the file or document below?`n`n%MyListBox%
;IfMsgBox, No
    ;return
; ; Otherwise, try to launch it:

return

;GuiClose:
GuiEscape:
ExitApp
;===================================================================================


