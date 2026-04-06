-- 1. 全局配置 (角度变量)
if not HQ_MinimapPos then HQ_MinimapPos = 45 end

-- 2. 创建按钮
HQ_MinimapButton = CreateFrame("Button", "HQ_MinimapButton", Minimap)
HQ_MinimapButton:SetWidth(31)
HQ_MinimapButton:SetHeight(31)
HQ_MinimapButton:SetFrameStrata("LOW")
HQ_MinimapButton:SetFrameLevel(9)
HQ_MinimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- 3. 设置图标 (Aspect of the Viper)
local icon = HQ_MinimapButton:CreateTexture("HQ_MinimapIcon", "BACKGROUND")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetTexture("Interface\\Icons\\Ability_Hunter_AspectOfTheViper")
icon:SetPoint("CENTER", 0, 0)

-- 4. 设置边框
local border = HQ_MinimapButton:CreateTexture("HQ_MinimapBorder", "OVERLAY")
border:SetWidth(53)
border:SetHeight(53)
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetPoint("TOPLEFT", 0, 0)

-- 5. 位置更新函数
function HQ_UpdateMinimapPos()
    local radius = 80 -- 小地图半径
    local x = math.cos(math.rad(HQ_MinimapPos)) * radius
    local y = math.sin(math.rad(HQ_MinimapPos)) * radius
    HQ_MinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- 6. 核心：Shift 拖拽逻辑
HQ_MinimapButton:RegisterForDrag("LeftButton")
HQ_MinimapButton:SetScript("OnDragStart", function()
    -- 只有按住 Shift 时才开启拖拽更新
    if IsShiftKeyDown() then
        this:SetScript("OnUpdate", function()
            local xpos, ypos = GetCursorPosition()
            local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
            local scale = Minimap:GetEffectiveScale()
            
            -- 计算相对于小地图中心的坐标
            local x = (xpos/scale) - xmin - 70
            local y = ypos/scale - ymin - 70
            
            -- 转换弧度为角度
            HQ_MinimapPos = math.deg(math.atan2(y, x))
            HQ_UpdateMinimapPos()
        end)
    end
end)

HQ_MinimapButton:SetScript("OnDragStop", function()
    -- 停止拖拽时清除 OnUpdate 脚本
    this:SetScript("OnUpdate", nil)
end)

HQ_MinimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
HQ_MinimapButton:SetScript("OnClick", function()
    -- 如果按住 Shift 正在拖动，则不触发点击
    if IsShiftKeyDown() then return end
    
    if arg1 == "LeftButton" then
        -- 检测 pfBrowser 是否存在且正在显示
        -- 注意：这里假设你的主面板名为 pfBrowser，如果不是请替换名称
        if pfBrowser and pfBrowser:IsShown() then
            pfBrowser:Hide()
        else
            -- 否则执行搜索/打开逻辑
            HeroismQuestSearch() 
        end
    else
        -- 右键逻辑：切换 HeroismQuestMain 显示
        if HeroismQuestMain then
            if HeroismQuestMain:IsShown() then 
                HeroismQuestMain:Hide() 
            else 
                HeroismQuestMain:Show() 
            end
        end
    end
end)

-- 8. 初始化位置
HQ_UpdateMinimapPos()
HQ_MinimapButton:Show()

-- 9. 添加 Tooltip (提示文字)
HQ_MinimapButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Heroism Quest", 1, 1, 1) -- 标题：白色
    GameTooltip:AddLine(" ") -- 空行
    GameTooltip:AddLine("|cff00ff00click:|r open/close quest search", 1, 1, 1)
    -- GameTooltip:AddLine("|cff00ff00右键:|r 切换主面板显示", 1, 1, 1)
    -- GameTooltip:AddLine("|cffffff00Shift+drag:|r move position", 1, 1, 1)
    GameTooltip:Show()
end)

HQ_MinimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)