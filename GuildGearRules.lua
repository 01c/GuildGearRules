GuildGearRules = LibStub("AceAddon-3.0"):NewAddon("GuildGearRules", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGearRules");
local _cstr = string.format;


local DEBUG_MSG_TYPE = {
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
};

local defaults = {
    profile = {
        DebuggingLevel = 0,
        DebugCache = false,

        alertSoundID = 8959,

        inspectGuildOnly = true,
        inspectCooldown = 5,

        welcomeEnabled = false,
        welcomeSoundID = 7094,

        gratulateEnabled = false,
        gratulateSoundID = 124,
        gratulateParty = true,
        gratulateGuild = true,
    },
};

local COMMS = {
    SCAN_GGR = "01",
    SCAN_GGR_REPLY = "02",
    SCAN_ADDONS = "03",
    SCAN_ADDONS_REPLY = "04",
};

function GuildGearRules:OnInitialize()
    self.AddOnsInstalled = { };
    local count = GetNumAddOns()
    for i = 1, count do
        name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(i);
        table.insert(self.AddOnsInstalled, name)
    end

    self.LastLog = "";
    self.LogLines = { };
    self.Constants = {
        CommsPrefix = "GuildGearRules",
        Version = "1.3.2",
        MessagePrefix = "[GGR] ",
        AddOnMessagePrefix = "|cff3ce13f[" .. L["GGR"] .. "]|r ",
        InspectRequest = "!gear",
        DingPattern1 = '^d+i+n+g+',
        DingPattern2 = 'i .*d+i+n+g+e+d+',  
        AlertTestItemID = 19019,
    };

    self.Locale = GetLocale();
    self.Rules = self:GetDefaultRules();

    self.Cache = self:GetModule("GuildGearRulesCache");
    self.Cache:Initialize(self);
    self.Inspector = self:GetModule("GuildGearRulesInspector");
    self.Inspector:Initialize(self);
    self.UI = self:GetModule("GuildGearRulesUserInterface");
    self.UI:Initialize(self);

    -- Cache the item used for test alert.
    self.Cache:Load(self.Constants.AlertTestItemID);

    self.GuildScanRunning = nil;
    self.GuildScanReplies = {};

    self.LastRetrievedGuildInfo = nil;
    self.GuildSettingsLoaded = false;
    self.RealmLoaded = false;

    self.LastInspectRequest = 0;
    self.ScanGuildResults = "";

    local pattern = string.gsub(ERR_GUILD_JOIN_S, "%s", ".*");
    self.JoinGuildMessage = string.match(ERR_GUILD_JOIN_S, pattern);

    self.Realm = nil;
    self.Guild = nil;
    self.CharacterName = nil;

    self.db = LibStub("AceDB-3.0"):New("GuildGearRulesDB", defaults, true);
    self.UpdateTimer = self:ScheduleRepeatingTimer("Update", 1);
    self.MinuteTimer = self:ScheduleRepeatingTimer("EveryMinute", 60);

    LibStub("AceConfig-3.0"):RegisterOptionsTable("GuildGearRules", self.UI:GetOptions());
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GuildGearRules", L["GUILD_GEAR_RULES"]);
    self.optionsFrame.default = function() self.db:ResetProfile(defaults); self.UI:Refresh(); end;

    self:RegisterChatCommand("ggr", "ChatCommand");
    self:RegisterChatCommand("guildgearrules", "ChatCommand");

    self:RegisterComm("GuildGearRules");

    self:Log("Initialized.");

    self:LoadGuildSettings();
    self:LoadRealm();
end

function GuildGearRules:GetDefaultRules()
    local defaultRules = {
        MaxItemQuality = nil,
        Tags = {
            {
                Tag = "SP",
                Type = "ItemAttribute",
                Text = L["RULES_TAG_SP"],
                Enabled = false,
                Pattern = L["ATTRIBUTE_SPELLPOWER"],
			},
            {
                Tag = "PVP",
                Type = "Zone",
                Text = L["RULES_TAG_PVP"],
                Enabled = false,
			},
            {
                Tag = "PVE",
                Type = "Zone",
                Text = L["RULES_TAG_PVE"],
                Enabled = false,
			},
        },
        ExceptionsAllowed = 0,
        ItemsAllowedIDs = { },
    };
    return defaultRules;
end

function GuildGearRules:IsTagEnabled(tag)
    for i = 1, #self.Rules.Tags do
        if (self.Rules.Tags[i].Tag == tag) then
           return self.Rules.Tags[i].Enabled;
        end
    end
end

function GuildGearRules:ChatCommand(input)
    LibStub("AceConfigCmd-3.0"):HandleCommand(L["CONFIG_COMMAND"], "GuildGearRules", input);
    self.UI:Refresh();
end

function GuildGearRules:LoadGuildSettings()
    self.GuildSettingsLoaded = false;
    self:Log("Attempting to load guild settings.");
    -- Make sure rules are defaulted first.
    self.Rules = self:GetDefaultRules();

    if (IsInGuild()) then
        local guildInfo = GetGuildInfoText();
        if (guildInfo == nil or string.len(guildInfo) == 0) then
            self:Log("Failed retrieving guild info text.");
            return;
        end

        self.Guild = GetGuildInfo("player")
        if (self.Guild == nil or string.len(self.Guild) == 0) then
            self:Log("Failed retrieving guild name.");
            return;
        end

        self.LastRetrievedGuildInfo = guildInfo;

        local arguments = string.match(guildInfo, "GGR%[(.-)%]");
        -- Loop through default arguments.
        if (arguments ~= nil) then
            local argIndex = 0;
            for arg in arguments:gmatch('[^,%s]+') do
                if (argIndex == 0) then
                    self.Rules.MaxItemQuality = tonumber(arg);
                elseif (argIndex == 1) then
                    self.Rules.ExceptionsAllowed = tonumber(arg);
                else
                    table.insert(self.Rules.ItemsAllowedIDs, tonumber(arg));
                end
                argIndex = argIndex + 1;
            end
        end

        arguments = string.match(guildInfo, "GGRTags%[(.-)%]");
        -- Loop through tag arguments.
        if (arguments ~= nil) then
            for arg in arguments:gmatch('[^,%s]+') do
                for i=1, #self.Rules.Tags do
                    local tag = self.Rules.Tags[i];
                    if (tag.Tag == arg) then
                        tag.Enabled = true;
                    end
                end
            end
        end

        self:Log("Loaded settings for " .. self.Guild .. ".");

        -- Cache all required items.
        for key, value in ipairs(self.Rules.ItemsAllowedIDs) do
            self.Cache:Load(value);
        end
    end

    self.GuildSettingsLoaded = true;
end

function GuildGearRules:OnEnable()
    self:Log("Enabling.")
    self:RegisterEvent("PLAYER_GUILD_UPDATE", "OnGuildUpdate")
    self:RegisterEvent("CHAT_MSG_WHISPER", "OnWhisper")
    self:RegisterEvent("CHAT_MSG_SYSTEM", "OnSystemMessage");
    self:RegisterEvent("CHAT_MSG_GUILD", "OnMessage", "GUILD");
    self:RegisterEvent("CHAT_MSG_PARTY", "OnMessage", "PARTY");
    SendSystemMessage(_cstr(L["ADDON_LOADED"], self.Constants.Version, "/" .. L["CONFIG_COMMAND"]));
end

function GuildGearRules:LoadRealm()
    self.CharacterName, self.Realm = UnitFullName("player");

    if (self.Realm ~= nil) then
        self.RealmLoaded = true;
        self:Log("Realm loaded.");
    else
        self:Log("Failed loading realm.");
    end
end

function GuildGearRules:OnCommReceived(prefix, text, distribution, sender)
    -- Only accept addon calls from guild members.
    if (prefix ~= self.Constants.CommsPrefix or not self:IsGuildMember(sender)) then
        return;
    end

    local identifier = string.sub(text, 0, 2);
    local contents = string.sub(text, 3);

    if (identifier == COMMS.SCAN_GGR) then
        self:SendCommMessage(self.Constants.CommsPrefix, COMMS.SCAN_GGR_REPLY .. self.Constants.Version, "WHISPER", sender)
    elseif (identifier == COMMS.SCAN_ADDONS) then
        local reply = "0";
        for arg in contents:gmatch('[^,%s]+') do
            for i = 1, #self.AddOnsInstalled do
                if (self.AddOnsInstalled[i]:lower():find(arg:lower(), 1, true)) then
                    local start = "";
                    if (reply == "0") then
                        reply = ""; 
                    elseif (reply:len() > 1) then
                        start = ", ";
                    end
                    reply = reply .. start .. self.AddOnsInstalled[i];
                    -- Only allow one reply per argument.
                    break;
                end
            end
        end
        self:SendCommMessage(self.Constants.CommsPrefix, COMMS.SCAN_ADDONS_REPLY .. reply, "WHISPER", sender)
    elseif (identifier == COMMS.SCAN_GGR_REPLY and self.GuildScanRunning ~= nil) then
        self.GuildScanReplies[sender] = contents;
    elseif (identifier == COMMS.SCAN_ADDONS_REPLY and self.GuildScanRunning ~= nil) then
        local installed = string.sub(contents, 0, 1);
        self.GuildScanReplies[sender] = contents;
    end
end

function GuildGearRules:VersionNumberSplit(text)
    local numbers = { };
    for arg in text:gmatch('[^.%s]+') do
        table.insert(numbers, tonumber(arg));
    end
    return numbers;
end

function GuildGearRules:OnScanEnd()
    self.ScanGuildResults = "";
    count = 0;
    for player, result in pairs(self.GuildScanReplies) do
        if (self.GuildScanRunning == 0) then
            if (result == "?") then
                self.ScanGuildResults = self.ScanGuildResults .. "|cff889d9d" .. player .. " " .. L["SCAN_GGR_MESSAGE_NOT_INSTALLED"] .. "|r\n";
            else
                local selfVersionNumber = self:VersionNumberSplit(self.Constants.Version);
                local versionNumber = self:VersionNumberSplit(result);
                local color = "|cff1eff0c";
                for i = 1, #selfVersionNumber do
                    if (versionNumber[i] == nil or versionNumber[i] < selfVersionNumber[i]) then
                        lowerVersion = true;
                        color = "|cffffff00";
                        break;
                    end
                end

                self.ScanGuildResults = self.ScanGuildResults .. color .. player .. " " .. _cstr(L["SCAN_GGR_MESSAGE"], result) .. "|r\n";
            end
        elseif (self.GuildScanRunning == 1) then
            if (result == "?") then
                self.ScanGuildResults = self.ScanGuildResults .. "|cff889d9d" .. player .. " " .. L["SCAN_ADDONS_MESSAGE_NOT_ALLOWED"] .. "|r\n";
            elseif (result == "0") then
                self.ScanGuildResults = self.ScanGuildResults .. "|cffffff00" .. player .. " " .. L["SCAN_ADDONS_MESSAGE_NO_MATCH"] .. "|r\n";
            else
                self.ScanGuildResults = self.ScanGuildResults .. "|cff1eff0c" .. player .. " " .. _cstr(L["SCAN_ADDONS_MESSAGE"], result) .. "|r\n";
            end
        end
        count = count + 1;
	end
    self.ScanGuildResults = self.ScanGuildResults .. _cstr(L["SCAN_COMPLETED"], count) .. "\n";
    self.UI:Refresh();
    self.GuildScanRunning = nil;
end

function GuildGearRules:ScanGuild(scanType)
    if (not IsInGuild()) then return false; end
    if (scanType ~= 0 and scanType ~= 1) then return; end
    if (scanType == 1 and (self.UI.ScanGuildAddOnsInput == "" or self.UI.ScanGuildAddOnsInput == nil)) then return; end

    self.ScanGuildResults = "";
    if (self.GuildScanRunning ~= nil) then
        self.ScanGuildResults = L["SCAN_ALREADY_RUNNING"];
        return;
    end
    self.ScanGuildResults = _cstr(L["SCAN_STARTED"], 5);

    self.GuildScanRunning = scanType;
    self.ScanUsersTimer = self:ScheduleTimer("OnScanEnd", 5);
    self.GuildScanReplies = { };
    self.UI:Refresh()
    
    -- Populate table with online members and nil values.
    local guildMembersCount = GetNumGuildMembers();
    for i = 1, guildMembersCount do
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline = GetGuildRosterInfo(i);
        name = self:StripRealm(name);
        if (isOnline) then
            self.GuildScanReplies[name] = "?";
        end
    end

    if (scanType == 0) then
        self:SendCommMessage(self.Constants.CommsPrefix, COMMS.SCAN_GGR, "GUILD");
    elseif (scanType == 1) then
        self:SendCommMessage(self.Constants.CommsPrefix, COMMS.SCAN_ADDONS .. self.UI.ScanGuildAddOnsInput, "GUILD");
    end
end

function GuildGearRules:StripRealm(name)
    return string.sub(string.match(name, '^.*\-'), 0, -2)
end

function GuildGearRules:ElementIndex(tab,el)
    for index, value in pairs(tab) do
	    if value == el then
	        return index
	    end
	end
    return nil
end

function GuildGearRules:Info(text)
    print(self.Constants.AddOnMessagePrefix .. text)
end

function GuildGearRules:Log(text, msgType)
    -- If debug level not specified, default to low
    msgType = msgType or DEBUG_MSG_TYPE.INFO;

    if (text == self.LastLog and self.db.profile.DebuggingLevel >= msgType) then 
        -- For repeated messages, add a counter at the end (#)
        self.LogLines[#self.LogLines].Times = self.LogLines[#self.LogLines].Times + 1;
        self.UI:Refresh();
        return;
    end

    self.LastLog = text

    local color = ""
    if msgType == DEBUG_MSG_TYPE.WARNING then
        color = "|cffff8000"
    elseif msgType == DEBUG_MSG_TYPE.ERROR then
        color = "|cffff4700"
    end

    local msg = color .. date("%H:%M:%S") .. ": " .. tostring(text) .. "|r"

    if self.db == nil then print(self.Constants.AddOnMessagePrefix .. "Error: Profile not initialized. Tried to log: " .. text) return end
    if (self.db.profile.DebuggingLevel >= msgType) then
        table.insert(self.LogLines, { Text = msg, Times = 1 } );
        self.UI:Refresh();
    end
end

function GuildGearRules:ClearLogs()
    self.LastLog = ""
    self.LogLines = { }
end

function GuildGearRules:EveryMinute()
    -- Check for new guild information.
    local guildInfo = GetGuildInfoText();
    if (guildInfo ~= nil or guildInfo:len() == 0 or guildInfo == self.LastRetrievedGuildInfo) then return; end
    self:LoadGuildSettings();
end

function GuildGearRules:Update()
    if (not self.RealmLoaded) then self:LoadRealm(); end
    if (not self.GuildSettingsLoaded) then self:LoadGuildSettings(); end

    if (not self.RealmLoaded or not self.GuildSettingsLoaded or self.Rules.MaxItemQuality == nil or not IsInGuild()) then
        self.Inspector:SetActive(false);
        return;
    else
        self.Inspector:SetActive(true);
    end

    if (self:IsTagEnabled("PVE")) then -- PVE Only.
        local inInstance, instanceType = IsInInstance();
        if (instanceType == "raid" or instanceType == "party") then
            self.Inspector:SetActive(true);
        else
            self.Inspector:SetActive(false);
        end
    elseif (self:IsTagEnabled("PVP")) then -- Allow battlegrounds and arenas.
        if (C_PvP.IsPVPMap()) then
            self.Inspector:SetActive(false);
        else
            self.Inspector:SetActive(true);
        end
    end

    if (self.Cache ~= nil) then self.Cache:Update(); end
    if (self.Inspector ~= nil) then self.Inspector:Update(); end
end

-- IsGuildMember("Tonedo") | IsGuildMember("Tonedo-HydraxianWatelords"), IsGuildMember("Tonedo", nil) IsGuildMember("Tonedo", "HydraxianWatelords")
function GuildGearRules:IsGuildMember(playerName, realm)
    if (not IsInGuild()) then
        return false;
    end

    if (realm == nil) then
        local i = string.find(playerName, "-")
        if (i) then
            -- Name contains realm, extract it.
            return self:IsGuildMember(string.sub(playerName, 0, i - 1), string.sub(playerName, i + 1));
        else
            -- No realm which,  player is on same realm.
            return self:IsGuildMember(playerName, self.Realm);
        end
    end
    
    -- Different realm, can't be in same guild.
    if (realm ~= self.Realm) then
        return false;
    end

    local fullName = playerName .. "-" .. realm;
    local guildMembersCount = GetNumGuildMembers();
    for i = 1, guildMembersCount do
        -- Realm name included by default.
        local guildieName = GetGuildRosterInfo(i);
        --if stripRealm then name = self:StripRealm(name) end
        if (fullName == guildieName) then
            return true;
        end
    end
    return false;
end

function GuildGearRules:OnWhisper(event, text, targetPlayer)
    if text == self.Constants.InspectRequest then
        if self.db.profile.inspectGuildOnly and not self:IsGuildMember(targetPlayer) then
            return
        end

        if (time() - self.LastInspectRequest < self.db.profile.inspectCooldown) then
            return;
        end

        self.LastInspectRequest = time();

        local itemLinks = ""
        for i = 1,19 do
            itemLocation = ItemLocation:CreateFromEquipmentSlot(i)
            if C_Item.DoesItemExist(itemLocation) == true then
                local oldItemLinks = itemLinks
                itemLinks = itemLinks .. C_Item.GetItemLink(itemLocation)
                -- If new message exceeds max string length, send previous and reset message to current item only.
                if string.len(itemLinks) > 255 then
                    SendChatMessage(oldItemLinks, "WHISPER", GetDefaultLanguage("player"), targetPlayer)
                    itemLinks = C_Item.GetItemLink(itemLocation)
                end
            end
        end
        -- Send any lasting items.
        SendChatMessage(itemLinks, "WHISPER", GetDefaultLanguage("player"), targetPlayer)
    end
end

function GuildGearRules:OnGuildUpdate(event, unitID)
    self:Log("Received guild update.");
    if (unitID ~= "player") then
        return;
    end

    self.Inspector:SetActive(false);
    self:LoadGuildSettings();
end

function GuildGearRules:OnMessage(channel, event, text, playerName)
    -- Ignore messages sent by the user.
    if string.find(string.lower(playerName), string.lower(self.CharacterName)) then
        return
    end

    -- Ding alert.
    if self.db.profile.gratulateEnabled and (string.match(string.lower(text), self.Constants.DingPattern1) or string.match(string.lower(text), self.Constants.DingPattern2)) then
        if (channel == "PARTY" and not self.db.profile.gratulateParty) or (channel == "GUILD" and not self.db.profile.gratulateGuild) then
            return
        end

        self:PlaySound(self.db.profile.gratulateEnabled, self.db.profile.gratulateSoundID)
    end
end

function GuildGearRules:OnSystemMessage(event, text)
    -- New member alert.
    if self.db.profile.welcomeEnabled and string.find(string.lower(text), self.JoinGuildMessage) then
        self:PlaySound(self.db.profile.welcomeEnabled, self.db.profile.welcomeSoundID)
    end
end

function GuildGearRules:PlaySound(condition, soundID)
    if condition then
        PlaySound(soundID)
    end
end
