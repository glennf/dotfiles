# Mac Setup Scripts - Dotfiles Cleanup & Creation

## TL;DR

> **Quick Summary**: Clean up nested dotfiles repo structure, audit current system for installed packages, create modular and idempotent Mac setup scripts using GNU Stow for dotfile management.
> 
> **Deliverables**:
> - Flattened repo structure (remove nested dotfiles/dotfiles/)
> - Brewfile with curated categories + Brewfile.work for corporate apps
> - Modular setup scripts (bootstrap.sh, scripts/brew.sh, scripts/macos.sh, scripts/apps.sh, scripts/stow.sh)
> - GNU Stow package structure for all dotfiles
> - Captured dotfiles: .zshrc, .p10k.zsh, .gitconfig, .zprofile
> - Comprehensive macOS defaults configuration
> - Updated README with usage instructions
> 
> **Estimated Effort**: Large
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Task 1 (flatten) → Task 2 (audit) → Tasks 3-6 (parallel scripts) → Task 7 (README)

---

## Context

### Original Request
User wants to clean up their dotfiles repository and create comprehensive Mac setup scripts for setting up a new Mac, capturing currently installed packages from Homebrew, npm, pip/pipx, and Mac App Store.

### Interview Summary
**Key Discussions**:
- **Audit current system**: YES - capture all installed packages with curation into categories
- **Dotfile deployment**: GNU Stow for symlink management
- **Script organization**: Modular scripts with main bootstrap.sh orchestrator
- **Idempotency**: Scripts must be safe to run multiple times without duplicates
- **Missing dotfiles**: Capture .p10k.zsh, .gitconfig, .zprofile from current system
- **macOS defaults**: Comprehensive (Finder, Dock, Trackpad, Keyboard, etc.)
- **App Store apps**: Use mas-cli to track and install
- **Repo structure**: Flatten nested dotfiles/dotfiles/ to single root
- **Work apps**: Separate Brewfile.work for Citrix, Webex, Zoom
- **File conflicts**: Backup to ~/.dotfiles-backup/ before symlinking
- **Version managers**: mise only (replaces sdkman)
- **P10k theme**: Auto-install into oh-my-zsh

### Research Findings
- Current repo: `/Users/glenn/projects/dotfiles/dotfiles/` (nested structure with its own .git)
- Existing files: `setup.sh` (problematic: has logout, non-idempotent), `.zshrc`, `readme.md`
- setup.sh installs: iterm2, git, speedtest_cli, alfred, vscode, chrome, slack, 1password, drawio, jetbrains-toolbox, webex, zoom, citrix-workspace
- .zshrc references: powerlevel10k theme, oh-my-zsh, zoxide, terraform completion, fabric-bootstrap.inc
- Missing from repo: .p10k.zsh, .gitconfig, .zprofile

### Metis Review
**Identified Gaps** (addressed):
- Nested git repos → Flatten structure decision made
- Hardcoded `/Users/$USER/` paths → Use `$HOME` in all scripts
- `logout` mid-script → Remove from new scripts
- Missing idempotency → Use `command -v X || install X` pattern
- Stow conflicts → Backup strategy implemented
- Intel vs Apple Silicon → Dynamic path detection

---

## Work Objectives

### Core Objective
Transform a messy, non-idempotent dotfiles repo into a clean, modular, stow-based Mac setup system that can reliably bootstrap a fresh Mac.

### Concrete Deliverables
```
/Users/glenn/projects/dotfiles/
├── bootstrap.sh              # Main entry point (executable)
├── Brewfile                  # Curated Homebrew packages (essentials, dev, productivity)
├── Brewfile.work             # Corporate apps (Citrix, Webex, Zoom)
├── Brewfile.mas              # Mac App Store apps
├── scripts/
│   ├── brew.sh               # Homebrew installation + bundle
│   ├── macos.sh              # macOS system defaults
│   ├── apps.sh               # Third-party apps (oh-my-zsh, mise, p10k)
│   └── stow.sh               # Dotfile deployment via stow
├── stow/
│   ├── zsh/
│   │   └── .zshrc
│   ├── p10k/
│   │   └── .p10k.zsh
│   ├── git/
│   │   └── .gitconfig
│   └── zprofile/
│       └── .zprofile
└── README.md                 # Usage documentation
```

### Definition of Done
- [ ] `./bootstrap.sh` runs without errors on fresh Mac
- [ ] `./bootstrap.sh` runs twice without duplicating entries or errors (idempotent)
- [ ] All dotfiles symlinked to home directory via stow
- [ ] `brew bundle check` reports all packages installed
- [ ] macOS defaults applied (Finder shows hidden files, etc.)

### Must Have
- Flattened repo structure (single .git at root)
- Brewfile generated from current system audit
- Separate Brewfile.work for corporate apps
- All scripts use `$HOME` not `/Users/$USER/`
- Idempotency guards on all operations
- Backup mechanism for existing dotfiles
- Support for both Intel and Apple Silicon Macs

### Must NOT Have (Guardrails)
- **NO** `logout`, `exit`, or interactive prompts mid-script
- **NO** hardcoded paths like `/Users/glenn/` or `/opt/homebrew/` without detection
- **NO** appending to shell configs without idempotency checks
- **NO** cloning repos into working directory without cleanup
- **NO** secrets, credentials, or .env files
- **NO** VSCode/JetBrains application settings (out of scope)
- **NO** SSH keys or GPG keys in repo

---

## Verification Strategy (MANDATORY)

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL tasks in this plan MUST be verifiable WITHOUT any human action.
> Every criterion is verified by running commands or using automated tools.

### Test Decision
- **Infrastructure exists**: NO (shell scripts, not code with test framework)
- **Automated tests**: N/A - verification via shell command assertions
- **Framework**: bash assertion commands

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

Verification Tool by Deliverable Type:

| Type | Tool | How Agent Verifies |
|------|------|-------------------|
| **Repo structure** | Bash (ls, find) | Check file existence and structure |
| **Brewfile validity** | Bash (brew bundle check) | Verify all packages listed are installed |
| **Script execution** | Bash (./script.sh) | Run script, check exit code |
| **Symlinks** | Bash (ls -la, readlink) | Verify symlinks point to stow directory |
| **macOS defaults** | Bash (defaults read) | Verify settings were applied |
| **Idempotency** | Bash (run twice, diff) | Run script twice, verify no changes on second run |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
└── Task 1: Flatten repo structure (BLOCKING - must complete first)

Wave 2 (After Wave 1):
├── Task 2: Audit system and generate Brewfiles (depends: 1)

Wave 3 (After Wave 2):
├── Task 3: Create scripts/brew.sh (depends: 2)
├── Task 4: Create scripts/macos.sh (depends: 1)
├── Task 5: Create scripts/apps.sh (depends: 1)
└── Task 6: Create scripts/stow.sh + stow packages (depends: 1)

Wave 4 (After Wave 3):
├── Task 7: Create bootstrap.sh orchestrator (depends: 3, 4, 5, 6)
└── Task 8: Create README.md (depends: 7)

Wave 5 (Final):
└── Task 9: Integration test - run full bootstrap (depends: all)

Critical Path: Task 1 → Task 2 → Task 3 → Task 7 → Task 9
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | All | None (sequential gate) |
| 2 | 1 | 3 | None |
| 3 | 2 | 7 | 4, 5, 6 |
| 4 | 1 | 7 | 3, 5, 6 |
| 5 | 1 | 7 | 3, 4, 6 |
| 6 | 1 | 7 | 3, 4, 5 |
| 7 | 3, 4, 5, 6 | 8, 9 | None |
| 8 | 7 | 9 | None |
| 9 | All | None | None (final) |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|-------------------|
| 1 | 1 | delegate_task(category="quick", load_skills=["git-master"]) |
| 2 | 2 | delegate_task(category="unspecified-low", load_skills=[]) |
| 3 | 3, 4, 5, 6 | dispatch parallel with category="unspecified-low" |
| 4 | 7, 8 | dispatch sequential with category="unspecified-low" |
| 5 | 9 | delegate_task(category="deep", load_skills=[]) |

---

## TODOs

- [x] 1. Flatten Repository Structure

  **What to do**:
  - Move contents from `dotfiles/dotfiles/` up to `dotfiles/` root
  - Preserve git history from inner repo
  - Delete the nested .git directory after merge
  - Verify no nested .git remains
  - Clean up old setup.sh (will be replaced)

  **Must NOT do**:
  - Lose git history
  - Leave nested .git directory

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single focused task - repo restructuring
  - **Skills**: [`git-master`]
    - `git-master`: Git operations for preserving history during restructure
  - **Skills Evaluated but Omitted**:
    - None needed - purely git operation

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential (Wave 1)
  - **Blocks**: All other tasks
  - **Blocked By**: None

  **References**:
  - `dotfiles/dotfiles/.git/config` - Current git remote: git@github.com:glennf/dotfiles
  - `dotfiles/dotfiles/setup.sh` - File to be replaced (reference for what existed)
  - `dotfiles/dotfiles/.zshrc` - File to preserve and move to stow structure

  **Acceptance Criteria**:

  ```
  Scenario: Repo structure is flattened
    Tool: Bash
    Preconditions: Current nested structure exists
    Steps:
      1. ls -la /Users/glenn/projects/dotfiles/ → should show bootstrap.sh location (after work)
      2. ls -la /Users/glenn/projects/dotfiles/.git → should exist (single .git)
      3. test ! -d /Users/glenn/projects/dotfiles/dotfiles/.git → nested .git should NOT exist
      4. git -C /Users/glenn/projects/dotfiles log --oneline -5 → should show preserved history
      5. git -C /Users/glenn/projects/dotfiles remote -v → should show github:glennf/dotfiles
    Expected Result: Single .git at root, history preserved, remote intact
    Evidence: Command outputs captured
  ```

  **Commit**: YES
  - Message: `refactor: flatten nested dotfiles repo structure`
  - Files: All moved/deleted files
  - Pre-commit: `git status` shows clean state

---

- [x] 2. Audit System and Generate Brewfiles

  **What to do**:
  - Run `brew bundle dump` to capture all installed Homebrew packages
  - Curate into categories: essentials, development, productivity, optional
  - Separate corporate apps (Citrix, Webex, Zoom) into Brewfile.work
  - Run `mas list` to capture Mac App Store apps → Brewfile.mas
  - Run `npm list -g --depth=0` → document in README (optional npm setup)
  - Run `pipx list` → document any pipx packages
  - Capture ~/.p10k.zsh, ~/.gitconfig, ~/.zprofile for stow packages

  **Must NOT do**:
  - Include secrets or credentials
  - Include packages user doesn't want
  - Hardcode user-specific paths

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: System audit and file organization, moderate effort
  - **Skills**: `[]`
    - No specialized skills needed - standard bash/file operations
  - **Skills Evaluated but Omitted**:
    - `git-master`: Not git-related task

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on Task 1)
  - **Parallel Group**: Sequential (Wave 2)
  - **Blocks**: Task 3
  - **Blocked By**: Task 1

  **References**:
  - Current `dotfiles/dotfiles/setup.sh:45-85` - Existing brew install commands for comparison
  - `~/.p10k.zsh` - Powerlevel10k config to capture
  - `~/.gitconfig` - Git config to capture
  - `~/.zprofile` - Shell profile to capture

  **Acceptance Criteria**:

  ```
  Scenario: Brewfile generated with categories
    Tool: Bash
    Preconditions: Task 1 complete, repo flattened
    Steps:
      1. test -f /Users/glenn/projects/dotfiles/Brewfile
      2. grep -q "# Essentials" /Users/glenn/projects/dotfiles/Brewfile
      3. grep -q "# Development" /Users/glenn/projects/dotfiles/Brewfile
      4. brew bundle check --file=/Users/glenn/projects/dotfiles/Brewfile → exit 0
    Expected Result: Brewfile exists with categories, validates against current system
    Evidence: Brewfile content, brew bundle check output

  Scenario: Corporate apps separated
    Tool: Bash
    Preconditions: Brewfile.work created
    Steps:
      1. test -f /Users/glenn/projects/dotfiles/Brewfile.work
      2. grep -qE "(citrix|webex|zoom)" /Users/glenn/projects/dotfiles/Brewfile.work
      3. ! grep -qE "(citrix|webex|zoom)" /Users/glenn/projects/dotfiles/Brewfile
    Expected Result: Corporate apps only in Brewfile.work, not in main Brewfile
    Evidence: grep outputs

  Scenario: Dotfiles captured for stow
    Tool: Bash
    Preconditions: Home directory dotfiles exist
    Steps:
      1. test -f /Users/glenn/projects/dotfiles/stow/p10k/.p10k.zsh
      2. test -f /Users/glenn/projects/dotfiles/stow/git/.gitconfig
      3. test -f /Users/glenn/projects/dotfiles/stow/zsh/.zshrc
    Expected Result: All referenced dotfiles captured in stow structure
    Evidence: ls -la outputs for stow directories
  ```

  **Commit**: YES
  - Message: `feat: add Brewfile and captured dotfiles from system audit`
  - Files: `Brewfile`, `Brewfile.work`, `Brewfile.mas`, `stow/**`
  - Pre-commit: `brew bundle check --file=Brewfile`

---

- [x] 3. Create scripts/brew.sh

  **What to do**:
  - Create idempotent Homebrew installation script
  - Install Homebrew if not present (with Apple Silicon / Intel detection)
  - Run `brew bundle` with Brewfile
  - Add option to include Brewfile.work for corporate apps
  - Handle errors gracefully

  **Must NOT do**:
  - Hardcode `/opt/homebrew/` or `/usr/local/` paths
  - Append to .zprofile without idempotency check
  - Exit or logout mid-script

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: Script creation, straightforward bash
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - None needed

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 4, 5, 6)
  - **Blocks**: Task 7
  - **Blocked By**: Task 2

  **References**:
  - Current `setup.sh:19-38` - Homebrew installation pattern (fix issues)
  - `Brewfile` - Generated in Task 2
  - Official Homebrew install: `https://brew.sh`

  **Acceptance Criteria**:

  ```
  Scenario: brew.sh is executable and has correct structure
    Tool: Bash
    Preconditions: scripts/ directory exists
    Steps:
      1. test -f /Users/glenn/projects/dotfiles/scripts/brew.sh
      2. test -x /Users/glenn/projects/dotfiles/scripts/brew.sh
      3. head -1 /Users/glenn/projects/dotfiles/scripts/brew.sh → contains "#!/usr/bin/env bash"
      4. grep -q 'command -v brew' /Users/glenn/projects/dotfiles/scripts/brew.sh → idempotency check
      5. grep -q 'brew bundle' /Users/glenn/projects/dotfiles/scripts/brew.sh
      6. ! grep -q '/opt/homebrew' /Users/glenn/projects/dotfiles/scripts/brew.sh → no hardcoded paths
    Expected Result: Script exists, is executable, has idempotency guards
    Evidence: grep outputs

  Scenario: brew.sh handles both architectures
    Tool: Bash
    Preconditions: Script created
    Steps:
      1. grep -q 'arch' /Users/glenn/projects/dotfiles/scripts/brew.sh || grep -q 'uname -m' /Users/glenn/projects/dotfiles/scripts/brew.sh
    Expected Result: Script detects architecture
    Evidence: grep output showing arch detection
  ```

  **Commit**: YES (group with Task 4, 5, 6)
  - Message: `feat: add modular setup scripts`
  - Files: `scripts/brew.sh`

---

- [x] 4. Create scripts/macos.sh

  **What to do**:
  - Create comprehensive macOS defaults script
  - Include: Finder (hidden files, path bar, status bar, Library visible)
  - Include: Dock (size, magnification, auto-hide, recent apps)
  - Include: Trackpad (tap to click, natural scrolling toggle)
  - Include: Keyboard (key repeat rate, disable press-and-hold)
  - Include: Screenshots (location, format)
  - Include: Security (require password after sleep)
  - All settings should be idempotent (defaults write is naturally idempotent)

  **Must NOT do**:
  - Change settings that require restart without warning
  - Include settings that break accessibility

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: Script creation with macOS defaults commands
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - None needed

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 3, 5, 6)
  - **Blocks**: Task 7
  - **Blocked By**: Task 1

  **References**:
  - Current `setup.sh:12-23` - Existing Finder defaults (expand on these)
  - `https://macos-defaults.com` - Reference for macOS defaults commands
  - `https://github.com/mathiasbynens/dotfiles/blob/main/.macos` - Popular macOS defaults reference

  **Acceptance Criteria**:

  ```
  Scenario: macos.sh has comprehensive defaults
    Tool: Bash
    Preconditions: Script created
    Steps:
      1. test -f /Users/glenn/projects/dotfiles/scripts/macos.sh
      2. test -x /Users/glenn/projects/dotfiles/scripts/macos.sh
      3. grep -c 'defaults write' /Users/glenn/projects/dotfiles/scripts/macos.sh → at least 10
      4. grep -q 'com.apple.finder' /Users/glenn/projects/dotfiles/scripts/macos.sh
      5. grep -q 'com.apple.dock' /Users/glenn/projects/dotfiles/scripts/macos.sh
    Expected Result: Script has 10+ defaults commands covering Finder and Dock
    Evidence: grep outputs

  Scenario: macos.sh applies without errors
    Tool: Bash
    Preconditions: Script created, macOS system available
    Steps:
      1. /Users/glenn/projects/dotfiles/scripts/macos.sh
      2. echo $? → 0 (success)
      3. defaults read com.apple.finder AppleShowAllFiles → YES
    Expected Result: Script runs successfully, settings applied
    Evidence: Exit code 0, defaults read output
  ```

  **Commit**: YES (group with Tasks 3, 5, 6)
  - Message: `feat: add modular setup scripts`
  - Files: `scripts/macos.sh`

---

- [x] 5. Create scripts/apps.sh

  **What to do**:
  - Install oh-my-zsh if not present (idempotent check for ~/.oh-my-zsh)
  - Clone powerlevel10k theme into oh-my-zsh custom themes
  - Install mise (replaces sdkman) via Homebrew or official installer
  - Configure mise with default versions if specified
  - Install zoxide if not already via Homebrew
  - Handle fabric-bootstrap.inc reference gracefully (optional dependency)

  **Must NOT do**:
  - Call `logout` or `exit`
  - Run oh-my-zsh installer if already installed
  - Use curl | sh without checking if already installed

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: Script creation for app installations
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - None needed

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 3, 4, 6)
  - **Blocks**: Task 7
  - **Blocked By**: Task 1

  **References**:
  - Current `setup.sh:49-62` - oh-my-zsh installation (fix the logout issue)
  - `~/.zshrc:9` - powerlevel10k theme reference
  - `https://ohmyz.sh/#install` - oh-my-zsh official install
  - `https://mise.jdx.dev/getting-started.html` - mise installation docs
  - `https://github.com/romkatv/powerlevel10k#oh-my-zsh` - p10k installation

  **Acceptance Criteria**:

  ```
  Scenario: apps.sh has idempotent installations
    Tool: Bash
    Preconditions: Script created
    Steps:
      1. test -f /Users/glenn/projects/dotfiles/scripts/apps.sh
      2. test -x /Users/glenn/projects/dotfiles/scripts/apps.sh
      3. grep -q 'test -d.*oh-my-zsh' /Users/glenn/projects/dotfiles/scripts/apps.sh || grep -q '\[ -d.*oh-my-zsh' /Users/glenn/projects/dotfiles/scripts/apps.sh
      4. grep -q 'powerlevel10k' /Users/glenn/projects/dotfiles/scripts/apps.sh
      5. grep -q 'mise' /Users/glenn/projects/dotfiles/scripts/apps.sh
      6. ! grep -q 'logout' /Users/glenn/projects/dotfiles/scripts/apps.sh
      7. ! grep -q 'exit' /Users/glenn/projects/dotfiles/scripts/apps.sh
    Expected Result: Script has idempotency checks, no logout/exit
    Evidence: grep outputs

  Scenario: apps.sh runs twice without errors
    Tool: Bash
    Preconditions: Script created
    Steps:
      1. /Users/glenn/projects/dotfiles/scripts/apps.sh → exit 0
      2. /Users/glenn/projects/dotfiles/scripts/apps.sh → exit 0 (second run idempotent)
    Expected Result: Both runs succeed without errors
    Evidence: Exit codes
  ```

  **Commit**: YES (group with Tasks 3, 4, 6)
  - Message: `feat: add modular setup scripts`
  - Files: `scripts/apps.sh`

---

- [x] 6. Create scripts/stow.sh and Stow Package Structure

  **What to do**:
  - Create stow/ directory structure with packages: zsh, p10k, git, zprofile
  - Move .zshrc to stow/zsh/.zshrc (update content to use $HOME)
  - Copy captured dotfiles to appropriate stow packages
  - Create stow.sh script that:
    - Installs stow via brew if not present
    - Creates ~/.dotfiles-backup/ for existing files
    - Backs up existing dotfiles before stowing
    - Runs `stow -v -d stow -t $HOME <packages>`
  - Update .zshrc to remove hardcoded /Users/glenn paths

  **Must NOT do**:
  - Overwrite existing files without backup
  - Use hardcoded paths in dotfiles
  - Include secrets or machine-specific paths

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: File organization and script creation
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - None needed

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 3, 4, 5)
  - **Blocks**: Task 7
  - **Blocked By**: Task 1

  **References**:
  - Current `dotfiles/dotfiles/.zshrc` - Content to move and update
  - `~/.p10k.zsh` - Content captured in Task 2
  - `~/.gitconfig` - Content captured in Task 2
  - `https://www.gnu.org/software/stow/manual/stow.html` - GNU Stow manual

  **Acceptance Criteria**:

  ```
  Scenario: Stow directory structure is correct
    Tool: Bash
    Preconditions: Task 2 complete
    Steps:
      1. test -d /Users/glenn/projects/dotfiles/stow/zsh
      2. test -f /Users/glenn/projects/dotfiles/stow/zsh/.zshrc
      3. test -d /Users/glenn/projects/dotfiles/stow/git
      4. test -f /Users/glenn/projects/dotfiles/stow/git/.gitconfig
      5. test -d /Users/glenn/projects/dotfiles/stow/p10k
      6. test -f /Users/glenn/projects/dotfiles/stow/p10k/.p10k.zsh
    Expected Result: All stow packages exist with correct files
    Evidence: test command outputs

  Scenario: stow.sh backs up existing files
    Tool: Bash
    Preconditions: Script created
    Steps:
      1. grep -q 'dotfiles-backup' /Users/glenn/projects/dotfiles/scripts/stow.sh
      2. grep -q 'mv.*backup' /Users/glenn/projects/dotfiles/scripts/stow.sh || grep -q 'cp.*backup' /Users/glenn/projects/dotfiles/scripts/stow.sh
    Expected Result: Script has backup logic
    Evidence: grep outputs

  Scenario: .zshrc has no hardcoded user paths
    Tool: Bash
    Preconditions: .zshrc moved to stow
    Steps:
      1. ! grep -q '/Users/glenn' /Users/glenn/projects/dotfiles/stow/zsh/.zshrc
      2. grep -q '\$HOME' /Users/glenn/projects/dotfiles/stow/zsh/.zshrc || grep -q '~' /Users/glenn/projects/dotfiles/stow/zsh/.zshrc
    Expected Result: No hardcoded paths, uses $HOME or ~
    Evidence: grep outputs

  Scenario: stow.sh dry-run succeeds
    Tool: Bash
    Preconditions: Script created, stow structure exists
    Steps:
      1. cd /Users/glenn/projects/dotfiles && stow -n -v -d stow -t $HOME zsh 2>&1
      2. echo $? → 0
    Expected Result: Dry-run shows what would be linked, no errors
    Evidence: stow dry-run output
  ```

  **Commit**: YES (group with Tasks 3, 4, 5)
  - Message: `feat: add modular setup scripts`
  - Files: `scripts/stow.sh`, `stow/**`

---

- [ ] 7. Create bootstrap.sh Orchestrator

  **What to do**:
  - Create main bootstrap.sh that orchestrates all setup scripts
  - Add command-line flags: `--no-brew`, `--no-macos`, `--no-apps`, `--work` (include Brewfile.work)
  - Verify running as non-root user
  - Run scripts in correct order: brew.sh → macos.sh → apps.sh → stow.sh
  - Add colorful output with progress indicators
  - Handle errors gracefully with informative messages
  - Add `--dry-run` option for testing

  **Must NOT do**:
  - Allow running as root
  - Continue on critical errors without user acknowledgment
  - Hardcode any paths

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: Script creation, orchestration logic
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - None needed

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential (Wave 4)
  - **Blocks**: Tasks 8, 9
  - **Blocked By**: Tasks 3, 4, 5, 6

  **References**:
  - `scripts/brew.sh` - Created in Task 3
  - `scripts/macos.sh` - Created in Task 4
  - `scripts/apps.sh` - Created in Task 5
  - `scripts/stow.sh` - Created in Task 6

  **Acceptance Criteria**:

  ```
  Scenario: bootstrap.sh has correct structure
    Tool: Bash
    Preconditions: All scripts created
    Steps:
      1. test -f /Users/glenn/projects/dotfiles/bootstrap.sh
      2. test -x /Users/glenn/projects/dotfiles/bootstrap.sh
      3. head -1 /Users/glenn/projects/dotfiles/bootstrap.sh → contains "#!/usr/bin/env bash"
      4. grep -q 'scripts/brew.sh' /Users/glenn/projects/dotfiles/bootstrap.sh
      5. grep -q 'scripts/macos.sh' /Users/glenn/projects/dotfiles/bootstrap.sh
      6. grep -q 'scripts/apps.sh' /Users/glenn/projects/dotfiles/bootstrap.sh
      7. grep -q 'scripts/stow.sh' /Users/glenn/projects/dotfiles/bootstrap.sh
    Expected Result: bootstrap.sh calls all sub-scripts
    Evidence: grep outputs

  Scenario: bootstrap.sh has flag support
    Tool: Bash
    Preconditions: Script created
    Steps:
      1. grep -qE '\-\-no-brew|\-\-dry-run|\-\-work' /Users/glenn/projects/dotfiles/bootstrap.sh
    Expected Result: Script supports command-line flags
    Evidence: grep output

  Scenario: bootstrap.sh prevents root execution
    Tool: Bash
    Preconditions: Script created
    Steps:
      1. grep -qE 'EUID|whoami.*root|\$UID' /Users/glenn/projects/dotfiles/bootstrap.sh
    Expected Result: Script checks for root and refuses to run
    Evidence: grep output

  Scenario: bootstrap.sh --help shows usage
    Tool: Bash
    Preconditions: Script created
    Steps:
      1. /Users/glenn/projects/dotfiles/bootstrap.sh --help 2>&1 | head -10
      2. echo $? → 0
    Expected Result: Help text displayed
    Evidence: Help output
  ```

  **Commit**: YES
  - Message: `feat: add bootstrap.sh orchestrator with CLI flags`
  - Files: `bootstrap.sh`
  - Pre-commit: `./bootstrap.sh --help`

---

- [ ] 8. Create README.md Documentation

  **What to do**:
  - Create comprehensive README.md with:
    - Quick start (one-liner to run bootstrap)
    - Prerequisites (Xcode CLI tools, Apple ID for mas)
    - What gets installed (Brewfile summary)
    - Script flags and options
    - Directory structure explanation
    - How to customize (edit Brewfile, add stow packages)
    - Troubleshooting common issues
    - How to add new dotfiles to stow

  **Must NOT do**:
  - Include machine-specific information
  - Include secrets or credentials

  **Recommended Agent Profile**:
  - **Category**: `writing`
    - Reason: Documentation creation
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - None needed

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential (Wave 4)
  - **Blocks**: Task 9
  - **Blocked By**: Task 7

  **References**:
  - All created files for accurate documentation
  - `Brewfile` - List packages for documentation
  - Current `dotfiles/dotfiles/readme.md` - Replace this

  **Acceptance Criteria**:

  ```
  Scenario: README has required sections
    Tool: Bash
    Preconditions: README created
    Steps:
      1. test -f /Users/glenn/projects/dotfiles/README.md
      2. grep -q '# ' /Users/glenn/projects/dotfiles/README.md → has title
      3. grep -qi 'quick start\|getting started' /Users/glenn/projects/dotfiles/README.md
      4. grep -qi 'prerequisite' /Users/glenn/projects/dotfiles/README.md
      5. grep -qi 'customize\|customization' /Users/glenn/projects/dotfiles/README.md
    Expected Result: README has key sections
    Evidence: grep outputs

  Scenario: README shows bootstrap command
    Tool: Bash
    Preconditions: README created
    Steps:
      1. grep -q 'bootstrap.sh' /Users/glenn/projects/dotfiles/README.md
      2. grep -q '\-\-' /Users/glenn/projects/dotfiles/README.md → documents flags
    Expected Result: README documents how to run setup
    Evidence: grep outputs
  ```

  **Commit**: YES
  - Message: `docs: add comprehensive README with setup instructions`
  - Files: `README.md`

---

- [ ] 9. Integration Test - Full Bootstrap Dry Run

  **What to do**:
  - Run `./bootstrap.sh --dry-run` to verify all scripts work together
  - Verify no errors or warnings
  - Run `shellcheck` on all shell scripts for quality
  - Test idempotency by running bootstrap concepts twice
  - Document any manual steps required after bootstrap

  **Must NOT do**:
  - Actually modify system during test (use dry-run where possible)
  - Skip shellcheck validation

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Thorough integration testing
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - None needed

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Final (Wave 5)
  - **Blocks**: None (final task)
  - **Blocked By**: All previous tasks

  **References**:
  - All created scripts and files
  - `bootstrap.sh` - Main entry point

  **Acceptance Criteria**:

  ```
  Scenario: All scripts pass shellcheck
    Tool: Bash
    Preconditions: All scripts created, shellcheck installed
    Steps:
      1. shellcheck /Users/glenn/projects/dotfiles/bootstrap.sh
      2. shellcheck /Users/glenn/projects/dotfiles/scripts/*.sh
      3. echo $? → 0 for all
    Expected Result: No shellcheck errors or warnings
    Evidence: shellcheck output (should be empty)

  Scenario: bootstrap.sh --dry-run succeeds
    Tool: Bash
    Preconditions: All scripts created
    Steps:
      1. /Users/glenn/projects/dotfiles/bootstrap.sh --dry-run
      2. echo $? → 0
    Expected Result: Dry run completes without errors
    Evidence: Dry run output

  Scenario: Stow packages deploy correctly
    Tool: Bash
    Preconditions: Scripts run, stow executed
    Steps:
      1. ls -la ~/.zshrc → shows symlink to stow/zsh/.zshrc
      2. ls -la ~/.gitconfig → shows symlink to stow/git/.gitconfig
      3. readlink ~/.zshrc → contains 'dotfiles/stow/zsh/.zshrc'
    Expected Result: All dotfiles are symlinks to stow directory
    Evidence: ls -la and readlink outputs

  Scenario: brew bundle check passes
    Tool: Bash
    Preconditions: brew.sh has run (or dry-run verified Brewfile)
    Steps:
      1. brew bundle check --file=/Users/glenn/projects/dotfiles/Brewfile
      2. echo $? → 0
    Expected Result: All Brewfile packages accounted for
    Evidence: brew bundle check output
  ```

  **Commit**: YES
  - Message: `test: verify full bootstrap integration`
  - Files: Any fixes discovered during testing

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `refactor: flatten nested dotfiles repo structure` | moved files | `git log --oneline -5` |
| 2 | `feat: add Brewfile and captured dotfiles from system audit` | Brewfile*, stow/** | `brew bundle check` |
| 3-6 | `feat: add modular setup scripts` | scripts/*, bootstrap.sh | `shellcheck scripts/*` |
| 7 | `feat: add bootstrap.sh orchestrator with CLI flags` | bootstrap.sh | `./bootstrap.sh --help` |
| 8 | `docs: add comprehensive README with setup instructions` | README.md | visual review |
| 9 | `test: verify full bootstrap integration` | any fixes | full test pass |

---

## Success Criteria

### Verification Commands
```bash
# Structure verification
test -f bootstrap.sh && test -x bootstrap.sh  # Expected: true (exit 0)
test -f Brewfile  # Expected: true
test -d stow/zsh && test -f stow/zsh/.zshrc  # Expected: true
ls scripts/  # Expected: brew.sh macos.sh apps.sh stow.sh

# Idempotency test
./bootstrap.sh --dry-run  # Expected: success
./bootstrap.sh --dry-run  # Expected: success (same output, no changes)

# Script quality
shellcheck bootstrap.sh scripts/*.sh  # Expected: no errors

# Brewfile validity
brew bundle check --file=Brewfile  # Expected: success

# Symlink verification (after running stow.sh)
ls -la ~ | grep -E '\.zshrc|\.gitconfig|\.p10k'  # Expected: symlinks to stow/
```

### Final Checklist
- [ ] Single .git at repo root (no nested repos)
- [ ] All scripts executable and pass shellcheck
- [ ] Brewfile captures current system with categories
- [ ] Brewfile.work contains corporate apps separately
- [ ] Stow packages for all dotfiles
- [ ] No hardcoded /Users/glenn paths in any file
- [ ] No `logout` or `exit` in scripts
- [ ] README documents full usage
- [ ] bootstrap.sh runs without errors (dry-run)
- [ ] Idempotent: running twice produces no changes on second run
