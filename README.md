[README (中文)](README.zh_CN.md)
# HeroismQuest Search Commands

### 📝 Introduction
`HeroismQuestSearch` is a script command used for rapid quest filtering. Its core logic is designed to help players identify quests that are **3 levels higher** than their current character level.

---

### 💻 Macro Implementation

#### Option A: Default Shortcut
The most concise way to call the script, utilizing the addon's built-in default offset (+3 levels).
```lua
/run HeroismQuestSearch()
```

#### Option B: Dynamic Level Precise Search (Recommended)
This script automatically retrieves the player's current level and forces the search range to be exactly `Current Level + 3`.
```lua
/run local lvl=UnitLevel("player"); HeroismQuestSearch(lvl + 3, lvl + 3, lvl)
```

---

### 🔍 Syntax & Parameter Analysis

The function `HeroismQuestSearch(min, max, ref)` is broken down as follows:

| Parameter | Script Variable | Logic Description |
| :--- | :--- | :--- |
| **Minimum Level (Min)** | `lvl + 3` | The lower bound of the quest level search. |
| **Maximum Level (Max)** | `lvl + 3` | The upper bound of the quest level search. |
| **Reference Level (Ref)** | `lvl` | Uses the player's actual level as the calculation baseline. |

---

### ⚙️ Usage Instructions
1. **Create Macro**: In-game, press `Esc` -> `Macros` -> `New`.
2. **Assign to Bar**: Drag the macro icon to your action bar. Click it to refresh the list of available quests that meet your criteria.

---

### 💡 Advanced Customization
To customize your search range, refer to the table below to modify the parameters:

| Scenario | Modified Core Code |
| :--- | :--- |
| **Search +1 to +3 levels** | `HeroismQuestSearch(lvl + 1, lvl + 3, lvl)` |
| **Search for same-level quests** | `HeroismQuestSearch(lvl, lvl, lvl)` |
| **Search specifically for Level 60** | `HeroismQuestSearch(60, 60, lvl)` |

---

### ⚠️ Important Notes
* **Environment Requirement**: This macro only functions if a specific addon supporting the `HeroismQuest` function (HeroismQuest and pfQuest) is installed and active.