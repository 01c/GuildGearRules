GuildGearRules = LibStub("AceAddon-3.0"):NewAddon("GuildGearRules", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGearRules");
local _cstr = string.format;

local DEBUG_MSG_TYPE = {
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
};

local ITEM_FAMILIES = {
    {
        Tag = "TOY",
        IDs = {
            13379, -- Piccolo of the Flaming Fire
            1973, -- Orb of Deception
            19979, -- Hook of the Master Angler
		},
	},
};

local CAPITAL_ZONES = {
    1453, -- Stormwind City
    1455, -- Ironforge
    1457, -- Darnassus
    1454, -- Orgrimmar
    1456, -- Thunder Bluff
    1458, -- Undercity
};

if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE then
    CAPITAL_ZONES = {
        84, -- Stormwind City
        87, -- Ironforge
        89, -- Darnassus
        103, -- The Exodar
        85, -- Orgrimmar
        88, -- Thunder Bluff
        90, -- Undercity
        110, -- Silvermoon City
        111, -- Shattrath City
        125, -- Dalaran - Dalaran City (Crystalsong Forest)
        126, -- Dalaran - The Underbelly (Crystalsong Forest)
        625, -- Dalaran (Broken Isles)
        1165, -- Dazar'alor
	};
end

local BUFF_FAMILIES = {
     {
        Tag = "WB",
        IDs = {
            -- Onyxia and Nefarian.
            16609, -- Warchief's Blessing
            22888, -- Rallying Cry of the Dragonslayer
            -- Hakkar.
            24425, -- Spirit of Zandalar
            -- Felwood.
            15366; -- Songflower Serenade
            -- Darkmoon Faire.
            23768, -- Sayge's Dark Fortune of Damage
            23769, -- Sayge's Dark Fortune of Resistance
            23767, -- Sayge's Dark Fortune of Armor
            23766, -- Sayge's Dark Fortune of Intelligence
            23738, -- Sayge's Dark Fortune of Spirit
            23737, -- Sayge's Dark Fortune of Stamina
            23735, -- Sayge's Dark Fortune of Strength
            23736, -- Sayge's Dark Fortune of Agility
            -- Dire Maul.
            22818, -- Mol'dar's Moxie
            22817, -- Fengus' Ferocity
            22820, -- Slip'kik's Savvy
        },
    },
    {
        Tag = "FL",
        IDs = {
            17626, -- Flask of the Titans
            17627, -- Distilled Wisdom
            17629, -- Chromatic Resistance
            17624, -- Flask of Petrification
            17628, -- Flask of Supreme Power
        },
    },
    {
        Tag = "ZA",
        IDs = {
            24382, -- Spirit of Zanza
            24417, -- Sheen of Zanza
            24383, -- Swiftness of Zanza
        },
    },
    {
        Tag = "BL",
        IDs = {
            10667, -- Rage of Ages
            10669, -- Strike of the Scorpok
            10668, -- Spirit of Boar
            10692, -- Infallible Mind
            10693, -- Spiritual Domination
        },
    },
    {
        Tag = "WS",
        IDs = {
            16329, -- Juju Might
            16323, -- Jugu Power
            16322, -- Juju Flurry
            16327, -- Juju Guile
            16321, -- Juju Escape
            16325, -- Juju Chill
            16326, -- Juju Ember
        },
    },
}

function GuildGearRules:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GuildGearRulesDB", self:DefaultSettings(), true);
    self.LastLog = "";
    self.LogLines = { };

    self.Constants = {
        AnnounceChannel = "GUILD",
        Version = GetAddOnMetadata("GuildGearRules", "version");
        MessagePrefix = "[GGR] ",
        AddOnMessagePrefix = "|cff3ce13f[" .. L["GGR"] .. "]|r ",
        InspectRequest = "!gear",
        DingPattern1 = '^d+i+n+g+',
        DingPattern2 = 'i .*d+i+n+g+e+d+',  
        AlertTestItemID = 19019,
        ViewCheatersCommand = "|cffffff00/" .. L["CONFIG_COMMAND"] .. " cheaters|r",
        ViewCheatersCommandOut = "/" .. L["CONFIG_COMMAND"] .. " cheaters",
        DownloadLink = "https://www.curseforge.com/wow/addons/guild-gear-rules",
    };

    self.SettingTags = self:GetSettingTags();

    self.Locale = GetLocale();
    self.Rules = self:GetDefaultRules();

    self.Cache = self:GetModule("GuildGearRulesCache"):Initialize(self);
    self.Inspector = self:GetModule("GuildGearRulesInspector"):Initialize(self);
    self.UI = self:GetModule("GuildGearRulesUserInterface"):Initialize(self);
    self.Network = self:GetModule("GuildGearRulesNetwork"):Initialize(self);
    GuildGearRulesCharacter:SetPointers();

    -- Cache the item used for test alert.
    self.Cache:Load(self.Constants.AlertTestItemID);

    self.LastRetrievedGuildInfo = nil;
    self.RealmLoaded = false;

    self.LastInspectRequest = 0;
    self.IgnoreOutgoingWhispers = { };

    local pattern = string.gsub(ERR_GUILD_JOIN_S, "%s", ".*");
    self.JoinGuildMessage = string.match(ERR_GUILD_JOIN_S, pattern);

    self.Realm = nil;
    self.Guild = nil;
    self.Player = self:GetCharacterInfo("player");

    self:RegisterChatCommand(L["CONFIG_COMMAND"] , "ChatCommand");
    self:RegisterChatCommand(L["CONFIG_COMMAND_LONG"], "ChatCommand");
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function (chatFrame, event, msg) return self:OutgoingWhisperFilter(chatFrame, event, msg); end)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function (chatFrame, event, msg, author) return self:IncomingWhisperFilter(chatFrame, event, msg, author); end)
    self:Log(tostring(self) .. " initialized.");

    self:LoadGuildSettings();
    self:LoadRealm();

    self.UpdateTimer = self:ScheduleRepeatingTimer("Update", 1);
    self.MinuteTimer = self:ScheduleRepeatingTimer("EveryMinute", 60);
end

function GuildGearRules:DefaultSettings()
    local defaults = {
        profile = {
            HideWarning = false,
            DebuggingLevel = 0,
            DebugCache = false,
            DebugNetwork = false,
            DebugData = false,

            removeBannedBuffs = true,
            receiveData = true,
            alertSoundID = 8959,

            inspectNotify = true,
            inspectGuildOnly = true,
            inspectCooldown = 5,

            welcomeEnabled = false,
            welcomeSoundID = 7094,

            gratulateEnabled = false,
            gratulateSoundID = 124,
            gratulateParty = true,
            gratulateGuild = true,
        },
        char = {
            MinimapButton = { hide = false },
		},
        factionrealm = {
            ignoredReporters = "",  
		}
    };
    return defaults;
end

function GuildGearRules:OnEnable()
    self:Log(tostring(self) .. " enabled.")
    self:RegisterEvent("PLAYER_GUILD_UPDATE", "OnGuildUpdate")
    self:RegisterEvent("CHAT_MSG_WHISPER", "OnWhisper")
    self:RegisterEvent("CHAT_MSG_SYSTEM", "OnSystemMessage");
    self:RegisterEvent("CHAT_MSG_GUILD", "OnMessage", "GUILD");
    self:RegisterEvent("CHAT_MSG_PARTY", "OnMessage", "PARTY");
    self:RegisterEvent("PLAYER_LEVEL_UP", "OnLevelUp"); -- Since some rules are level-based (buffs).
    SendSystemMessage(_cstr(L["ADDON_LOADED"], self.Constants.Version, "/" .. L["CONFIG_COMMAND"]));
end

function GuildGearRules:EveryMinute()
    self.Network:EveryMinute();

    self:LoadGuildSettings();
end

function GuildGearRules:Update()
    if (not self.RealmLoaded) then self:LoadRealm(); end
    if (not self.Rules.Loaded) then self:LoadGuildSettings(); end

    if (not self.RealmLoaded or not self.Rules.Loaded or not IsInGuild()) then
        self.Inspector:SetActive(false);
        return;
    end

    self.Inspector:SetActive(self:RuledZone());

    if (self.Cache ~= nil) then self.Cache:Update(); end
    if (self.Inspector ~= nil) then self.Inspector:Update(); end
end

function GuildGearRules:Message(text, sender, chatFrame)
    local start = self.Constants.AddOnMessagePrefix;
    if (sender ~= nil and sender ~= self.Player) then
        start = _cstr(L["MESSAGE_RECEIVED"], self.UI:ClassIDColored(sender.Name, sender.ClassID));
    end

    chatFrame = chatFrame or DEFAULT_CHAT_FRAME;

    if (chatFrame ~= nil) then
        chatFrame:AddMessage(start .. text);
    end
end

function GuildGearRules:GetDefaultRules()
    local defaultRules = {
        Loaded = false,
        Apply = {
            Level = 0,
            Capitals = true,
            World = true,
            Dungeons = true,
            Raids = true,
            Battlegrounds = true,
		},
        Items = {
            MaxQuality = nil,
            ExceptionsAllowed = 0,
            BannedAttributes = GuildGearRulesTable:New{ },
            AllowedIDs = GuildGearRulesTable:New{ },
		},
        ExcludedRanks = GuildGearRulesTable:New{ },
        BannedBuffGroups = GuildGearRulesTable:New{ },
    };
    return defaultRules;
end

function GuildGearRules:GetSettingTags()
    local tags = {
        {
            Identifier = "SP",
            Found = function() self.Rules.Items.BannedAttributes:Add({ Name =  L["RULES_TAG_SP"], Pattern = L["ATTRIBUTE_SPELLPOWER"] } ); end,
	    },
        {
            Identifier = "AP",
            Found = function() self.Rules.Items.BannedAttributes:Add({ Name =  L["RULES_TAG_AP"], Pattern = L["ATTRIBUTE_ATTACKPOWER"] } ); end,
	    },
        {
            Identifier = "A0",
            Found = function() self.Rules.Apply.Capitals = false; end,
	    },
        {
            Identifier = "A1",
            Found = function() self.Rules.Apply.World = false; end,
	    },
        {
            Identifier = "A2",
            Found = function() self.Rules.Apply.Dungeons = false; end,
	    },
        {
            Identifier = "A3",
            Found = function() self.Rules.Apply.Raids = false; end,
	    },
        {
            Identifier = "A4",
            Found = function() self.Rules.Apply.Battlegrounds = false; end,
	    },
        {
            Identifier = "L%(([%d]+)%)",
            Found = function(args) self.Rules.Apply.Level = tonumber(args); end,
		},
        {
            Identifier = "BUFFS%(([%w%.]+)%)",
            Type = "List",
            Found = 
            function(args)
                if (args ~= nil) then
                    local buffGroup = {
                        MinimumLevel = nil, 
                        IDs = GuildGearRulesTable:New{ },
				    };
                    self.Rules.BannedBuffGroups:Add(buffGroup);

                    for subArg in args:gmatch('[^%.%s]+') do
                        local level = subArg:match("^L(%d+)$");
                        if (level ~= nil) then
                            buffGroup.MinimumLevel = tonumber(level);
                        else
                            self:HandleIDArgument(subArg, buffGroup.IDs, BUFF_FAMILIES, "spell");
                        end
                    end
                end
            end,
	    },
        {
            Identifier = "R%(([%d%.]+)%)",
            Type = "List",
            Found = 
            function(args)
                if (args ~= nil) then
                    for subArg in args:gmatch('[^%.%s]+') do
                        self.Rules.ExcludedRanks:Add(tonumber(subArg));
                    end
                end
            end,
	    },
    };
    return tags;
end

function GuildGearRules:ChatCommand(input)
    LibStub("AceConfigCmd-3.0"):HandleCommand(L["CONFIG_COMMAND"], "GuildGearRules", input);
    self.UI:Refresh();
end

function GuildGearRules:LoadGuildSettings()
    self.Inspector:SetActive(false);
    self:Log("Attempting to load guild settings.");

    if (IsInGuild()) then
        -- Check for latest guild information.
        local guildInfo = GetGuildInfoText();

        if (guildInfo == nil) then 
            self:Log("Guild info returned NIL, keeping old settings.");
            return; 
        end
      
        if (string.len(guildInfo) == 0) then
            self:Log("Guild info returned empty, keeping old settings.");
            return;
        end

        if (guildInfo == self.LastRetrievedGuildInfo) then 
            self:Log("Guild info returned same as before, keeping old settings.");
            return; 
        end

        self.Guild = GetGuildInfo("player")
        if (self.Guild == nil or string.len(self.Guild) == 0) then
            self:Log("Failed retrieving guild name, keeping old settings.");
            return;
        end
        
        -- Proceed, make sure rules are defaulted first.
        self.Rules = self:GetDefaultRules();

        self.LastRetrievedGuildInfo = guildInfo;

        -- Capture all alphanumeric {%w} and comma {,} characters within the square brackets.
        -- Do not allow spaces to prevent guilds accidentally wasting characters in their guild information.
        local arguments = string.match(guildInfo, "GGR%[([%w,]+)%]");
        -- Loop through default arguments.
        if (arguments ~= nil) then
            self:Log("Loading main arguments: " .. arguments);
            local argIndex = 0;
            for arg in arguments:gmatch('[^,]+') do
                if (argIndex == 0) then
                    self.Rules.Items.MaxQuality = tonumber(arg);
                elseif (argIndex == 1) then
                    self.Rules.Items.ExceptionsAllowed = tonumber(arg);
                else
                    self:HandleIDArgument(arg, self.Rules.Items.AllowedIDs, ITEM_FAMILIES, "item");
                end
                argIndex = argIndex + 1;
            end

            -- Capture all alphanumeric {%w} and comma {,} and dot {%.} and parentheses {%(%)} characters within the square brackets.
            arguments = string.match(guildInfo, "GGRTags%[([%w,%.%(%)]+)%]");
            -- Loop through tag arguments.
            if (arguments ~= nil) then
                self:Log("Loading tag arguments: " .. arguments);
                for arg in arguments:gmatch('[^,]+') do
                    -- Check argument against all tags.
                    for i=1, #self.SettingTags do
                        local tag = self.SettingTags[i];
                        local args = string.match(arg, tag.Identifier);
                        if (args) then
                            tag.Found(args);
                            break;
                        end
                    end
                end
            end

            -- Cache all required items.
            for key, value in ipairs(self.Rules.Items.AllowedIDs) do
                self.Cache:Load(value);
            end

            self:Log("Loaded settings for " .. self.Guild .. ".");
            self.Rules.Loaded = true;
        else
            self:Log("No GGR tag found in guild information, rules defaulted.");
        end
    else
        -- No guild, default settings.
        self.Rules = self:GetDefaultRules();
    end
end

function GuildGearRules:HandleIDArgument(arg, list, idList, type)
    local numberArg = tonumber(arg);
    if (numberArg ~= nil) then
        if (self:DoesTypeExist(numberArg, type)) then
            list:Add(numberArg);
        end
    else
        -- Is string, check if it matches one of the ID families.
        for i = 1, #idList do
            if (idList[i].Tag == arg) then
                for j = 1, #idList[i].IDs do
                    if (self:DoesTypeExist(idList[i].IDs[j], type)) then
                        list:Add(idList[i].IDs[j]);
                    end
                end
                return;
            end
        end
        self:Log("Arguments: Unknown tag \"" .. arg .. "\".", DEBUG_MSG_TYPE.WARNING)
    end
end

function GuildGearRules:DoesTypeExist(id, type)
    if (type == nil) then self:Log("Arguments: No type given.", DEBUG_MSG_TYPE.ERROR); return; end
    if (type == "item") then
        local exists = C_Item.DoesItemExistByID(id);
        if (not exists) then self:Log("Arguments: Item with ID " .. id .. " could not be found.", DEBUG_MSG_TYPE.WARNING); end
        return exists;
    elseif (type == "spell") then
        local exists = C_Spell.DoesSpellExist(id);
        if (not exists) then self:Log("Arguments: Spell with ID " .. id .. " could not be found.", DEBUG_MSG_TYPE.WARNING); end
        return exists;
    end
    self:Log("Arguments: Unknown type \"" .. type .. "\".", DEBUG_MSG_TYPE.WARNING);
    return false;
end

function GuildGearRules:StripRealm(name)
    local i = string.find(name, "-");
    -- Do nothing if name doesn't contain realm.
    if (not i) then return name; end
    return string.sub(string.match(name, '^.*\-'), 0, -2)
end

function GuildGearRules:LoadRealm()
    _, self.Realm = UnitFullName("player");

    if (self.Realm ~= nil) then
        self.RealmLoaded = true;
        self:Log("Realm loaded.");
    else
        self:Log("Failed loading realm.");
    end
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

    if (self.db == nil) then self:Message("Error: Profile not initialized. Tried to log: " .. text); return; end
    if (self.db.profile.DebuggingLevel >= msgType) then
        local color = "";
        if (msgType == DEBUG_MSG_TYPE.WARNING) then
            color = "|cffff8000";
        elseif (msgType == DEBUG_MSG_TYPE.ERROR) then
            color = "|cffff4700";
        end
        local msg = color .. date("%H:%M:%S") .. ": " .. tostring(text) .. "|r";
        self.LastLog = text;
        table.insert(self.LogLines, { Text = msg, Times = 1 } );
        if (self.UI ~= nil) then self.UI:Refresh(); end
    end
end

function GuildGearRules:ClearLogs()
    self.LastLog = "";
    self.LogLines = { };
end

function GuildGearRules:IsInCapital()
    local id = C_Map.GetBestMapForUnit("player");
    for i = 1, #CAPITAL_ZONES do
        if (id == CAPITAL_ZONES[i]) then
            return true;
        end
    end
    return false;
end

function GuildGearRules:RuledZone()
    -- Returns wether player is in ruled zone or not.
    local inInstance, instanceType = IsInInstance();

    if (instanceType == "raid") then
        return self.Rules.Apply.Raids;
    elseif (instanceType == "party") then
        return self.Rules.Apply.Dungeons;
    elseif (C_PvP.IsPVPMap()) then
        return self.Rules.Apply.Battlegrounds;
    elseif (self:IsInCapital()) then
        return self.Rules.Apply.Capitals;
    else
        -- Player is not in raid, dungeon, battleground or capital, assume it is in the world.
        return self.Rules.Apply.World;
    end
end

-- IsGuildMember("Tonedo") | IsGuildMember("Tonedo-HydraxianWaterlords"), IsGuildMember("Tonedo", nil) IsGuildMember("Tonedo", "HydraxianWaterlords")
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
        if (fullName == guildieName) then
            return true;
        end
    end
    return false;
end

function GuildGearRules:GuildMemberClassID(memberName)
    if (memberName ~= nil and not memberName:match("-")) then
        memberName = memberName .. "-" .. self.Realm;
    end
    local guildMembersCount = GetNumGuildMembers();
    for i = 1, guildMembersCount do
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(i);
        if (memberName == name) then
            return self.UI:ClassNameID(classDisplayName);
        end
    end
    return 1;
end

function GuildGearRules:GuildCharacterInfo(memberName, memberUID)
    if (memberName ~= nil and not memberName:match("-")) then
        memberName = memberName .. "-" .. self.Realm;
    end

    local guildMembersCount = GetNumGuildMembers();
    for i = 1, guildMembersCount do
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(i);
        local type, server, uid = strsplit("-", GUID);
        if (memberName == name or memberUID == uid) then
            local classID = self.UI:ClassNameID(classDisplayName);
            local characterInfo =
            {
                Name = self:StripRealm(name),
                Level = level,
                ClassID = classID,
                UnitID = unitID,
                GUID = GUID,
                UID = uid,
	        };
            return characterInfo;
        end
    end
    return nil;
end

function GuildGearRules:GetCharacterInfo(unitID)
    local guid = UnitGUID(unitID);
    if (guid == nil) then return nil; end

    local _, _, classID = UnitClass(unitID);

    local type, server, uid = strsplit("-", guid);
    local characterInfo =
    {
        Name = UnitName(unitID),
        Level = UnitLevel(unitID),
        ClassID = classID,
        UnitID = unitID,
        GUID = guid,
        UID = uid,
	};
    return characterInfo;
end

function GuildGearRules:IsIgnored(name)
    for ignored in self.db.factionrealm.ignoredReporters:gmatch('[^\n]+') do
        if (ignored == name) then
            return true;
        end
    end
    return false;
end

function GuildGearRules:IgnoreReporter(name)
    if (self:IsIgnored(name)) then return; end
    local start = "\n";
    if (self.db.factionrealm.ignoredReporters:len() == 0) then start = ""; end
    self.db.factionrealm.ignoredReporters = self.db.factionrealm.ignoredReporters .. start .. name;
end

function GuildGearRules:AddSorted(array, layer, toSort, text)
    table.insert(array, layer .. toSort .. "-" .. text);
end

function GuildGearRules:PlaySound(condition, soundID)
    if condition then
        PlaySound(soundID)
    end
end

-- Prevent player from having to see the inspection results themselves, causing spam in the chat window.
function GuildGearRules:OutgoingWhisperFilter(chatFrame, event, msg)
    local id = chatFrame:GetID();
    if (self.IgnoreOutgoingWhispers[id] ~= nil and self.IgnoreOutgoingWhispers[id] > 0 and msg ~= self.Constants.InspectRequest) then
        self.IgnoreOutgoingWhispers[id] = self.IgnoreOutgoingWhispers[id] - 1;
        return true;
    end
end

-- Replace inspects request with a message confirming if its success.
function GuildGearRules:IncomingWhisperFilter(chatFrame, event, msg, author)
    if (msg == self.Constants.InspectRequest) then
        -- If inspection is on cooldown the player will not get notified about the attempt.
        if (self.db.profile.inspectNotify and (time() - self.LastInspectRequest >= self.db.profile.inspectCooldown)) then
            self:Message(self:StripRealm(author) .. " inspected you.", nil, chatFrame);
        end
        return true;
    end
end

function GuildGearRules:OnWhisper(event, text, targetPlayer)
    if (text == self.Constants.InspectRequest) then
        if (self.db.profile.inspectGuildOnly and not self:IsGuildMember(targetPlayer)) then
            return;
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
                if (itemLinks:len() > 255) then
                    self:SendGearReply(oldItemLinks, targetPlayer);
                    itemLinks = C_Item.GetItemLink(itemLocation)
                end
            end
        end
        -- Send any lasting items.
        if (itemLinks:len() > 0) then
            self:SendGearReply(itemLinks, targetPlayer);
        end
    end
end

function GuildGearRules:SendGearReply(contents, targetPlayer)
    SendChatMessage(contents, "WHISPER", GetDefaultLanguage("player"), targetPlayer);

    -- Go through all possible chat windows. (Max 10 here, actual Blizzard limit unknown)
    for i = 1, 10 do 
        -- Check if they contain the whisper channel.
        local args = {GetChatWindowMessages(i)}; 
        for j=1, #args do
            if (args[j] == "WHISPER") then
                -- Increment outgoing whispers to ignore.
                if (self.IgnoreOutgoingWhispers[i] == nil) then self.IgnoreOutgoingWhispers[i] = 0; end
                self.IgnoreOutgoingWhispers[i] = self.IgnoreOutgoingWhispers[i] + 1;
                break;
            end
        end 
    end
end

function GuildGearRules:OnGuildUpdate(event, unitID)
    self:Log("Received guild update for " .. unitID .. ".");
    if (unitID ~= "player") then
        return;
    end

    self:LoadGuildSettings();
end

function GuildGearRules:OnMessage(channel, event, text, playerName)
    -- Ignore messages sent by the user.
    if string.find(string.lower(playerName), string.lower(self.Player.Name)) then
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

-- https://wow.gamepedia.com/API_UnitLevel
-- "Note that the value returned by UnitLevel("player") will most likely be incorrect when called in a PLAYER_LEVEL_UP event handler,
-- or shortly after leveling in general. Check the PLAYER_LEVEL_UP payload for the correct level."
-- Core.Player.Level is updated on PLAYER_LEVEL_UP, might still give wrong results on other players though.
function GuildGearRules:OnLevelUp(event, level)
    self.Player.Level = level;
    if (self.Inspector ~= nil and self.Inspector.IsActive) then
        self.Inspector:ScanPlayer();
    end
end