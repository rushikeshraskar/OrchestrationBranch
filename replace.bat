@echo off
setlocal enabledelayedexpansion

REM Check if required parameters are provided
if "%~1"=="" (
    echo Usage: replace.bat "current_version" "new_version"
    echo Example: replace.bat "1.0.0" "2.0.0"
    exit /b 1
)

if "%~2"=="" (
    echo Usage: replace.bat "current_version" "new_version"
    echo Example: replace.bat "1.0.0" "2.0.0"
    exit /b 1
)

set "currentVersion=%~1"
set "newVersion=%~2"
set "cpRepoUrl=https://github.com/rushikeshraskar/TestCPRepo1"
set "cpRepoDir=%~dp0TestCPRepo1"

echo.
echo ======================================
echo Update Version in CP Repository
echo ======================================
echo CP Repo URL: %cpRepoUrl%
echo Current Version: %currentVersion%
echo New Version: %newVersion%
echo ======================================
echo.

if exist "%cpRepoDir%" (
    echo Repository already exists. Removing it...
    rmdir /s /q "%cpRepoDir%"
)

echo [STEP 1] Cloning CP repository...
git clone %cpRepoUrl% "%cpRepoDir%"
if %errorlevel% neq 0 (
    echo Error: Failed to clone CP repository
    exit /b 1
)
echo [STEP 1] CP repository cloned successfully!
echo.

REM Change to CP repo directory
cd /d "%cpRepoDir%"

REM Fetch and checkout main branch
echo [STEP 2] Checking out main branch...
git fetch origin main
git checkout main
if %errorlevel% neq 0 (
    echo Error: Failed to checkout main branch in CP repo
    cd /d "%~dp0"
    exit /b 1
)
echo [STEP 2] Checked out main successfully!
echo.

REM Find and replace version in .env file
echo [STEP 3] Making version replacement in CP repository...
set "envFile=%cpRepoDir%\.env"

if not exist "%envFile%" (
    echo Warning: .env file not found at %envFile%
    echo Searching for .env file in repository...
    for /r "%cpRepoDir%" %%F in (.env) do (
        set "envFile=%%F"
        echo Found .env file at: %%F
        goto found_cp_env
    )
    echo Error: No .env file found in CP repository
    cd /d "%~dp0"
    exit /b 1
)

:found_cp_env
echo Performing version replacement in: %envFile%
powershell -Command ^
    "$content = [System.IO.File]::ReadAllText('%envFile%'); " ^
    "$newContent = $content -replace [regex]::Escape('%currentVersion%'), '%newVersion%'; " ^
    "[System.IO.File]::WriteAllText('%envFile%', $newContent);"

if %errorlevel% neq 0 (
    echo Error: Failed to perform version replacement
    cd /d "%~dp0"
    exit /b 1
)
echo [STEP 3] Version replacement successful!
echo.

REM Commit changes
echo [STEP 4] Committing changes...
git add -A
git commit -m "Update: %currentVersion% to %newVersion%"
if %errorlevel% neq 0 (
    echo Error: No changes to commit or commit failed
    cd /d "%~dp0"
    exit /b 1
)
echo [STEP 4] Changes committed successfully!
echo.

REM Push to main branch
echo [STEP 5] Pushing changes to main branch...
git push origin main
if %errorlevel% neq 0 (
    echo Error: Failed to push to main branch
    cd /d "%~dp0"
    exit /b 1
)
echo [STEP 5] Pushed to main successfully!
echo.

REM Return to original directory
cd /d "%~dp0"

echo.
echo ======================================
echo Operation completed successfully!
echo ======================================
echo Summary:
echo - Updated version in TestCPRepo1
echo - Version changed: %currentVersion% to %newVersion%
echo - Repository location: %cpRepoDir%
echo ======================================
exit /b 0
