GuildGearRulesUserInterface = GuildGearRules:NewModule("GuildGearRulesUserInterface");
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGearRules");
local _cstr = string.format;

local C = {
    GUILD = "|cff3ce13f",
    PARTY = "|cffaaabfe"
};

local CLASSES_FILE =
{
	[1] = "WARRIOR",
	[2] = "PALADIN",
	[3] = "HUNTER",
	[4] = "ROGUE",
	[5] = "PRIEST",
    [6] = "DEATHKNIGHT",
	[7] = "SHAMAN",
	[8] = "MAGE",
	[9] = "WARLOCK",
    [10] = "MONK",
	[11] = "DRUID",
    [12] = "DEMONHUNTER",
};

local CLASSES_NAME =
{
	[1] = "Warrior",
	[2] = "Paladin",
	[3] = "Hunter",
	[4] = "Rogue",
	[5] = "Priest",
    [6] = "Death Knight",
	[7] = "Shaman",
	[8] = "Mage",
	[9] = "Warlock",
    [10] = "Monk",
	[11] = "Druid",
    [12] = "Demon Hunter",
};

local CLASS_COLORS =
{
	["WARRIOR"] = "|cffc79c6e",
	["PALADIN"] = "|cfff58cba",
	["HUNTER"] = "|cffabd473",
	["ROGUE"] = "|cfffff569",
	["PRIEST"] = "|cffffffff",
    ["DEATHKNIGHT"] = "",
	["SHAMAN"] = "|cff0070de",
	["MAGE"] = "|cff40c7eb",
	["WARLOCK"] = "|cff8787ed",
    ["MONK"] = "",
	["DRUID"] = "|cffff7d0a",
    ["DEMONHUNTER"] = "",
};

local function Color(col, text)
    return col .. text .. "|r";
end

local lastDesc = "";
local function Desc(text)
    lastDesc = text;
    return text;
end

function GuildGearRulesUserInterface:Initialize(core)
    self.Core = core;
    self.ViewedCheater = nil;
    self.ScanGuildAddOnsInput = ""
end

function GuildGearRulesUserInterface:GetOptions()
    options = {
        name = "Guild Gear Rules",
        handler = GuildGearRulesUserInterface,
        type = "group",
        childGroups = "tab",
        args = {
            gui = {
                order = 0.25,
                type = "execute",
                guiHidden = true,
                name = L["OPEN_GUI"],
                func = "Show",
			},
            mainDesc = {
                order = 0.5,
                type = "description",
                name = "|cfffff569" .. L["VERSION"] .. "|r " .. self.Core.Constants.Version,
                fontSize = "small",
            },
            basics = {
                order = 1,
                name = L["BASICS"],
                type = "group",
                args = {
                    checker = {
                        order = 1,
                        type = "group",
                        guiInline = true,
                        name = "Gear Checker",
                        desc = Desc(_cstr(L["GEAR_CHECKER_DESC"], Color(C.GUILD, L["GUILD_MEMBERS"]), Color(C.GUILD, L["GUILD_CHANNEL"]))),
                        args = {
                            desc = {
                                order = 1,
                                type = "description",
                                name = lastDesc,
                                fontSize = "medium",
                            },
                            sound = {
                                order = 2,
                                type = "select",
                                name = L["ALERT_SOUND"],
                                desc = L["SOUND_TO_PLAY"],
                                set = function(info,val) self.Core.db.profile.alertSoundID = val; self.Core:PlaySound(true, val); end,
                                get = function(info) return self.Core.db.profile.alertSoundID end,
                                values = {
                                    [8959] = L["SOUND_RAID_WARNING"],
                                    [12867] = L["SOUND_ALARM_CLOCK_WARNING"],
                                    [8046] = L["SOUND_RAGNAROS"],
                                    [8809] = L["SOUND_KELTHUZAD"],
                                }
                            },
                            test = {
                                order = 3,
                                type = "execute",
                                name = L["GEAR_CHECKER_TEST_ALERT"],
                                func = "AlertTest",
                                desc = L["GEAR_CHECKER_TEST_ALERT_DESC"],
                                disabled = function() return not IsInGuild() end,
					        },
                            footer = {
                                order = 4,
                                type = "description",
                                name = L["GEAR_CHECKER_FOOTER"],
                                fontSize = "small",
                            },
                        },
                    },
                    rules = {
                        order = 2,
                        type = "group",
                        inline = true,
                        cmdHidden = true,
                        name = L["RULES"],
                        args = {
                            title = {
                                order = 1,
                                type = "description",
                                name = function() if not IsInGuild() then return L["RULES_NOT_IN_GUILD"] else return _cstr(L["RULES_LOADED"], Color(C.GUILD, GetGuildInfo("player"))) end end,
                                fontSize = "medium",
                            },
                            maxQuality = {
                                order = 3,
                                type = "description",
                                name = function() return "|cffe6cc80" .. L["RULES_MAX_ITEM_QUALITY"] .. "|r: " .. self:GetItemQualityText(self.Core.Rules.MaxItemQuality) end,
                                fontSize = "small",
					        },
                            exceptionsAllowed = {
                                order = 4,
                                type = "description",
                                name = function() return "|cffe6cc80" .. L["RULES_EXCEPTIONS_ALLOWED"] .. "|r: " .. self.Core.Rules.ExceptionsAllowed; end,
                                fontSize = "small",
                            },
                            alwaysAllowed = {
                                order = 4,
                                type = "description",
                                name = function() return "|cffe6cc80" .. L["RULES_ALWAYS_ALLOWED"] .. "|r: " .. self:GetItemsAllowed(); end,
                                fontSize = "small",
                            },
                            tags = {
                                order = 5,
                                type = "description",
                                name = function() return "|cffe6cc80" .. L["RULES_EXTRAS"] .. "|r: " .. self:GetTags(); end,
                                fontSize = "small",
                            },
                        },
                    },
                    inspection = {
                        order = 3,
                        type = "group",
                        guiInline = true,
                        name = L["INSPECTION"],
                        desc = Desc(_cstr(L["INSPECTION_DESC"], "!gear")),
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
                                name = L["INSPECTION_FOOTER"],
                                fontSize = "small",
                            },
                            guildOnly = {
                                order = 3,
                                type = "toggle",
                                width = "half",
                                name = Color(C.GUILD, L["GUILD_ONLY"]),
                                desc = L["GUILD_ONLY_DESC"],
                                set = function(info,val) self.Core.db.profile.inspectGuildOnly = val end,
                                get = function(info) return self.Core.db.profile.inspectGuildOnly end,
                            },
                            cooldown = {
                                order = 4,
                                type = "select",
                                name = L["COOLDOWN"],
                                desc = L["INSPECTION_COOLDOWN_DESC"],
                                set = function(info,val) self.Core.db.profile.inspectCooldown = val; end,
                                get = function(info) return self.Core.db.profile.inspectCooldown; end,
                                values = {
                                    [0] = L["COOLDOWN_NONE"],
                                    [1] = L["COOLDOWN_SECONDS_1"],
                                    [5] = L["COOLDOWN_SECONDS_5"],
                                    [10] = L["COOLDOWN_SECONDS_10"],
                                    [30] = L["COOLDOWN_SECONDS_30"],
                                }
                            },
                        },
                    },
                },
            },
            social = {
                order = 2,
                name = L["SOCIAL"],
                type = "group",
                args = {
                    welcome = {
                        order = 1,
                        name = L["NEW_MEMBER_ALERT"],
                        desc = Desc(_cstr(L["NEW_MEMBER_ALERT_DESC"], Color(C.GUILD, L["GUILD"]))),
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
                                name = L["ENABLED"],
                                desc = L["TOGGLE_ENABLE_DESC"],
                                set = function(info,val) self.Core.db.profile.welcomeEnabled = val end,
                                get = function(info) return self.Core.db.profile.welcomeEnabled end,
                            },
                            sound = {
                                order = 3,
                                type = "select",
                                name = L["ALERT_SOUND"],
                                desc = L["SOUND_TO_PLAY"],
                                disabled = function() return not self.Core.db.profile.welcomeEnabled; end,
                                set = function(info,val) self.Core.db.profile.welcomeSoundID = val; self.Core:PlaySound(true, val); end,
                                get = function(info) return self.Core.db.profile.welcomeSoundID end,
                                values = {
                                    [7094] = L["SOUND_RANDOM_PEASANT_GREETINGS"],
                                    [7194] = L["SOUND_RANDOM_PEON_GREETINGS"],
                                }
                            },
						},
					},
                    gratulate = {
                        order = 2,
                        name = L["LEVEL_UP_ALERT"],
                        desc = Desc(L["LEVEL_UP_ALERT_DESC"]),
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
                                name = L["ENABLED"],
                                desc = L["TOGGLE_ENABLE_DESC"],
                                set = function(info,val) self.Core.db.profile.gratulateEnabled = val end,
                                get = function(info) return self.Core.db.profile.gratulateEnabled end,
                            },
                            sound = {
                                order = 3,
                                type = "select",
                                name = L["ALERT_SOUND"],
                                desc = L["SOUND_TO_PLAY"],
                                disabled = function() return not self.Core.db.profile.gratulateEnabled; end,
                                set = function(info,val) self.Core.db.profile.gratulateSoundID = val; self.Core:PlaySound(true, val); end,
                                get = function(info) return self.Core.db.profile.gratulateSoundID end,
                                values = {
                                    [124] = L["SOUND_LEVEL_UP"],
                                    [8455] = L["SOUND_PVP_VICTORY_ALLIANCE"],
                                    [8454] = L["SOUND_PVP_VICTORY_HORDE"],
                                },
                            },
                            party = {
                                order = 4,
                                type = "toggle",
                                width = "half",
                                disabled = function() return not self.Core.db.profile.gratulateEnabled; end,
                                name = Color(C.PARTY, L["PARTY"]),
                                desc = L["REACT_ON_PARTY_CHANNEL"],
                                set = function(info,val) self.Core.db.profile.gratulateParty = val end,
                                get = function(info) return self.Core.db.profile.gratulateParty end,
                            },
                            guild = {
                                order = 5,
                                type = "toggle",
                                width = "half",
                                disabled = function() return not self.Core.db.profile.gratulateEnabled; end,
                                name = Color(C.GUILD, L["GUILD"]),
                                desc = L["REACT_ON_GUILD_CHANNEL"],
                                set = function(info,val) self.Core.db.profile.gratulateGuild = val end,
                                get = function(info) return self.Core.db.profile.gratulateGuild end,
                            },
                        }
                    },
                },
            },
            cheaters = {
                order = 3,
                name = L["CHEATERS"],
                type = "group",
                cmdHidden = true,
                args = {
                    desc = {
                        order = 1,
                        type = "description",
                        name = L["CHEATERS_DESC"],
                        fontSize = "medium",
                    },
                    cheaters = {
                        order = 2,
                        name = L["CHEATER_VIEW"],
                        type = "select",
                        cmdHidden = true,
                        desc = L["CHEATERS_SELECT"],
                        set = function(info,val) self.ViewedCheater = val; end,
                        get = function(info) return self.ViewedCheater; end,
                        values = function() return self:GetCheaterList(); end,
                    },
                    clear = {
                        order = 3,
                        type = "execute",
                        cmdHidden = true,
                        name = L["CHEATERS_REMOVE"],
                        desc = L["CHEATERS_REMOVE_DESC"],
                        func = function() self.Core.Inspector:ForgetCheater(self.Core.Inspector:GetCheaterID(self.ViewedCheater)); end,
                        disabled = function() return self.ViewedCheater == nil; end,
					},
                    refresh = {
                        order = 4,
                        type = "execute",
                        cmdHidden = true,
                        name = L["CHEATERS_REFRESH"],
                        desc = L["CHEATERS_REFRESH_DESC"],
                        func = "Refresh",
					},
                    info = {
                        order = 5,
                        name = "Information",
                        type = "group",
                        guiInline = true,
                        cmdHidden = true,
                        args = {
                            desc = {
                                order = 1,
                                type = "description",
                                name = function() return self:GetCheaterInfo() end,
                                fontSize = "medium",
                            },
						},
					},
                },
            },
            advanced = {
                order = 4,
                name = L["ADVANCED"],
                type = "group",
                args = {
                    scanGGR = {
                        order = 1,
                        type = "execute",
                        name = L["SCAN_GGR"],
                        desc = L["SCAN_GGR_DESC"],
                        func = function() self.Core:ScanGuild(0); end,
                        disabled = function() return not IsInGuild(); end,
					},
                    scanGuildAddOns = {
                        order = 2,
                        type = "execute",
                        name = L["SCAN_ADDONS"],
                        desc = L["SCAN_ADDONS_DESC"],
                        func = function() self.Core:ScanGuild(1) end,
                        disabled = function() return not IsInGuild() or self.ScanGuildAddOnsInput == ""; end
					},
                    scanGuildAddOnsInput = {
                        order = 3,
                        type = "input",
                        name = L["SCAN_ADDONS_INPUT"],
                        desc = L["SCAN_ADDONS_INPUT_DESC"],
                        set = function(info, val) self.ScanGuildAddOnsInput = val; end,
                        get = function() return self.ScanGuildAddOnsInput; end,
                        disabled = function() return not IsInGuild(); end,
					},
                    scanResults = {
                        order = 4,
                        name = L["SCAN_RESULTS"],
                        type = "group",
                        guiInline = true,
                        cmdHidden = true,
                        args = {
                            text = {
                                type = "description",
                                width = "full",
                                name = function() return self.Core.ScanGuildResults; end,
					        },
						},
					},
                },
            },
            debugging = {
                order = 5,
                name = L["DEBUGGING"],
                type = "group",
                args = {
                    level = {
                        order = 1,
                        type = "select",
                        name = L["DEBUGGING_LEVEL"],
                        desc = L["DEBUGGING_LEVEL_DESC"],
                        set = function(info,val) self.Core.db.profile.DebuggingLevel = val; end,
                        get = function(info) return self.Core.db.profile.DebuggingLevel; end,
                        values = {
                            [0] = L["DEBUGGING_LEVEL_0"],
                            [1] = L["DEBUGGING_LEVEL_1"],
                            [2] = L["DEBUGGING_LEVEL_2"],
                            [3] = L["DEBUGGING_LEVEL_3"],
                        }
                    },
                    debugCache = {
                        order = 2,
                        type = "toggle",
                        disabled = function() return self.Core.db.profile.DebuggingLevel == 0; end,
                        name = L["DEBUG_CACHE"],
                        set = function(info,val) self.Core.db.profile.DebugCache = val end,
                        get = function(info) return self.Core.db.profile.DebugCache end,
                    },
                    clearLogs = {
                        order = 3,
                        type = "execute",
                        name = L["CLEAR_DEBUG_LOGS"],
                        desc = L["CLEAR_DEBUG_LOGS_DESC"],
                        func = function() self.Core:ClearLogs(); end,
                    },
                    logs = {
                        order = 4,
                        name = L["DEBUG_LOGS"],
                        type = "group",
                        guiInline = true,
                        cmdHidden = true,
                        args = {
                            debugLogs = {
                                type = "description",
                                width = "full",
                                name = function() return self:GetLogs(); end,
                            },
                        },
                    },
                },
            },
        },
    };
    return options;
end

function GuildGearRulesUserInterface:Show()
    LibStub("AceConfigDialog-3.0"):Open("GuildGearRules");
end

function GuildGearRulesUserInterface:AlertTest()
    itemName, itemLink = GetItemInfo(self.Core.Constants.AlertTestItemID);
    self.Core.Inspector:Alert("Cheaterboy", "player", itemLink);
end

function GuildGearRulesUserInterface:GetItemsAllowed()
    if (#self.Core.Rules.ItemsAllowedIDs == 0) then return "-"; end

    local text = "";
    for i = 1, #self.Core.Rules.ItemsAllowedIDs do
        text = text .. self:DeadItemLink(self.Core.Rules.ItemsAllowedIDs[i]) .. " ";
    end
    return text;
end

function GuildGearRulesUserInterface:GetTags()
    local text = "";
    for i = 1, #self.Core.Rules.Tags do
        local attribute = self.Core.Rules.Tags[i];
        if (attribute.Enabled) then
            text = text .. "|cfffffc01[" .. attribute.Text .. "]|r ";
        end
    end

    -- No attributes enabled.
    if (text == "") then
        text = "-";
    end

    return text;
end

function GuildGearRulesUserInterface:GetLogs()
    local logs = "";
    if (#self.Core.LogLines == 0) then return logs; end

    for i = #self.Core.LogLines, 1, -1  do
        local ending = "";
        if (self.Core.LogLines[i].Times > 1) then
            ending = " |cffc41f3b(#" .. self.Core.LogLines[i].Times .. ")|r";
        end
        logs = logs .. self.Core.LogLines[i].Text .. ending .. "\n";
    end
    return logs;
end

function GuildGearRulesUserInterface:GetCheaterList()
    local cheaterList = { };
    for key, cheater in pairs(self.Core.Inspector.Cheaters) do
        if (#cheater.Items > self.Core.Rules.ExceptionsAllowed) then
            cheaterList[cheater.GUID] = self:ClassColored(cheater.Name, CLASSES_FILE[cheater.ClassID]);
        end
    end
    return cheaterList;
end

function GuildGearRulesUserInterface:GetCheaterInfo()
    if (self.ViewedCheater == nil) then return L["CHEATER_NIL_SELECTED"]; end
    local cheater = self.Core.Inspector.Cheaters[self.Core.Inspector:GetCheaterID(self.ViewedCheater)];

    local text = _cstr(L["CHEATER_INFORMATION"], cheater.Name, cheater.Level, cheater.Race, CLASSES_NAME[cheater.ClassID], #cheater.Items) .. "\n";
    for i = 1, #cheater.Items do
        text = text .. _cstr(L["CHEATER_INFORMATION_ITEM_SEEN"], cheater.Items[i].Link, cheater.Items[i].Time) .. "\n";
    end
    return text;
end

function GuildGearRulesUserInterface:Refresh()
    LibStub("AceConfigRegistry-3.0"):NotifyChange("GuildGearRules");
end

function GuildGearRulesUserInterface:ViewCheater(value)
    self.ViewedCheater = value;
end

function GuildGearRulesUserInterface:ClassColoredName(name, unitID)
    classFileName, classId = UnitClassBase(unitID);
    return self:ClassColored(name, classFileName);
end

function GuildGearRulesUserInterface:ClassColored(text, classFileName)
    rPerc, gPerc, bPerc, argbHex = GetClassColor(classFileName);
    local color = "|c" .. argbHex;
	return color .. text .. "|r";
end

function GuildGearRulesUserInterface:GetItemQualityText(val)
    if (val == nil) then return "-"; end
    return ITEM_QUALITY_COLORS[val].hex .._G["ITEM_QUALITY" .. val .. "_DESC"] .. " |r";
end

function GuildGearRulesUserInterface:DeadItemLink(itemID)
    return ITEM_QUALITY_COLORS[C_Item.GetItemQualityByID(itemID)].hex .. "[" .. C_Item.GetItemNameByID(itemID) .. "]" .. "|r";
end