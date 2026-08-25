:; exec "$(dirname "$0")/sync-from-official.sh" "$@"; exit
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-from-official.ps1" %*
exit /b %ERRORLEVEL%
