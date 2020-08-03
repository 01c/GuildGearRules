GuildGearRulesNetwork = GuildGearRules:NewModule("GuildGearRulesNetwork", "AceComm-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGearRules");
local _cstr = string.format;

local COLOR_SEARCH = {
    NONE = "|cff889d9d",
    SOME = "|cffffff00",
    VALID = "|cff1eff0c",
    PLAYER = "|cffff8000",
}

local COMMS = {
    SCAN_GGR = "01",
    SCAN_GGR_REPLY = "02",
    SEARCH_ADDONS = "03",
    SEARCH_ADDONS_REPLY = "04",
    CHEATER_DATA = "05",
};

function GuildGearRulesNetwork:Initialize(core)
    self.Core = core;
    self.UI = self.Core:GetModule("GuildGearRulesUserInterface");

    self.VersionAlerted = false;
    -- Changing the prefix will break compatibility with older versions.
    self.CommsPrefix = "GuildGearRules";
    self.SearchStatus = "NONE";
    self.SearchReplies = { };
    self.GuildMemberVersions = { };
    self.MessageToNonUsers = "";

    local guildMembersCount = GetNumGuildMembers();
    for i = 1, guildMembersCount do
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline = GetGuildRosterInfo(i);
        name = self.Core:StripRealm(name);
        if (isOnline) then
            self.GuildMemberVersions[name] = { Version = "?", Online = true, ClassID = self.UI:ClassNameID(classDisplayName) };
        end
    end

    self:Log(tostring(self) .. " initialized.");
    self:ScheduleTimer("RegisterComms", 1);
    return self;
end

function GuildGearRulesNetwork:Log(text, msgType)
    if (self.Core.db.profile.DebugNetwork) then
        self.Core:Log("Network: " .. text, msgType)
    end
end

function GuildGearRulesNetwork:RegisterComms()
    -- Registering Comms on initialization caused infinite loading screen every 1/3 login or so once a few people in the guild had 1.4.
    -- Delaying it by one second seems to have fixed it. 
    self:RegisterComm(self.CommsPrefix);
    -- Broadcast addon version at start, at the same time requesting version from clients v1.4 and later.
    self:Send(COMMS.SCAN_GGR, self.Core.Constants.Version, "GUILD");
    self:RegisterEvent("GUILD_ROSTER_UPDATE", "UpdateGuildMemberList");
    self:Log(tostring(self) .. " registered for Comms.");
end

function GuildGearRulesNetwork:GetActiveAddOns()
    local activeAddOns = { };
    local count = GetNumAddOns();
    for i = 1, count do
        name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(i);
        if (IsAddOnLoaded(name)) then
            table.insert(activeAddOns, name);
        end       
    end
    return activeAddOns;
end

function GuildGearRulesNetwork:Send(messageType, data, channel, target)
    if (messageType == nil) then return; end
    local message = messageType;
    if (data ~= nil) then message = message .. data; end
    self:SendCommMessage(self.CommsPrefix, message, channel, target)
    self:Log("Sending " .. message .. " to " .. tostring(target));
end

function GuildGearRulesNetwork:OnCommReceived(prefix, text, distribution, sender)
    -- Only accept addon calls from guild members.
    if (prefix ~= self.CommsPrefix or not self.Core:IsGuildMember(sender)) then
        return;
    end
    self:Log("Received " .. text .. " from " .. sender);

    local identifier = string.sub(text, 0, 2);
    local contents = string.sub(text, 3);

    if (identifier == COMMS.SCAN_GGR) then
        self:Send(COMMS.SCAN_GGR_REPLY, self.Core.Constants.Version, "WHISPER", sender)
        if (contents:len() > 0) then
            self.GuildMemberVersions[sender] = { Version = self:ValidateVersion(sender, contents), Online = true, ClassID = self.Core:GuildMemberClassID(sender) };
        end
    elseif (identifier == COMMS.SCAN_GGR_REPLY) then
        self.GuildMemberVersions[sender] = { Version = self:ValidateVersion(sender, contents), Online = true, ClassID = self.Core:GuildMemberClassID(sender) };
    elseif (identifier == COMMS.SEARCH_ADDONS) then
        local reply = "0";
        local activeAddOns = self:GetActiveAddOns();
        for arg in contents:gmatch('[^,%s]+') do
            for i = 1, #activeAddOns do
                if (activeAddOns[i]:lower():find(arg:lower(), 1, true)) then
                    local start = "";
                    if (reply == "0") then
                        reply = ""; 
                    elseif (reply:len() > 1) then
                        start = ", ";
                    end
                    reply = reply .. start .. activeAddOns[i];
                    -- Only allow one reply per argument.
                    break;
                end
            end
        end
        self:Send(COMMS.SEARCH_ADDONS_REPLY, reply, "WHISPER", sender)
    elseif (identifier == COMMS.SEARCH_ADDONS_REPLY and self.SearchStatus == "RUNNING") then
        if (self.SearchReplies[sender] ~= nil) then
            self.SearchReplies[sender].Value = contents;
        end
    elseif (identifier == COMMS.CHEATER_DATA and self.Core.db.profile.receiveData) then
        local senderCharacter = self.Core:GuildCharacterInfo(sender);
        if (sender == self.Core.Player.Name or self.Core:IsIgnored(senderCharacter.Name)) then return; end

        local scannedUID = contents:match("(.-)&");
        if (not scannedUID) then return; end
        contents = contents:sub(scannedUID:len() + 2);
        local guid = self.Core.GUIDStart .. scannedUID;

        local scannedCharacter = self.Core:GuildCharacterInfo(nil, scannedUID);
        local character = self.Core.Inspector:RegisterCheater(scannedCharacter);
        if (character ~= nil and scannedCharacter ~= nil) then
            -- Sender has cleared data on cheater, remove entirely.
            if (contents:len() < 3) then
                self:Log("Removing data from " .. senderCharacter.Name .. " on " .. scannedCharacter.Name .. ".");
                character:RemoveData(senderCharacter)
                self.Core.UI:UpdateCharacterView()
            else
                self:Log("Updating data from " .. senderCharacter.Name .. " on " .. scannedCharacter.Name .. ".");
                character:GetData(senderCharacter):Read(contents);
            end
        end
    end
end

function GuildGearRulesNetwork:SearchGuildAddOns(search)
    if (not IsInGuild()) then return false; end

    if (self.SearchStatus == "RUNNING") then
        return;
    end

    self.SearchStatus = "RUNNING";
    self.SearchReplies = { };
    self.UI:Refresh();
    
    -- Populate table with online members and nil values.
    local guildMembersCount = GetNumGuildMembers();
    for i = 1, guildMembersCount do
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline = GetGuildRosterInfo(i);
        name = self.Core:StripRealm(name);
        if (isOnline) then
            self.SearchReplies[name] = { Value = "?", ClassID = self.UI:ClassNameID(classDisplayName) };
        end
    end

    self:Send(COMMS.SEARCH_ADDONS, search, "GUILD");
    self.SearchUsersTimer = self:ScheduleTimer("OnSearchEnd", 5);
end

function GuildGearRulesNetwork:OnSearchEnd()
    self.UI:Refresh();
    self.SearchStatus = "NONE";
end

function GuildGearRulesNetwork:GetSearchResults()
    if (self.SearchStatus == "RUNNING") then return _cstr(L["SEARCH_RUNNING"], 5); end

    local array = { };
    count = 0;

    for player, result in pairs(self.SearchReplies) do
        if (result.Value == "?") then
            self.Core:AddSorted(array, 0, player, self.UI:ClassIDColored(player, result.ClassID) .. " "  .. COLOR_SEARCH.NONE .. L["SEARCH_ADDONS_MESSAGE_NOT_ALLOWED"] .. "|r");
        elseif (result.Value == "0") then
            self.Core:AddSorted(array, 1, player, self.UI:ClassIDColored(player, result.ClassID) .. " " .. COLOR_SEARCH.SOME .. L["SEARCH_ADDONS_MESSAGE_NO_MATCH"] .. "|r");
        else
            local color = COLOR_SEARCH.VALID;
            local layer = 2;
            if (player == self.CharacterName) then
                color = COLOR_SEARCH.PLAYER;
                layer = 3;
            end
            self.Core:AddSorted(array, layer, player, self.UI:ClassIDColored(player, result.ClassID) .. " " .. color .. _cstr(L["SEARCH_ADDONS_MESSAGE"], result.Value) .. "|r");
        end
        count = count + 1;
	end

    -- Sort.
    table.sort(array);
    local output = _cstr(L["DISPLAYING_MEMBERS"], count) .. "\n";
    -- Remove string used for sorting.
    for i, text in ipairs(array) do
        output = output .. string.match(text, "-(.*)") .. "\n"; 
    end
    return output;
end

function GuildGearRulesNetwork:GetUsersList()
    local array = { };
    count = 0;

    for player, status in pairs(self.GuildMemberVersions) do
        local ending = "";
        if (not status.Online) then ending = " " .. L["SCAN_GGR_LOGGED_OFF"]; end

        if (status.Version == "?") then
            local text = L["SCAN_GGR_MESSAGE_NOT_INSTALLED"];
            if (status.Notified ~= nil and status.Notified) then
                text = L["SCAN_GGR_MESSAGE_NOTIFIED"];
            end
            self.Core:AddSorted(array, 0, player, self.UI:ClassIDColored(player, status.ClassID) .. " " .. COLOR_SEARCH.NONE .. text .. ending .. "|r");
        else
            local selfVersionNumber = self:VersionNumberSplit(self.Core.Constants.Version);
            local versionNumber = self:VersionNumberSplit(status.Version);
            local layer = 2;
            local color = COLOR_SEARCH.VALID;

            for i = 1, #selfVersionNumber do
                if (versionNumber[i] == nil or versionNumber[i] < selfVersionNumber[i]) then
                    lowerVersion = true;
                    color = COLOR_SEARCH.SOME;
                    layer = 1;
                    break;
                end
            end

            if (player == self.CharacterName) then
                color = COLOR_SEARCH.PLAYER;
                layer = 3;
            end

            self.Core:AddSorted(array, layer, player, self.UI:ClassIDColored(player, status.ClassID) .. " " .. color .. _cstr(L["SCAN_GGR_MESSAGE"], status.Version) .. ending .. "|r");
        end
        count = count + 1;
	end

    -- Sort.
    table.sort(array);
    local output = _cstr(L["DISPLAYING_MEMBERS"], count) .. "\n";
    -- Remove string used for sorting.
    for i, text in ipairs(array) do
        output = output .. string.match(text, "-(.*)") .. "\n"; 
    end
    return output;
end

function GuildGearRulesNetwork:UpdateGuildMemberList()
    -- Flag users who have logged off as offline and vice-versa.
    local guildMembersCount = GetNumGuildMembers();
    for i = 1, guildMembersCount do
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline = GetGuildRosterInfo(i);
        name = self.Core:StripRealm(name);

        -- If a user logs in that was logged in previously (might have updated) or has not been logged at all, ask for their version.
        if (isOnline and (self.GuildMemberVersions[name] == nil or (self.GuildMemberVersions[name] ~= nil and not self.GuildMemberVersions[name].Online))) then         
            local version = "?";
            if (self.GuildMemberVersions[name] ~= nil) then version = self.GuildMemberVersions[name].Version; end

            self.GuildMemberVersions[name] = { Version = version, Online = true, ClassID = self.UI:ClassNameID(classDisplayName) };
            self:Send(COMMS.SCAN_GGR, self.Core.Constants.Version, "WHISPER", name);
        end

        -- Update online status.
        if (self.GuildMemberVersions[name] ~= nil) then
            self.GuildMemberVersions[name].Online = isOnline;
        end
    end
end

function GuildGearRulesNetwork:NotifyNonUsers()
    if (self.MessageToNonUsers == nil or self.MessageToNonUsers:len() == 0) then return; end

    for player, status in pairs(self.GuildMemberVersions) do
        if (status.Version == "?" and status.Online and (status.Notified == nil or not status.Notified)) then
            status["Notified"] = true;
            SendChatMessage(self.MessageToNonUsers, "WHISPER", GetDefaultLanguage("player"), player);
        end
	end

    self.Core.UI:Refresh();
end

function GuildGearRulesNetwork:EveryMinute()
    self:UpdateGuildMemberList();
end

function GuildGearRulesNetwork:VersionNumberSplit(text)
    local numbers = { };
    for arg in text:gmatch('[^.%s]+') do
        table.insert(numbers, tonumber(arg));
    end
    return numbers;
end

function GuildGearRulesNetwork:ValidateVersion(sender, contents)
    if (contents == nil) then return nil; end

    if (not self.VersionAlerted) then
        local selfVersionNumber = self:VersionNumberSplit(self.Core.Constants.Version);
        local versionNumber = self:VersionNumberSplit(contents);

        local higherVersion = false;
        for i = 1, #selfVersionNumber do
            -- Version number is higher or same as client.
            if (versionNumber[i] ~= nil and versionNumber[i] >= selfVersionNumber[i]) then
                if (versionNumber[i] > selfVersionNumber[i]) then
                    higherVersion = true;
                end
            -- If not, don't check following numbers.
            else
                break;
            end
        end

        if (higherVersion) then
            local classID = self.Core:GuildMemberClassID(sender);
            self.Core:Message(_cstr(L["NEW_VERSION_DETECTED"], contents, self.Core.UI:ClassIDColored(sender, classID), "|cffffff00/" .. L["CONFIG_COMMAND"] .. " gui|r"));
            self.VersionAlerted = true;
        end
    end

    return contents;
end