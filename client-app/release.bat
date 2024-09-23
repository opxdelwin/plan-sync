@echo off
cls
SETLOCAL ENABLEDELAYEDEXPANSION

REM Store the current working directory in a variable
SET "pwd_variable=%cd%"

REM Removing old releases file.
echo Deleting Old releases folder
del /Q "%pwd_variable%/releases"

REM Run Flutter commands sequentially and check for errors
echo Running flutter clean...
call flutter clean
IF ERRORLEVEL 1 (
    echo Error: flutter clean failed.
    exit /b 1
)

echo Running flutter pub get...
call flutter pub get
IF ERRORLEVEL 1 (
    echo Error: flutter pub get failed.
    exit /b 1
)

echo Running flutter build appbundle --release...
call flutter build appbundle --release
IF ERRORLEVEL 1 (
    echo Error: flutter build appbundle failed.
    exit /b 1
)

REM Navigate to the release bundle directory
cd build\app\outputs\bundle\release\
IF ERRORLEVEL 1 (
    echo Error: Failed to change directory to build\app\outputs\bundle\release.
    exit /b 1
)

REM Extract version code from pubspec.yaml and rename the bundle
SET "version_code="
FOR /F "tokens=2 delims=:" %%a IN ('findstr /C:"version:" "%pwd_variable%\pubspec.yaml"') DO (
    SET "version_code=%%a"
)
SET "version_code=!version_code: =!"  REM Remove leading spaces

IF EXIST "app-release.aab" (
    echo Renaming app-release.aab to !version_code!.aab...
    REN "app-release.aab" "!version_code!.aab"
) ELSE (
    echo Error: app-release.aab not found.
    exit /b 1
)

REM Create releases directory if it doesn't exist
echo Creating releases directory...
if not exist "%pwd_variable%\releases" mkdir "%pwd_variable%\releases"

REM Move the renamed bundle to the releases directory
echo Moving !version_code!.aab to %pwd_variable%\releases\...
MOVE "!version_code!.aab" "%pwd_variable%\releases\" 
IF ERRORLEVEL 1 (
    echo Error: Failed to move the bundle.
    exit /b 1
)

REM Create a zip file of the specified folder and move it to releases
echo Creating zip file of native libraries...
powershell -command "Compress-Archive -Path '%pwd_variable%\build\app\intermediates\merged_native_libs\release\out\lib\' -DestinationPath '%pwd_variable%\releases\symbol.zip'"
IF ERRORLEVEL 1 (
    echo Error: Failed to create zip file.
    exit /b 1
)

REM Open folder in explorer
cd "%pwd_variable%/releases"
call explorer .

echo Process completed successfully.