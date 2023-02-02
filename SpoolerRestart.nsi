/* GSolone 17/11/22
   Credits:
    https://superuser.com/a/1689265 (spooler ACL modifications) - alternative: https://www.winhelponline.com/blog/view-edit-service-permissions-windows/
    https://nsis.sourceforge.io/PowerShell_support (NSIS PowerShell support)
    https://stackoverflow.com/a/31073886/2220346 (CMD if service exists, then stop it)
    https://stackoverflow.com/a/1018605/2220346 (NSIS Create shortcut and execute it minimized)
   Icon:
    https://www.flaticon.com/free-icons/print - Print icons created by Freepik - Flaticon
    https://www.flaticon.com/free-icons/forbidden - Forbidden icons created by Good Ware - Flaticon
   Modifiche:
    18/11/22- Bugfix: risolvo il mancato scambio dati corretto tra NSIS e PowerShell. Integro due macro nuove per permettere di accodare il parametro ACL rilevato da sc shshow via NSIS CMD.
              Change: inserisco tutto il necessario per installare l'applicazione a bordo macchina e non solo eseguirla.
                      I file di backup si salvano nella cartella programma e non più nella UserProfile così da rimanere un po' più al sicuro.
              Improve: rimuovo il blocco e lo script per ottenere la UserProfile dell'utente connesso alla macchina.
              Improve: pulizia codice di troppo e commenti. Porto in blocco header tutti i vari puntamenti / credits verso fonti utilizzate.
              Improve: il blocco di disinstallazione ora si occupa anche del restore delle configurazioni originali prima di fare la pulizia di file e cartelle del programma.
              New: scrivo e porto dentro il batch che si occupa del riavvio servizi di stampa. Icona sul Desktop (Public) in avvio minimizzato e con icona del programma.
              New: scelta obbligata nella schermata componenti, valutare rimozione e passare direttamente all'installazione per una prossima versione.
    17/11/22- prima versione.
*/

!define PRODUCT_NAME "User Spooler Restart"
!define PRODUCT_VERSION "0.2"
!define PRODUCT_VERSION_MINOR "1.0"
!define PRODUCT_PUBLISHER "Emmelibri S.r.l."
!define PRODUCT_WEB_SITE "https://www.emmelibri.it"
!define PRODUCT_BUILD "${PRODUCT_NAME} ${PRODUCT_VERSION}.${PRODUCT_VERSION_MINOR} (build ${MyTIMESTAMP})"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\exe\RestartSpooler.cmd"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define USRDIR "$PROGRAMFILES\${PRODUCT_NAME}"

!include "MUI.nsh"
!include "FileFunc.nsh"
!include "Include\nsProcess.nsh"
!include "Include\nsPsExec.nsh"
!include "Include\nsSpoolerRestart.nsh"
!addplugindir "Plugins"

!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_NODESC
!define MUI_ICON "Include\icons\printer.ico"
!define MUI_UNICON "Include\icons\printer_uninstall.ico"
!define /date MyTIMESTAMP_Yr "%Y"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

VIProductVersion "${PRODUCT_VERSION}.${PRODUCT_VERSION_MINOR}"
VIAddVersionKey ProductName "${PRODUCT_NAME}"
VIAddVersionKey Comments "${PRODUCT_NAME}"
VIAddVersionKey CompanyName "Emmelibri S.r.l."
VIAddVersionKey LegalCopyright GSolone
VIAddVersionKey FileDescription "Permits spooler restart to user"
VIAddVersionKey FileVersion ${PRODUCT_VERSION}
VIAddVersionKey ProductVersion ${PRODUCT_VERSION}
VIAddVersionKey InternalName "${PRODUCT_VERSION}"
VIAddVersionKey LegalTrademarks "GSolone, ${MyTIMESTAMP_Yr}"
VIAddVersionKey OriginalFilename "SpoolerRestart-${PRODUCT_VERSION}.exe"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "EM_UserSpoolerRestart_${PRODUCT_VERSION}.exe"
InstallDir "${USRDIR}"
ShowInstDetails show
ShowUnInstDetails show
BrandingText "Emmelibri S.r.l. - GSolone ${MyTIMESTAMP_Yr}"

Var LPDSVC_ORIG_CONFIG
Var SPOOLER_ORIG_CONFIG
Var LPDSVC_RESTORE
Var SPOOLER_RESTORE

RequestExecutionLevel admin
SpaceTexts none

Section "User Spooler Restart" INST_SpoolerModACL
 ; Root folder
 SetOverwrite on
 SetOutPath "${USRDIR}"
 File "Include\icons\printer.ico"
 File "Include\RestartSpooler.cmd"
 CreateDirectory "${USRDIR}\Save"

 ; Script
 SetOutPath "${USRDIR}\PS1"
 File "Include\Split.ps1"
 
 ; Check esistenza servizio LPDSVC che si allaccia a Spooler
 SimpleSC::ExistsService "LPDSVC"
 Pop $0 ; returns an errorcode (<>0) otherwise success (0)
 StrCmp $0 0 0 LPDSVC_KO
  DetailPrint "LPDSVC service found."
  nsExec::ExecToStack '"$SYSDIR\cmd.exe" /c "sc sdshow LPDSVC"'
  Pop $0 ; return value/error/timeout
  Pop $1 ; printed text, up to ${NSIS_MAX_STRLEN}
  Push $1
  Call Trim
  Pop $LPDSVC_ORIG_CONFIG
  DetailPrint "Current configuration: $LPDSVC_ORIG_CONFIG"
  IfFileExists "${USRDIR}\Save\LPDSVC.config" 0 LPDSVC_Backup
   DetailPrint "${USRDIR}\Save\LPDSVC.config already found, skip."
   Goto LPDSVC_Backup_Skip

  LPDSVC_Backup:
   ${BackupConfiguration} "${USRDIR}\Save\LPDSVC.config" "$LPDSVC_ORIG_CONFIG"
  
  LPDSVC_Backup_Skip:
   ${PowerShellExecFileParam} "${USRDIR}\PS1\Split.ps1" "$LPDSVC_ORIG_CONFIG"
   Pop $R1
   DetailPrint "Modifying LPDSVC service configuration ..."
   nsExec::ExecToStack '"$SYSDIR\cmd.exe" /c "sc.exe sdset LPDSVC "$R1""'
   Pop $0 ; return value/error/timeout
   Pop $1 ; printed text, up to ${NSIS_MAX_STRLEN}
   DetailPrint "$1"
   Goto SPOOLER_Check

 LPDSVC_KO:
  DetailPrint "LPDSVC service was not found or shutted down."
  
 ; Check ACL Spooler
 SPOOLER_Check:
  SimpleSC::ExistsService "Spooler"
  Pop $0 ; returns an errorcode (<>0) otherwise success (0)
  StrCmp $0 0 0 SPOOLER_KO
   DetailPrint "Spooler service found."
   nsExec::ExecToStack '"$SYSDIR\cmd.exe" /c "sc sdshow Spooler"'
   Pop $0 ; return value/error/timeout
   Pop $1 ; printed text, up to ${NSIS_MAX_STRLEN}
   Push $1
   Call Trim
   Pop $SPOOLER_ORIG_CONFIG
   DetailPrint "Current configuration: $SPOOLER_ORIG_CONFIG"
   IfFileExists "${USRDIR}\Save\SPOOLER.config" 0 SPOOLER_Backup
    DetailPrint "${USRDIR}\Save\SPOOLER.config already found, skip."
    Goto SPOOLER_Backup_Skip
    
  SPOOLER_Backup:
   ${BackupConfiguration} "${USRDIR}\Save\SPOOLER.config" "$SPOOLER_ORIG_CONFIG"

  SPOOLER_Backup_Skip:
   ${PowerShellExecFileParam} "${USRDIR}\PS1\Split.ps1" "$SPOOLER_ORIG_CONFIG"
   Pop $R1
   DetailPrint "Modifying SPOOLER service configuration ..."
   nsExec::ExecToStack '"$SYSDIR\cmd.exe" /c "sc.exe sdset Spooler "$R1""'
   Pop $0 ; return value/error/timeout
   Pop $1 ; printed text, up to ${NSIS_MAX_STRLEN}
   DetailPrint "$1"
   Goto URS_Exit
   
 SPOOLER_KO:
  DetailPrint "Spooler service was not found or shutted down."

 URS_Exit:
  SetOutPath "${USRDIR}"
  CreateDirectory "$SMPrograms\User Spooler Restart"
  CreateShortcut "$SMPrograms\User Spooler Restart\Riavvia Servizi Stampa.lnk" "${USRDIR}\RestartSpooler.cmd" "" "${USRDIR}\printer.ico" 0 SW_SHOWMINIMIZED
  CreateShortCut "$DESKTOP\Riavvia Servizi Stampa.lnk" "${USRDIR}\RestartSpooler.cmd" "" "${USRDIR}\printer.ico" 0 SW_SHOWMINIMIZED
SectionEnd

Section -Post
 WriteUninstaller "${USRDIR}\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "${USRDIR}\RestartSpooler.cmd"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "${USRDIR}\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "${USRDIR}\printer.ico"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function .onInit
 SetShellVarContext All
 IntOp $0 ${SF_SELECTED} | ${SF_RO}
 SectionSetFlags ${INST_SpoolerModACL} $0
FunctionEnd

Function un.onInit
  SetShellVarContext All
FunctionEnd

Section Uninstall
  SetOutPath $TEMP
  ; Ripristino precedenti ACL
  DetailPrint "Search and restore original services configuration, please wait."
  
  SimpleSC::ExistsService "LPDSVC"
  Pop $0 ; returns an errorcode (<>0) otherwise success (0)
  StrCmp $0 0 0 SPOOLER_Restore
   DetailPrint "LPDSVC service found, restore configuration in progress."
   ${RestoreConfiguration} "${USRDIR}\Save\LPDSVC.config" "$LPDSVC_RESTORE"
   nsExec::ExecToStack '"$SYSDIR\cmd.exe" /c "sc.exe sdset LPDSVC "$LPDSVC_RESTORE""'
   Pop $0 ; return value/error/timeout
   Pop $1 ; printed text, up to ${NSIS_MAX_STRLEN}
   DetailPrint "$1"

  SPOOLER_Restore:
   SimpleSC::ExistsService "Spooler"
   Pop $0 ; returns an errorcode (<>0) otherwise success (0)
   StrCmp $0 0 0 UNINSTALL_Delete
    DetailPrint "Spooler service found, restore configuration in progress."
    ${RestoreConfiguration} "${USRDIR}\Save\SPOOLER.config" "$SPOOLER_RESTORE"
    nsExec::ExecToStack '"$SYSDIR\cmd.exe" /c "sc.exe sdset Spooler "$SPOOLER_RESTORE""'
    Pop $0 ; return value/error/timeout
    Pop $1 ; printed text, up to ${NSIS_MAX_STRLEN}
    DetailPrint "$1"
  
  ; Cancellazione file
  UNINSTALL_Delete:
   ; Collegamenti
   Delete "$SMPrograms\User Spooler Restart\Riavvia Servizi Stampa.lnk"
   RmDir "$SMPrograms\User Spooler Restart"
   Delete "$DESKTOP\Riavvia Servizi Stampa.lnk"
   ; Script
   Delete "${USRDIR}\PS1\Split.ps1"
   RMDir "${USRDIR}\PS1"
   ; Backup configurazioni
   Delete "${USRDIR}\Save\SPOOLER.config"
   Delete "${USRDIR}\Save\LPDSVC.config"
   RMDir "${USRDIR}\Save"
   ; Cartella principale
   Delete "${USRDIR}\RestartSpooler.cmd"
   Delete "${USRDIR}\printer.ico"
   Delete "${USRDIR}\uninst.exe"
   RMDir "${USRDIR}"
   
   DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
   DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
   DeleteRegKey HKLM "Software\${PRODUCT_NAME}"
SectionEnd