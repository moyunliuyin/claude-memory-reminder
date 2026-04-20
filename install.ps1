# install.ps1 - Prints setup instructions for Windows PowerShell users
# No automatic modification of settings.json

$SkillDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

@"
===========================================
 Claude Memory & Reminder Skill - Installer
===========================================

This script only prints manual steps. It will NOT modify your
~/.claude/settings.json automatically.

Skill location: $SkillDir

-------------------------------------------
Step 1. Deploy the hook script (run in Git Bash / WSL)
-------------------------------------------

  mkdir -p ~/.claude/hooks
  cp "$SkillDir/hooks/session-start.sh" ~/.claude/hooks/
  chmod +x ~/.claude/hooks/session-start.sh

Note: Claude Code on Windows uses bash syntax inside hooks.
      Run these commands in Git Bash or WSL, NOT PowerShell.

-------------------------------------------
Step 2. Register the hook in settings.json
-------------------------------------------

Open `C:\Users\<you>\.claude\settings.json` and add this block
under the top-level object (merge with existing keys):

  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/session-start.sh" }
        ]
      }
    ]
  }

-------------------------------------------
Step 3. Initialize a project's memory folder
-------------------------------------------

Find your project's memory folder at:
  `C:\Users\<you>\.claude\projects\<PROJECT>\memory\`

Copy the template files:
  Copy-Item "$SkillDir\templates\MEMORY.md"    "C:\Users\<you>\.claude\projects\<PROJECT>\memory\"
  Copy-Item "$SkillDir\templates\reminders.md" "C:\Users\<you>\.claude\projects\<PROJECT>\memory\"

Then fill in User Info / Preferences in MEMORY.md.

-------------------------------------------
Step 4. (Optional) Customize parameters
-------------------------------------------

  Copy-Item "$SkillDir\config.example.json" "$SkillDir\config.json"
  # Edit config.json

-------------------------------------------
Step 5. Verify
-------------------------------------------

Start a new Claude Code session. Claude should print a tier-check report
before answering your first message.
"@
