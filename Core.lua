GuildGearRules = LibStub("AceAddon-3.0"):NewAddon("GuildGearRules", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0")

local C = {
    GUILD = "|cff3ce13f",
    PARTY = "|cffaaabfe"
}

local function Color(col, text)
    return col .. text .. "|r"
end

local lastDesc = ""
local function Desc(text)
    lastDesc = text
    return text
end

function GuildGearRules:GetOptions()
    options = {
        name = "Guild Gear Rules",
        handler = GuildGearRules,
        type = "group",
        childGroups = "tab",
        args = {
            gui = {
                order = 0.25,
                type = "execute",
                guiHidden = true,
                name = "Open the GUI.",
                func = "ShowGUI",
			},
            mainDesc = {
                order = 0.5,
                type = "description",
                name = "|cfffff569Version|r " .. self.Constants.Version,
                fontSize = "small",
            },
            basics = {
                order = 1,
                name = "Basics",
                type = "group",
                args = {
                    gearOptions = {
                        order = 1,
                        type = "group",
                        inline = true,
                        cmdHidden = true,
                        name = "Gear Checker",
                        args = {
                            desc = {
                                order = 1,
                                type = "description",
                                name = "Alerts you if nearby " .. Color(C.GUILD, "guild members") .. " break the rules.\n\nAnnounces in " .. Color(C.GUILD, "guild channel") .. " if you break the rules and when you abide them again.",
                                fontSize = "medium",
                            },
                            footer = {
                                order = 5,
                                type = "description",
                                name = "This is a core functionality and cannot be toggled.",
                                fontSize = "small",
                            },
                        },
                    },
                    rules = {
                        order = 2,
                        type = "group",
                        inline = true,
                        cmdHidden = true,
                        name = "Rules",
                        args = {
                            title = {
                                order = 1,
                                type = "description",
                                name = function() if not IsInGuild() then return "Not in a guild." else return "Rules loaded for " .. Color(C.GUILD, GetGuildInfo("player")) .. "." end end,
                                fontSize = "medium",
                            },
                            maxQuality = {
                                order = 3,
                                type = "description",
                                name = function() return "|cffe6cc80Max Item Quality|r: " .. self:GetItemQualityText(self.Rules.MaxItemQuality) end,
                                fontSize = "small",
					        },
                            exceptions = {
                                order = 4,
                                type = "description",
                                name = function() return "|cffe6cc80Exceptions|r: " .. self.ExceptionsText end,
                                fontSize = "small",
                            },
                        },
                    },
                    inspection = {
                        order = 3,
                        type = "group",
                        guiInline = true,
                        name = "Distant Inspection",
                        desc = Desc("Allow players to inspect you by whispering |cffff7eff!gear|r."),
                        args = {
                            desc = {
                                order = 1,
                                type = "description",
                                name = lastDesc,
                                fontSize = "medium",
                            },
                            descExtra = {
                                order = 2,
                                type = "description",
                                name = "This will reply with a item link to each of your equipped items.",
                                fontSize = "small",
                            },
                            enabled = {
                                order = 3,
                                type = "toggle",
                                width = "half",
                                name = "Enabled",
                                desc = "Activate or deactivate the function.",
                                set = function(info,val) self.db.profile.inspectEnabled = val end,
                                get = function(info) return self.db.profile.inspectEnabled end
                            },
                            guildOnly = {
                                order = 4,
                                type = "toggle",
                                width = "half",
                                disabled = function() return not self.db.profile.inspectEnabled; end,
                                name = Color(C.GUILD, "Guild only"),
                                desc = "Only allow members of the same guild to inspect you.",
                                set = function(info,val) self.db.profile.inspectGuildOnly = val end,
                                get = function(info) return self.db.profile.inspectGuildOnly end
                            },
                        },
                    },
                },
            },
            social = {
                order = 2,
                name = "Social",
                type = "group",
                args = {
                    welcome = {
                        order = 1,
                        name = "Welcome",
                        desc = Desc("Alerts you with a sound when new " .. Color(C.GUILD, "guild members") .. " join."),
                        type = "group",
                        guiInline = true,
                        args = {
                            desc = {
                                order = 1,
                                type = "description",
                                name = lastDesc,
                                fontSize = "medium",
                            },
                            enabled = {
                                order = 2,
                                type = "toggle",
                                width = "half",
                                name = "Enabled",
                                desc = "Activate or deactivate the function.",
                                set = function(info,val) self.db.profile.welcomeEnabled = val; self:PlaySound(val, self.db.profile.welcomeSoundID) end,
                                get = function(info) return self.db.profile.welcomeEnabled end
                            },
						},
					},
                    gratulate = {
                        order = 2,
                        name = "Gratulate",
                        desc = Desc("Alerts you with a sound when players write ding in specified channels."),
                        type = "group",
                        guiInline = true,
                        args = { 
                            desc = {
                                order = 1,
                                type = "description",
                                name = lastDesc,
                                fontSize = "medium",
                            },
                            enabled = {
                                order = 2,
                                type = "toggle",
                                width = "half",
                                name = "Enabled",
                                desc = "Activate or deactivate the function.",
                                set = function(info,val) self.db.profile.gratulateEnabled = val; self:PlaySound(val, self.db.profile.gratulateSoundID) end,
                                get = function(info) return self.db.profile.gratulateEnabled end
                            },
                            party = {
                                order = 4,
                                type = "toggle",
                                width = "half",
                                disabled = function() return not self.db.profile.gratulateEnabled; end,
                                name = Color(C.PARTY, "Party"),
                                desc = "React on party channel.",
                                set = function(info,val) self.db.profile.gratulateParty = val end,
                                get = function(info) return self.db.profile.gratulateParty end
                            },
                            guild = {
                                order = 5,
                                type = "toggle",
                                width = "half",
                                disabled = function() return not self.db.profile.gratulateEnabled; end,
                                name = Color(C.GUILD, "Guild"),
                                desc = "React on guild channel.",
                                set = function(info,val) self.db.profile.gratulateGuild = val end,
                                get = function(info) return self.db.profile.gratulateGuild end
                            },
                        }
                    },
                },
            },
            advanced = {
                order = 3,
                name = "Advanced",
                type = "group",
                args = {
                    scanGuild = {
                        order = 1,
                        type = "execute",
                        name = "Scan Guild Members",
                        func = "CheckGuildUsers",
                        desc = "Scans addon usage among online guild members, returning their version if installed. Prints results in the scan results tab.",
                        disabled = function() return not IsInGuild() end
					},
                    debugEnabled = {
                        order = 2,
                        type = "toggle",
                        name = "Debug Logs",
                        desc = "Print debug logs.",
                        set = function(info,val) self.db.profile.DebugLogs = val end,
                        get = function(info) return self.db.profile.DebugLogs end
                    },
                    scanResults = {
                        order = 3,
                        name = "Scan Results",
                        type = "group",
                        cmdHidden = true,
                        args = {
                            text = {
                                type = "description",
                                width = "full",
                                name = function() return self.ScanGuildResults end,
					        },
						},
					},
                    debugLogs = {
                        order = 4,
                        name = "Debug Logs",
                        type = "group",
                        cmdHidden = true,
                        args = {
                            debugLogs = {
                                type = "description",
                                width = "full",
                                name = function() return self.Logs end,
                            },
                        },
                    },
                },
            },
        },
    }
    return options
end

local defaults = {
    profile = {
        DebugLogs = false,

        inspectEnabled = true,
        inspectGuildOnly = true,

        welcomeEnabled = false,
        welcomeSoundID = 6125,

        gratulateEnabled = false,
        gratulateSoundID = 124,
        gratulateParty = false,
        gratulateGuild = false,
    },
}

local constants = {
    CommsPrefix = "GuildGearRules",
    Version = "1.3",
    MessagePrefix = "[GGR] ",
    AddOnMessagePrefix = Color(C.GUILD, "[Guild Gear Rules] "),
    InspectRequest = "!gear",
    DingPattern1 = '^d+i+n+g+',
    DingPattern2 = 'i .*d+i+n+g+e+d+',  
}

local defaultRules = {
    MaxItemQuality = nil,
    DungeonsOnly = false,
    ItemExeceptionsIDs = { }
}

local IsCheating = false
local lastWrongTime = 0

function GuildGearRules:OnInitialize()
    self:RegisterComm("GuildGearRules")
    self.Logs = ""
    self.Constants = constants
    self.Rules = defaultRules
    self.ItemCacheQueue = {}
    self.InspectIndex = 0
    self.InspectedGUIDTimes = { }
    self.PlayerUnitIDs = {}

    self.AddonScanRunning = false
    self.AddonGuildies = {}

    self.GuildSettingsLoaded = false
    self.RealmLoaded = false

    self.ScanGuildResults = ""
    self.ExceptionsText = "-"

    self.Realm = nil
    self.Guild = nil
    self.CharacterName = nil

    self.db = LibStub("AceDB-3.0"):New("GuildGearRulesDB", defaults, true)
    self.ScanTimer = self:ScheduleRepeatingTimer("TimerFeedback", 3)

    self.ScannerTooltip = CreateFrame("GameTooltip", "ScannerTooltip", nil, "GameTooltipTemplate");
    ScannerTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");

    local options = self:GetOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("GuildGearRules", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GuildGearRules", "Guild Gear Rules")

    self:RegisterChatCommand("ggr", "ChatCommand")
    self:RegisterChatCommand("guildgearrules", "ChatCommand")

    self:RegisterChatCommand("GGRTarget", "InspectCommand")
    self:RegisterChatCommand("GGRAll", "InspectMembers")
    self:RegisterChatCommand("GGRCheck", "CheckGuildUsers")

    self:Log("Initialized.")

    self:LoadGuildSettings()
    self:LoadRealm()
end

function GuildGearRules:ChatCommand(input)
    LibStub("AceConfigCmd-3.0"):HandleCommand("ggr", "GuildGearRules", input)
    LibStub("AceConfigRegistry-3.0"):NotifyChange("GuildGearRules");
end

function GuildGearRules:ShowGUI()
    LibStub("AceConfigDialog-3.0"):Open("GuildGearRules")
end

function GuildGearRules:CoreEnabled()
    return self.GuildSettingsLoaded and self.RealmLoaded and self.Rules.MaxItemQuality ~= nil and IsInGuild()
end

function GuildGearRules:LoadGuildSettings()
    self:Log("Loading guild settings.")
    -- Make sure rules are defaulted first.
    self.Rules = defaultRules
    self.ExceptionsText = "-"

    if IsInGuild() then
        local guildInfo = GetGuildInfoText()
        if guildInfo == nil or string.len(guildInfo) == 0 then
            self:Log("Failed retrieving guild info text.")
            return
        end

        self.Guild = GetGuildInfo("player")
        if self.Guild == nil or string.len(self.Guild) == 0 then
            self:Log("Failed retrieving guild name.")
            return
        end

        -- Cut to start within bracket.
        local index = string.find(guildInfo, 'GGR')
        if index == nil then return end
        guildInfo = string.sub(guildInfo, index + 4)

        -- Cut to end within bracket.
        index = string.find(guildInfo, ']') - 1
        if index == nil then return end
        guildInfo = string.sub(guildInfo, 0, index)

        -- Loop through the arguments.
        local argIndex = 0
        for arg in guildInfo:gmatch('[^,%s]+') do
            if argIndex == 0 then
                self.Rules.MaxItemQuality = tonumber(arg)
            elseif argIndex == 1 then
                self.Rules.DungeonsOnly = arg
            else
                table.insert(self.Rules.ItemExeceptionsIDs, tonumber(arg))
            end
            argIndex = argIndex + 1
        end

        self:Log("Loaded settings for " .. self.Guild .. ".")

        self:RegisterEvent("GET_ITEM_INFO_RECEIVED", "OnReceiveItemInfo");
        -- Cache all required items.
        for key, value in ipairs(self.Rules.ItemExeceptionsIDs) do
            self:CacheItem(value)
        end

        self:CheckIfCacheLoaded()
    end

    self.GuildSettingsLoaded = true
    if self.Rules.MaxItemQuality ~= nil then
        self:CheckPlayerItems()

        -- Dont register these events before excemptions (guild info) and realm is loaded.
        self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "OnMouseOverUnitChanged")
        self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "CheckPlayerItems")
        self:RegisterEvent("INSPECT_READY", "OnInspectReady")
    end
end

function GuildGearRules:OnEnable()
    self:Log("Enabling.")
    self:RegisterEvent("PLAYER_GUILD_UPDATE", "OnGuildUpdate")
    self:RegisterEvent("CHAT_MSG_WHISPER", "OnWhisper")
    self:RegisterEvent("CHAT_MSG_SYSTEM", "OnSystemMessage");
    self:RegisterEvent("CHAT_MSG_GUILD", "OnMessage", "GUILD");
    self:RegisterEvent("CHAT_MSG_PARTY", "OnMessage", "PARTY");
    SendSystemMessage("Guild Gear Rules loaded (version " .. self.Constants.Version .. "). Type /ggr for help.");
end

function GuildGearRules:OnCacheLoaded()
    self:Log("Cache loaded.")
    self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");

    self.ExceptionsText = "-"
    if table.getn(self.Rules.ItemExeceptionsIDs) > 0 then
        self.ExceptionsText = ""
        for key, value in ipairs(self.Rules.ItemExeceptionsIDs) do
            self.ExceptionsText = self.ExceptionsText .. self:GetDeadItemLink(value) .. "  "
        end
    end
end

function GuildGearRules:LoadRealm()
    self.CharacterName, self.Realm = UnitFullName("player")

    if self.Realm ~= nil then
        self.RealmLoaded = true
        self:Log("Realm loaded.")
    else
        self:Log("Failed loading realm.")
    end
end

function GuildGearRules:CheckIfCacheLoaded()
	if table.getn(self.ItemCacheQueue) == 0 then
		self:OnCacheLoaded()
    end
end

function GuildGearRules:CacheItem(itemID)
    -- Will be nil if not cached and start a GET_ITEM_INFO_RECEIVED request.
	local itemName = GetItemInfo(itemID)

    -- If item is not cached, add it to the queue.
	if itemName == nil then
        self:Log(itemID .. " is not cached, adding to queue.")
		table.insert(self.ItemCacheQueue, itemID)
	end
end

function GuildGearRules:OnReceiveItemInfo(event, itemID, success)
    if not success then
        return
    end

    -- Array contains received item.
    local itemIndex = self:ElementIndex(self.ItemCacheQueue, itemID)
    if itemIndex ~= nil then
        table.remove(self.ItemCacheQueue, itemIndex)
	    self:CheckIfCacheLoaded()
    end
end

function GuildGearRules:InspectCommand()
    if not self:CoreEnabled() then return end

    self:StartInspect("target")
end

function GuildGearRules:OnCommReceived(prefix, text, distribution, sender)
    if prefix ~= self.Constants.CommsPrefix then
        return
    end

    -- Only accept addon calls from guild members.
    if not self:IsGuildie(sender) then
        return
    end

    local identifier = string.sub(text, 0, 2)
    local contents = string.sub(text, 3)

    if identifier == "01" then
        self:SendCommMessage(self.Constants.CommsPrefix, "02" .. self.Constants.Version, "WHISPER", sender)
    elseif identifier == "02" then
        self.AddonGuildies[sender] = contents
    end
end

function GuildGearRules:OnScanEnd()
    self.ScanGuildResults = ""
    count = 0
    for player, version in pairs(self.AddonGuildies) do
        if version == "?" then
            self.ScanGuildResults = self.ScanGuildResults .. "|cff889d9d" .. player .. " does not have GGR.|r\n"
        else
            self.ScanGuildResults = self.ScanGuildResults .. "|cff1eff0c" .. player .. " has v" .. version .. " installed.|r\n"
        end
        count = count + 1
	end
    self.ScanGuildResults = self.ScanGuildResults .. "Scanned " .. count .. " members.\n"
    LibStub("AceConfigRegistry-3.0"):NotifyChange("GuildGearRules");
    self.AddonScanRunning = false
end

function GuildGearRules:CheckGuildUsers()
    if not IsInGuild() then
        return false
    end

    self.ScanGuildResults = ""

    if self.AddonScanRunning then
        self.ScanGuildResults = self.ScanGuildResults .. "Scan is already running, please wait."
        return
    end

    self.ScanGuildResults = self.ScanGuildResults .. "Scanning for other users in guild, please wait 5 seconds..."

    self.AddonScanRunning = true
    self.ScanUsersTimer = self:ScheduleTimer("OnScanEnd", 5)
    self.AddonGuildies = { }

    LibStub("AceConfigRegistry-3.0"):NotifyChange("GuildGearRules");
    
    -- Populate table with online members and nil values.
    local guildMembersCount = GetNumGuildMembers();
    for i = 1, guildMembersCount do
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline = GetGuildRosterInfo(i)
        name =  self:StripRealm(name)
        if isOnline then
            self.AddonGuildies[name] = "?"
        end
    end

    self:SendCommMessage(self.Constants.CommsPrefix, "01", "GUILD")
end

function GuildGearRules:StripRealm(name)
    return string.sub(string.match(name, '^.*\-'), 0, -2)
end

function GuildGearRules:GetItemQualityText(val)
    if val == nil then
        self:Log("Parameter is nil.")
        return "-"
    end
    local text = ITEM_QUALITY_COLORS[val].hex
    if val == 0 then
        text = text .. ITEM_QUALITY0_DESC
    elseif val == 1 then
        text = text ..  ITEM_QUALITY1_DESC
    elseif val == 2 then 
        text = text ..  ITEM_QUALITY2_DESC
    elseif val == 2 then
        text = text ..  ITEM_QUALITY2_DESC
    elseif val == 3 then
        text = text ..  ITEM_QUALITY3_DESC
    elseif val == 4 then
        text = text ..  ITEM_QUALITY4_DESC
    elseif val == 5 then
        text = text ..  ITEM_QUALITY5_DESC
    end
    text = text .. "|r"
    return text;
end

function GuildGearRules:GetDeadItemLink(itemID)
    return ITEM_QUALITY_COLORS[C_Item.GetItemQualityByID(itemID)].hex .. "[" .. C_Item.GetItemNameByID(itemID) .. "]" .. "|r"
end

function GuildGearRules:CreateTitle(text)
    return "|cffff8000" .. text .. "|r"
end

function GuildGearRules:ElementIndex(tab,el)
    for index, value in pairs(tab) do
	    if value == el then
	        return index
	    end
	end
    return nil
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function GuildGearRules:Alert(text)
    PlaySound(8959)
    print(self.Constants.AddOnMessagePrefix .. text)
end

function GuildGearRules:Info(text)
    print(self.Constants.AddOnMessagePrefix .. text)
end

function GuildGearRules:Log(text)
    msg = date("%H:%M:%S") .. ": " .. tostring(text) .. "\n"

    if self.db == nil then print(msg) return end
    if self.db.profile.DebugLogs then
        self.Logs = self.Logs .. msg
        LibStub("AceConfigRegistry-3.0"):NotifyChange("GuildGearRules");
    end
end

function GuildGearRules:CheckPlayerItems()
    -- Do no scanning if not in guild or no rules found.
    if not IsInGuild() or self.Rules.MaxItemQuality == nil then
        return false
    end

    local gearValid = true
    -- Go through each equipment slot.
    for i = 1,19,1
    do
        local itemLocation = ItemLocation:CreateFromEquipmentSlot(i)
        -- Only check slots that are not empty.
        if C_Item.DoesItemExist(itemLocation) == true then
            local itemQuality = C_Item.GetItemQuality(itemLocation)

            -- Quality exceeds maximum allowed.
            if itemQuality > self.Rules.MaxItemQuality then
                -- If item is not one of the exceptions.
                local itemID = C_Item.GetItemID(itemLocation)
                if not has_value(self.Rules.ItemExeceptionsIDs, itemID) then
                    gearValid = false
                    if IsCheating == false then
                        local itemLink = C_Item.GetItemLink(itemLocation)
                        SendChatMessage(self.Constants.MessagePrefix .. "Opsies, " .. itemLink .. " is equipped!", "GUILD")
                        IsCheating = true
                    end
                end
            end
        end
    end

    if gearValid == true and IsCheating == true then
        IsCheating = false
        SendChatMessage(self.Constants.MessagePrefix .. "I'm cheating no more, I promise!", "GUILD")
    end

    self:Log("Scanning player items.")
end

function GuildGearRules:TimerFeedback()
    if not self.RealmLoaded then self:LoadRealm() end
    if not self.GuildSettingsLoaded then self:LoadGuildSettings() end

    if not self:CoreEnabled() then
        return
    end

    self.PlayerUnitIDs = { }

    self:InspectMembers()
end

function GuildGearRules:OnMouseOverUnitChanged()
    if not self:CoreEnabled() then return end

    -- Prevent from double-checking party, raid members or player, locking the inspect function.
    if UnitInRaid("mouseover") or UnitInParty("mouseover") or UnitGUID("mouseover") == UnitGUID("player") then
        return
    end

    self:StartInspect("mouseover")
end

function GuildGearRules:InspectMembers()
    if not self:CoreEnabled() then return end

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
        if self:StartInspect(unit) then
            self.InspectIndex = i
            break
        end
    end
end

function GuildGearRules:CanInspect(unit)
    if not UnitIsPlayer(unit) then
        return nil
    end

    -- 3 is the distIndex for Duel and Inspect (7 yards).
    if not CheckInteractDistance(unit, 3) or not CanInspect(unit, false) then
        -- Cannot inspect this unit.
        return nil
    end

    -- Ignore players not in the same guild.
    local name, realm = UnitName(unit)
    if not self:IsGuildie(name, realm) then
        self:Log(name .. " is not in the same guild. Not inspecting.")
        return nil
    end

    return name
end

function GuildGearRules:StartInspect(unit)
    local name = self:CanInspect(unit)
    if name == nil then return false end

    local guid = UnitGUID(unit);

    -- Prevent new inspects from firing if player is already stored.
    if self.PlayerUnitIDs[guid] ~= nil then
        return false
    end

    -- Ensure that each unit can be requested only 5 seconds after since receiving last INSPECT_READY.
    if self.InspectedGUIDTimes[guid] ~= nil and time() - self.InspectedGUIDTimes[guid] <= 5 then return false end
    self.InspectedGUIDTimes[guid] = time()

    -- Store player unitID and GUID.
    self.PlayerUnitIDs[guid] = unit;

    NotifyInspect(unit)
    self:Log("Requesting data for " .. unit .. ", " .. name .. " (" .. guid .. ").")
    return true
end

function GuildGearRules:PartyInformation()
    local players = GetHomePartyInfo();
    -- Cancel if player is not in a party or raid.
    if players == nil then return nil, 0, nil end

    local maxPlayers = 4
    local partyType = "party"
    if IsInRaid() then
        partyType = "raid"
        maxPlayers = 40
    end
    local count = table.getn(players)

    return partyType, count, players, maxPlayers
end

function GuildGearRules:OnInspectReady(event, inspecteeGUID)
    local unitID = nil
    -- Do nothing if no such GUID stored. Other AddOn might be calling.
    if self.PlayerUnitIDs[inspecteeGUID] == nil then
        -- Unless the GUID exists in raid or party, grab it anyway.
        -- This way units that the player inspects will be auto-scanned, and not scanned again for 5 seconds.
        local found = false

        local partyType, count = self:PartyInformation()
        if count == 0 then return end

        for i = 1, count do
            unitID = partyType .. i
            if UnitGUID(unitID) == inspecteeGUID then
                local name, realm = UnitName()
                if self:IsGuildie(name, realm) then
                    found = true
                end
                break
            end
        end

        if not found then return end
    else
        -- Retrieve stored unitID by event GUID, e.g. "target".
        unitID = self.PlayerUnitIDs[inspecteeGUID];
        -- Get current GUID of unitID, e.g. "target".
        local currentGuid = UnitGUID(unitID); 
        -- Cancel if event GUID does not match current GUID. Player target or party members might have changed.
        if inspecteeGUID ~= currentGuid then return end
    end

    -- Update inspected time, ensuring we don't ask for a new inspect while sill receiving information.
    self.InspectedGUIDTimes[inspecteeGUID] = time()

    local name, realm = UnitName(unitID)

    local filledSlots = 0
    -- Go through each equipment slot.
    for i = 1,19 do
        local itemQuality = GetInventoryItemQuality(unitID, i)
        -- Only check slots that are not empty.
        if itemQuality ~= nil then
            filledSlots = filledSlots + 1
            -- Quality exceeds maximum allowed.
            if itemQuality > self.Rules.MaxItemQuality then
                -- If item is not one of the exceptions.
                local itemID, unknown = GetInventoryItemID(unitID, i);
                if not has_value(self.Rules.ItemExeceptionsIDs, itemID) then
                    local itemLink = GetInventoryItemLink(unitID, i)
                    self:Alert(name .. " uses " .. itemLink .. ".")
                end
            -- Check for illegal attributes.
            else
                --[[local itemID, unknown = GetInventoryItemID(unitID, i);
                ScannerTooltip:SetHyperlink("item:" .. itemID)
                for j=1,ScannerTooltip:NumLines() do 
                    local mytext=_G["ScannerTooltipTextLeft"..i] 
                    if mytext ~= nil then
                        local text=mytext:GetText()
                        print(text)
                    end
                end--]]
            end
        end
    end
    ClearInspectPlayer()
    self:Log("Received data for " .. filledSlots .. " slots on " .. unitID .. ", " .. name .. " (" .. inspecteeGUID .. ").")
end

-- IsGuildie("Tonedo") | IsGuildie("Tonedo-HydraxianWatelords"), IsGuildie("Tonedo", nil) IsGuildie("Tonedo", "HydraxianWatelords")
function GuildGearRules:IsGuildie(playerName, realm)
    if not IsInGuild() then
        return false
    end

    if realm == nil then
        local i = string.find(playerName, "-")
        if i then
            -- Name contains realm, extract it.
            return self:IsGuildie(string.sub(playerName, 0, i - 1), string.sub(playerName, i + 1))
        else
            -- No realm which,  player is on same realm.
            return self:IsGuildie(playerName, self.Realm)
        end
    end
    
    -- Different realm, can't be in same guild.
    if realm ~= self.Realm then
        return false
    end

    local fullName = playerName .. "-" .. realm
    local guildMembersCount = GetNumGuildMembers();
    for i = 1, guildMembersCount do
        -- Realm name included by default.
        local guildieName = GetGuildRosterInfo(i)
        --if stripRealm then name = self:StripRealm(name) end
        if fullName == guildieName then
            return true
        end
    end
    return false
end

function GuildGearRules:OnWhisper(event, text, targetPlayer)
    if self.db.profile.inspectEnabled and text == self.Constants.InspectRequest then
        if self.db.profile.inspectGuildOnly and not self:IsGuildie(targetPlayer) then
            return
        end

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
    self:Log(event .. " " .. unitID)
    self:Log(GetGuildInfo("player"))
    if unitID ~= "player" then
        return
    end

    self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
    self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
    self:UnregisterEvent("INSPECT_READY");

    self.GuildSettingsLoaded = false
    self:LoadGuildSettings()
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
    if self.db.profile.welcomeEnabled and string.find(string.lower(text), " has joined the guild.") then
        self:PlaySound(self.db.profile.welcomeEnabled, self.db.profile.welcomeSoundID)
    end
end

function GuildGearRules:PlaySound(condition, soundID)
    if condition then
        PlaySound(soundID)
    end
end
