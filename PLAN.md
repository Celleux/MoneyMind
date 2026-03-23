# Enforce Critical Quest System Rules: Deterministic Rotation + Graceful Exit on All Quests

## What's Changing

Two gaps found when auditing the quest system against the critical implementation notes:

---

### 1. Deterministic Daily Quest Rotation

**Problem:** Right now, quest selection uses random numbers that change every time the app opens. This means a user could close and reopen the app to "reroll" their daily quests.

**Fix:** Lock quest selection to the calendar day + player level so the same 3 quests always appear for a given day. No more quest shopping by restarting.

- Same player state + same date = same quests every time
- Lucky quest assignment is also locked to the day

---

### 2. Graceful Exit ("Archive Quest") on Every Quest Card

**Problem:** The Write-Off / graceful abandon option currently only exists on the special "Operation: Get Paid" quest. Regular daily and weekly quest cards have no way to gracefully step away.

**Fix:** Add a small "Archive" option to every expanded quest card — tucked below the Complete button so it doesn't distract, but always available. The user earns +15 XP for "Financial Wisdom" and the quest is marked as archived, never as "failed."

- Appears as a subtle text button: "Not for me right now" below the main action
- Awards +15 XP with a brief encouraging message: "That's okay — you tried, and that took courage."
- Shows a brief confirmation before archiving
- Quest disappears from the active list gracefully
- Works identically in daily quests, weekly quests, and chain quests

---

### What's Already Correct (No Changes Needed)
- All data is offline-first via SwiftData ✓
- Quest chains already lock sequentially ✓
- Seasonal quests already rotate by month ✓
- 50-level + boss system is complete ✓
- All quest titles already use RPG language ✓
- UI already uses premium gradients, glows, and animations ✓
- No "Quest Failed" text exists anywhere ✓
