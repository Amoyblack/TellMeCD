local AddonPrintlogo = "|cFF00FF7F[TellMeCD]|r: "
local bCanShow = true
local altFrame = CreateFrame("Frame")
local iSpellid = 0
local timei = 0


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
		local msg = string.format(" %s > 冷却中 (还有%d秒)",GetSpellLink(iSpellid), remaingcd)
		SendCDMsg(msg)
	elseif enable == 1 then
		local msg = string.format(" %s > 准备就绪！",GetSpellLink(iSpellid))
		SendCDMsg(msg)
	end
end



GameTooltip:HookScript("OnTooltipSetSpell", function(self)
  local id = select(2, self:GetSpell())
  SetSpellID(id)
end)

GameTooltip:HookScript("OnHide", function(self)
	SetSpellID(0)
end)

altFrame:SetScript("OnUpdate", function (self, elasped)
	timei = timei + elasped
	if timei > 0.1 then
		if bCanShow and IsAltKeyDown() then
			TellCD()
			bCanShow = false
		elseif not IsAltKeyDown() then
			bCanShow = true
		end
		timei = 0
	end
end)
