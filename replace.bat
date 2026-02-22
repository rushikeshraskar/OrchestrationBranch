@echo off
setlocal enabledelayedexpansion

REM Check if required parameters are provided
if "%~1"=="" (
    echo Usage: replace.bat "current_version" "new_version" "source_branch" "target_branch"
    echo Example: replace.bat "1.0.0" "2.0.0" "main" "release/2.0.0"
    exit /b 1
)

if "%~2"=="" (
    echo Usage: replace.bat "current_version" "new_version" "source_branch" "target_branch"
    echo Example: replace.bat "1.0.0" "2.0.0" "main" "release/2.0.0"
    exit /b 1
)

if "%~3"=="" (
    echo Usage: replace.bat "current_version" "new_version" "source_branch" "target_branch"
    echo Example: replace.bat "1.0.0" "2.0.0" "main" "release/2.0.0"
    exit /b 1
)

if "%~4"=="" (
    echo Usage: replace.bat "current_version" "new_version" "source_branch" "target_branch"
    echo Example: replace.bat "1.0.0" "2.0.0" "main" "release/2.0.0"
    exit /b 1
)

set "searchText=%~1"
set "replaceText=%~2"
set "sourceBranch=%~3"
set "targetBranch=%~4"
set "repoUrl=https://github.com/rushikeshraskar/DemoRepoForProduct1"
set "repoDir=%~dp0DemoRepoForProduct1"

echo.
echo ======================================
echo Git Repository Operations
echo ======================================
echo Repo URL: %repoUrl%
echo Source Branch: %sourceBranch%
echo Target Branch: %targetBranch%
echo Current Version: %searchText%
echo New Version: %replaceText%
echo ======================================
echo.

REM Clone the repository
echo [STEP 1] Cloning repository...
if exist "%repoDir%" (
    echo Repository already exists. Removing it...
    rmdir /s /q "%repoDir%"
)

git clone %repoUrl% "%repoDir%"
if %errorlevel% neq 0 (
    echo Error: Failed to clone repository
    exit /b 1
)
echo [STEP 1] Repository cloned successfully!
echo.

REM Change to repo directory
cd /d "%repoDir%"

REM Checkout source branch
echo [STEP 2] Checking out source branch: %sourceBranch%...
git fetch origin %sourceBranch%
git checkout %sourceBranch%
if %errorlevel% neq 0 (
    echo Error: Failed to checkout source branch
    cd /d "%~dp0"
    exit /b 1
)
echo [STEP 2] Checked out %sourceBranch% successfully!
echo.

REM Create and checkout target branch
echo [STEP 3] Creating target branch: %targetBranch%...
git checkout -b %targetBranch%
if %errorlevel% neq 0 (
    echo Error: Failed to create target branch
    cd /d "%~dp0"
    exit /b 1
)
echo [STEP 3] Target branch %targetBranch% created and checked out!
echo.

REM Find and replace in .env file
echo [STEP 4] Making replacement changes...
REM Look for .env file in repo root
set "envFile=%repoDir%\.env"

if not exist "%envFile%" (
    echo Warning: .env file not found at %envFile%
    echo Searching for .env file in repository...
    for /r "%repoDir%" %%F in (.env) do (
        set "envFile=%%F"
        echo Found .env file at: %%F
        goto found_env
    )
    echo Error: No .env file found in repository
    cd /d "%~dp0"
    exit /b 1
)

:found_env
echo Performing replacement in: %envFile%
powershell -Command ^
    "$content = [System.IO.File]::ReadAllText('%envFile%'); " ^
    "$newContent = $content -replace [regex]::Escape('%searchText%'), '%replaceText%'; " ^
    "[System.IO.File]::WriteAllText('%envFile%', $newContent);"

if %errorlevel% neq 0 (
    echo Error: Failed to perform replacement
    cd /d "%~dp0"
    exit /b 1
)
echo [STEP 4] Replacement successful!
echo.

REM Commit changes
echo [STEP 5] Committing changes...
git add -A
git commit -m "Update: %searchText% to %replaceText%"
if %errorlevel% neq 0 (
    echo No changes to commit or commit failed
    cd /d "%~dp0"
    exit /b 1
)
echo [STEP 5] Changes committed successfully!
echo.

REM Push to target branch
echo [STEP 6] Pushing to target branch...
git push origin %targetBranch%
if %errorlevel% neq 0 (
    echo Error: Failed to push to target branch
    cd /d "%~dp0"
    exit /b 1
)
echo [STEP 6] Pushed to %targetBranch% successfully!
echo.

REM Return to original directory
cd /d "%~dp0"

echo ======================================
echo All operations completed successfully!
echo ======================================
echo Summary:
echo - Repository cloned from: %repoUrl%
echo - Source branch: %sourceBranch%
echo - Target branch: %targetBranch%
echo - Version update: %searchText% ^-^> %replaceText%
echo - Repository location: %repoDir%
echo ======================================
exit /b 0
