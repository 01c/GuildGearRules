GuildGearRulesUserInterface = GuildGearRules:NewModule("GuildGearRulesUserInterface", "AceHook-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGearRules");
local _cstr = string.format;

local DEBUG_MSG_TYPE = {
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
};

local TOOLTIP_TYPE = {
    BANNED = 1,
    BANNED_PARTLY = 2,
    ALWAYS_ALLOWED = 3,
}

local C = {
    GUILD = "|cff3ce13f",
    PARTY = "|cffaaa7ff",
    RULE = "|cffe6cc80",
    TITLE = "|cffffd100",
    ATTRIBUTE = "|cff03f002",
    RED = "|cffcb2121",
    GREEN = "|cff49cb21",
    ORANGE = "|cffcb8121",
    GRAY = "|cFFCFCFCF",
    WHITE = '|cFFFFFFFF',
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
    ["DEATHKNIGHT"] = "|cffc41f3b",
	["SHAMAN"] = "|cff0070de",
	["MAGE"] = "|cff40c7eb",
	["WARLOCK"] = "|cff8787ed",
    ["MONK"] = "|cff00ff96",
	["DRUID"] = "|cffff7d0a",
    ["DEMONHUNTER"] = "|cffa330c9",
};

local INVENTORY_SLOT =
{
    [0] = INVTYPE_AMMO,
    [1] = INVTYPE_HEAD,
    [2] = INVTYPE_NECK,
    [3] = INVTYPE_SHOULDER,
    [5] = INVTYPE_CHEST,
    [6] = INVTYPE_WAIST,
    [7] = INVTYPE_LEGS,
    [8] = INVTYPE_FEET,
    [9] = INVTYPE_WRIST,
    [10] = INVTYPE_HAND,
    [11] = INVTYPE_FINGER .. " (1)",
    [12] = INVTYPE_FINGER .. " (2)",
    [13] = INVTYPE_TRINKET .. " (1)",
    [14] = INVTYPE_TRINKET .. " (2)",
    [15] = INVTYPE_CLOAK,
    [16] = INVTYPE_WEAPONMAINHAND,
    [17] = INVTYPE_WEAPONOFFHAND,
    [18] = INVTYPE_RANGED,
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
    self.Network = self.Core:GetModule("GuildGearRulesNetwork");

    LibStub("AceConfig-3.0"):RegisterOptionsTable("GuildGearRules", self:GetOptions());
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GuildGearRules", L["GUILD_GEAR_RULES"]);
    self.optionsFrame.default = function() self.Core.db:ResetProfile(self.Core:DefaultSettings()); self:Refresh(); end;
    self:Refresh();

    self.MinimapButtonTexture = 136031;
    self.MinimapButtonTextureActive = 135995;

    self.SortedCheaterGUIDS = { };
    self.SortedCheaterIDs = { };
    self.ViewedCheater = nil;
    self.ViewedCharacterData = nil;

    self.ScanGuildAddOnsInput = "";

    self:SetupMinimapButton();
    if (not self.Core.db.profile.HideWarning) then
        self:ShowWarning();
    end
    --[[
    self:SecureHook(GameTooltip, "SetBagItem", "UpdateItemTooltip");
    self:SecureHook(GameTooltip, "SetInventoryItem", "UpdateItemTooltip");
    self:SecureHook(GameTooltip, "Hide", "HideTooltip");
    self:SecureHook(ItemRefTooltip, "SetHyperlink", "OnSetHyperlink");
    self:SecureHook(ItemRefTooltip, "Hide", "HideTooltip");

    self.ExtendedTooltips = { };
    self.ExtendedTooltips["GameTooltip"] = CreateFrame("GameTooltip", "GuildGearRulesExtendedGameTooltip", nil, "GameTooltipTemplate");
    self.ExtendedTooltips["ItemRefTooltip"] = CreateFrame("GameTooltip", "GuildGearRulesExtendedItemRefTooltip", nil, "GameTooltipTemplate");
    ]]--
    self.Core:Log(tostring(self) .. " initialized.");
    return self;
end
--[[
function GuildGearRulesUserInterface:ShowWarningTooltip(tooltip, tooltipType, info)
    local extendedTooltip = self.ExtendedTooltips[tooltip:GetName()];
    if (extendedTooltip == nil) then return; end

    local headerText = "";
    if (tooltipType == TOOLTIP_TYPE.BANNED) then
        headerText = Color(C.RED, L["TOOLTIP_BANNED"]);
    elseif (tooltipType == TOOLTIP_TYPE.BANNED_PARTLY) then
        headerText = Color(C.ORANGE, L["TOOLTIP_BANNED_PARTLY"]);
    elseif (tooltipType == TOOLTIP_TYPE.ALWAYS_ALLOWED) then
        headerText = Color(C.GREEN, L["TOOLTIP_ALLOWED"]);
    end

    if (true) then
        local y = tooltip:GetTop();
        local screenHeight = GetScreenHeight();
        local anchors = { Base = "ANCHOR_TOP", First = { From = "BOTTOMLEFT", To = "TOPLEFT", }, Second = { From = "BOTTOMRIGHT", To = "TOPRIGHT", }, };
        if (y ~= nil and screenHeight - y <= 100) then
            anchors = { Base = "ANCHOR_BOTTOM", First = { From = "TOPLEFT", To = "BOTTOMLEFT", }, Second = { From = "TOPRIGHT", To = "BOTTOMRIGHT", }, };
        end
        extendedTooltip:SetOwner(tooltip, anchors.Base);
        extendedTooltip:ClearLines();

        extendedTooltip:AddDoubleLine(Color(C.TITLE, "Guild Gear Rules"), headerText);
        if (info ~= nil) then
            extendedTooltip:AddLine(info, 1, 1, 1, true);
        end
        extendedTooltip:Show();

        extendedTooltip:SetPoint(anchors.First.From, tooltip, anchors.First.To, 0, 0)
        extendedTooltip:SetPoint(anchors.Second.From, tooltip, anchors.Second.To, 0, 0)

        for i = 1, extendedTooltip:NumLines() do 
            local line = _G[extendedTooltip:GetName() .. "TextLeft"..i];
            local lineRight = _G[extendedTooltip:GetName() .. "TextRight"..i];
            line:SetFont("Fonts\\FRIZQT__.TTF", 10);
            lineRight:SetFont("Fonts\\FRIZQT__.TTF", 10);
        end
    end

    if (true) then
        tooltip:AddLine(" ");
        tooltip:AddDoubleLine(Color(C.TITLE, "Guild Gear Rules"), headerText);
        if (info ~= nil) then
            tooltip:AddLine(info, 1, 1, 1, true);
        end
        tooltip:Show();
    end
end

function GuildGearRulesUserInterface:ValidateTooltip(tooltip, itemLink)
    self:HideTooltip(tooltip);
    if (itemLink ~= nil) then
        local spellName, spellID = GetItemSpell(itemLink);

        -- Check if it's a consumable which applies a banned buff.
        if (spellID ~= nil) then
            for i = 1, #self.Core.Rules.BannedBuffGroups do
                local buffGroup = self.Core.Rules.BannedBuffGroups[i];
                if (buffGroup.IDs:Contains(spellID)) then
                    self:ShowWarningTooltip(tooltip, TOOLTIP_TYPE.BANNED_PARTLY, "Buff " .. self:Buff(spellID) .. " is banned from level " .. tostring(buffGroup.MinimumLevel) .. ".");
                    return;
                end
            end
        end

        local itemID = select(3, self:HyperlinkInfo(itemLink));
        -- Check if is allowed item.
        if (self.Core.Rules.Items.AllowedIDs:Contains(itemID)) then
            self:ShowWarningTooltip(tooltip, TOOLTIP_TYPE.ALWAYS_ALLOWED, "Exempted from the rules.");
            return;
        end

        local quality = C_Item.GetItemQualityByID(itemLink);
        if (quality ~= nil and quality > 2) then
            self:ShowWarningTooltip(tooltip, TOOLTIP_TYPE.BANNED, "Exceeds " .. self:GetItemQualityText(self.Core.Rules.Items.MaxQuality) .. " quality.");
        else
            local attribute = self.Core.Inspector:HasBannedAttribute(tooltip, itemLink);
            if (attribute) then
                self:ShowWarningTooltip(tooltip, TOOLTIP_TYPE.BANNED, "Attribute " .. self:Attribute(attribute) .. " is banned.");
            end
        end
    end
end

function GuildGearRulesUserInterface:OnSetHyperlink(tooltip, itemLink)
    -- SetHyperlink might be called after the tooltip has been hidden, so better check if it's visible.
    if (itemLink ~= nil and tooltip:IsVisible()) then
        self:ValidateTooltip(tooltip, itemLink);
    else
        self:HideTooltip(tooltip);
    end
end

function GuildGearRulesUserInterface:UpdateItemTooltip(tooltip)
    local name, itemLink = tooltip:GetItem();
    if (itemLink ~= nil) then
        self:ValidateTooltip(tooltip, itemLink);
    else
        self:HideTooltip(tooltip);
    end
end

function GuildGearRulesUserInterface:HideTooltip(tooltip)
    local extended = self.ExtendedTooltips[tooltip:GetName()]
    if (extended ~= nil) then
        extended:Hide();
    end
end
]]--

function GuildGearRulesUserInterface:SetupMinimapButton()
    local lbd = LibStub("LibDataBroker-1.1"):NewDataObject("GuildGearRules", {
        type = "data source",
        text = L["GUILD_GEAR_RULES"],
        icon = self.MinimapButtonTexture,
        OnClick = function(_, button)
            if button == "LeftButton" then
                self:Show();
                return;
            elseif button == "MiddleButton" then
                self:ShowTab("rules");
                return;
            elseif button == "RightButton" then
                if not IsModifierKeyDown() then
                    self:ShowTab("cheatersTab");
                    return;
                elseif IsControlKeyDown() then
                    self:ToggleMinimapButton();
                    return;
                end
            end
        end,
        OnTooltipShow = function (tooltip)
            tooltip:AddDoubleLine(Color(C.WHITE, L["GUILD_GEAR_RULES"]), "v" .. self.Core.Constants.Version);
            tooltip:AddLine(Color(C.RULE, L["MINIMAP_BUTTON_DESC"]) .. "\n\n");
            tooltip:AddLine(Color(C.GRAY, L["LEFT_CLICK"]) .. ": " .. L["TOGGLE_FRAME"]);
            tooltip:AddLine(Color(C.GRAY, L["MIDDLE_CLICK"]) .. ": " .. L["OPEN_RULES"]);
            tooltip:AddLine(Color(C.GRAY, L["RIGHT_CLICK"]) .. ": " .. L["OPEN_CHEATERS"]);
            tooltip:AddLine(Color(C.GRAY, L["RIGHT_CLICK_CTRL"]) .. ": " .. L["HIDE_MINIMAP_BUTTON"]);
        end,
    });
    self.MinimapButton = LibStub("LibDBIcon-1.0");
    self.MinimapButton:Register("GuildGearRules", lbd, self.Core.db.char.MinimapButton);
    self:RefreshMinimapButtonAlertState();
end

function GuildGearRulesUserInterface:RefreshMinimapButtonAlertState()
    local button = self.MinimapButton:GetMinimapButton("GuildGearRules");
    -- Button might be disabled and not found, in that case do nothing.
    if (button == nil ) then return; end

    local anyCheaters = false;
    for key, cheater in pairs(self.Core.Inspector.Cheaters) do
        if (cheater:CheatingDataCount() > 0) then
            anyCheaters = true;
            break;
        end
    end

    if (anyCheaters) then
        button.icon:SetVertexColor(1, 1, 1);
        button.icon:SetTexture(self.MinimapButtonTextureActive);
    else
        button.icon:SetVertexColor(0.5, 0.5, 0.5);
        button.icon:SetTexture(self.MinimapButtonTexture);
    end
end

function GuildGearRulesUserInterface:ToggleMinimapButton()
    self.Core.db.char.MinimapButton.hide = not self.Core.db.char.MinimapButton.hide; 
    if (self.Core.db.char.MinimapButton.hide) then 
        self.MinimapButton:Hide("GuildGearRules"); 
    else 
        self.MinimapButton:Show("GuildGearRules");
        -- Refresh the state of the minimap button since it could not be refreshed while disabled.
        self:RefreshMinimapButtonAlertState();
    end
    self:Refresh();
end

function GuildGearRulesUserInterface:ShowWarning()
    local AceGUI = LibStub("AceGUI-3.0");
    -- Create a container frame
    local f = AceGUI:Create("Frame");
    f:SetWidth(400);
    f:SetHeight(200);
    f.frame:SetMaxResize(400, 200);
    f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end);
    f:SetTitle(L["GUILD_GEAR_RULES"] .. " " .. L["WARNING"]);
    f:SetLayout("Flow");

    local desc = AceGUI:Create("Label");
    desc:SetText(_cstr(L["WARNING_DESC"], L["GUILD_GEAR_RULES"]));
    desc:SetFullWidth(true);

    local openOptions = AceGUI:Create("Button");
    openOptions:SetText(L["OPEN_SETTINGS"]);
    openOptions:SetWidth(200);
    openOptions:SetCallback("OnClick", function() print(self.Show()) end)

    local checkBox = AceGUI:Create("CheckBox");
    checkBox:SetCallback("OnValueChanged", function(widget, callback, val) self.Core.db.profile.HideWarning = val; end);
    checkBox:SetLabel(L["DONT_SHOW_AGAIN"]);
    checkBox:SetFullWidth(true);

    f:AddChild(desc);
    f:AddChild(openOptions);
    f:AddChild(checkBox);
end

function GuildGearRulesUserInterface:GetOptions()
    options = {
        name = "Guild Gear Rules",
        handler = GuildGearRulesUserInterface,
        type = "group",
        childGroups = "tab",
        args = {
            gui = {
                order = 0.1,
                type = "execute",
                guiHidden = true,
                name = L["TOGGLE_FRAME"],
                func = function() self:Show(); end,
			},
            cheaters = {
                order = 0.2,
                type = "execute",
                guiHidden = true,
                name = L["OPEN_CHEATERS"],
                func = function() self:ShowTab("cheatersTab"); end,
			},
            mainDesc = {
                order = 0.3,
                type = "description",
                name = "|cfffff569" .. L["VERSION"] .. "|r " .. self.Core.Constants.Version .. " " .. "|cfffff569" .. L["AUTHOR"] .. "|r Tonedo",
                fontSize = "small",
            },
            core = {
                order = 1,
                name = L["CORE"],
                type = "group",
                args = {
                    checker = {
                        order = 1,
                        type = "group",
                        cmdHidden = true,
                        guiInline = true,
                        name = L["CORE_INFO"],
                        desc = Desc(_cstr(L["CORE_INFO_DESC"], Color(C.TITLE, L["GUILD_GEAR_RULES"]), Color(C.GUILD, L["GUILD_MEMBERS"]), Color(C.GUILD, L["GUILD_CHANNEL"]), Color(C.GUILD, L["GUILD"]:lower()), Color(C.TITLE, L["RULES"]))),
                        args = {
                            desc = {
                                order = 1,
                                type = "description",
                                name = lastDesc,
                                fontSize = "medium",
                            },
                            websiteLink = {
                                order = 2,
                                type = "input",
                                width = "full",
                                disabled = false,
                                name = L["CORE_INFO_UPDATES"],
                                get = function() return self.Core.Constants.DownloadLink; end,
					        },
                        },
                    },
                    options = {
                        order = 2,
                        type = "group",
                        guiInline = true,
                        name = L["OPTIONS"],
                        args = {
                            removeBannedBuffs = {
                                order = 1,
                                confirm = function() return not self.Core.db.profile.removeBannedBuffs; end,
                                type = "toggle",
                                name = L["CORE_REMOVE_BANNED_BUFFS"],
                                desc = L["CORE_REMOVE_BANNED_BUFFS_DESC"],
                                set = function(info,val) self.Core.db.profile.removeBannedBuffs = val; end,
                                get = function(info) return self.Core.db.profile.removeBannedBuffs; end,
                            },
                            receiveData = {
                                order = 2,
                                type = "toggle",
                                name = L["CORE_RECEIVE_DATA"],
                                desc = L["CORE_RECEIVE_DATA_DESC"],
                                set = function(info,val) self.Core.db.profile.receiveData = val; end,
                                get = function(info) return self.Core.db.profile.receiveData; end,
                            },
                            minimapButton = {
                                order = 3,
                                type = "toggle",
                                name = L["CORE_MINIMAP_BUTTON"],
                                desc = L["CORE_MINIMAP_BUTTON_DESC"],
                                set = function(info,val) self:ToggleMinimapButton() end,
                                get = function(info) return not self.Core.db.char.MinimapButton.hide; end,
                            },
                            startUpWarning = {
                                order = 4,
                                type = "toggle",
                                name = L["CORE_STARTUP_WARNING"],
                                desc = L["CORE_STARTUP_WARNING_DESC"],
                                set = function(info,val) self.Core.db.profile.HideWarning = val; end,
                                get = function(info) return self.Core.db.profile.HideWarning; end,
                            },
                        },
                    },
                    alert = {
                        order = 3,
                        type = "group",
                        guiInline = true,
                        name = L["CORE_ALERT"],
                        desc = Desc(_cstr(L["CORE_ALERT_DESC"], Color(C.GUILD, L["GUILD_MEMBERS"]))),
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
                                name = L["SOUND"],
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
                                width = "half",
                                name = L["TEST"],
                                func = "AlertTest",
                                desc = L["CORE_ALERT_TEST_DESC"],
                                disabled = function() return not IsInGuild() end,
					        },
                        },
                    },
                    inspection = {
                        order = 4,
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
                            notify = {
                                order = 3,
                                type = "toggle",
                                width = "half",
                                name = L["INSPECTION_NOTIFY"],
                                desc = L["INSPECTION_NOTIFY_DESC"],
                                set = function(info,val) self.Core.db.profile.inspectNotify = val end,
                                get = function(info) return self.Core.db.profile.inspectNotify end,
                            },
                            guildOnly = {
                                order = 4,
                                type = "toggle",
                                width = "half",
                                name = Color(C.GUILD, L["GUILD_ONLY"]),
                                desc = L["GUILD_ONLY_DESC"],
                                set = function(info,val) self.Core.db.profile.inspectGuildOnly = val end,
                                get = function(info) return self.Core.db.profile.inspectGuildOnly end,
                            },
                            cooldown = {
                                order = 5,
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
            rules = {
                order = 2,
                name = L["RULES"],
                type = "group",
                cmdHidden = true,
                args = {
                    title = {
                        order = 1,
                        type = "header",
                        cmdHidden = true,
                        name = function() if not self.Core.Rules.Loaded then return L["RULES_NOT_LOADED"] else return _cstr(L["RULES_LOADED"], Color(C.GUILD, GetGuildInfo("player"))) end end,
					},
                    limitations = {
                        order = 2,
                        type = "group",
                        cmdHidden = true,
                        name = L["RULES_LIMITATIONS"],
                        guiInline = true,
                        args = {
                            capitals = {
                                order = 1,
                                type = "toggle",
                                cmdHidden = true,
                                width = 0.7,
                                name = "|cfffffbff" .. L["RULES_LIMITATIONS_CAPITALS"] .. "|r",
                                desc = L["RULES_LIMITATIONS_ZONE_DESC"],
                                get = function(info) return self.Core.Rules.Apply.Capitals end,
                            },
                            world = {
                                order = 1,
                                type = "toggle",
                                cmdHidden = true,
                                width = 0.7,
                                name = "|cfffffbff" .. L["RULES_LIMITATIONS_WORLD"] .. "|r",
                                desc = L["RULES_LIMITATIONS_ZONE_DESC"],
                                get = function(info) return self.Core.Rules.Apply.World end,
                            },
                            dungeons = {
                                order = 3,
                                type = "toggle",
                                cmdHidden = true,
                                width = 0.7,
                                name = "|cffaaa7ff" .. L["RULES_LIMITATIONS_DUNGEONS"] .. "|r",
                                desc = L["RULES_LIMITATIONS_ZONE_DESC"],
                                get = function(info) return self.Core.Rules.Apply.Dungeons end,
                            },
                            raid = {
                                order = 3,
                                type = "toggle",
                                cmdHidden = true,
                                width = 0.7,
                                name = "|cffff4709" .. L["RULES_LIMITATIONS_RAIDS"] .. "|r",
                                desc = L["RULES_LIMITATIONS_ZONE_DESC"],
                                get = function(info) return self.Core.Rules.Apply.Raids end,
                            },
                            battleground = {
                                order = 4,
                                type = "toggle",
                                cmdHidden = true,
                                width = 0.7,
                                name = "|cffff7d00" .. L["RULES_LIMITATIONS_BATTLEGROUNDS"] .. "|r",
                                desc = L["RULES_LIMITATIONS_ZONE_DESC"],
                                get = function(info) return self.Core.Rules.Apply.Battlegrounds end,
                            },
                            level = {
                                order = 5,
                                type = "description",
                                name = function () return Color(C.RULE, L["RULES_LIMITATIONS_LEVELS"]) .. ": " .. self:GetRulesLevel(self.Core.Rules.Apply.Level); end,
                            },
                            excludedRanks = {
                                order = 6,
                                type = "description",
                                name = function() return Color(C.RULE, _cstr(L["RULES_LIMITATIONS_RANKS"], Color(C.GREEN, "Applied"), Color(C.ORANGE, "Excluded")) .. ":\n") .. self:GetExcludedRanks(self.Core.Rules.ExcludedRanks) end,
                                fontSize = "small",
					        },
                        },
                    },
                    items = {
                        order = 3,
                        type = "group",
                        cmdHidden = true,
                        name = L["RULES_ITEMS"],
                        guiInline = true,
                        args = {
                            maxQuality = {
                                order = 1,
                                type = "description",
                                name = function() return Color(C.RULE, L["RULES_ITEMS_MAX_QUALITY"]) .. ": " .. self:GetItemQualityText(self.Core.Rules.Items.MaxQuality) end,
                                fontSize = "small",
					        },
                            bannedAttributes = {
                                order = 2,
                                type = "description",
                                name = function() return Color(C.RULE, L["RULES_ITEMS_BANNED_ATTRIBUTES"]) .. ": " .. self:GetBannedAttributes() end,
                                fontSize = "small",
					        },
                            exceptionsAllowed = {
                                order = 3,
                                type = "description",
                                name = function() return Color(C.RULE, L["RULES_ITEMS_EXCEPTIONS_ALLOWED"]) .. ": " .. self.Core.Rules.Items.ExceptionsAllowed; end,
                                fontSize = "small",
                            },
                            alwaysAllowed = {
                                order = 4,
                                type = "description",
                                name = function() return Color(C.RULE, L["RULES_ITEMS_ALWAYS_ALLOWED"]) .. ": " .. self:GetItemsAllowed(); end,
                                fontSize = "small",
                            },
                        },
					},
                    buffs = {
                        order = 4,
                        type = "group",
                        cmdHidden = true,
                        name = L["RULES_BUFFS"],
                        guiInline = true,
                        args = {
                            bannedBuffs = {
                                order = 1,
                                type = "description",
                                name = function() return self:GetBannedBuffs(); end,
                                fontSize = "small",
                            },
                        },
                    },
                },
			},
            social = {
                order = 3,
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
                                name = L["SOUND"],
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
                                name = L["SOUND"],
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
            cheatersTab = {
                order = 4,
                name = L["CHEATERS"],
                type = "group",
                cmdHidden = true,
                args = {
                    desc = {
                        order = 1,
                        type = "description",
                        name = L["CHEATERS_DESC"],
                    },
                    cheaters = {
                        order = 2,
                        name = L["CHEATER_VIEW"],
                        type = "select",
                        cmdHidden = true,
                        desc = L["CHEATERS_SELECT"],
                        set = function(info,val) self:ViewCheater(self.SortedCheaterGUIDS[val]); end,
                        get = function(info) if (self.ViewedCheater ~= nil) then return self.SortedCheaterIDs[self.ViewedCheater.GUID]; end return nil; end,
                        values = function() return self:GetCheaterList(); end,
                    },
                    clear = {
                        order = 3,
                        type = "execute",
                        cmdHidden = true,
                        name = L["CHEATERS_REMOVE"],
                        desc = L["CHEATERS_REMOVE_DESC"],
                        func = function() self.Core.Inspector:ForgetCheater(self.ViewedCheater); end,
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
                    cheaterHeader = {
                        order = 5,
                        type = "header",
                        name = function() return self:GetCheaterHeader(); end,
					},
                    reporters = {
                        order = 6,
                        name = L["CHEATER_REPORTER"],
                        type = "select",
                        cmdHidden = true,
                        desc = L["CHEATER_REPORTER_DESC"],
                        set = function(info,val) self:ViewCheaterData(val); end,
                        get = function(info) if (self.ViewedCharacterData ~= nil) then return self.ViewedCharacterData.Capturer.GUID; end return nil; end,
                        values = function() return self:GetCheaterDataList(); end,
                    },
                    ignoreReporter = {
                        order = 7,
                        name = L["CHEATER_REPORTER_IGNORE"],
                        type = "execute",
                        cmdHidden = true,
                        desc = _cstr(L["CHEATER_REPORTER_IGNORE_DESC"], Color(C.TITLE, L["ADVANCED"])),
                        func = function() self.Core:IgnoreReporter(self.ViewedCharacterData.Capturer.Name); end,
                        disabled = function() return self.ViewedCharacterData == nil or self.ViewedCharacterData.Capturer.GUID == self.Core.Player.GUID or self.Core:IsIgnored(self.ViewedCharacterData.Capturer.Name); end,
                    },
                    bannedItems = {
                        order = 8,
                        name = L["CHEATER_INFORMATION_BANNED_ITEMS"],
                        type = "group",
                        guiInline = true,
                        cmdHidden = true,
                        args = {
                            equipped = {
                                order = 1,
                                type = "description",
                                name = function() return self:GetCheaterBannedItems(true); end,
                                fontSize = "medium",
                            },
                            unEquipped = {
                                order = 2,
                                type = "description",
                                name = function() return self:GetCheaterBannedItems(false); end,
                                fontSize = "medium",
                            },
						}
					},
                    bannedBuffs = {
                        order = 9,
                        name = L["CHEATER_INFORMATION_BANNED_BUFFS"],
                        type = "group",
                        guiInline = true,
                        cmdHidden = true,
                        args = {
                            active = {
                                order = 1,
                                type = "description",
                                name = function() return self:GetCheaterBannedBuffs(true); end,
                                fontSize = "medium",
                            },
                            unActive = {
                                order = 2,
                                type = "description",
                                name = function() return self:GetCheaterBannedBuffs(false); end,
                                fontSize = "medium",
                            },
						}
					},
                },
            },
            advanced = {
                order = 5,
                name = L["ADVANCED"],
                type = "group",
                args = {
                    users = {
                        order = 1,
                        name = L["ADVANCED_USERS"],
                        type = "group",
                        args = {
                            notify = {
                                order = 1,
                                name = L["ADVANCED_VERSIONS_NOTIFY"],
                                type = "group",
                                desc = Desc(L["ADVANCED_VERSIONS_NOTIFY_DESC"]),
                                guiInline = true,
                                args = {
                                    desc = {
                                        order = 1,
                                        type = "description",
                                        name = lastDesc,
                                        cmdHidden = true,
					                },
                                    message = {
                                        order = 2,
                                        type = "input",
                                        width = 1.8,
                                        name = L["MESSAGE"],
                                        validate = function(info, val) if (val:len() > 255) then return "Maximum of 255 characters allowed."; else return true; end end, 
                                        set = function(info, val) self.Network.MessageToNonUsers = val; end,
                                        get = function() return self.Network.MessageToNonUsers; end,
                                        disabled = function() return not IsInGuild(); end,
					                },
                                    send = {
                                        order = 3,
                                        type = "execute",
                                        width = "half",
                                        name = L["SEND"],
                                        func = function() self.Network:NotifyNonUsers(); end,
                                        disabled = function() return not IsInGuild() or self.Network.MessageToNonUsers == nil or self.Network.MessageToNonUsers:len() == 0; end,
					                },
						        },
					        },
                            list = {
                                order = 2,
                                name = L["ADVANCED_STATUS"],
                                type = "group",
                                guiInline = true,
                                cmdHidden = true,
                                args = {
                                    text = {
                                        type = "description",
                                        width = "full",
                                        name = function() return self.Network:GetUsersList(); end,
					                },
						        },
					        },
                        },
                    },
                    addons = {
                        order = 2,
                        name = L["ADDONS"],
                        type = "group",
                        args = {
                            options = {
                                order = 1,
                                name = L["SEARCH"],
                                type = "group",
                                desc = Desc(L["SEARCH_ADDONS_DESC"]),
                                guiInline = true,
                                args = {
                                    desc = {
                                        order = 1,
                                        type = "description",
                                        name = lastDesc,
					                },
                                    input = {
                                        order = 2,
                                        type = "input",
                                        width = 1.8,
                                        name = L["SEARCH_ADDONS_INPUT"],
                                        set = function(info, val) self.SearchGuildAddOnsInput = val; end,
                                        get = function() return self.SearchGuildAddOnsInput; end,
                                        disabled = function() return not IsInGuild(); end,
					                },
                                    search = {
                                        order = 3,
                                        type = "execute",
                                        width = "half",
                                        name = L["SEARCH"],
                                        func = function() self.Network:SearchGuildAddOns(self.SearchGuildAddOnsInput) end,
                                        disabled = function() return not IsInGuild() or self.SearchGuildAddOnsInput == ""; end
					                },
						        },
					        },
                            list = {
                                order = 2,
                                name = L["SEARCH_RESULTS"],
                                type = "group",
                                guiInline = true,
                                cmdHidden = true,
                                args = {
                                    text = {
                                        type = "description",
                                        width = "full",
                                        name = function() return self.Network:GetSearchResults(); end,
					                },
						        },
					        },
                        },
                    },
                    ignoredReporters = {
                        order = 3,
                        name = L["IGNORED_REPORTERS"],
                        type = "group",
                        desc = Desc(L["IGNORED_REPORTERS_DESC"]),
                        args = {
                            desc = {
                                order = 1,
                                type = "description",
                                name = lastDesc,
					        },
                            list = {
                                order = 2,
                                type = "input",
                                width = "full",
                                multiline = true,
                                name = L["LIST"],
                                set = function(info, val) self.Core.db.factionrealm.ignoredReporters = val; end,
                                get = function() return self.Core.db.factionrealm.ignoredReporters; end,
                                disabled = function() return not IsInGuild(); end,
					        },
                        },
                    },
                },
            },
            debugging = {
                order = 6,
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
                        width = "half",
                        disabled = function() return self.Core.db.profile.DebuggingLevel == 0; end,
                        name = L["DEBUG_CACHE"],
                        set = function(info,val) self.Core.db.profile.DebugCache = val end,
                        get = function(info) return self.Core.db.profile.DebugCache end,
                    },
                    debugData = {
                        order = 3,
                        type = "toggle",
                        width = "half",
                        disabled = function() return self.Core.db.profile.DebuggingLevel == 0; end,
                        name = L["DEBUG_DATA"],
                        set = function(info,val) self.Core.db.profile.DebugData = val end,
                        get = function(info) return self.Core.db.profile.DebugData end,
                    },
                    debugNetwork = {
                        order = 5,
                        type = "toggle",
                        width = "half",
                        disabled = function() return self.Core.db.profile.DebuggingLevel == 0; end,
                        name = L["DEBUG_NETWORK"],
                        set = function(info,val) self.Core.db.profile.DebugNetwork = val end,
                        get = function(info) return self.Core.db.profile.DebugNetwork end,
                    },
                    clearLogs = {
                        order = 6,
                        type = "execute",
                        name = L["CLEAR_DEBUG_LOGS"],
                        desc = L["CLEAR_DEBUG_LOGS_DESC"],
                        func = function() self.Core:ClearLogs(); end,
                    },
                    logs = {
                        order = 7,
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

function GuildGearRulesUserInterface:UpdateCharacterView()
    -- Update currently viewed cheater in UI.
    local cheaters = self.Core.Inspector.Cheaters;

    local exists = false;
    for index, value in pairs(cheaters) do
        if (value:HasCheatedDataCount() > 0 and value.GUID == self.ViewedCheater.GUID) then
            exists = true;
        end
    end

    if (not exists) then
        self.ViewedCheater = nil;
        self.ViewedCharacterData = nil;
    end

    if (self.ViewedCheater == nil or self.ViewedCheater:HasCheatedDataCount() == 0) then
        if (#cheaters > 0) then
            for key, cheater in pairs(cheaters) do
                if (cheater:HasCheatedDataCount() > 0) then
                    self:ViewCheater(cheater.GUID);
                    break;
                end
            end
        end
    end
end

function GuildGearRulesUserInterface:ViewCheater(guid)
    self.ViewedCheater = self.Core.Inspector:GetCheater(guid);
    for key, data in pairs(self.ViewedCheater.Data) do
        if (data.HasCheated) then
            self.ViewedCharacterData = data;
            break;
        end
    end
    self:Refresh();
end

function GuildGearRulesUserInterface:GetCheaterList()
    local array = { };
    for key, cheater in pairs(self.Core.Inspector.Cheaters) do            
        if (cheater:HasCheatedDataCount() > 0) then
            local hasCheatedCount = cheater:HasCheatedDataCount();
            local cheatingCount = cheater:CheatingDataCount();

            local ending = " " .. Color(C.ORANGE, L["CHEATER_STATUS_MIXED"]);
            local sort = 1;
            -- All reports show as cheating.
            if (cheatingCount > 0 and cheatingCount == hasCheatedCount) then
                ending = " " .. Color(C.RED, L["CHEATER_STATUS_CHEATING"]);
                sort = 0;
            -- No reports show as cleared.
            elseif (cheatingCount == 0) then
                ending = " " .. Color(C.GREEN, L["CHEATER_STATUS_CLEARED"]);
                sort = 2;
            end

            self.Core:AddSorted(array, sort, cheater.Name, "[" .. cheater.GUID .. "]" .. self:ClassColored(cheater.Name, CLASSES_FILE[cheater.ClassID]) .. " (" .. hasCheatedCount .. ")" .. ending);
        end
    end

    table.sort(array);
    self.SortedCheaterGUIDS = { };
    self.SortedCheaterIDs = { };
    local cheaterList = { };
    local count = 1;
    for i, text in ipairs(array) do
        local guid = string.match(text, "%[(.*)%]");
        local text = string.match(text, "%](.*)");
        cheaterList[count] = text;
        self.SortedCheaterGUIDS[count] = guid;
        self.SortedCheaterIDs[guid] = count;
        count = count + 1;
    end

    return cheaterList;
end

function GuildGearRulesUserInterface:ViewCheaterData(guid)
    for key, data in pairs(self.ViewedCheater.Data) do
        if (data.Capturer.GUID == guid) then
            self.ViewedCharacterData = data;
        end
    end
end

function GuildGearRulesUserInterface:GetCheaterDataList()
    local dataList = { };
    if (self.ViewedCheater == nil) then return dataList; end

    for key, data in pairs(self.ViewedCheater.Data) do
        if (data.HasCheated) then
            local ending = " " .. Color(C.GREEN, L["CHEATER_STATUS_CLEARED"]);
            if (data:IsCheating()) then
                ending = " " .. Color(C.RED, L["CHEATER_STATUS_CHEATING"]);
            end

            dataList[data.Capturer.GUID] = self:ClassColored(data.Capturer.Name, CLASSES_FILE[data.Capturer.ClassID]) .. ending;
        end
    end
    return dataList;
end

function GuildGearRulesUserInterface:GetCheaterHeader()
    if (self.ViewedCheater == nil) then return L["CHEATER_NIL_SELECTED"]; end
    return self.ViewedCheater.Name .. " " .. self.ViewedCheater.Level .. " " .. " " .. CLASSES_NAME[self.ViewedCheater.ClassID];
end

function GuildGearRulesUserInterface:GetCheaterBannedItems(equipped)
    if (self.ViewedCharacterData == nil) then return ""; end
    local text = L["CHEATER_ITEMS_EQUIPPED_CURRENTLY"] .. "\n";
    if (not equipped) then text = L["CHEATER_ITEMS_EQUIPPED_PREVIOUSLY"] .. "\n"; end

    for key, item in pairs(self.ViewedCharacterData.Items) do
        if (equipped == item.Equipped) then
            if (item == nil or item.SlotID == nil or item.Link == nil or item.Time == nil) then
                self.Core:Log("Cannot display banned item, value missing.", DEBUG_MSG_TYPE.ERROR)
            else
                text = text .. "|cffffd100" .. INVENTORY_SLOT[tonumber(item.SlotID)] .. "|r: " .. _cstr(L["CHEATER_INFORMATION_ITEM_SEEN"], item.Link, item.Time) .. "\n";
            end
        end
    end
    return text;
end

function GuildGearRulesUserInterface:GetCheaterBannedBuffs(active)
    if (self.ViewedCharacterData == nil) then return ""; end
    local text = L["CHEATER_BUFFS_ACTIVE_CURRENTLY"] .. "\n";
    if (not active) then text = L["CHEATER_BUFFS_ACTIVE_PREVIOUSLY"] .. "\n"; end

    for key, buff in pairs(self.ViewedCharacterData.Buffs) do
        if (active == buff.Active) then
            if (buff == nil or buff.SpellID == nil or buff.Time == nil) then
                self.Core:Log("Cannot display banned buff, value missing.", DEBUG_MSG_TYPE.ERROR)
            else
                text = text .. _cstr(L["CHEATER_INFORMATION_ITEM_SEEN"], self:Buff(buff.SpellID), buff.Time) .. "\n";
            end
        end
    end
    return text;
end

function GuildGearRulesUserInterface:Show(ignoreToggle)
    ignoreToggle = ignoreToggle or false;
    local dialog = LibStub("AceConfigDialog-3.0");
    if (dialog.OpenFrames["GuildGearRules"] and not ignoreToggle) then
        dialog:Close("GuildGearRules")
    else
        PlaySound(882);
        dialog:Open("GuildGearRules")
    end
end

function GuildGearRulesUserInterface:ShowTab(tab)
    self:Show(true)
    if (tab ~= nil) then
        LibStub("AceConfigDialog-3.0"):SelectGroup("GuildGearRules", tab);
    end
end

function GuildGearRulesUserInterface:AlertTest()
    itemName, itemLink = GetItemInfo(self.Core.Constants.AlertTestItemID);
    self.Core.Inspector:Alert("Cheaterboy", 4, itemLink);
end

function GuildGearRulesUserInterface:GetItemsAllowed()
    if (#self.Core.Rules.Items.AllowedIDs == 0) then return "-"; end

    local text = "";
    for i = 1, #self.Core.Rules.Items.AllowedIDs do
        text = text .. self:DeadItemLink(self.Core.Rules.Items.AllowedIDs[i]) .. " ";
    end
    return text;
end

function GuildGearRulesUserInterface:GetRulesLevel(level)
    if (level == 0) then return L["RULES_LIMITATIONS_LEVEL_ALL"] else return _cstr(L["RULES_LIMITATIONS_LEVEL"], level) end 
end

function GuildGearRulesUserInterface:GetExcludedRanks(ranks)
    local text = "";
    for i = 1, GuildControlGetNumRanks() do
        local name = GuildControlGetRankName(i);
        if (name ~= nil) then
            local color = C.GREEN;
            if (ranks:Contains(i)) then color = C.ORANGE; end
            text = text .. "#" .. i .. " " .. Color(color, "[" .. name .. "]") .. "\n";
        end
    end

    -- No attributes enabled.
    if (text == "") then
        text = "-";
    end

    return text;
end

function GuildGearRulesUserInterface:GetBannedAttributes()
    local text = "";
    for i = 1, #self.Core.Rules.Items.BannedAttributes do
        local attribute = self.Core.Rules.Items.BannedAttributes[i];
        if (attribute.Name ~= nil) then
            text = text .. self:Attribute(attribute) .. " ";
        end
    end

    -- No attributes enabled.
    if (text == "") then
        text = "-";
    end

    return text;
end

function GuildGearRulesUserInterface:FormattedBoolean(bool)
    if (bool) then return L["YES"]; else return L["NO"] ; end
end

function GuildGearRulesUserInterface:GetRulesApply()
    local text = Color(C.RULE, L["RULES_APPLY_IN_WORLD"]) .. ": " .. self:FormattedBoolean(self.Core.Rules.Apply.World);
    text = text .. "\n" .. Color(C.RULE, L["RULES_APPLY_IN_DUNGEONS"]) .. ": " .. self:FormattedBoolean(self.Core.Rules.Apply.Dungeons);
    text = text .. "\n" .. Color(C.RULE, L["RULES_APPLY_IN_RAIDS"]) .. ": " .. self:FormattedBoolean(self.Core.Rules.Apply.Raids);
    text = text .. "\n" .. Color(C.RULE, L["RULES_APPLY_IN_BATTLEGROUNDS"]) .. ": " .. self:FormattedBoolean(self.Core.Rules.Apply.Battlegrounds);
    return text;
end

function GuildGearRulesUserInterface:GetBannedBuffs()
    local text = "";
    for i = 1, #self.Core.Rules.BannedBuffGroups do
        local buffGroup = self.Core.Rules.BannedBuffGroups[i];
        if (buffGroup.MinimumLevel == nil) then
            text = text .. Color(C.RULE, L["RULES_BANNED_BUFFS"]) .. "\n";
        else
            text = text .. Color(C.RULE, _cstr(L["RULES_BANNED_BUFFS_LEVEL"], buffGroup.MinimumLevel) .. "\n");
        end

        for j = 1, #buffGroup.IDs do
            text = text .. self:Buff(buffGroup.IDs[j]) .. "\n";
        end

        text = text .. "\n";
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

function GuildGearRulesUserInterface:Refresh()
    LibStub("AceConfigRegistry-3.0"):NotifyChange("GuildGearRules");
end

function GuildGearRulesUserInterface:ClassColoredName(name, unitID)
    classFileName, classId = UnitClassBase(unitID);
    return self:ClassColored(name, classFileName);
end

function GuildGearRulesUserInterface:ClassColored(text, classFileName)
    rPerc, gPerc, bPerc, argbHex = GetClassColor(classFileName);
    text = text or "(Missing text)";
    local color = "|c" .. argbHex;
	return color .. text .. "|r";
end

function GuildGearRulesUserInterface:ClassIDColored(text, classID)
    local r, g, b, hex = GetClassColor(CLASSES_FILE[classID]);
	return "|c" .. hex .. text .. "|r";
end

function GuildGearRulesUserInterface:ClassNameID(className)
    for i = 1, #CLASSES_NAME do
        if (CLASSES_NAME[i] == className) then
            return i;
        end
    end
    return nil;
end

function GuildGearRulesUserInterface:Buff(spellID)
    local name = GetSpellInfo(spellID);
    return "|cffffd100[" .. name .. "]|r";
end

function GuildGearRulesUserInterface:Attribute(attribute)
    if (attribute == nil or attribute.Name == nil) then
        return "Missing text";
    end

    return Color(C.ATTRIBUTE, "[" .. attribute.Name .. "]");
end

function GuildGearRulesUserInterface:GetItemQualityText(val)
    if (val == nil) then return "-"; end
    return ITEM_QUALITY_COLORS[val].hex .._G["ITEM_QUALITY" .. val .. "_DESC"] .. "|r";
end

function GuildGearRulesUserInterface:DeadItemLink(itemID)
    local quality = C_Item.GetItemQualityByID(itemID);
    -- Quality might not be returned if item aint cached.
    if (quality == nil or quality == -1) then
        return "|cff889d9d[" .. itemID .. "]|r";
    end
    return ITEM_QUALITY_COLORS[quality].hex .. "[" .. C_Item.GetItemNameByID(itemID) .. "]" .. "|r";
end

function GuildGearRulesUserInterface:HyperlinkInfo(hyperlink)
    local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name = string.find(hyperlink,
    "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?");
    return Color, Ltype, tonumber(Id), Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name;
end