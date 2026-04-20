#!/usr/bin/env bash
# install.sh - Prints setup instructions (no automatic modifications)

set -u

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"

cat <<EOF
===========================================
 Claude Memory & Reminder Skill — Installer
===========================================

This script only prints manual steps. It will NOT modify your
~/.claude/settings.json automatically (to avoid breaking other config).

Skill location: $SKILL_DIR

-------------------------------------------
Step 1. Deploy the hook script
-------------------------------------------

  mkdir -p ~/.claude/hooks
  cp "$SKILL_DIR/hooks/session-start.sh" ~/.claude/hooks/
  chmod +x ~/.claude/hooks/session-start.sh

-------------------------------------------
Step 2. Register the hook in ~/.claude/settings.json
-------------------------------------------

Add this block under the top-level object (merge with existing keys):

  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/session-start.sh" }
        ]
      }
    ]
  }

If you already have a "hooks" key, merge SessionStart into its array.

-------------------------------------------
Step 3. Initialize a project's memory folder
-------------------------------------------

  TARGET="\$HOME/.claude/projects/YOUR-PROJECT/memory"
  mkdir -p "\$TARGET"
  cp "$SKILL_DIR/templates/MEMORY.md" "\$TARGET/"
  cp "$SKILL_DIR/templates/reminders.md" "\$TARGET/"

Then fill in User Info / Preferences in MEMORY.md.

-------------------------------------------
Step 4. (Optional) Customize parameters
-------------------------------------------

  cp "$SKILL_DIR/config.example.json" "$SKILL_DIR/config.json"
  # Edit config.json:
  #   cooldown_hours, ondemand_timeout_days, verified_refresh_day,
  #   extract_days, boundary_days

-------------------------------------------
Step 5. Verify
-------------------------------------------

Start a new Claude Code session. Claude should print a tier-check report
before answering your first message.

EOF
