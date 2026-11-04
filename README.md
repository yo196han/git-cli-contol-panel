# git-cli-control-panel

A menu-driven command-line tool for managing local Git projects and GitHub repositories.

**Author:** y0h4n  
**GitHub:** https://github.com/yo196han

The repository provides two platform-specific scripts:

- `git-cli-control-panel-by-y0h4n.bat` — Windows
- `git-cli-control-panel-by-y0h4n-package-detect.sh` — Linux / Bash (updated package-manager detection version)

## Features

### Git project operations

- Upload a local project to a GitHub repository
- Clone a repository
- Pull the latest changes
- Create and switch to a branch
- Switch branches
- Merge a branch into the current branch
- Delete a local branch
- View Git status
- View commit history
- Undo the latest commit:
  - Soft reset: keep changes staged
  - Hard reset: discard changes
- Stash changes, with an optional message
- Apply and remove the latest stash (`git stash pop`)
- Create and push an annotated tag
- View the current diff

### GitHub repository management

- List your GitHub repositories
- Select a repository as the active repository
- Clear the active repository selection
- Create a public or private repository
- Delete a repository after confirming its name

The active repository selection is temporary and lasts only while the script is running.

## Requirements

### Windows

- Windows with Command Prompt
- `curl`
- A GitHub personal access token
- Git for Windows (the script can offer to download and launch its installer if Git is not detected)

The Windows script downloads the Git for Windows installer for the detected processor architecture and launches it. Complete the installer, then run the control panel again if necessary.

### Linux

- Bash
- A supported package manager for automatic dependency installation
- Root access or `sudo` for system package managers that require elevated privileges
- A GitHub personal access token

The Linux script checks for these dependencies:

- `git`
- `curl`
- `jq`

If one or more are missing, it asks whether you want to install Git, curl, and jq. If you accept, it first detects which supported package-manager command is available, reports the detected manager, and then runs that manager's installation command.

### Linux package-manager detection

The script checks for the following package-manager commands, in this order:

| Package-manager command | Common distribution family |
|---|---|
| `apt-get` | Debian, Ubuntu and derivatives |
| `apt` | Debian, Ubuntu and derivatives |
| `nala` | Debian / Ubuntu-based systems using Nala |
| `dnf5` | Fedora and distributions using DNF5 |
| `dnf` | Fedora, RHEL and derivatives |
| `microdnf` | Minimal RHEL-compatible environments |
| `yum` | Older RHEL / CentOS-compatible systems |
| `pacman` | Arch Linux, Manjaro and derivatives |
| `apk` | Alpine Linux |
| `zypper` | openSUSE and SUSE systems |
| `emerge` | Gentoo |
| `xbps-install` | Void Linux |
| `eopkg` | Solus |
| `urpmi` | Mageia |
| `nix-env` | Nix environments |
| `guix` | GNU Guix |

The script uses the first matching command in this list. It then executes the corresponding installation command for `git`, `curl`, and `jq`.

Examples of the commands used:

```bash
# Debian / Ubuntu
sudo apt-get update
sudo apt-get install -y git curl jq

# Fedora
sudo dnf install -y git curl jq

# Arch Linux
sudo pacman -Sy --needed --noconfirm git curl jq

# Alpine Linux
sudo apk add git curl jq

# openSUSE
sudo zypper --non-interactive install git curl jq
```

For `apt`, `nala`, `dnf5`, `microdnf`, `yum`, `emerge`, `xbps-install`, `eopkg`, and `urpmi`, the script uses the equivalent command for that manager. For Nix and Guix, it uses their respective package-install commands.

System package managers are run with root privileges: the script runs directly when already root, otherwise it uses `sudo` when available. Nix and Guix commands are run as the current user.

If no supported package manager is detected, the script displays a message asking you to install the dependencies manually. Package availability and exact package names can vary by distribution and configuration.

**Note:** `jq` is used for GitHub repository listing and selection. The script warns if `jq` is still unavailable. Git and curl are required for the tool to continue.

## Setup

1. Download or clone the repository.
2. Keep the script and environment file in the same directory.
3. Copy `env-template.txt` to a file named `.env`.
4. Edit `.env` and add your GitHub username and personal access token:

   ```dotenv
   GITHUB_TOKEN=your-personal-access-token
   GITHUB_USERNAME=your-github-username
   ```

5. Save the file.

Do not commit `.env`, upload it to GitHub, or share it. It contains your private access token.

### GitHub personal access token

Create a personal access token in your GitHub account settings. Grant only the permissions needed for the operations you plan to use.

Depending on the token type and GitHub's current permission model, typical permissions may include:

- Repository access to the repositories you want to manage
- Repository contents read/write access for Git operations
- Metadata read access
- Repository administration access if you want to create or delete repositories

Deleting a repository requires the appropriate delete-repository permission. Organization policies may impose additional restrictions.

Treat your token like a password. If it is exposed, revoke it and create a replacement.

## Run the script

### Windows

Double-click the batch file, or open Command Prompt in the script directory and run:

```bat
git-cli-control-panel-by-y0h4n.bat
```

If Git is missing, the script offers to download and launch the Git for Windows installer. Follow the installer's instructions.

### Linux

From the script directory, make the Bash script executable:

```bash
chmod +x git-cli-control-panel-by-y0h4n-package-detect.sh
```

Run it:

```bash
./git-cli-control-panel-by-y0h4n-package-detect.sh
```

If dependencies are missing, the script asks whether to install them. If you answer `Y`, it detects the available package manager, displays its name, and runs the corresponding installation command.

Keep `.env` beside the script. The Linux script loads `.env` from the script's own directory.

## Menu options

| Option | Action |
|---:|---|
| 1 | Upload Project |
| 2 | Clone Repository |
| 3 | Pull Latest Changes |
| 4 | Create & Switch Branch |
| 5 | Switch Branch |
| 6 | Merge Branch |
| 7 | Delete Branch |
| 8 | Show Status |
| 9 | Show Commit Log |
| 10 | Undo Last Commit |
| 11 | Stash Changes |
| 12 | Pop Stash |
| 13 | Add Tag |
| 14 | Show Diff |
| 15 | List Repositories |
| 16 | Select a Repo to Work With |
| 17 | Clear Selected Repo |
| 18 | Create New Repository |
| 19 | Delete Repository |
| 20 | Exit |

## Uploading a project

1. Select **Upload Project**.
2. Enter a repository name, or use the currently selected repository if one is active.
3. Enter the local project folder path. Press Enter to use the current directory.
4. The script initializes Git if needed and configures the commit author using your GitHub username.
5. It adds `.env` to the project's `.gitignore` and removes `.env` from Git's index if it was already tracked.
6. Enter a commit message, or press Enter to use the default message.
7. Choose whether to push to an existing branch or create a new branch.
8. Follow the prompts to push.

The upload operation stages all files in the selected project directory. Check the staged changes and ignore rules before pushing.

## Important safety notes

- **Protect `.env`.** Both scripts attempt to exclude `.env` during upload, but verify your `.gitignore` and staged files before pushing.
- **Review staged files.** Upload stages all files in the selected project directory.
- **Force push can overwrite remote history.** The Linux script asks before force-pushing after a normal push fails. Review the remote history before agreeing.
- **Hard reset is destructive.** The hard-reset option permanently discards changes associated with the undone commit.
- **Repository deletion is permanent.** Confirm the repository name carefully.
- **Branch deletion can discard unmerged work.** Use force deletion only when you understand what will be lost.
- **Stash pop can cause conflicts.** Resolve conflicts before continuing.
- **Use a least-privilege token.** Grant only the permissions your workflow needs.

## Platform differences

The Windows and Linux scripts provide the same general menu, but their implementations differ:

- The Windows script uses a Windows batch file and can download and launch the Git for Windows installer.
- The Linux script uses Bash and detects the first available supported package manager before installing missing dependencies.
- The Linux script uses `jq` to parse GitHub API responses. Repository listing and selection require it.
- The Linux script uses GitHub API authorization with a Bearer token.
- Repository listing and selection request up to 100 repositories.

## Troubleshooting

### `.env` file not found

Make sure the file is named exactly `.env`, not `.env.txt`, and is in the same directory as the script. On Windows, start the batch file from its directory so the relative `.env` path resolves correctly.

### `GITHUB_TOKEN` or `GITHUB_USERNAME` is missing

Check that `.env` contains both variables:

```dotenv
GITHUB_TOKEN=your-personal-access-token
GITHUB_USERNAME=your-github-username
```

Replace the example values with your actual credentials. Do not include placeholder angle brackets.

### No supported package manager detected on Linux

Install Git, curl, and jq manually using your distribution's package manager, then run the script again.

### Linux installation fails

Check your internet connection, repository configuration, package-manager availability, and permissions. For system package managers, make sure you can use root or `sudo`. Nix and Guix installations use the current user's environment.

### GitHub API request fails

Check your internet connection, token validity, token permissions, and repository ownership. The API may reject requests if the token cannot access the requested repository or action.

### Push is rejected

A push may be rejected because the remote branch has commits that are not present locally, branch protection prevents the push, or the token lacks write access. Fetch and review the remote history before considering a force push.

## Security checklist

Before publishing or sharing your project, verify that:

- `.env` is not tracked by Git
- No personal access token is hard-coded in either script
- No credentials appear in committed remote URLs, logs, or configuration
- The token has only the permissions you need
- Destructive operations are used carefully

## License

No license file was included with the supplied project files. Add a `LICENSE` file and update this section if you intend to distribute the project under a specific open-source license.
