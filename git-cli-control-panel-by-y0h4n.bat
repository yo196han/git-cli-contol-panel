@echo off
setlocal EnableDelayedExpansion

:: Green color
color 0A

:: =============================
:: Session State
:: =============================
set "ACTIVE_REPO="

:: =============================
:: Detect System Info
:: =============================
for /f "tokens=2 delims==" %%A in ('wmic os get Caption /value 2^>nul') do set "OS_NAME=%%A"
for /f "tokens=2 delims==" %%A in ('wmic os get Version /value 2^>nul') do set "OS_VER=%%A"

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=AMD64 (64-bit)"
if "%PROCESSOR_ARCHITECTURE%"=="x86"   set "ARCH=x86 (32-bit)"
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=ARM64"
if "%PROCESSOR_ARCHITECTURE%"=="ARM"   set "ARCH=ARM"
if not defined ARCH set "ARCH=Unknown"

:: =============================
:: Load .env file
:: =============================
if not exist ".env" (
    echo [ERROR] .env file not found!
    pause
    exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
    set "%%A=%%B"
)

if "%GITHUB_TOKEN%"=="" (
    echo [ERROR] GITHUB_TOKEN is missing in .env
    pause
    exit /b 1
)
if "%GITHUB_USERNAME%"=="" (
    echo [ERROR] GITHUB_USERNAME is missing in .env
    pause
    exit /b 1
)

:: =============================
:: Check if Git is installed
:: =============================
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  [!] Git is not installed on this system.
    echo.
    set /p INSTALL_GIT="  Would you like to install Git now? (Y/N): "
    if /i "!INSTALL_GIT!"=="Y" goto INSTALL_GIT
    echo.
    echo  [WARNING] Git is required. Exiting...
    pause
    exit /b 1
) else (
    for /f "tokens=3" %%V in ('git --version') do set "GIT_VER=%%V"
)

:: Save script's own directory
set "SCRIPT_DIR=%~dp0"

:: =============================
:SPLASH
:: =============================
cls
color 0A
echo.
echo.
echo          .:--=+****++=:.
echo       :+*#%%@@@@@@@@@@%%#*+:
echo      *%%@@@%%*#%%@@@%%#*%%@@@%%*
echo     +@%%@%%@*:.     .:*@%%@%%@+
echo     @@%%@@%%:          :@%%@%%@@
echo    %%@@%%@%%@:         :@%%@%%@@@
echo    @+@%%@%%@*:.     .:*@%%@%%@+@
echo    @@*%%@@%%%%         %%@@@%%*@
echo    @@@+%%  @*:.      .:*@%%+.%%
echo     @%%  @ @:           :@%%@@%%
echo     +%%@  %%*=.       .=*%%%%+@
echo      -*%%@@@%%*%%@@@@@@*%%@%%*-
echo     :*%%@@@@@%%*:@@@@%%:*%%@@@%%*:
echo.
echo   =========================================
echo    git-cli-control-panel  by  y0h4n
echo    https://github.com/yo196han
echo   =========================================
echo.
echo    Welcome! This tool lets you manage your
echo    GitHub repositories directly from the CLI.
echo.
set /p "_=    Press Enter to open the main menu..."

:: =============================
:MAIN_MENU
:: =============================
cls
color 0A
echo.
echo          .:--=+****++=:.
echo       :+*#%%@@@@@@@@@@%%#*+:
echo      *%%@@@%%*#%%@@@%%#*%%@@@%%*
echo     +@%%@%%@*:.     .:*@%%@%%@+
echo     @@%%@@%%:          :@%%@%%@@
echo    %%@@%%@%%@:         :@%%@%%@@@
echo    @+@%%@%%@*:.     .:*@%%@%%@+@
echo    @@*%%@@%%%%         %%@@@%%*@      git-cli-control-panel by y0h4n
echo    @@@+%%  @*:.      .:*@%%+.%%
echo     @%%  @ @:           :@%%@@%%     github: https://github.com/yo196han
echo     +%%@  %%*=.       .=*%%%%+@
echo      -*%%@@@%%*%%@@@@@@*%%@%%*-
echo     :*%%@@@@@%%*:@@@@%%:*%%@@@%%*:
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n
echo   -----------------------------------------
echo   OS  : %OS_NAME%
echo   Ver : %OS_VER%
echo   CPU : %ARCH%
echo   Git : v!GIT_VER!
if not "!ACTIVE_REPO!"=="" (
echo   REPO: !ACTIVE_REPO!
) else (
echo   REPO: None selected
)
echo  =========================================
echo.
echo  [1]  Upload Project
echo  [2]  Clone Repository
echo  [3]  Pull Latest Changes
echo  [4]  Create ^& Switch Branch
echo  [5]  Switch Branch
echo  [6]  Merge Branch
echo  [7]  Delete Branch
echo  [8]  Show Status
echo  [9]  Show Commit Log
echo  [10] Undo Last Commit
echo  [11] Stash Changes
echo  [12] Pop Stash
echo  [13] Add Tag
echo  [14] Show Diff
echo  [15] List Repositories
echo  [16] Select a Repo to Work With
echo  [17] Clear Selected Repo
echo  [18] Create New Repository
echo  [19] Delete Repository
echo  [20] Exit
echo.
set "CHOICE="
set /p CHOICE="Choose an option: "

if "!CHOICE!"=="1"  goto UPLOAD
if "!CHOICE!"=="2"  goto CLONE
if "!CHOICE!"=="3"  goto PULL
if "!CHOICE!"=="4"  goto CREATE_BRANCH
if "!CHOICE!"=="5"  goto SWITCH_BRANCH
if "!CHOICE!"=="6"  goto MERGE
if "!CHOICE!"=="7"  goto DELETE_BRANCH
if "!CHOICE!"=="8"  goto STATUS
if "!CHOICE!"=="9"  goto LOG
if "!CHOICE!"=="10" goto UNDO
if "!CHOICE!"=="11" goto STASH
if "!CHOICE!"=="12" goto POP_STASH
if "!CHOICE!"=="13" goto TAG
if "!CHOICE!"=="14" goto DIFF
if "!CHOICE!"=="15" goto LIST_REPOS
if "!CHOICE!"=="16" goto SELECT_REPO
if "!CHOICE!"=="17" goto CLEAR_REPO
if "!CHOICE!"=="18" goto CREATE_REPO
if "!CHOICE!"=="19" goto DELETE_REPO
if "!CHOICE!"=="20" goto END


echo.
echo [ERROR] Invalid option!
pause
goto MAIN_MENU

:: =============================
:INSTALL_GIT
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  INSTALL GIT
echo  =========================================
echo.
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "GIT_URL=https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe"
    set "GIT_FILE=%TEMP%\Git-64-bit.exe"
    echo  [INFO] Downloading Git for AMD64...
) else if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set "GIT_URL=https://github.com/git-for-windows/git/releases/latest/download/Git-32-bit.exe"
    set "GIT_FILE=%TEMP%\Git-32-bit.exe"
    echo  [INFO] Downloading Git for x86...
) else if "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set "GIT_URL=https://github.com/git-for-windows/git/releases/latest/download/Git-arm64.exe"
    set "GIT_FILE=%TEMP%\Git-arm64.exe"
    echo  [INFO] Downloading Git for ARM64...
) else if "%PROCESSOR_ARCHITECTURE%"=="ARM" (
    set "GIT_URL=https://github.com/git-for-windows/git/releases/latest/download/Git-arm64.exe"
    set "GIT_FILE=%TEMP%\Git-arm.exe"
    echo  [INFO] Downloading Git for ARM...
) else (
    echo  [ERROR] Unknown architecture. Download manually: https://git-scm.com/downloads
    pause
    exit /b 1
)

curl -L -o "%GIT_FILE%" "%GIT_URL%"
if %errorlevel% neq 0 (
    echo  [ERROR] Download failed. Download manually: https://git-scm.com/downloads
    pause
    exit /b 1
)

start /wait "" "%GIT_FILE%"
del "%GIT_FILE%" 2>nul
echo  [DONE] Git installed! Please re-run this script.
pause
exit /b 0

:: =============================
:UPLOAD
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  UPLOAD
echo  =========================================
echo.
if not "!ACTIVE_REPO!"=="" (
    echo  [INFO] Using selected repo: !ACTIVE_REPO!
    set "GITHUB_REPO=!ACTIVE_REPO!"
) else (
    set /p GITHUB_REPO="Enter GitHub repo name: "
    if "!GITHUB_REPO!"=="" (
        echo [ERROR] Repo name cannot be empty!
        pause
        goto MAIN_MENU
    )
)

set "GITHUB_REPO=!GITHUB_REPO:"=!"

:: Ask for project path
echo.
set /p PROJECT_PATH="Enter project folder path (or press Enter for current folder): "
if "!PROJECT_PATH!"=="" (
    set "PROJECT_PATH=%CD%"
)

set "PROJECT_PATH=!PROJECT_PATH:"=!"

if not exist "!PROJECT_PATH!" (
    echo [ERROR] Path does not exist: !PROJECT_PATH!
    pause
    goto MAIN_MENU
)

cd /d "!PROJECT_PATH!"
if %errorlevel% neq 0 (
    echo [ERROR] Cannot access path: !PROJECT_PATH!
    pause
    goto MAIN_MENU
)

echo [INFO] Working in: !PROJECT_PATH!
echo.
echo [INFO] Setting up Git...
if exist ".git" (
    echo [INFO] Git already initialized, skipping git init.
) else (
    git init
)

git config user.name "%GITHUB_USERNAME%" >nul 2>&1
git config user.email "%GITHUB_USERNAME%@users.noreply.github.com" >nul 2>&1

if not exist ".gitignore" (
    echo .env> .gitignore
    echo [INFO] Created .gitignore with .env
) else (
    findstr /i "\.env" .gitignore >nul 2>&1
    if !errorlevel! neq 0 (
        echo .env>> .gitignore
        echo [INFO] Added .env to .gitignore
    )
)

git rm --cached .env >nul 2>&1

git remote remove origin >nul 2>&1
git remote add origin "https://%GITHUB_TOKEN%@github.com/%GITHUB_USERNAME%/!GITHUB_REPO!.git"

echo [INFO] Staging all files...
git add .

echo.
set /p COMMIT_MSG="Enter commit message (or press Enter for default): "
if "!COMMIT_MSG!"=="" set "COMMIT_MSG=Update project"

echo [INFO] Committing: !COMMIT_MSG!
git commit -m "!COMMIT_MSG!"

if %errorlevel% neq 0 (
    echo [ERROR] Nothing to commit.
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)

echo.
echo  [1] Push to existing branch
echo  [2] Create and push to new branch
echo.
set /p BRANCH_CHOICE="Choose branch option: "

echo [INFO] Fetching remote branches...
git fetch origin >nul 2>&1

if "!BRANCH_CHOICE!"=="1" (
    echo.
    echo [INFO] Available remote branches:
    git branch -r
    echo.
    set /p PUSH_BRANCH="Enter branch name to push to: "
    if "!PUSH_BRANCH!"=="" (
        echo [ERROR] Branch name cannot be empty!
        pause
        cd /d "!SCRIPT_DIR!"
        goto MAIN_MENU
    )
    set "PUSH_BRANCH=!PUSH_BRANCH: =!"
    set "PUSH_BRANCH=!PUSH_BRANCH:origin/=!"
) else if "!BRANCH_CHOICE!"=="2" (
    echo.
    set /p PUSH_BRANCH="Enter new branch name: "
    if "!PUSH_BRANCH!"=="" (
        echo [ERROR] Branch name cannot be empty!
        pause
        cd /d "!SCRIPT_DIR!"
        goto MAIN_MENU
    )
    git checkout -b "!PUSH_BRANCH!" >nul 2>&1
    echo [INFO] Created and switched to new branch: !PUSH_BRANCH!
) else (
    echo [ERROR] Invalid option!
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)

echo.
echo [INFO] Pushing to GitHub...
git branch -M "!PUSH_BRANCH!" >nul 2>&1
git push -u origin "!PUSH_BRANCH!"
set "PUSH_ERR=!errorlevel!"
if "!PUSH_ERR!"=="0" (
    echo [DONE] Pushed to !PUSH_BRANCH!.
    goto UPLOAD_SUCCESS
)
echo [INFO] Normal push failed, trying force push...
git push -u origin "!PUSH_BRANCH!" --force
set "PUSH_ERR=!errorlevel!"
if "!PUSH_ERR!"=="0" (
    echo [DONE] Pushed to !PUSH_BRANCH! ^(force^).
    goto UPLOAD_SUCCESS
)
echo [ERROR] Push failed. Make sure the repo exists on GitHub.
pause
cd /d "!SCRIPT_DIR!"
goto MAIN_MENU
:UPLOAD_SUCCESS

echo.
echo  =========================================
echo   [DONE] Uploaded to:
echo   https://github.com/%GITHUB_USERNAME%/!GITHUB_REPO!
echo  =========================================
echo.
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:CLONE
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  CLONE
echo  =========================================
echo.
if not "!ACTIVE_REPO!"=="" (
    echo  [INFO] Using selected repo: !ACTIVE_REPO!
    set "CLONE_REPO=!ACTIVE_REPO!"
) else (
    set /p CLONE_REPO="Enter repo name to clone: "
    if "!CLONE_REPO!"=="" (
        echo [ERROR] Repo name cannot be empty!
        pause
        goto MAIN_MENU
    )
)

set "CLONE_REPO=!CLONE_REPO:"=!"

echo.
set /p CLONE_PATH="Enter folder path to clone into (or press Enter for current folder): "
if "!CLONE_PATH!"=="" (
    set "CLONE_PATH=%CD%"
)
set "CLONE_PATH=!CLONE_PATH:"=!"

if not exist "!CLONE_PATH!" (
    echo [ERROR] Path does not exist: !CLONE_PATH!
    pause
    goto MAIN_MENU
)

cd /d "!CLONE_PATH!"

if exist "!CLONE_REPO!\.git" (
    echo [ERROR] Folder '!CLONE_REPO!' already exists and is a git repo!
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)

echo [INFO] Cloning into: !CLONE_PATH!
git clone "https://%GITHUB_TOKEN%@github.com/%GITHUB_USERNAME%/!CLONE_REPO!.git"
set "CLONE_ERR=!errorlevel!"
if "!CLONE_ERR!" neq "0" (
    echo [ERROR] Clone failed. Check repo name and token permissions.
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
echo [DONE] Cloned successfully!
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:PULL
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  PULL
echo  =========================================
echo.
echo.
set /p PULL_PATH="Enter project folder path (or press Enter for current folder): "
if "!PULL_PATH!"=="" (
    set "PULL_PATH=%CD%"
)
set "PULL_PATH=!PULL_PATH:"=!"

if not exist "!PULL_PATH!" (
    echo [ERROR] Path does not exist: !PULL_PATH!
    pause
    goto MAIN_MENU
)

cd /d "!PULL_PATH!"

if not "!ACTIVE_REPO!"=="" (
    echo  [INFO] Pulling latest changes for: !ACTIVE_REPO!
) else (
    echo  [INFO] Pulling latest changes...
)
echo.
git pull
set "PULL_ERR=!errorlevel!"
if "!PULL_ERR!" neq "0" (
    echo [ERROR] Pull failed. Make sure this is a valid git repo.
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
echo.
echo [DONE] Pull complete!
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:CREATE_BRANCH
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  CREATE BRANCH
echo  =========================================
echo.
set /p BRANCH_PATH="Enter project folder path (or press Enter for current folder): "
if "!BRANCH_PATH!"=="" set "BRANCH_PATH=%CD%"
set "BRANCH_PATH=!BRANCH_PATH:"=!"
cd /d "!BRANCH_PATH!"

set /p BRANCH_NAME="Enter new branch name: "
if "!BRANCH_NAME!"=="" (
    echo [ERROR] Branch name cannot be empty!
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
git checkout -b "!BRANCH_NAME!"
set "CB_ERR=!errorlevel!"
if "!CB_ERR!" neq "0" (
    echo [ERROR] Failed to create branch.
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
echo [DONE] Branch '!BRANCH_NAME!' created and switched!
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:SWITCH_BRANCH
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  SWITCH BRANCH
echo  =========================================
echo.
set /p BRANCH_PATH="Enter project folder path (or press Enter for current folder): "
if "!BRANCH_PATH!"=="" set "BRANCH_PATH=%CD%"
set "BRANCH_PATH=!BRANCH_PATH:"=!"
cd /d "!BRANCH_PATH!"

echo [INFO] Available branches:
echo.
git branch
echo.
set /p BRANCH_NAME="Enter branch name to switch to: "
if "!BRANCH_NAME!"=="" (
    echo [ERROR] Branch name cannot be empty!
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
git checkout "!BRANCH_NAME!"
set "SW_ERR=!errorlevel!"
if "!SW_ERR!" neq "0" (
    echo [ERROR] Failed to switch branch.
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
echo [DONE] Switched to '!BRANCH_NAME!'
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:MERGE
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  MERGE
echo  =========================================
echo.
set /p MERGE_PATH="Enter project folder path (or press Enter for current folder): "
if "!MERGE_PATH!"=="" set "MERGE_PATH=%CD%"
set "MERGE_PATH=!MERGE_PATH:"=!"
cd /d "!MERGE_PATH!"

echo [INFO] Available branches:
echo.
git branch
echo.
set /p MERGE_BRANCH="Enter branch name to merge into current: "
if "!MERGE_BRANCH!"=="" (
    echo [ERROR] Branch name cannot be empty!
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
git merge "!MERGE_BRANCH!"
set "MERGE_ERR=!errorlevel!"
if "!MERGE_ERR!" neq "0" (
    echo [ERROR] Merge failed. Resolve conflicts and try again.
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
echo [DONE] Merge complete!
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:DELETE_BRANCH
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  DELETE BRANCH
echo  =========================================
echo.
set /p DEL_PATH="Enter project folder path (or press Enter for current folder): "
if "!DEL_PATH!"=="" set "DEL_PATH=%CD%"
set "DEL_PATH=!DEL_PATH:"=!"
cd /d "!DEL_PATH!"

echo [INFO] Available branches:
echo.
git branch
echo.
set /p DEL_BRANCH="Enter branch name to delete: "
if "!DEL_BRANCH!"=="" (
    echo [ERROR] Branch name cannot be empty!
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
git branch -d "!DEL_BRANCH!" >nul 2>&1
set "DEL_ERR=!errorlevel!"
if "!DEL_ERR!" neq "0" (
    echo [WARN] Normal delete failed. Force deleting...
    git branch -D "!DEL_BRANCH!"
    set "DEL_ERR=!errorlevel!"
)
if "!DEL_ERR!" neq "0" (
    echo [ERROR] Failed to delete branch '!DEL_BRANCH!'!
) else (
    echo [DONE] Branch '!DEL_BRANCH!' deleted!
)
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:STATUS
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  STATUS
echo  =========================================
echo.
set /p STATUS_PATH="Enter project folder path (or press Enter for current folder): "
if "!STATUS_PATH!"=="" set "STATUS_PATH=%CD%"
set "STATUS_PATH=!STATUS_PATH:"=!"
cd /d "!STATUS_PATH!"
echo.
git status
echo.
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:LOG
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  LOG
echo  =========================================
echo.
set /p LOG_PATH="Enter project folder path (or press Enter for current folder): "
if "!LOG_PATH!"=="" set "LOG_PATH=%CD%"
set "LOG_PATH=!LOG_PATH:"=!"
cd /d "!LOG_PATH!"
echo.
git log --oneline --graph --decorate --all
echo.
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:UNDO
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  UNDO
echo  =========================================
echo.
set /p UNDO_PATH="Enter project folder path (or press Enter for current folder): "
if "!UNDO_PATH!"=="" set "UNDO_PATH=%CD%"
set "UNDO_PATH=!UNDO_PATH:"=!"
cd /d "!UNDO_PATH!"
echo.
echo  [1] Undo commit but keep changes (soft)
echo  [2] Undo commit and discard changes (hard)
echo.
set /p UNDO_TYPE="Choose: "

:: Check how many commits exist
for /f %%C in ('git rev-list --count HEAD 2^>nul') do set "COMMIT_COUNT=%%C"
if "!COMMIT_COUNT!"=="" set "COMMIT_COUNT=0"

if !COMMIT_COUNT! LSS 2 (
    echo [ERROR] Only !COMMIT_COUNT! commit^(s^) exist. Cannot undo further.
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)

if "!UNDO_TYPE!"=="1" (
    git reset --soft HEAD~1
    set "UNDO_ERR=!errorlevel!"
    if "!UNDO_ERR!"=="0" (
        echo [DONE] Last commit undone, changes kept!
    ) else (
        echo [ERROR] Undo failed.
    )
) else if "!UNDO_TYPE!"=="2" (
    echo.
    echo [WARN] This will permanently discard all changes!
    set /p CONFIRM="Are you sure? (Y/N): "
    if /i "!CONFIRM!"=="Y" (
        git reset --hard HEAD~1
        set "UNDO_ERR=!errorlevel!"
        if "!UNDO_ERR!"=="0" (
            echo [DONE] Last commit undone, changes discarded!
        ) else (
            echo [ERROR] Undo failed.
        )
    ) else (
        echo [INFO] Operation cancelled.
    )
) else (
    echo [ERROR] Invalid option!
)
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:STASH
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  STASH
echo  =========================================
echo.
set /p STASH_PATH="Enter project folder path (or press Enter for current folder): "
if "!STASH_PATH!"=="" set "STASH_PATH=%CD%"
set "STASH_PATH=!STASH_PATH:"=!"
cd /d "!STASH_PATH!"
echo.
set /p STASH_MSG="Enter stash message (or press Enter for default): "
if "!STASH_MSG!"=="" (
    git stash
) else (
    git stash push -m "!STASH_MSG!"
)
set "STASH_ERR=!errorlevel!"
if "!STASH_ERR!" neq "0" (
    echo [ERROR] Stash failed. Nothing to stash?
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
echo [DONE] Changes stashed!
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:POP_STASH
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  POP STASH
echo  =========================================
echo.
set /p POP_PATH="Enter project folder path (or press Enter for current folder): "
if "!POP_PATH!"=="" set "POP_PATH=%CD%"
set "POP_PATH=!POP_PATH:"=!"
cd /d "!POP_PATH!"
echo.
echo [INFO] Available stashes:
echo.
git stash list
echo.
echo [INFO] Applying latest stash...
git stash pop
set "POP_ERR=!errorlevel!"
if "!POP_ERR!" neq "0" (
    echo [ERROR] No stash to apply or conflict occurred.
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
echo [DONE] Stash applied!
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:TAG
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  TAG
echo  =========================================
echo.
set /p TAG_PATH="Enter project folder path (or press Enter for current folder): "
if "!TAG_PATH!"=="" set "TAG_PATH=%CD%"
set "TAG_PATH=!TAG_PATH:"=!"
cd /d "!TAG_PATH!"
echo.
set /p TAG_NAME="Enter tag name (e.g. v1.0.0): "
if "!TAG_NAME!"=="" (
    echo [ERROR] Tag name cannot be empty!
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
set /p TAG_MSG="Enter tag message: "
if "!TAG_MSG!"=="" set "TAG_MSG=Release !TAG_NAME!"
git tag -a "!TAG_NAME!" -m "!TAG_MSG!"
set "TAG_ERR=!errorlevel!"
if "!TAG_ERR!" neq "0" (
    echo [ERROR] Tag creation failed. Tag may already exist.
    pause
    cd /d "!SCRIPT_DIR!"
    goto MAIN_MENU
)
echo [INFO] Pushing tag to GitHub...
git push origin "!TAG_NAME!"
echo [DONE] Tag !TAG_NAME! created and pushed!
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:DIFF
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  DIFF
echo  =========================================
echo.
set /p DIFF_PATH="Enter project folder path (or press Enter for current folder): "
if "!DIFF_PATH!"=="" set "DIFF_PATH=%CD%"
set "DIFF_PATH=!DIFF_PATH:"=!"
cd /d "!DIFF_PATH!"
echo.
git diff
echo.
cd /d "!SCRIPT_DIR!"
pause
goto MAIN_MENU

:: =============================
:LIST_REPOS
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  LIST REPOS
echo  =========================================
echo.
echo [INFO] Fetching your repositories from GitHub...
echo.

curl -s -H "Authorization: Bearer %GITHUB_TOKEN%" ^
     -H "Accept: application/vnd.github+json" ^
     "https://api.github.com/user/repos?per_page=100&sort=updated" ^
     > "%TEMP%\gh_repos.json"

set COUNT=0
for /f "tokens=2 delims=:," %%N in ('findstr "\"name\"" "%TEMP%\gh_repos.json" ^| findstr /v "full_name owner description language default_branch"') do (
    set "RAW=%%~N"
    set "RAW=!RAW:"=!"
    set "RAW=!RAW: =!"
    if not "!RAW!"=="" (
        set /a COUNT+=1
        set "REPO_!COUNT!=!RAW!"
        echo  [!COUNT!] !RAW!
    )
)

if !COUNT!==0 (
    echo [ERROR] No repositories found or API error!
)

echo.
echo  Total: !COUNT! repositories
del "%TEMP%\gh_repos.json" 2>nul
pause
goto MAIN_MENU

:: =============================
:SELECT_REPO
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  SELECT REPO
echo  =========================================
echo.
echo [INFO] Fetching your repositories from GitHub...
echo.

curl -s -H "Authorization: Bearer %GITHUB_TOKEN%" ^
     -H "Accept: application/vnd.github+json" ^
     "https://api.github.com/user/repos?per_page=100&sort=updated" ^
     > "%TEMP%\gh_repos.json"

set COUNT=0
for /f "tokens=2 delims=:," %%N in ('findstr "\"name\"" "%TEMP%\gh_repos.json" ^| findstr /v "full_name owner description language default_branch"') do (
    set "RAW=%%~N"
    set "RAW=!RAW:"=!"
    set "RAW=!RAW: =!"
    if not "!RAW!"=="" (
        set /a COUNT+=1
        set "REPO_!COUNT!=!RAW!"
        echo  [!COUNT!] !RAW!
    )
)

if !COUNT!==0 (
    echo [ERROR] No repositories found or API error!
    pause
    goto MAIN_MENU
)

echo.
set /p REPO_CHOICE="Select repo number: "

if "!REPO_CHOICE!"=="" (
    echo [ERROR] No selection made!
    pause
    goto MAIN_MENU
)

call set "SELECTED_REPO=%%REPO_!REPO_CHOICE!%%"
set "SELECTED_REPO=!SELECTED_REPO:"=!"

if "!SELECTED_REPO!"=="" (
    echo [ERROR] Invalid selection!
    pause
    goto MAIN_MENU
)

set "ACTIVE_REPO=!SELECTED_REPO!"

echo.
echo  =========================================
echo   [DONE] Now working with: !ACTIVE_REPO!
echo   https://github.com/%GITHUB_USERNAME%/!ACTIVE_REPO!
echo  =========================================

del "%TEMP%\gh_repos.json" 2>nul
pause
goto MAIN_MENU

:: =============================
:CLEAR_REPO
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  CLEAR REPO
echo  =========================================
echo.
if "!ACTIVE_REPO!"=="" (
    echo  [INFO] No repo currently selected.
) else (
    echo  [INFO] Clearing selected repo: !ACTIVE_REPO!
    set "ACTIVE_REPO="
    echo  [DONE] Repo selection cleared!
)
pause
goto MAIN_MENU

:: =============================
:CREATE_REPO
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  CREATE REPO
echo  =========================================
echo.
set /p NEW_REPO_NAME="Enter new repository name: "
if "!NEW_REPO_NAME!"=="" (
    echo [ERROR] Repo name cannot be empty!
    pause
    goto MAIN_MENU
)
set "NEW_REPO_NAME=!NEW_REPO_NAME: =!"

echo.
set /p NEW_REPO_DESC="Enter description (or press Enter to skip): "

echo.
echo  [1] Public
echo  [2] Private
echo.
set /p REPO_VIS="Choose visibility: "
if "!REPO_VIS!"=="1" (
    set "REPO_PRIVATE=false"
) else if "!REPO_VIS!"=="2" (
    set "REPO_PRIVATE=true"
) else (
    echo [ERROR] Invalid option!
    pause
    goto MAIN_MENU
)

echo.
echo [INFO] Creating repository on GitHub...

curl -s -X POST ^
     -H "Authorization: Bearer %GITHUB_TOKEN%" ^
     -H "Accept: application/vnd.github+json" ^
     -d "{\"name\":\"!NEW_REPO_NAME!\",\"description\":\"!NEW_REPO_DESC!\",\"private\":!REPO_PRIVATE!}" ^
     "https://api.github.com/user/repos" > "%TEMP%\create_repo.json"

findstr /i "\"full_name\"" "%TEMP%\create_repo.json" >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] Failed to create repository. Check token permissions or repo name.
    type "%TEMP%\create_repo.json"
    del "%TEMP%\create_repo.json" 2>nul
    pause
    goto MAIN_MENU
)

del "%TEMP%\create_repo.json" 2>nul
echo.
echo  =========================================
echo   [DONE] Repository created:
echo   https://github.com/%GITHUB_USERNAME%/!NEW_REPO_NAME!
echo  =========================================
echo.
set /p SET_ACTIVE="Set as active repo? (Y/N): "
if /i "!SET_ACTIVE!"=="Y" set "ACTIVE_REPO=!NEW_REPO_NAME!"
pause
goto MAIN_MENU

:: =============================
:DELETE_REPO
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n  ^|  DELETE REPO
echo  =========================================
echo.
if not "!ACTIVE_REPO!"=="" (
    echo  [INFO] Active repo: !ACTIVE_REPO!
    set /p USE_ACTIVE="Delete active repo '!ACTIVE_REPO!'? (Y/N): "
    if /i "!USE_ACTIVE!"=="Y" (
        set "DEL_REPO_NAME=!ACTIVE_REPO!"
        goto DO_DELETE_REPO
    )
)
set /p DEL_REPO_NAME="Enter repository name to delete: "
if "!DEL_REPO_NAME!"=="" (
    echo [ERROR] Repo name cannot be empty!
    pause
    goto MAIN_MENU
)

:DO_DELETE_REPO
echo.
echo  [WARN] This will PERMANENTLY delete: !DEL_REPO_NAME!
echo  [WARN] This action CANNOT be undone!
echo.
set /p DEL_CONFIRM="Type the repo name to confirm: "
if not "!DEL_CONFIRM!"=="!DEL_REPO_NAME!" (
    echo [ERROR] Name does not match. Cancelled.
    pause
    goto MAIN_MENU
)

echo.
echo [INFO] Deleting repository...
curl -s -X DELETE ^
     -H "Authorization: Bearer %GITHUB_TOKEN%" ^
     -H "Accept: application/vnd.github+json" ^
     "https://api.github.com/repos/%GITHUB_USERNAME%/!DEL_REPO_NAME!" > "%TEMP%\del_repo.json"

for %%F in ("%TEMP%\del_repo.json") do set "DEL_SIZE=%%~zF"
del "%TEMP%\del_repo.json" 2>nul

if "!DEL_SIZE!"=="0" (
    if "!ACTIVE_REPO!"=="!DEL_REPO_NAME!" set "ACTIVE_REPO="
    echo.
    echo  =========================================
    echo   [DONE] Repository '!DEL_REPO_NAME!' deleted.
    echo  =========================================
) else (
    echo [ERROR] Failed to delete. Check token has 'delete_repo' permission.
)
echo.
pause
goto MAIN_MENU

:: =============================
:END
:: =============================
cls
color 0A
echo.
echo  =========================================
echo   git-cli-control-panel by y0h4n
echo   Goodbye!
echo  =========================================
echo.
pause
exit /b 0