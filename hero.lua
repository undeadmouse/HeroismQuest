local HERO_QUESTS = {}
local HERO_QUESTS_ORD = {}
local compat = pfQuestCompat
local locale = GetLocale()
-- Define the bitmask maps (Standard 1.12 values)
local classMasks = {
    ["WARRIOR"] = 1, ["PALADIN"] = 2, ["HUNTER"] = 4, ["ROGUE"] = 8,
    ["PRIEST"] = 16, ["SHAMAN"] = 64, ["MAGE"] = 128, ["WARLOCK"] = 256, ["DRUID"] = 1024
}

local raceMasks = {
    ["Human"] = 1, ["Orc"] = 2, ["Dwarf"] = 4, ["NightElf"] = 8,
    ["Undead"] = 16, ["Tauren"] = 32, ["Gnome"] = 64, ["Troll"] = 128,
    -- Turtle WoW specific:
    ["Goblin"] = 256, ["HighElf"] = 512 
}

if not HQ_SearchText or not string.find(HQ_SearchText, "^%*hero%*") then
    HQ_SearchText = "*hero*"
end

--- Checks if the player meets the requirements for a pfQuest data entry
-- @param questData The table containing ["class"] and ["race"] keys
-- @return boolean True if the player matches, false otherwise
local function CanPlayerDoQuest(questData)
    if not questData then return false end

    -- 1. Get Player Info
    local _, pClassEn = UnitClass("player")
    local _, pRaceEn = UnitRace("player")
    
    local pClassVal = classMasks[pClassEn] or 0
    local pRaceVal = raceMasks[pRaceEn] or 0

    -- 2. Check Class (If 0 or nil, all classes can do it)
    local qClassReq = questData["class"] or 0
    local classMatch = (qClassReq == 0) or (bit.band(qClassReq, pClassVal) > 0)

    -- 3. Check Race (If 0 or nil, all races can do it)
    local qRaceReq = questData["race"] or 0
    local raceMatch = (qRaceReq == 0) or (bit.band(qRaceReq, pRaceVal) > 0)

    return classMatch and raceMatch
end

local function SelectView(view)
  for id, frame in pairs(pfBrowser.tabs) do
    pfUI.api.SetButtonFontColor(frame.button, 1, 1, 1, 0.7)
    frame:Hide()
  end
  pfUI.api.SetButtonFontColor(view.button, 0.2, 1, 0.8, 1)
  view.button:Hide()
  view.button:Show()
  view:Show()
end


local function ShowFilterUnit(minLvl, maxLvl)
    local unitDB = pfDB["units"]["data"]
    for idx, button in pairs(pfBrowser.tabs["units"].buttons) do
        button:Hide()
    end
    local index = 1
    for id, info in pairs(unitDB) do
        if type(info) == "table" and not info.fac then
            local low, high
            -- 解析 lvl 字符串 (处理 "8-9" 或 "10" 格式)
            if string.find(info.lvl, "-") then
                _, _, low, high = string.find(info.lvl, "(%d+)-(%d+)")
            else
                low = info.lvl
                high = info.lvl
            end
            low = tonumber(low)
            high = tonumber(high)
            -- 范围重叠逻辑判断
            -- 只要单位的等级范围与你的目标范围有交集，就判定为符合
            if low and high and (low <= maxLvl and high >= minLvl) then
                index = AddUnit(id, info, index)
            end
        end
    end
end


local function updateQuestText(ret)
    for idx, id in ipairs(HERO_QUESTS_ORD) do
        local quest = pfBrowser.tabs["quests"].buttons[idx]
        if not quest then return end
        quest.id = id
        quest:Reload()
        quest.text:SetText(ret[id])
    end
end

local function AddDependQuests(ret, questDB, id, data, depth)
    -- 1. 安全检查：任务数据是否存在，以及是否已经完成
    -- 这里的 id 必须是存在的 key
    local questDataLocale = pfDB["quests"]["loc"][id]
    -- 建议使用更稳妥的完成度检查方法
    local isDone = pfQuest_history and pfQuest_history[id] 
    if type(questDataLocale) == "table" and not isDone and not HERO_QUESTS[id] then
        -- 2. 安全拼接名称（防止 zhCN 缺失导致报错）
        local titleEN = questDataLocale['T'] or "Unknown"
        local titleCN = ""
        if pfDB["quests"]["zhCN"] and pfDB["quests"]["zhCN"][id] and locale ~= "zhCN" then
            titleCN = " " .. (pfDB["quests"]["zhCN"][id]['T'] or "")
        end
        local name = titleEN .. titleCN
        
        -- 3. 递归缩进显示
        if depth > 0 then
            name = string.rep("^", depth) .. name
        end
        
        ret[id] = "|cffffcc00|Hquest:0:0:0:0|h[" .. name .. "]|h|r"
        HERO_QUESTS[id] = id
        table.insert(HERO_QUESTS_ORD, id)
        -- 5. 递归处理前置任务
        if data and data["pre"] and depth < 10 then -- 增加深度保护
            for _, qID in ipairs(data["pre"]) do
                -- 核心：必须确保子任务的数据在数据库中存在
                if questDB[qID] then
                    AddDependQuests(ret, questDB, qID, questDB[qID], depth + 1)
                end
            end
        end
    end
    return resIdx
end

local function filterQuest(ret, questDB, localeDB, playerLvl, minLvl, maxLvl)
    -- Hide All
    HERO_QUESTS = {}
    HERO_QUESTS_ORD = {}
    for id, data in pairs(questDB) do
        if type(data) == "table" and CanPlayerDoQuest(data) then
            local qMin = data["min"] or 0
            local qLvl = data["lvl"] or 0
            -- Condition 1: min >= playerLevel
            -- Condition 2: lvl >= playerLevel + 3 AND lvl < playerLevel + 5
            if qMin <= playerLvl and qLvl >= minLvl and qLvl <= maxLvl and pfQuest_history[id] == nil then
                -- Try to get the name from the locale table if available
                AddDependQuests(ret, questDB, id, data, 0)
            end
        end
    end
end

local function AddUnit(ret, id, info)
    local unitDataLocale = pfDB["units"]["loc"][id]

    -- 2. 安全拼接名称（防止 zhCN 缺失导致报错）
    local titleEN = unitDataLocale
    local titleCN = ""
    if pfDB["units"]["zhCN"] and pfDB["units"]["zhCN"][id] and locale ~= "zhCN" then
        titleCN = " " .. (pfDB["units"]["zhCN"][id] or "")
    end
    local name = titleEN .. titleCN
    
    -- 4. 设置 UI 文本
    -- unit.text:SetText("|cffffcc00|Hquest:0:0:0:0|h[" .. unit.name .. "]|h|r")
    ret[id] = "|cffffcc00|Hquest:0:0:0:0|h[" .. name .. "]|h|r"
end

local function filterUnit(ret, minLvl, maxLvl)
    local unitDB = pfDB["units"]["data"]
    for id, info in pairs(unitDB) do
        if type(info) == "table" and not info.fac then
            local low, high
            -- 解析 lvl 字符串 (处理 "8-9" 或 "10" 格式)
            if string.find(info.lvl, "-") then
                _, _, low, high = string.find(info.lvl, "(%d+)-(%d+)")
            else
                low = info.lvl
                high = info.lvl
            end
            low = tonumber(low)
            high = tonumber(high)
            -- 范围重叠逻辑判断
            -- 只要单位的等级范围与你的目标范围有交集，就判定为符合
            if low and high and (low <= maxLvl and high >= minLvl) then
                index = AddUnit(ret, id, info)
            end
        end
    end
end

local oldGetID = pfDatabase.GetIDByName

function delayUpdateText(ret)
    local totalElapsed = 0
    local delay = 0.2 -- 想要延迟 0.2 秒

    local timerFrame = CreateFrame("Frame")
    timerFrame:SetScript("OnUpdate", function()
        local elapsed = arg1 -- 1.12 中 OnUpdate 的参数是 arg1，表示秒数
        totalElapsed = totalElapsed + elapsed
        
        if totalElapsed >= delay then
            -- 在这里执行你的代码
            updateQuestText(ret)
            -- 执行完后关闭计时器
            timerFrame:SetScript("OnUpdate", nil)
        end
    end)
end

function pfDatabase:GetIDByName(name, db, partial, server)
    -- 1. 拦截检查：是否以 *hero 开头
    -- 使用 ^ 匹配字符串开头，转义 * 号使用 %*
    local isHero = name ~= nil and string.find(name, "^%*hero%*")
    
    if not isHero then
        -- 如果不是以 *hero* 开头，立即返回原函数结果
        return oldGetID(self, name, db, partial, server)
    end

    -- save the search text
    HQ_SearchText = name

    -- 2. 解析参数：提取格式为 *hero*增量,玩家等级 的数字
    local _, _, diff, pLevel = string.find(name, "^%*hero%*(%d*)[%,%*]?(%d*)")    

    -- 转换为数字，如果解析失败则给默认值
    local diffLvl = tonumber(diff) or 3   -- 默认比玩家高 3 级
    local playerLvl = tonumber(pLevel) or UnitLevel("player")
    
    -- 3. 计算目标等级区间
    local targetLvl = playerLvl + diffLvl
    local minL = targetLvl
    local maxL = targetLvl

    -- 4. 执行自定义过滤逻辑
    local ret = {}
    if db == "units" then
        if filterUnit then 
            filterUnit(ret, minL, maxL) 
        end
        return ret
    elseif db == "quests" then
        if pfDB and pfDB["quests"] and filterQuest then
            filterQuest(ret, pfDB["quests"]["data"], pfDB["quests"]["loc"], playerLvl, minL, maxL)
        end
        delayUpdateText(ret)
        return ret
    end

    -- 兜底返回空表或原函数
    return ret
end


HeroismQuestSearch = function(minLvl, maxLvl, requiredLvl)
    local playerLevel = requiredLvl or UnitLevel("player")
    local minL = minLvl or playerLevel + 3
    local maxL = maxLvl or playerLevel + 3

    pfBrowser:Show()
    SelectView(pfBrowser.tabs["quests"])
    -- clear result first
    pfBrowser.input:SetText("")
    pfBrowser.input:SetText(HQ_SearchText)
end
