/*
    ProcFromWin -- Get the process name, path, pid, and other information from a window.



  This program was created after I had a little trouble finding out where
  a "fakeav" program was running from, so that I could kill and clean it.
  I hope it's useful for someone. 

  As always, this program, including all code and binaries, is licensed under my
  custom license, as free and open-source software. By using either the code or binaries
  of this program, you are agreeing to that License. This Program is protected under 
  version 1.1 of the License.


  Because this program contains code written by others, those pieces of code are
  excluded from the License. As the code is written in AHK, some parts of the binaries
  may be excluded from the License as well, but bound to the AHK license instead.
  
  THIS IS BETA SOFTWARE, and has known bugs. You use it at your OWN RISK. More features 
  and code cleanup coming whenever I get around to it. The first full (non-beta) release 
  may include an ini file to configure a few gui-related elements of the program, such as those 
  shown in the Configuration section below. I may one day add information about any network 
  resources (eg: local ports) being used by the application, and/or a reverse pfw implementation
  to grab windows owned by a certain process. 

  Any official binaries of this program should work in Wine, but will only find information
  for apps running in Wine. Anything else will show up as "explorer.exe" only. The deletion
  feature may not work at all, but the process killer should. Any binaries you compile
  yourself may or may not work in any way, and cannot be guaranteed to represent the original
  program. The file location function only works under ahk basic.

   -- george2
*/

  ;Configuration: Edit this if you want to.
KillAllSleepTime := 100   ;In milliseconds
MainGuiColor := c3c3c3    ;I like just a neutral grayish color.
MainGuiTrans := 225       ;255 is fully visible, 0 is invisible. I think 225 works well.

  ;This is just to make changing the version/name string easier for me.
                                          ;BACON!                                          This program contains ?332? lines, including code, whitespace, and comments, and has ?9339? characters.
PFWVerString = ProcFromWin 0.9.3 beta


  ;Set a few important things: 
DetectHiddenText, On
DetectHiddenWindows, On
#SingleInstance, Force


;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
;===  GUI Stuff  ===============================
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  ;Main Gui
MainGuiCreate:
Gui, Font, q5 s9 c000000, Segoe UI
Gui, Color, %MainGuiColor%
Gui, Font, s8
Gui, Add, Text,, Hold cursor over window and press `n spacebar to grab info.

MainGuiShow:
Gui, Show, Hide, %PFWVerString%
Gui +ToolWindow -Caption +AlwaysOnTop +LastFound
Gui, Show, x0 y0, %PFWVerString%
WinSet, Transparent, %MainGuiTrans%, %PFWVerString%

;== Tray Menu Stuff ==
Menu, Tray, NoStandard
Menu, Tray, Add, &Help, HelpGui
Menu, Tray, Add, &About, AboutGui
Menu, Tray, Add, &Suspend/Resume, SuspendIt
Menu, Tray, Add, &Exit, EndIt
Menu, Tray, Tip, %PFWVerString%
Return

GuiClose:
OnExit:
Gui, Destroy
ExitApp
Return
  ;End Main Gui (and Tray stuff)


  ;Gui 2 - WinInfo
GetWinInfo: 
Space::
Win := GetWinofInterest()
ProcPID := GetProcPid()
ProcFullPath := GetProcPath(ProcPID)
ProcName := GetJustProc()
WinGetTitle, WinTitle, ahk_id %Win%
If WinTitle = 
  WinTitle = None
WinGetText, WinText, ahk_id %Win%
WinGetPos, XPos, YPos, WinWidth, WinHeight, ahk_id %Win%

CreateInfoWin:
IfWinExist, Window Information
	Gui, 2:Destroy
WinActivate, %PFWVerString%
Gui, 2:+owner1
Gui, 2:Add, Text,, Process: %ProcName%`nPID: %ProcPid%`nProcess location: %ProcFullPath%
Gui, 2:Add, Text, gKillItName Center, Kill all instances of process
Gui, 2:Add, Text, gKillItPid Center, Kill only this specific process. (Using PID)
Gui, 2:Add, Text, gDelIt Center, Try to delete exe.
Gui, 2:Add, Text, gMoreInfoGui Center, More information
Gui, 2:Show, h200, Window Information
Return

2GuiClose:
Gui, 2:Destroy
WinActivate, %PFWVerString%
Return

 ;The Gui options- Kill and Delete.
KillItName:
ProcessCloseAll(ProcName)
If Not ErrorLevel
	Gui, 2:Add, Text,, Process appears to have been killed successfully. 
ProcState := ProcessExist(ProcName)
Gui, 2:+Resize
Return

KillItPid:
ProcessCloseAll(ProcPID)
If Not ErrorLevel
	Gui, 2:Add, Text,, Process appears to have been killed successfully. 
ProcState := ProcessExist(ProcPID)
Gui, 2:+Resize
Return

DelIt:     ;No, you can't make it delete itself. :P
Process, close, %ProcName%
IfNotExist, %ProcFullPath%
	Gui, 2:Add, Text,, That file does not appear to exist.
IfExist, %ProcFullPath%
{
	FileDelete, %ProcFullPath%
	IfNotExist, %ProcFullPath%
		Gui, 2:Add, Text,, File successfully deleted.
}

Return
  ;End Gui 2 - WinInfo

  ;Gui 3 - About
AboutGui:
Gui, 3:+owner1
Gui, 3:Color, dddddd
Gui, 3:Font, c000044 s9 q5, Segoe UI
Gui, 3:Add, Text, gPFWHome, %PFWVerString%
Gui, 3:Add, Text, gMEHome, Created by george2. 
Gui, 3:Add, Text, gAHKHome, Made possible by AHK.
Gui, 3:Show,, About %PFWVerString%
Return

PFWHome:
;Run, www.[myhome].com/[pfwhomepage]?PWF
Return

MEHome:
;Run, www.[myhome].com/?PWF
Return

AHKHome:
Run, www.autohotkey.com
Return

3GuiClose:
Gui, 3:Destroy
WinActivate, %PFWVerString%
Return
  ;End Gui 3 - About

  ;Gui 4 - Help
HelpGui:
Gui, 4:+owner1
Gui, 4:Font, s9 q5, Segue UI
Gui, 4:Add, Text, Center, To use ProcFromWin, simply point your cursor over the `nwindow you want to analyze`, and hit the spacebar.`nThis should show you a window with information`nabout the window you selected`, and the options to `nkill and/or delete the exe running the window, `nor show more information about it.`n`nProcFromWin was designed after I ran into a `nscareware/fakeav that was using a script host to run `nitself`, and had a little trouble figuring out what `nexe/process the malware was using. I couldn't `nstop thinking about how much easier it `nwould have been if I had had a tool like this.`nNow I do. I hope someone else can put`nit to use for a similar purpose.`n`n
Gui, 4:Show,, ProcFromWin Help
Return

4GuiClose:
Gui, 4:Destroy
WinActivate, %PFWVerString%
Return
  ;End Gui 4 - Help

  ;Gui 5 - More Information
MoreInfoGui:
Gui, 5:+owner2
Gui, 5:Add, Picture,, %ProcFullPath%
Gui, 5:Add, Text, , Copyable executable location:
Gui, 5:Add, Edit, , %ProcFullPath%
Gui, 5:Add, Text, , `nWindow title: %WinTitle%
Gui, 5:Add, Text, , `nWindow text (if any):
Gui, 5:Add, Edit, h100 w300, %WinText%
Gui, 5:Add, Text, , `nWindow size and position: XPos = %XPos%`, YPos = %YPos%`, Width = %WinWidth%`, Height = %WinHeight% %A_Space%  %A_Space% 
Gui, 5:Add, Text, gMakeFakeWin, `nEmulate window
Gui, 5:Add, Text, , 
Gui, 5:Show,, More Information
Gui, 5:+Resize
Return

5GuiClose:
Gui, 5:Destroy
WinActivate, %PFWVerString%
Return
  ;End Gui 5 - More Info

  ;Gui 6 - Fake Window
MakeFakeWin:
Gui, 6:Destroy
Gui, 6:+owner5
Gui, 6:Add, Text,, %WinText%
Gui, 6:Show, W%WinWidth% H%WinHeight% X%XPos% Y%YPos%, %WinTitle%
WinMove, A,, %XPos%, %YPos%, %WinWidth%, %WinHeight%
WinSet, Transparent, 200, A
Gui, 6:+ToolWindow
Return

6GuiClose:
Gui, 6:Destroy
WinActivate, %PFWVerString%
Return
  ;End Gui 6 - Fake Window


SuspendIt:
If Suspent = 1
{
	Suspend
	WinRestore, %PFWVerString%
	Suspent := 0
}
Else
{
	Suspent := 1
	WinMinimize, %PFWVerString%
	Suspend
}
Return

EndIt:
Gui, 6:Destroy
Gui, 5:Destroy
Gui, 4:Destroy
Gui, 3:Destroy
Gui, 2:Destroy
Gui, 1:Destroy
ExitApp
Return
;=================;
;= End Gui Stuff =;
;^^^^^^^^^^^^^^^^^;










;==================================================;
;== These are the functions used by the program. ==;
;=          They are what makes it tick.          =;
;=  CAUTION: Looking at these functions may fry   =;
;=  your brains, or make you think of spaghetti.  =;
;==             YOU HAVE BEEN WARNED             ==;
;==================================================;

GetWinofInterest() ;Get the ID of the window under the cursor
{
	MouseGetPos,,, Win
	Return, Win
}
Return


GetWinId()  ;Don't have clue what this does. Uses the Win ID to get the Win ID? Anyway, it's not used at all in this program, so I don't know why I wrote it. You can delete it if you want, but it'll only save a few bytes.
{
	global Win
	WinGet, WinID, ID, ahk_id %Win%
	Return, WinID
}
Return


GetProcPath(p_pid)  ;code contributed by an #ahk-er -- gets proc (exe) and full path from win. I didn't change a whole lot here, but I did make a few tweaks.
{
	h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", p_pid )
	If (ErrorLevel or h_process = 0)  ;Check for errors
		Return, "Error retrieving information! (Usually occurs if the window was running as admin. Try running PFW as admin if you need this info.)"
	name_size = 255   ;Don't let the path be over 255 chars long. I don't recommend changing this unless you have a valid reason.
	VarSetCapacity( ProcFullPath, name_size )    ; ^
	result := DllCall( "psapi.dll\GetModuleFileNameExA", "uint", h_process, "uint", 0, "str", ProcFullPath, "uint", name_size )    ;Call psapi.dll's GetModuleFileNameExA function.
	DllCall( "CloseHandle", h_process )   ;Release the dll
	Return, ProcFullPath
}
Return


GetJustProc() ;Get only the proc (exe) for the win
{
	global Win
	WinGet, ProcName, ProcessName, ahk_id %Win%
	Return, ProcName
}
Return


GetProcPID() ;Get just the pid
{
	global Win
	WinGet, ProcPID, PID, ahk_id %Win%
	Return, ProcPID
}
Return


ProcessExist(exeName)  ;From https://github.com/camerb/AHKs/blob/master/FcnLib-Rewrites.ahk
{
	Process, Exist, %exeName%
	return !!ERRORLEVEL
}


ProcessClose(exeName)  ;From same
{
	Process, Close, %exeName%
}


ProcessCloseAll(exeName)  ;From same
{
	while ProcessExist(exeName)
	{
		ProcessClose(exeName)
		Sleep, %KillAllSleepTime%  ;Slightly modified from original. camerb had the sleep time set to 10 ms.
	}
}

;EOF