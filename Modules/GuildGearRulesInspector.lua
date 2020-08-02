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
    self.Network = self.Core:GetModule("GuildGearRulesNetwork");

    self.LastDataTransmission = 0;
    self.DataTransmissionCooldown = 1;

    self.SuccessfulInspectGUIDTimes = { };
    self.AttemptedInspectGUIDTimes = { };
    self.LastDirectInspectTime = 0;
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

    self.Core:Log(tostring(self) .. " initialized.");
    return self;
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
        self:RegisterEvent("UNIT_AURA", "ScanPlayer");
        -- Ensure buffs that could not be removed when in combat are removed.
        self:RegisterEvent("PLAYER_REGEN_ENABLED", "ScanPlayer");
        self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "ScanPlayer");
        self:RegisterEvent("INSPECT_READY", "OnInspectReady");
    elseif (not active and self.IsActive) then
        self.Core:Log("Deactivating inspector.");
        self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");
        self:UnregisterEvent("PLAYER_TARGET_CHANGED");
        self:UnregisterEvent("UNIT_AURA");
        self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
        self:UnregisterEvent("INSPECT_READY");
    end

    self.IsActive = active;
end

function GuildGearRulesInspector:ForgetCheater(cheater)
    if (cheater == nil) then
        return;
    end

    for index, value in pairs(self.Cheaters) do
        if (value.GUID == cheater.GUID) then
            table.remove(self.Cheaters, index);
            break;
        end
    end

    -- Update currently viewed cheater in UI.
    self.Core.UI:UpdateCharacterView();
end

function GuildGearRulesInspector:Update()
    if (not self.IsActive) then return; end
    self:HookInspectFrame();

    -- Only send data about one cheater per cooldown, to prevent data spam.
    if (time() - self.LastDataTransmission >= self.DataTransmissionCooldown) then
        local latestSendTime = 10000000000000;
        local cheaterToTransmit = nil;

        -- Pick the cheater whose data sent the longest time ago.
        for index, cheater in pairs(self.Cheaters) do
            local lastSend = cheater:GetLastSendTime();
            if (lastSend ~= nil and lastSend < latestSendTime) then
                cheaterToTransmit = cheater;
                latestSendTime = lastSend;
            end
        end

        if (cheaterToTransmit ~= nil and cheaterToTransmit:SendData()) then
            self.LastDataTransmission = time();
        end
    end

    -- Default inspection.
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

function GuildGearRulesInspector:Alert(name, classID, bannedThing, sender)
    self.Core:PlaySound(true, self.Core.db.profile.alertSoundID)
    self.Core:Message(self.Core.UI:ClassIDColored(name, classID) .. " " .. _cstr(L["ALERT_MESSAGE_SELF"], bannedThing, self.Core.ViewCheatersCommand), sender);
end

function GuildGearRulesInspector:AlertStopped(name, classID, sender)
    self.Core:PlaySound(true, self.Core.db.profile.alertSoundID)
    self.Core:Message(L["ALERT_MESSAGE_STOPPED"], sender);
end

function GuildGearRulesInspector:ScanPlayer()
    self.Core:Log("Scanning player.");

    local cheater = self:GetCheater(self.Core.Player.GUID);
    local wasCheatingBeforeScan = (cheater ~= nil and cheater:CheatingDataCount() > 0);

    if (self:RulesApply(self.Core.Player.UnitID)) then
        self:ScanUnit(self.Core.Player);
    end

    cheater = self:GetCheater(self.Core.Player.GUID);
    -- Stopped cheating.
    if (wasCheatingBeforeScan and (cheater == nil or cheater:CheatingDataCount() == 0)) then
        SendChatMessage(self.Core.Constants.MessagePrefix .. _cstr(L["ALERT_MESSAGE_GUILD_CHAT_ENDED"], "/ggr cheaters"), self.Core.AnnounceChannel);
    end
end

function GuildGearRulesInspector:ScanUnit(characterInfo)
    -- Go through each equipment slot.
    local filledSlots = 0;
    for i = 1, #self.InventorySlots do
        if (self:ValidateItem(characterInfo, self.InventorySlots[i])) then
            filledSlots = filledSlots + 1;
        end
    end

    local cheater = self:GetCheater(characterInfo.GUID);
    if (cheater ~= nil) then
        cheater:GetData(self.Core.Player):ClearBuffs();
    end

    -- Validate buffs.
    for i = 1, #self.Core.Rules.BannedBuffGroups do
        local buffGroup = self.Core.Rules.BannedBuffGroups[i];
        if (buffGroup.MinimumLevel == nil or buffGroup.MinimumLevel <= characterInfo.Level) then
            self:ValidateBuffs(characterInfo, buffGroup.IDs);
        end
    end

    local cheater = self:GetCheater(characterInfo.GUID);
    if (cheater ~= nil) then
        cheater:GetData(self.Core.Player):BuffsUpdated();
    end

    return filledSlots;
end

function GuildGearRulesInspector:ValidateBuffs(characterInfo, ggrTable)
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID = UnitAura(characterInfo.UnitID, i, "CANCELABLE");
        if (spellID ~= nil and ggrTable:Contains(spellID)) then
            local registerBuff = true;
            -- If player self, remove buff automatically if enabled.
            -- Buff will not be registered, in case unit is in combat and buff cannot be removed a new scan is ran when combat ends.
            if (characterInfo.UnitID == "player" and self.Core.db.profile.removeBannedBuffs) then
                CancelUnitBuff(characterInfo.UnitID, i, "CANCELABLE");
                registerBuff = false;
            end

            if (registerBuff) then
                self:RegisterBuffCheat(characterInfo, spellID);
            end
        end
    end
end

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

function GuildGearRulesInspector:RulesApply(unitID)
    return UnitLevel(unitID) >= self.Core.Rules.Apply.Level;
end

function GuildGearRulesInspector:ShouldScan(unitID)
    -- Dont scan if running default inspection.
    if (self.InspectedUnitID) then return; end

    local guid = UnitGUID(unitID);
    if (guid == nil) then return nil, nil; end

    if (not self:RulesApply(unitID)) then return nil, nil; end

    -- Ignore non-players and user.
    if (not UnitIsPlayer(unitID) or UnitIsUnit(unitID, "player")) then return nil, nil; end
    -- Dont issue any new requests if the inspect window is open to prevent it from bugging out (removing old data when new arrives)
    if (self:IsInspectWindowOpen()) then return nil, nil; end
    --Make sure unit is same faction first to prevent error from CanInspect on other faction.
    if (UnitFactionGroup(unitID) ~= UnitFactionGroup("player")) then return nil, nil; end
    -- 3 is the distIndex for Duel and Inspect (7 yards).
    if (not CheckInteractDistance(unitID, 3) or not CanInspect(unitID, false)) then return nil, nil; end

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

    -- Make sure the rules apply to this unit before we scan and potentially flag it as a cheater.
    if (not self:RulesApply(unitID)) then
        return;
    end

    self.SuccessfulInspectGUIDTimes[inspecteeGUID] = time();

    local characterInfo = self.Core:GetCharacterInfo(unitID);

    -- Scan unit and get how many slots we scanned.
    local filledSlots = self:ScanUnit(characterInfo);

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

    -- Sometimes itemID is found when item quality is not. This could be checked to see if the slot is empty, but it's not reliable since itemID is also nil sometimes even if the slot is not empty.

    -- Only check slots which we have information about.
    if (itemQuality ~= nil) then
        local itemID, unknown = GetInventoryItemID(characterInfo.UnitID, slot);
        local itemLink = GetInventoryItemLink(characterInfo.UnitID, slot);
        
        -- Cancel any pending validation on previous item in same slot.
        self.Core.Cache:Cancel(characterInfo, slot);

        local removeItem = true;
        -- If item is not one of the exceptions.
        if (not self.Core.Rules.Items.AllowedIDs:Contains(itemID)) then
            -- Check quality first.
            if (itemQuality > self.Core.Rules.Items.MaxQuality) then
                self:RegisterItemCheat(characterInfo, itemID, itemLink, slot);
                removeItem = false;
            -- Quality okay, check attributes on items that are at least green (ignore grays and whites for performance)
            elseif (itemQuality >= 2) then
                local cacheItem = self.Core.Cache:New(itemID, true);
                cacheItem.Meta = {
                    CharacterInfo = characterInfo,
                    ItemLink = itemLink,
                    SlotID = slot,
		        };
                self.Core.Cache:Load(itemID, cacheItem);
                removeItem = false;
            end
        end

        -- Remove item currently on slot if not currently being checked for attributes (or replaced removed by new item).
        if (removeItem) then
            local cheater = self:GetCheater(characterInfo.GUID);
            if (cheater ~= nil) then
                cheater:GetData(self.Core.Player):ClearItemSlot(slot);
            end
        end
        return true;
    end
    return false;
end

function GuildGearRulesInspector:ValidateItemAttributes(itemID, itemLink, slot, characterInfo)
    itemName = C_Item.GetItemNameByID(itemID);
    if (itemName == nil) then
        self.Core:Log(itemID .. " could not get item name.", DEBUG_MSG_TYPE.ERROR);
        return; 
    end

    local bannedAttributesFound = false;

    self.ScannerTooltip:ClearLines();
    self.ScannerTooltip:SetHyperlink("item:" .. itemID);
    for i = 1, self.ScannerTooltip:NumLines() do 
        local line = _G["GuildGearRulesScannerTooltipTextLeft"..i];
        if (line ~= nil) then
            local text=line:GetText();

            if (text == RETRIEVING_ITEM_INFO) then
                self.Core:Log(itemLink .. " still retreiving information.", DEBUG_MSG_TYPE.ERROR);
                break;
            end

            for i=1, #self.Core.Rules.Items.BannedAttributes do
                local attribute = self.Core.Rules.Items.BannedAttributes[i];
                if (text:gsub('%d', '') == attribute.Pattern) then
                    self:RegisterItemCheat(characterInfo, itemID, itemLink, slot);
                    bannedAttributesFound = true;
                    break;
                end
            end
        end
    end

    -- This item is okay, remove item previously on slot.
    if (not bannedAttributesFound) then
        local cheater = self:GetCheater(characterInfo.GUID);
        if (cheater ~= nil) then
            cheater:GetData(self.Core.Player):ClearItemSlot(slot);
        end
    end

    return false;
end

function GuildGearRulesInspector:GetCheater(GUID)
    capturerGUID = capturer or self.Core.Player.GUID;
    for i = 1, #self.Cheaters do
        if (self.Cheaters[i].GUID == GUID) then
            return self.Cheaters[i];
        end
    end
    return nil;
end

function GuildGearRulesInspector:RegisterCheater(characterInfo)
    if (not characterInfo) then
        self.Core:Log("Nil character info provided.", DEBUG_MSG_TYPE.ERROR);
        return nil;
    end

    local cheater = self:GetCheater(characterInfo.GUID);
    if (cheater == nil) then
        cheater = GuildGearRulesCharacter:New(characterInfo)
        table.insert(self.Cheaters, cheater);
    else
        cheater.Level = characterInfo.Level;
    end

    return cheater;
end

function GuildGearRulesInspector:RegisterItemCheat(characterInfo, itemID, itemLink, slot)
    local character = self:RegisterCheater(characterInfo);
    if (character ~= nil) then
        character:GetData(self.Core.Player):NewItem(itemID, itemLink, slot, true);
    end
end

function GuildGearRulesInspector:RegisterBuffCheat(characterInfo, spellID)
    local character = self:RegisterCheater(characterInfo);
    if (character ~= nil) then
        character:GetData(self.Core.Player):NewBuff(spellID);
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