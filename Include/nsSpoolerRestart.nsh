/*
 nsSpoolerRestart
 A toybox of macros written or merged for EM-SpoolerRestart
 GSolone 17/11/22
   Credits:
     https://nsis.sourceforge.io/Write_text_to_a_file
   Mods:
     18/11/22- New: inserisco la nuova macro per il ripristino configurazione (RestoreConfiguration) e ne definisco un alias.
               New: inserisco le funzioni PowerShellExec modificate per accettare un ulteriore parametro (-ACL).
               Change: nella macro di BackupConfiguration rimuovo la label di non toccare il file (ora il file verrà salvato in ProgramFiles dove l'utente non ha potere). Definisco un alias per la macro.
*/

!macro BackupConfiguration Param1 Param2
  FileOpen $9 "${Param1}" w
  FileWrite $9 "${Param2}"
  FileClose $9
!macroend

!macro RestoreConfiguration Param1 Param2
  FileOpen $4 "${Param1}" r
  FileRead $4 "${Param2}"
  FileClose $4
!macroend

!define BackupConfiguration `!insertmacro BackupConfiguration`
!define RestoreConfiguration `!insertmacro RestoreConfiguration`


; Trim
;   Removes leading & trailing whitespace from a string
;	Source: https://nsis.sourceforge.io/Remove_leading_and_trailing_whitespaces_from_a_string
; Usage:
;   Push
;   Call Trim
;   Pop
Function Trim
	Exch $R1 ; Original string
	Push $R2

Loop:
	StrCpy $R2 "$R1" 1
	StrCmp "$R2" " " TrimLeft
	StrCmp "$R2" "$\r" TrimLeft
	StrCmp "$R2" "$\n" TrimLeft
	StrCmp "$R2" "$\t" TrimLeft
	GoTo Loop2
TrimLeft:
	StrCpy $R1 "$R1" "" 1
	Goto Loop

Loop2:
	StrCpy $R2 "$R1" 1 -1
	StrCmp "$R2" " " TrimRight
	StrCmp "$R2" "$\r" TrimRight
	StrCmp "$R2" "$\n" TrimRight
	StrCmp "$R2" "$\t" TrimRight
	GoTo Done
TrimRight:
	StrCpy $R1 "$R1" -1
	Goto Loop2

Done:
	Pop $R2
	Exch $R1
FunctionEnd

; PowerShell, modified macros
!macro PowerShellExecFileMacroParam PSFile Param
  !define PSExecID ${__LINE__}
  Push $R0

  nsExec::ExecToStack 'powershell -inputformat none -ExecutionPolicy Bypass -File "${PSFile}" -ACL "${Param}"'

  Pop $R0 ;return value is first on stack
  ;script output is second on stack, leave on top of it
  IntCmp $R0 0 finish_${PSExecID}
  SetErrorLevel 2

finish_${PSExecID}:
  Exch ;now $R0 on top of stack, followed by script output
  Pop $R0
  !undef PSExecID
!macroend

!macro PowerShellExecFileLogMacroParam PSFile Param
  !define PSExecID ${__LINE__}
  Push $R0

  nsExec::ExecToLog 'powershell -inputformat none -ExecutionPolicy Bypass -File "${PSFile}" -ACL "${Param}"'
  ;nsExec::ExecToLog 'powershell -inputformat none -ExecutionPolicy Bypass "& "${PSFile} -ACL $\"${Param}$\""'
  ;nsExec::ExecToLog 'powershell.exe "& "${PSFile} -ACL ${Param}"'
  Pop $R0 ;return value is on stack
  IntCmp $R0 0 finish_${PSExecID}
  SetErrorLevel 2

finish_${PSExecID}:
  Pop $R0
  !undef PSExecID
!macroend

!define PowerShellExecFileParam `!insertmacro PowerShellExecFileMacroParam`
!define PowerShellExecFileLogParam `!insertmacro PowerShellExecFileLogMacroParam`