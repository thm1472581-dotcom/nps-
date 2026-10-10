@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

REM ============================================================
REM  NPS ??????????nps2 / npc2?
REM  ??:
REM    scripts\build_all.bat
REM    scripts\build_all.bat windows          ? Windows amd64
REM    scripts\build_all.bat linux            ? Linux amd64
REM    scripts\build_all.bat all              Windows + Linux amd64????
REM ============================================================

cd /d "%~dp0.."
set "ROOT=%CD%"
set "DIST=%ROOT%\dist"
set "LDFLAGS=-s -w -buildid="
set "CGO_ENABLED=0"

set "TARGET=%~1"
if "%TARGET%"=="" set "TARGET=all"

where go >nul 2>&1
if errorlevel 1 (
  echo [ERROR] ??? go????? Go ??? PATH
  exit /b 1
)

echo.
echo ========== NPS ????? ==========
echo ????: %ROOT%
echo ????: %DIST%
echo ????: %TARGET%
go version
echo.

if not exist "%DIST%" mkdir "%DIST%"

set "FAIL=0"

if /i "%TARGET%"=="windows" goto :build_windows
if /i "%TARGET%"=="linux" goto :build_linux
if /i "%TARGET%"=="all" goto :build_all
echo [ERROR] ????: %TARGET% ??? windows / linux / all?
exit /b 1

:build_all
call :do_windows
call :do_linux
goto :summary

:build_windows
call :do_windows
goto :summary

:build_linux
call :do_linux
goto :summary

:do_windows
echo ----- ?? Windows amd64 -----
set "GOOS=windows"
set "GOARCH=amd64"
set "OUT_S=%DIST%\windows_amd64_server"
set "OUT_C=%DIST%\windows_amd64_client"
if not exist "%OUT_S%" mkdir "%OUT_S%"
if not exist "%OUT_C%" mkdir "%OUT_C%"

echo [1/2] nps2.exe ...
go build -a -ldflags "%LDFLAGS%" -o "%OUT_S%\nps2.exe" .\cmd\nps2
if errorlevel 1 (
  echo [FAIL] nps2.exe
  set "FAIL=1"
) else (
  echo [OK] %OUT_S%\nps2.exe
)

echo [2/2] npc2.exe ...
go build -a -ldflags "%LDFLAGS%" -o "%OUT_C%\npc2.exe" .\cmd\npc2
if errorlevel 1 (
  echo [FAIL] npc2.exe
  set "FAIL=1"
) else (
  echo [OK] %OUT_C%\npc2.exe
)

call :copy_server_assets "%OUT_S%"
call :copy_client_assets "%OUT_C%"
echo.
goto :eof

:do_linux
echo ----- ???? Linux amd64 -----
set "GOOS=linux"
set "GOARCH=amd64"
set "OUT_S=%DIST%\linux_amd64_server"
set "OUT_C=%DIST%\linux_amd64_client"
if not exist "%OUT_S%" mkdir "%OUT_S%"
if not exist "%OUT_C%" mkdir "%OUT_C%"

echo [1/2] nps2 ...
go build -a -ldflags "%LDFLAGS%" -o "%OUT_S%\nps2" .\cmd\nps2
if errorlevel 1 (
  echo [FAIL] nps2
  set "FAIL=1"
) else (
  echo [OK] %OUT_S%\nps2
)

echo [2/2] npc2 ...
go build -a -ldflags "%LDFLAGS%" -o "%OUT_C%\npc2" .\cmd\npc2
if errorlevel 1 (
  echo [FAIL] npc2
  set "FAIL=1"
) else (
  echo [OK] %OUT_C%\npc2
)

call :copy_server_assets "%OUT_S%"
call :copy_client_assets "%OUT_C%"
echo.
goto :eof

:copy_server_assets
set "DEST=%~1"
if not exist "%DEST%\conf" mkdir "%DEST%\conf"
if not exist "%DEST%\web" mkdir "%DEST%\web"
xcopy /E /I /Y /Q "%ROOT%\conf\*" "%DEST%\conf\" >nul
if exist "%ROOT%\web\views" xcopy /E /I /Y /Q "%ROOT%\web\views" "%DEST%\web\views\" >nul
if exist "%ROOT%\web\static" xcopy /E /I /Y /Q "%ROOT%\web\static" "%DEST%\web\static\" >nul
REM ??????????????????
if not exist "%DEST%\conf\tasks.json" echo []> "%DEST%\conf\tasks.json"
if not exist "%DEST%\conf\clients.json" echo []> "%DEST%\conf\clients.json"
if not exist "%DEST%\conf\hosts.json" echo []> "%DEST%\conf\hosts.json"
echo [OK] ?????? conf / web ?? -^> %DEST%
goto :eof

:copy_client_assets
set "DEST=%~1"
if not exist "%DEST%\conf" mkdir "%DEST%\conf"
if exist "%ROOT%\conf\npc.conf" copy /Y "%ROOT%\conf\npc.conf" "%DEST%\conf\" >nul
if exist "%ROOT%\conf\multi_account.conf" copy /Y "%ROOT%\conf\multi_account.conf" "%DEST%\conf\" >nul
echo [OK] ?????? conf ?? -^> %DEST%
goto :eof

:summary
echo ========== ???? ==========
dir /B "%DIST%"
if "%FAIL%"=="1" (
  echo.
  echo [ERROR] ???????????????
  exit /b 1
)
echo.
echo ????:
echo   %DIST%\windows_amd64_server
echo   %DIST%\windows_amd64_client
echo   %DIST%\linux_amd64_server
echo   %DIST%\linux_amd64_client
echo.
echo ???
exit /b 0
