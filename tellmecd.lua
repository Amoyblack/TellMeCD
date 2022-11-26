local AddonPrintlogo = "|cFF00FF7F[TellMeCD]|r: "
local bCanShow = true
local altFrame = CreateFrame("Frame")
local iSpellid = 0
local zhCNLocal = {
    [1] = " %s > 冷却中 (还有%d秒)",
    [2] = " %s > 准备就绪！",
}

local enUSLocal = {
    [1] = " %s > is cooling down (%d sec remaing)",
    [2] = " %s > is Ready！",    
}

local CurrentLocal = {}

local function SetSpellID(id)
	iSpellid = id
end

local function SendCDMsg(msg)
    if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
        SendChatMessage(msg, "INSTANCE_CHAT")
    elseif (IsInRaid()) then
        SendChatMessage(msg, "RAID")
    elseif (IsInGroup()) then
        SendChatMessage(msg, "PARTY")
    else
        print (AddonPrintlogo..msg)
    end
end


local function TellCD()
	if iSpellid == 0 then return end
    local start, duration, enable = GetSpellCooldown(iSpellid)
	if duration > 0 then
		local ServerTime = GetTime()
		local remaingcd = start + duration - ServerTime
		local msg = string.format(CurrentLocal[1],GetSpellLink(iSpellid), remaingcd)
		SendCDMsg(msg)
	elseif enable == 1 then
		local msg = string.format(CurrentLocal[2],GetSpellLink(iSpellid))
		SendCDMsg(msg)
	end
end


local function RepeatMethod()
    if bCanShow and IsAltKeyDown() then
        TellCD()
        bCanShow = false
    elseif not IsAltKeyDown() then
        bCanShow = true
    end
end

local function OnSpellTooltipFunc(tooltip, data)
    if data and data.id then
        SetSpellID(data.id)
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnSpellTooltipFunc)

-- GameTooltip:HookScript("OnTooltipSetSpell", function(self)
--   local id = select(2, self:GetSpell())
--   SetSpellID(id)
-- end)

GameTooltip:HookScript("OnHide", function(self)
	SetSpellID(0)
end)


local function On_EventCB(self, event, arg)
    if event == "PLAYER_ENTERING_WORLD" then
        local clientlang = GetLocale()
        if clientlang == "zhCN" or clientlang == "zhTW" then
            CurrentLocal = zhCNLocal
        else
            CurrentLocal = enUSLocal
        end
    end
end


altFrame:SetScript("OnEvent", On_EventCB)
altFrame:RegisterEvent("PLAYER_ENTERING_WORLD")


if not altFrame.Ticker then
    altFrame.Ticker = C_Timer.NewTicker(0.07, RepeatMethod)
end