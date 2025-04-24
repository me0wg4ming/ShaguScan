if ShaguScan.disabled then return end

local core = CreateFrame("Frame", nil, WorldFrame)

core.guids = {}

core.add = function(unit)
  local _, guid = UnitExists(unit)

  if guid then
    core.guids[guid] = GetTime()
  end
end

-- unitstr
core:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
core:RegisterEvent("PLAYER_TARGET_CHANGED")
core:RegisterEvent("PLAYER_ENTERING_WORLD")

-- arg1
core:RegisterEvent("UNIT_COMBAT")
core:RegisterEvent("UNIT_HAPPINESS")
core:RegisterEvent("UNIT_MODEL_CHANGED")
core:RegisterEvent("UNIT_PORTRAIT_UPDATE")
core:RegisterEvent("UNIT_FACTION")
core:RegisterEvent("UNIT_FLAGS")
core:RegisterEvent("UNIT_AURA")
core:RegisterEvent("UNIT_HEALTH")
core:RegisterEvent("UNIT_CASTEVENT")

core:SetScript("OnEvent", function()
  if event == "UPDATE_MOUSEOVER_UNIT" then
    this.add("mouseover")
  elseif event == "PLAYER_ENTERING_WORLD" then
    this.add("player")
  elseif event == "PLAYER_TARGET_CHANGED" then
    this.add("target")
  else
    this.add(arg1)
  end
end)

local soundButton = CreateFrame("Button", "ShaguScanSoundToggle", Minimap)
soundButton:SetWidth(24)
soundButton:SetHeight(24)
soundButton:SetFrameStrata("LOW")
soundButton:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, 0)

-- Dragging support (optional)
soundButton:SetMovable(true)
soundButton:EnableMouse(true)
soundButton:RegisterForDrag("LeftButton")
soundButton:SetScript("OnDragStart", function()
  this:StartMoving()
end)
soundButton:SetScript("OnDragStop", function()
  this:StopMovingOrSizing()
end)

-- Background icon
soundButton.icon = soundButton:CreateTexture(nil, "BACKGROUND")
soundButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Horn_02")
soundButton.icon:SetWidth(24)
soundButton.icon:SetHeight(24)
soundButton.icon:SetPoint("CENTER", soundButton, "CENTER")

-- Tooltip
soundButton:SetScript("OnEnter", function()
  GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT")
  GameTooltip:AddLine("ShaguScan Sound Toggle")
  GameTooltip:AddLine("Click to toggle PvP alert sound.")
  GameTooltip:AddLine("Status: " .. (ShaguScan_db.soundalert and "|cff00ff00ON" or "|cffff0000OFF"))
  GameTooltip:Show()
end)
soundButton:SetScript("OnLeave", function()
  GameTooltip:Hide()
end)

local menuFrame = CreateFrame("Frame", "ShaguScanDropdown", UIParent, "UIDropDownMenuTemplate")

local menuList = {}

-- Create the popup dialog
StaticPopupDialogs["SHAGUSCAN_NEW"] = {
  text = "Enter name for the new scanner:",
  button1 = "Create",
  button2 = "Cancel",
  hasEditBox = 1,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,

  OnAccept = function()
    local editBox = getglobal("StaticPopup1EditBox")
    local text = editBox:GetText()
    if SlashCmdList and SlashCmdList["SHAGUSCAN"] then
      SlashCmdList["SHAGUSCAN"](text)
    end
  end,

  EditBoxOnEnterPressed = function()
    local text = this:GetText()
    this:GetParent():Hide()
    if SlashCmdList and SlashCmdList["SHAGUSCAN"] then
      SlashCmdList["SHAGUSCAN"](text)
    end
  end,
}

-- Dropdown menu builder
function ShaguScan_InitDropdownMenu()
  local label = ShaguScan_db.soundalert and "Disable Sound" or "Enable Sound"

  UIDropDownMenu_AddButton({
    text = "ShaguScan Options",
    isTitle = 1,
    notCheckable = 1
  })

  UIDropDownMenu_AddButton({
    text = label,
    notCheckable = 1,
    func = function()
      ShaguScan_db.soundalert = not ShaguScan_db.soundalert
      if ShaguScan_db.soundalert then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00ShaguScan:|r Sound alert |cff33ff33enabled|r.")
      else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00ShaguScan:|r Sound alert |cffff3333disabled|r.")
      end
    end
  })

  UIDropDownMenu_AddButton({
    text = "Create New Scanner",
    notCheckable = 1,
    func = function()
      StaticPopup_Show("SHAGUSCAN_NEW")
      getglobal("StaticPopup1EditBox"):SetText("Scanner_" .. math.random(1000, 9999))
    end
  })
end

-- Right-click minimap button opens menu
soundButton:RegisterForClicks("RightButtonUp")
soundButton:SetScript("OnClick", function()
  ToggleDropDownMenu(1, nil, menuFrame, "cursor", 0, 0)
  UIDropDownMenu_Initialize(menuFrame, ShaguScan_InitDropdownMenu, "MENU")
end)


ShaguScan.core = core