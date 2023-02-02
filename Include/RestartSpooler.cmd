:: User Spooler Restart
:: GSolone 2022
:: Credits: https://stackoverflow.com/a/3325123/2220346
@echo off
sc query | findstr /i "lpdsvc"
IF %ERRORLEVEL% EQU 0 net stop lpdsvc
net stop spooler
ping -n 5 127.0.0.1 > nul
for /F "tokens=3 delims=: " %%H in ('sc query "lpdsvc" ^| findstr /i "STAT"') do (
  if /I "%%H" NEQ "RUNNING" (
   net start "lpdsvc"
  )
)
for /F "tokens=3 delims=: " %%H in ('sc query "spooler" ^| findstr /i "STAT"') do (
  if /I "%%H" NEQ "RUNNING" (
   net start "spooler"
  )
)