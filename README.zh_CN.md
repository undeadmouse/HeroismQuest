# HeroismQuest 任务搜索指令

### 📝 简介
`HeroismQuestSearch` 是用于快速筛选任务的脚本指令。其核心逻辑是帮助玩家寻找**高于自身等级 3 级**的任务。

---

### 💻 宏代码实现

#### 方案 A：默认快捷方式
这是最简短的表达方式，调用插件内置的默认偏移量（+3级）。
```lua
/run HeroismQuestSearch()
```

#### 方案 B：动态等级精确搜索 (推荐)
该脚本会自动获取玩家当前等级，并强制锁定搜索范围为 `当前等级 + 3`。
```lua
/run local lvl=UnitLevel("player"); HeroismQuestSearch(lvl + 3, lvl + 3, lvl)
```

---

### 🔍 语法与参数解析

该函数 `HeroismQuestSearch(min, max, ref)` 的参数拆解如下：

| 参数名称 | 脚本对应代码 | 逻辑描述 |
| :--- | :--- | :--- |
| **最低等级 (Min)** | `lvl + 3` | 搜索任务等级的下限。 |
| **最高等级 (Max)** | `lvl + 3` | 搜索任务等级的上限。 |
| **参考等级 (Ref)** | `lvl` | 以玩家当前实际等级作为计算基准。 |

---

### ⚙️ 使用说明
1. **创建宏**：在游戏内按 `Esc` -> `宏命令设置` -> `新建`。
2. **放置按键**：将宏图标拖到动作条，点击即可刷新符合条件的可接任务。

---

### 💡 扩展应用
如果你想自定义搜索范围，可以参考下表修改参数：

| 需求场景 | 修改后的核心代码 |
| :--- | :--- |
| **搜索高 1 到 3 级** | `HeroismQuestSearch(lvl + 1, lvl + 3, lvl)` |
| **搜索刚好同级的任务** | `HeroismQuestSearch(lvl, lvl, lvl)` |
| **搜索特定 60 级任务** | `HeroismQuestSearch(60, 60, lvl)` |

---

### ⚠️ 注意事项
* **环境要求**：此宏必须在安装了支持 `HeroismQuest` 函数的特定插件（HeroismQuesst 和 pfQuest）后才能生效。
* **英文客户端日显示中文问题**: 下个[有爱魔兽圆体-R.ttf](https://www.ziti.net.cn/static/upload/other/20210904/1630729322472632.ttf)。复制到`TurtleWoW\Fonts`目录下, 改名为`FRIZQT__.ttf`。如果聊天支持中文，复制多一个，改名为`ARIALN.ttf`
---