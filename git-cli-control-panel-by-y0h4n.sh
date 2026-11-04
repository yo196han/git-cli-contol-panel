#!/usr/bin/env bash
# git-cli-control-panel by y0h4n — Linux Bash edition
# Keep this file beside your .env file.

set -uo pipefail

GREEN=$'\033[0;32m'
RESET=$'\033[0m'
RED=$'\033[0;31m'
YELLOW=$'\033[0;33m'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ACTIVE_REPO=""
GITHUB_TOKEN=""
GITHUB_USERNAME=""
OS_NAME="$(. /etc/os-release 2>/dev/null; printf '%s' "${PRETTY_NAME:-Linux}")"
OS_VER="$(uname -r)"
ARCH="$(uname -m)"
GIT_VER="not installed"

pause() { read -r -p "Press Enter to continue..." _; }
header() {
    clear 2>/dev/null || true
    printf '%s\n' "${GREEN}"
    cat <<'ART'
          .:--=+****++=:.
       :+*#%@@@@@@@@@@%#*+:
      *%@@@%*#%@@@%#*%@@@%*
     +@%@%@*:.     .:*@%@%@+
     @@%@@%:          :@%@@%@@
    %@@%@%%@:         :@%@%@@@
    @+@%@%@*:.     .:*@%@%@+@
    @@*%@@%%%         %@@@%*@
    @@@+%  @*:.      .:*@%+.%
     @%  @ @:           :@%@@%
     +%@  %*=.       .=*%%+@
      -*%@@@%*%@@@@@@*%@%*-
     :*%@@@@@%*:@@@@%:*%@@@%*:
ART
    printf '%s\n' "${RESET}"
    printf ' =========================================\n'
    printf '  git-cli-control-panel by y0h4n | %s\n' "$1"
    printf ' =========================================\n\n'
}
info() { printf '%s[INFO]%s %s\n' "$GREEN" "$RESET" "$*"; }
done_msg() { printf '%s[DONE]%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s[WARN]%s %s\n' "$YELLOW" "$RESET" "$*"; }
error() { printf '%s[ERROR]%s %s\n' "$RED" "$RESET" "$*"; }
ask_path() {
    local prompt="$1" answer
    read -r -p "$prompt" answer
    answer="${answer/#\~/$HOME}"
    [[ -z "$answer" ]] && answer="$PWD"
    if [[ ! -d "$answer" ]]; then error "Path does not exist: $answer"; return 1; fi
    cd -- "$answer" || { error "Cannot access path: $answer"; return 1; }
}
need_repo_name() {
    if [[ -n "$ACTIVE_REPO" ]]; then
        printf -v "$1" '%s' "$ACTIVE_REPO"
        info "Using selected repo: $ACTIVE_REPO"
    else
        read -r -p "Enter repository name: " REPLY
        [[ -n "$REPLY" ]] || { error "Repository name cannot be empty."; return 1; }
        printf -v "$1" '%s' "$REPLY"
    fi
}
api() {
    curl --fail --silent --show-error \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github+json" "$@"
}
repo_path() {
    local p
    read -r -p "Enter project folder path (or Enter for current folder): " p
    p="${p/#\~/$HOME}"; [[ -n "$p" ]] || p="$PWD"
    [[ -d "$p" ]] || { error "Path does not exist: $p"; return 1; }
    cd -- "$p" || return 1
}
load_env() {
    local env_file="$SCRIPT_DIR/.env"
    if [[ ! -f "$env_file" ]]; then error ".env file not found in $SCRIPT_DIR"; return 1; fi
    # .env is treated as a shell environment file. Only use a file you trust.
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
    GITHUB_TOKEN="${GITHUB_TOKEN:-}"
    GITHUB_USERNAME="${GITHUB_USERNAME:-}"
    [[ -n "$GITHUB_TOKEN" ]] || { error "GITHUB_TOKEN is missing in .env"; return 1; }
    [[ -n "$GITHUB_USERNAME" ]] || { error "GITHUB_USERNAME is missing in .env"; return 1; }
}
run_as_root() {
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        error "Root privileges are required. Run as root or install sudo."
        return 1
    fi
}

detect_package_manager() {
    # Detect the package manager available on this system before installing anything.
    # Prefer the native/full-featured command where multiple wrappers are present.
    local managers=(apt-get apt nala dnf5 dnf microdnf yum pacman apk zypper emerge xbps-install eopkg urpmi nix-env guix)
    local manager
    for manager in "${managers[@]}"; do
        if command -v "$manager" >/dev/null 2>&1; then
            printf '%s' "$manager"
            return 0
        fi
    done
    return 1
}

install_git() {
    header "INSTALL GIT"
    local package_manager

    if ! package_manager="$(detect_package_manager)"; then
        error "No supported package manager was detected on this system."
        printf '%s\n' "Install git, curl, and jq manually, then rerun this script."
        return 1
    fi

    info "Detected package manager: $package_manager"
    info "Installing Git, curl, and jq using $package_manager..."

    case "$package_manager" in
        apt-get)
            run_as_root apt-get update && run_as_root apt-get install -y git curl jq
            ;;
        apt)
            run_as_root apt update && run_as_root apt install -y git curl jq
            ;;
        nala)
            run_as_root nala update && run_as_root nala install -y git curl jq
            ;;
        dnf5)
            run_as_root dnf5 install -y git curl jq
            ;;
        dnf)
            run_as_root dnf install -y git curl jq
            ;;
        microdnf)
            run_as_root microdnf install -y git curl jq
            ;;
        yum)
            run_as_root yum install -y git curl jq
            ;;
        pacman)
            run_as_root pacman -Sy --needed --noconfirm git curl jq
            ;;
        apk)
            run_as_root apk add git curl jq
            ;;
        zypper)
            run_as_root zypper --non-interactive install git curl jq
            ;;
        emerge)
            run_as_root emerge --noreplace dev-vcs/git net-misc/curl app-misc/jq
            ;;
        xbps-install)
            run_as_root xbps-install -Sy git curl jq
            ;;
        eopkg)
            run_as_root eopkg install -y git curl jq
            ;;
        urpmi)
            run_as_root urpmi --auto git curl jq
            ;;
        nix-env)
            nix-env -iA nixpkgs.git nixpkgs.curl nixpkgs.jq
            ;;
        guix)
            guix install git curl jq
            ;;
        *)
            error "Unsupported package manager: $package_manager"
            return 1
            ;;
    esac
}

choose_repo_path() { repo_path; }

upload_project() {
    header "UPLOAD"
    local repo project commit branch_choice branch
    need_repo_name repo || { pause; return; }
    choose_repo_path || { pause; return; }
    project="$PWD"
    info "Working in: $project"
    if [[ ! -d .git ]]; then git init || { pause; return; }; else info "Git already initialized."; fi
    git config user.name "$GITHUB_USERNAME"
    git config user.email "${GITHUB_USERNAME}@users.noreply.github.com"
    touch .gitignore
    grep -qxF '.env' .gitignore || printf '%s\n' '.env' >> .gitignore
    git rm --cached --ignore-unmatch .env >/dev/null 2>&1 || true
    git remote remove origin >/dev/null 2>&1 || true
    git remote add origin "https://github.com/${GITHUB_USERNAME}/${repo}.git"
    info "Staging all files..."
    git add -A
    read -r -p "Enter commit message (Enter for default): " commit
    [[ -n "$commit" ]] || commit="Update project"
    git commit -m "$commit" || { error "Nothing to commit or commit failed."; pause; return; }
    printf '\n[1] Push to existing branch\n[2] Create and push to new branch\n'
    read -r -p "Choose branch option: " branch_choice
    git fetch origin >/dev/null 2>&1 || true
    case "$branch_choice" in
        1)
            info "Available remote branches:"
            git branch -r
            read -r -p "Enter branch name to push to: " branch
            branch="${branch#origin/}"
            ;;
        2)
            read -r -p "Enter new branch name: " branch
            [[ -n "$branch" ]] && git checkout -b "$branch" || { error "Invalid branch name."; pause; return; }
            ;;
        *) error "Invalid option."; pause; return ;;
    esac
    [[ -n "$branch" ]] || { error "Branch name cannot be empty."; pause; return; }
    info "Pushing to GitHub..."
    if git push -u origin "$branch"; then
        done_msg "Pushed to $branch."
    else
        warn "Normal push failed. Force push can overwrite remote history."
        read -r -p "Force push? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git push -u origin "$branch" --force || { error "Push failed."; pause; return; }
            done_msg "Force pushed to $branch."
        else
            info "Push cancelled."; pause; return
        fi
    fi
    printf '\n[DONE] Uploaded to: https://github.com/%s/%s\n' "$GITHUB_USERNAME" "$repo"
    cd "$SCRIPT_DIR"; pause
}

clone_repo() {
    header "CLONE"
    local repo path
    need_repo_name repo || { pause; return; }
    read -r -p "Enter folder path to clone into (Enter for current folder): " path
    path="${path/#\~/$HOME}"; [[ -n "$path" ]] || path="$PWD"
    [[ -d "$path" ]] || { error "Path does not exist: $path"; pause; return; }
    if [[ -e "$path/$repo" ]]; then error "Target folder already exists: $path/$repo"; pause; return; fi
    git clone "https://github.com/${GITHUB_USERNAME}/${repo}.git" "$path/$repo" || { error "Clone failed. Check repo name and token permissions."; pause; return; }
    done_msg "Cloned successfully!"
    pause
}
pull_latest() {
    header "PULL"
    ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    git pull && done_msg "Pull complete!" || error "Pull failed. Make sure this is a valid git repo."
    cd "$SCRIPT_DIR"; pause
}
create_branch() {
    header "CREATE BRANCH"
    ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    local branch; read -r -p "Enter new branch name: " branch
    [[ -n "$branch" ]] || { error "Branch name cannot be empty."; cd "$SCRIPT_DIR"; pause; return; }
    git checkout -b "$branch" && done_msg "Branch '$branch' created and switched!" || error "Failed to create branch."
    cd "$SCRIPT_DIR"; pause
}
switch_branch() {
    header "SWITCH BRANCH"
    ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    git branch; local branch; read -r -p "Enter branch name to switch to: " branch
    [[ -n "$branch" ]] || { error "Branch name cannot be empty."; cd "$SCRIPT_DIR"; pause; return; }
    git checkout "$branch" && done_msg "Switched to '$branch'." || error "Failed to switch branch."
    cd "$SCRIPT_DIR"; pause
}
merge_branch() {
    header "MERGE"
    ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    git branch; local branch; read -r -p "Enter branch name to merge into current: " branch
    [[ -n "$branch" ]] || { error "Branch name cannot be empty."; cd "$SCRIPT_DIR"; pause; return; }
    git merge "$branch" && done_msg "Merge complete!" || error "Merge failed. Resolve conflicts and try again."
    cd "$SCRIPT_DIR"; pause
}
delete_branch() {
    header "DELETE BRANCH"
    ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    git branch; local branch; read -r -p "Enter branch name to delete: " branch
    [[ -n "$branch" ]] || { error "Branch name cannot be empty."; cd "$SCRIPT_DIR"; pause; return; }
    if ! git branch -d "$branch"; then
        warn "Normal delete failed. Force delete?"
        read -r -p "Force delete '$branch'? (y/N): " c
        [[ "$c" =~ ^[Yy]$ ]] && git branch -D "$branch"
    fi
    cd "$SCRIPT_DIR"; pause
}
show_status() {
    header "STATUS"; ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    git status; cd "$SCRIPT_DIR"; pause
}
show_log() {
    header "LOG"; ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    git log --oneline --graph --decorate --all; cd "$SCRIPT_DIR"; pause
}
undo_commit() {
    header "UNDO"
    ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    local count choice confirm
    count="$(git rev-list --count HEAD 2>/dev/null || echo 0)"
    if (( count < 2 )); then error "Only $count commit(s) exist. Cannot undo further."; cd "$SCRIPT_DIR"; pause; return; fi
    printf '[1] Undo commit but keep changes (soft)\n[2] Undo commit and discard changes (hard)\n'
    read -r -p "Choose: " choice
    case "$choice" in
        1) git reset --soft HEAD~1 && done_msg "Last commit undone; changes kept." || error "Undo failed." ;;
        2)
            warn "This permanently discards changes."
            read -r -p "Are you sure? (Y/N): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then git reset --hard HEAD~1 && done_msg "Last commit undone; changes discarded." || error "Undo failed."
            else info "Operation cancelled."; fi ;;
        *) error "Invalid option." ;;
    esac
    cd "$SCRIPT_DIR"; pause
}
stash_changes() {
    header "STASH"; ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    local msg; read -r -p "Enter stash message (Enter for default): " msg
    if [[ -n "$msg" ]]; then git stash push -m "$msg"; else git stash; fi
    done_msg "Stash command completed."; cd "$SCRIPT_DIR"; pause
}
pop_stash() {
    header "POP STASH"; ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    git stash list; git stash pop && done_msg "Stash applied!" || error "No stash to apply or conflict occurred."
    cd "$SCRIPT_DIR"; pause
}
add_tag() {
    header "TAG"; ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    local tag msg; read -r -p "Enter tag name (e.g. v1.0.0): " tag
    [[ -n "$tag" ]] || { error "Tag name cannot be empty."; cd "$SCRIPT_DIR"; pause; return; }
    read -r -p "Enter tag message: " msg; [[ -n "$msg" ]] || msg="Release $tag"
    git tag -a "$tag" -m "$msg" || { error "Tag creation failed. Tag may already exist."; cd "$SCRIPT_DIR"; pause; return; }
    info "Pushing tag to GitHub..."; git push origin "$tag" && done_msg "Tag $tag created and pushed!" || error "Tag created locally, but push failed."
    cd "$SCRIPT_DIR"; pause
}
show_diff() {
    header "DIFF"; ask_path "Enter project folder path (Enter for current folder): " || { pause; return; }
    git diff; cd "$SCRIPT_DIR"; pause
}
fetch_repos() {
    local json
    json="$(api "https://api.github.com/user/repos?per_page=100&sort=updated")" || { error "Could not fetch repositories. Check token permissions."; return 1; }
    command -v jq >/dev/null || { error "jq is required. Install it with your package manager."; return 1; }
    printf '%s' "$json" | jq -r 'if type=="array" then to_entries[] | "\(.key+1)\t\(.value.name)" else .message end'
}
list_repos() {
    header "LIST REPOS"; info "Fetching your repositories from GitHub..."
    local listing; listing="$(fetch_repos)" && printf '%s\n' "$listing"
    pause
}
select_repo() {
    header "SELECT REPO"; info "Fetching your repositories from GitHub..."
    local json count choice name
    json="$(api "https://api.github.com/user/repos?per_page=100&sort=updated")" || { error "Could not fetch repositories."; pause; return; }
    count="$(printf '%s' "$json" | jq 'if type=="array" then length else 0 end')"
    if (( count == 0 )); then error "No repositories found or API error."; pause; return; fi
    printf '%s' "$json" | jq -r 'to_entries[] | "  [\(.key+1)] \(.value.name)"'
    read -r -p "Select repo number: " choice
    [[ "$choice" =~ ^[0-9]+$ ]] || { error "Invalid selection."; pause; return; }
    name="$(printf '%s' "$json" | jq -r --argjson n "$choice" '.[$n-1].name // empty')"
    [[ -n "$name" ]] || { error "Invalid selection."; pause; return; }
    ACTIVE_REPO="$name"
    done_msg "Now working with: $ACTIVE_REPO"
    printf 'https://github.com/%s/%s\n' "$GITHUB_USERNAME" "$ACTIVE_REPO"
    pause
}
clear_repo() {
    header "CLEAR REPO"
    if [[ -z "$ACTIVE_REPO" ]]; then info "No repo currently selected."
    else info "Clearing selected repo: $ACTIVE_REPO"; ACTIVE_REPO=""; done_msg "Repo selection cleared!"; fi
    pause
}
create_repo() {
    header "CREATE REPO"
    local name desc visibility private response
    read -r -p "Enter new repository name: " name
    [[ -n "$name" ]] || { error "Repo name cannot be empty."; pause; return; }
    read -r -p "Enter description (Enter to skip): " desc
    printf '\n[1] Public\n[2] Private\n'
    read -r -p "Choose visibility: " visibility
    case "$visibility" in 1) private=false ;; 2) private=true ;; *) error "Invalid option."; pause; return ;; esac
    info "Creating repository on GitHub..."
    response="$(jq -n --arg name "$name" --arg description "$desc" --argjson private "$private" '{name:$name,description:$description,private:$private}' | api -X POST -H 'Content-Type: application/json' -d @- "https://api.github.com/user/repos")" || {
        error "Failed to create repository. Check token permissions or repo name."
        pause; return
    }
    if ! printf '%s' "$response" | jq -e '.full_name' >/dev/null; then
        error "GitHub did not confirm repository creation:"
        printf '%s\n' "$response" | jq .
        pause; return
    fi
    done_msg "Repository created: https://github.com/$GITHUB_USERNAME/$name"
    read -r -p "Set as active repo? (Y/N): " choice
    [[ "$choice" =~ ^[Yy]$ ]] && ACTIVE_REPO="$name"
    pause
}
delete_repo() {
    header "DELETE REPO"
    local name confirm code
    if [[ -n "$ACTIVE_REPO" ]]; then
        info "Active repo: $ACTIVE_REPO"
        read -r -p "Delete active repo '$ACTIVE_REPO'? (Y/N): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then name="$ACTIVE_REPO"; fi
    fi
    if [[ -z "${name:-}" ]]; then
        read -r -p "Enter repository name to delete: " name
    fi
    [[ -n "$name" ]] || { error "Repo name cannot be empty."; pause; return; }
    warn "This will PERMANENTLY delete: $name — this cannot be undone."
    read -r -p "Type the repo name to confirm: " confirm
    [[ "$confirm" == "$name" ]] || { error "Name does not match. Cancelled."; pause; return; }
    code="$(curl -sS -o /dev/null -w '%{http_code}' -X DELETE \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H 'Accept: application/vnd.github+json' \
        "https://api.github.com/repos/${GITHUB_USERNAME}/${name}")"
    if [[ "$code" == "204" ]]; then
        [[ "$ACTIVE_REPO" == "$name" ]] && ACTIVE_REPO=""
        done_msg "Repository '$name' deleted."
    else error "Delete failed (HTTP $code). Check token has delete_repo permission."; fi
    pause
}
main_menu() {
    while true; do
        header "MAIN MENU"
        printf ' OS  : %s\n Ver : %s\n CPU : %s\n Git : %s\n REPO: %s\n' \
            "$OS_NAME" "$OS_VER" "$ARCH" "$GIT_VER" "${ACTIVE_REPO:-None selected}"
        printf '%s\n' \
          ' [1]  Upload Project' \
          ' [2]  Clone Repository' \
          ' [3]  Pull Latest Changes' \
          ' [4]  Create & Switch Branch' \
          ' [5]  Switch Branch' \
          ' [6]  Merge Branch' \
          ' [7]  Delete Branch' \
          ' [8]  Show Status' \
          ' [9]  Show Commit Log' \
          ' [10] Undo Last Commit' \
          ' [11] Stash Changes' \
          ' [12] Pop Stash' \
          ' [13] Add Tag' \
          ' [14] Show Diff' \
          ' [15] List Repositories' \
          ' [16] Select a Repo to Work With' \
          ' [17] Clear Selected Repo' \
          ' [18] Create New Repository' \
          ' [19] Delete Repository' \
          ' [20] Exit'
        printf '\n'
        read -r -p "Choose an option: " choice
        case "$choice" in
            1) upload_project ;; 2) clone_repo ;; 3) pull_latest ;;
            4) create_branch ;; 5) switch_branch ;; 6) merge_branch ;;
            7) delete_branch ;; 8) show_status ;; 9) show_log ;;
            10) undo_commit ;; 11) stash_changes ;; 12) pop_stash ;;
            13) add_tag ;; 14) show_diff ;; 15) list_repos ;;
            16) select_repo ;; 17) clear_repo ;; 18) create_repo ;;
            19) delete_repo ;; 20) header "GOODBYE"; printf 'Goodbye!\n'; exit 0 ;;
            *) error "Invalid option."; pause ;;
        esac
    done
}

cd "$SCRIPT_DIR" || exit 1
load_env || { pause; exit 1; }
missing_deps=()
command -v git  >/dev/null 2>&1 || missing_deps+=("git")
command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
command -v jq   >/dev/null 2>&1 || missing_deps+=("jq")

if (( ${#missing_deps[@]} > 0 )); then
    warn "Missing dependencies: ${missing_deps[*]}"
    read -r -p "Would you like to install Git, curl, and jq now? (Y/N): " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        install_git || { pause; exit 1; }
    else
        error "Installation declined."
        printf 'Please install the missing dependencies and run this script again.\n'
        exit 1
    fi
fi

command -v git  >/dev/null 2>&1 || { error "Git installation did not complete."; exit 1; }
command -v curl >/dev/null 2>&1 || { error "curl is required. Install curl and rerun."; exit 1; }
command -v jq   >/dev/null 2>&1 || warn "jq is not installed. Repository listing and selection will be unavailable."
GIT_VER="$(git --version | awk '{print $3}')"
header "WELCOME"
printf 'Welcome! This tool lets you manage your GitHub repositories directly from the CLI.\n'
printf 'GitHub: https://github.com/%s\n\n' "$GITHUB_USERNAME"
read -r -p "Press Enter to open the main menu..."
main_menu
