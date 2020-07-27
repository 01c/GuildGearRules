GuildGearRulesInspector = GuildGearRules:NewModule("GuildGearRulesInspector", "AceEvent-3.0", "AceHook-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGearRules");
local _cstr = string.format;

local DEBUG_MSG_TYPE = {
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
};

function GuildGearRulesInspector:Initialize(core)
    self.Core = core;
    self.IsActive = false;
    self.InspectIndex = 0;
    self.SuccessfulInspectGUIDTimes = { };
    self.AttemptedInspectGUIDTimes = { };
    self.LastDirectInspectTime = 0;
    self.IsCheating = false;
    self.WasCheatingBeforeScan = false;
    self.Hooked = false;
    self.InspectedUnitID = nil;
    self.Cheaters = { };
     -- Dont check shirts or tabards.
    self.InventorySlots = { 0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 };
    self.ScannerTooltip = CreateFrame("GameTooltip", "GuildGearRulesScannerTooltip", nil, "GameTooltipTemplate");
    self.ScannerTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");

    -- This delay should not be necessary, since realistically inspects will not be sent this often in a 40-man raid.
    -- But it helps to keep the traffic down, thus not interfering with normal inspect requests. (at least in small parties)
    self.SuccessfulInspectCooldown = 10;
    self.AttemptedInspectCooldown = 2;
    self.UnitIDs = {
        "mouseover",
        "target",
    }

    -- Add nameplates and raid unitIDs.
    for i = 1, 40 do
       table.insert(self.UnitIDs, "nameplate"..i)
       table.insert(self.UnitIDs, "raid"..i)
    end
    -- Add party unitIDs.
    for i = 1, 4 do
       table.insert(self.UnitIDs, "party"..i)
    end

    InspectFrame_LoadUI();
    self:HookInspectFrame();
end

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end

    return false
end

function GuildGearRulesInspector:HookInspectFrame()
    if (InspectFrame ~= nil and not self.Hooked) then
        self:Hook("InspectFrame_Show", "OnInspectRequest", true);
        self.Hooked = true;
    end
end

function GuildGearRulesInspector:OnInspectRequest(unit)
    self.Core:Log("Normal inspection requested. Scanning stopped.");
    self.InspectedUnitID = unit;
end

function GuildGearRulesInspector:SetActive(active)  
    if (active and not self.IsActive) then
        self.Core:Log("Activating inspector.");
        self:ScanPlayer();
        self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "OnNewUnit", "mouseover");
        self:RegisterEvent("PLAYER_TARGET_CHANGED", "OnNewUnit", "target");
        self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "ScanPlayer");
        self:RegisterEvent("INSPECT_READY", "OnInspectReady");
    elseif (not active and self.IsActive) then
        self.Core:Log("Deactivating inspector.");
        self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");
        self:UnregisterEvent("PLAYER_TARGET_CHANGED");
        self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
        self:UnregisterEvent("INSPECT_READY");
    end

    self.IsActive = active;
end

function GuildGearRulesInspector:ForgetCheater(id)
    if (id == nil or self.Cheaters[id] == nil) then
        return;
    end

    table.remove(self.Cheaters, id);
    -- Update currently viewed cheater in UI.
    self.Core.UI.ViewedCheater = nil;
    if (#self.Cheaters > 0) then
        for key, cheater in pairs(self.Cheaters) do
            if (#cheater.Items > self.Core.Rules.ExceptionsAllowed) then
                self.Core.UI.ViewedCheater = cheater.GUID;
                break;
            end
        end
    end
end

function GuildGearRulesInspector:Update()
    if (not self.IsActive) then return; end

    self:HookInspectFrame();

    if (self.InspectedUnitID) then
        -- Forget about request if unit is too far away.
        if (not CheckInteractDistance(self.InspectedUnitID, 3) or not CanInspect(self.InspectedUnitID, false)) then
            self.Core:Log("Cancelling normal inspection.");
            self.InspectedUnitID = nil;
        else
            self.Core:Log("Repeating normal inspection.");
            NotifyInspect(self.InspectedUnitID);
            return;
        end
    end
    
    local latestInspectTime = 10000000000000;
    local unitIDToScan = nil;

    -- Go through all possible units, and get the one that was successfully inspected the longest time (GUID wise, not unitID) ago.
    for i=1, #self.UnitIDs do
        local unitID = self.UnitIDs[i];
        if (self:NameplatesEnabled() and (unitID == "target" or unitID == "mouseover")) then
            -- Dont query target if nameplates are enabled because that will only risk not being able to resolve their GUIDs.
        else
            name, guid = self:ShouldScan(unitID);
            -- Is valid for inspection, not already called etc.
            if (name ~= nil) then
                local lastInspected = self.SuccessfulInspectGUIDTimes[guid];
                -- Never inspected, pick this directly.
                if (lastInspected == nil) then
                    unitIDToScan = unitID;
                    break;
                -- Compare times.
                elseif (lastInspected < latestInspectTime) then
                    unitIDToScan = unitID;
                    latestInspectTime = lastInspected;
                end
            end
        end
    end

    if (unitIDToScan ~= nil) then
        self:AttemptScan(unitIDToScan, false);
    end
end

function GuildGearRulesInspector:Alert(name, unitID, itemLink)
    self.Core:PlaySound(true, self.Core.db.profile.alertSoundID)
    print(self.Core.Constants.AddOnMessagePrefix .. "[" .. self.Core.UI:ClassColoredName(name, unitID) .. "] " .. _cstr(L["ALERT_MESSAGE_SELF"], itemLink, "|cffffff00/" .. L["CONFIG_COMMAND"] .. " gui|r"))
end

function GuildGearRulesInspector:GetCharacterInfo(unitID)
    local guid = UnitGUID(unitID);
    if (guid == nil) then return nil; end

    local _, _, classID = UnitClass(unitID);

    local characterInfo =
    {
        Name = UnitName(unitID),
        Level = UnitLevel(unitID),
        ClassID = classID,
        Race = UnitRace(unitID),
        UnitID = unitID,
        GUID = guid
	};

    return characterInfo;
end

function GuildGearRulesInspector:ScanPlayer()
    -- Do no scanning if not in guild or no rules found.
    if (not IsInGuild() or self.Core.Rules.MaxItemQuality == nil) then
        return false;
    end

    self.Core:Log("Scanning player items.");

    local characterInfo = self:GetCharacterInfo("player");
    
    self.WasCheatingBeforeScan = self.IsCheating;
    self.IsCheating = false;

    -- Go through each equipment slot.
    for i = 1, #self.InventorySlots do
        self:ValidateItem(characterInfo, self.InventorySlots[i]);
    end

    -- Stopped cheating.
    if (self.WasCheatingBeforeScan and not self.IsCheating) then
        SendChatMessage(self.Core.Constants.MessagePrefix .. L["ALERT_MESSAGE_GUILD_CHAT_ENDED"], "GUILD");
    end
end

--[[function GuildGearRulesInspector:InspectMembers()
    local partyType, count = self:PartyInformation()
    -- Cancel if group has no members, since it might still be under formation. (No accepted invitiations)
    if count == 0 then return end

    -- Reset index or increment index. Index might be beyond count if party has changed.
    if self.InspectIndex >= count then
        self.InspectIndex = 0
    else
        self.InspectIndex = self.InspectIndex + 1
    end

    -- Loop through players from current index, if a inspectable unit is found, inspect it and break
    for i = self.InspectIndex, count do
        local unit = partyType .. i
        if self:AttemptScan(unit) then
            self.InspectIndex = i
            break
        end
    end
end

function GuildGearRulesInspector:IsInspecting(name)
    if self:IsInspectWindowOpen() then
        local currentInspectUnitName = InspectNameText:GetText()
        if currentInspectUnitName == name then
            self.Core:Log("Current inspecting " .. currentInspectUnitName .. ", won't request data.", DEBUG_MSG_TYPE.WARNING)
            return true
        end
    end
    return false
end]]--

function GuildGearRulesInspector:IsInspectWindowOpen()
    local inspectFrame = InspectPaperDollItemsFrame;
    if (inspectFrame ~= nil and inspectFrame:IsVisible()) then
        return true;
    end
    return false;
end

function GuildGearRulesInspector:AttemptScan(unitID)
    local name, guid = self:ShouldScan(unitID);
    if (name == nil) then return false; end

    -- Store time for the request for this GUID.
    self.AttemptedInspectGUIDTimes[guid] = time();

    NotifyInspect(unitID);
    self.Core:Log("[|cff0070ffRequest|r] " .. unitID .. ", " .. self.Core.UI:ClassColoredName(name, unitID) .. " (" .. guid .. ").");
    return true;
end

function GuildGearRulesInspector:ShouldScan(unitID)
    -- Dont scan if running default inspection.
    if (self.InspectedUnitID) then return; end

    local guid = UnitGUID(unitID);
    if (guid == nil) then return nil, nil; end

    if (not UnitIsPlayer(unitID) and not UnitIsUnit(unitID, "player")) then
        return nil, nil;
    end

    -- Dont issue any new requests if the inspect window is open to prevent it from bugging out (removing old data when new arrives)
    if (self:IsInspectWindowOpen()) then return nil, nil; end

    -- Check if unit is same faction first to prevent error from CanInspect on other faction.
    if (UnitFactionGroup(unitID) ~= UnitFactionGroup("player")) then
        return nil, nil;
    end

    -- 3 is the distIndex for Duel and Inspect (7 yards).
    if (not CheckInteractDistance(unitID, 3) or not CanInspect(unitID, false)) then
        -- Cannot inspect this unit.
        return nil, nil;
    end

    local name, realm = UnitName(unitID);
    -- Ignore players not in the same guild.
    if (not self.Core:IsGuildMember(name, realm)) then
        return nil, nil;
    end

    -- Inspects can be requested only X seconds after receiving last INSPECT_READY.
    if (self.SuccessfulInspectGUIDTimes[guid] ~= nil and time() - self.SuccessfulInspectGUIDTimes[guid] <= self.SuccessfulInspectCooldown) then return nil; end
    -- As well as no less than X seconds after last request attempt.
    if (self.AttemptedInspectGUIDTimes[guid] ~= nil and time() - self.AttemptedInspectGUIDTimes[guid] <= self.AttemptedInspectCooldown) then return nil; end

    return name, guid;
end

function GuildGearRulesInspector:PartyInformation()
    local players = GetHomePartyInfo();
    -- Cancel if player is not in a party or raid.
    if players == nil then return nil, 0, nil end;

    local maxPlayers = 4;
    local partyType = "party";
    if (IsInRaid()) then
        partyType = "raid";
        maxPlayers = 40;
    end
    local count = table.getn(players);

    return partyType, count, players, maxPlayers;
end

-- Attempts to get GUID from UnitID.
function GuildGearRulesInspector:GetUnitID(guid, ignoreGuild)
    ignoreGuild = ignoreGuild or false;
    -- Try to resolve GUID regardless if we requested it. This way units that the player inspects will be auto-scanned, and not scanned again for X seconds.
    for i=1, #self.UnitIDs do
        local unitID = self.UnitIDs[i];
        if (UnitGUID(unitID) == guid) then
            local name, realm = UnitName(unitID);
            if (self.Core:IsGuildMember(name, realm) or ignoreGuild) then 
                return unitID;
            end
        end
    end
    return nil;
end

function GuildGearRulesInspector:OnInspectReady(event, inspecteeGUID)
    local scanRequest = true;
    if (self.InspectedUnitID and self:GetUnitID(inspecteeGUID, true) == self.InspectedUnitID) then
        self.InspectedUnitID = nil;
        scanRequest = false;
        self.Core:Log("Received normal inspection.");
    end

    local unitID = self:GetUnitID(inspecteeGUID);
    if (unitID == nil) then
        self.Core:Log("Receiving for " .. inspecteeGUID .. ". UnitID not resolved to guild member.", DEBUG_MSG_TYPE.ERROR);
        return;
    end

    -- Update inspected time, ensuring we don't ask for a new inspect while still receiving information.
    self.SuccessfulInspectGUIDTimes[inspecteeGUID] = time();

    local characterInfo = self:GetCharacterInfo(unitID);

    local filledSlots = 0;
    -- Go through each equipment slot.
    for i = 1, #self.InventorySlots do
        if (self:ValidateItem(characterInfo, self.InventorySlots[i])) then
            filledSlots = filledSlots + 1;
        end
    end

    -- Clear data (as recommended) if the unit was requested and inspection window is not open.
    local ending = ""
    if (scanRequest and self:IsInspectWindowOpen() == false and self.InspectedUnitID == nil) then
        ending = ", clearing";
        ClearInspectPlayer();
    end

    self.Core:Log("[|cff1eff0CHandled|r] " .. unitID .. ", " .. self.Core.UI:ClassColoredName(characterInfo.Name, unitID) .. "|r (" .. inspecteeGUID .. "), "  .. filledSlots .. " slots" .. ending .. ".");
end

function GuildGearRulesInspector:ValidateItem(characterInfo, slot)
    local itemQuality = GetInventoryItemQuality(characterInfo.UnitID, slot);
    -- Only check slots that are not empty.
    if (itemQuality ~= nil) then
        local itemID, unknown = GetInventoryItemID(characterInfo.UnitID, slot);
        local itemLink = GetInventoryItemLink(characterInfo.UnitID, slot);

        -- If registered and had another item on this slot previously, remove it.
        local cheaterID = self:GetCheaterID(characterInfo.GUID);
        if (cheaterID ~= nil) then
            local sameSlotItemID = self:GetCheaterSlotItem(cheaterID, slot);
            if (sameSlotItemID ~= nil) then
                -- Removed item previously on the same slot.
                table.remove(self.Cheaters[cheaterID].Items, sameSlotItemID);
            end
        end

        -- If item is not one of the exceptions.
        if (not has_value(self.Core.Rules.ItemsAllowedIDs, itemID)) then
            -- Check quality first.
            if (itemQuality > self.Core.Rules.MaxItemQuality) then
                self:RegisterCheat(characterInfo, itemLink, slot);
            -- Quality okay, check attributes on items that are at least green (ignore grays and whites)
            elseif (itemQuality >= 2) then
                local cacheItem = self.Core.Cache:New(itemID, true);
                cacheItem.Meta = {
                    CharacterInfo = characterInfo,
                    ItemLink = itemLink,
                    SlotID = slot,
		        };
                self.Core.Cache:Load(itemID, cacheItem);
            end
        end
        return true;
    end
    return false;
end

function GuildGearRulesInspector:HasIllegalAttributes(itemID, itemLink, slot, characterInfo)
    itemName = C_Item.GetItemNameByID(itemID);
    if (itemName == nil) then
        self.Core.Log(itemID .. " could not get item name.", DEBUG_MSG_TYPE.ERROR);
        return; 
    end
    self.ScannerTooltip:ClearLines();
    self.ScannerTooltip:SetHyperlink("item:" .. itemID);
    for i = 1, self.ScannerTooltip:NumLines() do 
        local line = _G["GuildGearRulesScannerTooltipTextLeft"..i];
        if (line ~= nil) then
            local text=line:GetText();

            if (text == RETRIEVING_ITEM_INFO) then
                self.Core.Log(itemLink .. " still retreiving information.", DEBUG_MSG_TYPE.ERROR);
                break;
            end

            for i=1, #self.Core.Rules.Tags do
                local tag = self.Core.Rules.Tags[i];
                if (tag.Type == "ItemAttribute" and tag.Enabled and string.find(text, tag.Pattern)) then               
                    self:RegisterCheat(characterInfo, itemLink, slot);
                    break;
                end
            end
        end
    end
    return false
end

function GuildGearRulesInspector:GetCheaterID(GUID)
    for i = 1, #self.Cheaters do
        if (self.Cheaters[i].GUID == GUID) then
            return i;
        end
    end
    return nil;
end

function GuildGearRulesInspector:GetCheaterItemID(cheaterID, itemLink)
    for i = 1, #self.Cheaters[cheaterID].Items do
        if self.Cheaters[cheaterID].Items[i].Link == itemLink then
            return i
        end
    end
    return nil
end

function GuildGearRulesInspector:GetCheaterSlotItem(cheaterID, slot)
    for i = 1, #self.Cheaters[cheaterID].Items do
        if self.Cheaters[cheaterID].Items[i].SlotID == slot then
            return i
        end
    end
    return nil
end

function GuildGearRulesInspector:RegisterCheat(characterInfo, itemLink, slot)
    if (not characterInfo) then
        self.Core:Log("Nil character info provided.", DEBUG_MSG_TYPE.ERROR);
        return;
    end

    if (not UnitExists(characterInfo.UnitID)) then
        self.Core:Log("Unit " .. characterInfo.UnitID .. " does not exist.", DEBUG_MSG_TYPE.ERROR);
        return;
    end
    
    local cheaterID = self:GetCheaterID(characterInfo.GUID);
    local cheater = nil;
    if (cheaterID ~= nil) then
        cheater = self.Cheaters[cheaterID];
    end

    if (cheater == nil) then
        -- Register.
        local newCheater = {
            GUID = characterInfo.GUID,
            Name = characterInfo.Name,
            Level = characterInfo.Level,
            Race = characterInfo.Race,
            ClassID = characterInfo.ClassID,
            HasAlerted = false,
            Items = { }
		};
        table.insert(self.Cheaters, newCheater);
        cheaterID = #self.Cheaters;
        cheater = self.Cheaters[cheaterID];
    else
        cheater.Level = characterInfo.Level;
    end

    local sameSlotItemID = self:GetCheaterSlotItem(cheaterID, slot);
    if (sameSlotItemID ~= nil) then
        -- Remove item previously on the same slot.
        table.remove(cheater.Items, sameSlotItemID);
    end

    local item = {
        Link = itemLink,
        SlotID = slot,
        Time = date("%H:%M:%S")
	};
    table.insert(cheater.Items, item);

    local itemsEquipped = #cheater.Items;
    if (itemsEquipped > self.Core.Rules.ExceptionsAllowed) then
        -- Alert the first time seen cheating.
        if (not cheater.HasAlerted) then
            self:Alert(characterInfo.Name, characterInfo.UnitID, itemLink);
            cheater.HasAlerted = true;

            if (UnitGUID("player") == characterInfo.GUID) then
                SendChatMessage(self.Core.Constants.MessagePrefix .. _cstr(L["ALERT_MESSAGE_GUILD_CHAT_START"], itemLink), "GUILD");
            end
        end

        if (UnitGUID("player") == characterInfo.GUID) then
            self.IsCheating = true;
        end
    else
        -- Not breaking rules, reset alert to fire again.
        cheater.HasAlerted = false;
    end
end

function GuildGearRulesInspector:NameplatesEnabled()
    return GetCVarInfo("nameplateShowFriends") == "1";
end

function GuildGearRulesInspector:OnNewUnit(unitID, event)
    -- Skip target and mouseover if nameplates are enabled to prevent clogging, also don't inspect player.
    if (self:NameplatesEnabled()) then return; end
    
    -- Only allow one direct inspect per second.
    if (self.LastDirectInspectTime ~= time()) then
        self.LastDirectInspectTime = time();
        self:AttemptScan(unitID);
    end
end