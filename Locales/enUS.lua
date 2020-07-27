local L = LibStub("AceLocale-3.0"):NewLocale("GuildGearRules", "enUS", true, true) 
if not L then return end

L['ATTRIBUTE_SPELLPOWER'] = ".*Increases damage and healing done by magical spells and effects by up to .*." 

-- NOTE: If a string does not need to be translated, remove the line entirely and it will use the default language instead.

-- General.
L["GUILD_GEAR_RULES"] = "Guild Gear Rules"
L["GGR"] = "GGR"
L["CONFIG_COMMAND"] = "ggr"
L["ADDON_LOADED"] = "Guild Gear Rules loaded (version %s). Type %s for help."
L["VERSION"] = "Version"
L["OPEN_GUI"] = "Open the GUI."

L["ENABLED"] = "Enabled"
L["TOGGLE_ENABLE_DESC"] = "Activate or deactivate the function."
L["GUILD_MEMBERS"] = "guild members"
L["GUILD_CHANNEL"] = "guild channel"
L["ALERT_SOUND"] = "Alert Sound"
L["SOUND_TO_PLAY"] = "Sound to play."
L["PARTY"] = "Party"
L["GUILD"] = "Guild"
L["LEVEL"] = "Level"
L["COOLDOWN"] = "Cooldown"
L["COOLDOWN_NONE"] = "None."
L["COOLDOWN_SECONDS_1"] = "One second."
L["COOLDOWN_SECONDS_5"] = "Five seconds."
L["COOLDOWN_SECONDS_10"] = "Ten seconds."
L["COOLDOWN_SECONDS_30"] = "Thirty seconds."

-- Sounds.
L["SOUND_RAID_WARNING"] = "Raid Warning"
L["SOUND_ALARM_CLOCK_WARNING"] = "Alarm Clock Warning"
L["SOUND_RAGNAROS"] = "Ragnaros"
L["SOUND_KELTHUZAD"] = "Kel'Thuzad"
L["SOUND_RANDOM_PEASANT_GREETINGS"] = "Random Peasant Greetings"
L["SOUND_RANDOM_PEON_GREETINGS"] = "Random Peon Greetings"
L["SOUND_LEVEL_UP"] = "Level Up"
L["SOUND_PVP_VICTORY_ALLIANCE"] = "PVP Victory Alliance"
L["SOUND_PVP_VICTORY_HORDE"] = "PVP Victory Horde"

-- Basics tab.
L["BASICS"] = "Basics"
L["GEAR_CHECKER_DESC"] = "Alerts you if nearby %s break the rules.\n\nAnnounces in %s if you break the rules and when you abide them again."
L["GEAR_CHECKER_FOOTER"] = "This is a core functionality and cannot be toggled."
L["GEAR_CHECKER_TEST_ALERT"] = "Test Alert"
L["GEAR_CHECKER_TEST_ALERT_DESC"] = "Play an alert the same way it would do if it detected a nearby cheater."

L["RULES"] = "Rules"
L["RULES_NOT_IN_GUILD"] = "Not in a guild."
L["RULES_LOADED"] = "Rules loaded for %s."
L["RULES_MAX_ITEM_QUALITY"] = "Max Item Quality"
L["RULES_EXCEPTIONS_ALLOWED"] = "Exceptions Allowed"
L["RULES_ALWAYS_ALLOWED"] = "Always Allowed"
L["RULES_EXTRAS"] = "Extras"
L["RULES_TAG_SP"] = "No generic spell power"
L["RULES_TAG_PVP"] = "Battlegrounds excluded"
L["RULES_TAG_PVE"] = "Only raids and dungeons"

L["INSPECTION"] = "Distant Inspection"
L["INSPECTION_DESC"] = "Allow players to inspect you by whispering |cffff7eff%s|r regardless if they have the addon themselves."
L["INSPECTION_FOOTER"] = "This will reply with a item link to each of your equipped items."
L["INSPECTION_COOLDOWN_DESC"] = "Limit possible spam by setting a cooldown on replies."

-- Social tab.
L["SOCIAL"] = "Social"
L["NEW_MEMBER_ALERT"] = "Welcome"
L["NEW_MEMBER_ALERT_DESC"] = "Alerts you when a new player joins the %s."

L["LEVEL_UP_ALERT"] = "Gratulate"
L["LEVEL_UP_ALERT_DESC"] = "Alerts you with a sound when players write ding in specified channels."
L["GUILD_ONLY"] = "Guild only"
L["GUILD_ONLY_DESC"] = "Only allow members of the same guild to inspect you."
L["REACT_ON_PARTY_CHANNEL"] = "React on party channel."
L["REACT_ON_GUILD_CHANNEL"] = "React on guild channel."

-- Cheaters tab.
L["CHEATERS"] = "Cheaters"
L["CHEATER_VIEW"] = "View Cheater"
L["CHEATERS_DESC"] = "Information about cheaters is remembered as long as you stay logged in even if items are unequipped or until cleared manually."
L["CHEATERS_SELECT"] = "Select a cheater to view information about."
L["CHEATERS_REMOVE"] = "Remove"
L["CHEATERS_REMOVE_DESC"] = "Removes all information about the selected character. This does not prevent it from being scanned again."
L["CHEATERS_REFRESH"] = "Refresh"
L["CHEATERS_REFRESH_DESC"] = "Refresh shown information about cheaters."
L["CHEATER_NIL_SELECTED"] = "Select a cheater to view information."
L["CHEATER_INFORMATION"] = "%s Level %s %s %s\nIllegal items(%i):"
L["CHEATER_INFORMATION_ITEM_SEEN"] = "%s seen %s."

-- Advanced tab.
L["ADVANCED"] = "Advanced"
L["SCAN_GGR"] = "Scan GGR Usage"
L["SCAN_GGR_DESC"] = "Check GGR usage in the guild."
L["SCAN_GGR_MESSAGE"] = "has v%s installed."
L["SCAN_GGR_MESSAGE_NOT_INSTALLED"] = "does not have GGR."

L["SCAN_ADDONS"] = "Scan AddOns"
L["SCAN_ADDONS_DESC"] = "Check if specified AddOns are enabled in the guild. Retrieves one result per argument."
L["SCAN_ADDONS_INPUT"] = "AddOn Names"
L["SCAN_ADDONS_INPUT_DESC"] = "Separate AddOn names by comma.\nE.g. |cffffff00WeakAuras, DBM-Core|r.\n|cffffff00guild|r will match GuildGearRules|r."
L["SCAN_ADDONS_MESSAGE"] = "has %s enabled."
L["SCAN_ADDONS_MESSAGE_NO_MATCH"] = "has no matching AddOns enabled."
L["SCAN_ADDONS_MESSAGE_NOT_ALLOWED"] = "doesn't allow AddOn scanning (GGR version probably too old)."

L["SCAN_RESULTS"] = "Scan Results"
L["SCAN_STARTED"] = "Scanning, please wait %s seconds..."
L["SCAN_ALREADY_RUNNING"] = "Scan is already running, please wait."
L["SCAN_COMPLETED"] = "Scanned %i members."

-- Debugging tab.
L["DEBUGGING"] = "Debugging"
L["DEBUGGING_LEVEL"] = "Debug Level"
L["DEBUGGING_LEVEL_DESC"] = "Decides which logs are printed. Turn off for best performance."
L["DEBUGGING_LEVEL_0"] = "None"
L["DEBUGGING_LEVEL_1"] = "Errors"
L["DEBUGGING_LEVEL_2"] = "Errors and Warnings"
L["DEBUGGING_LEVEL_3"] = "All"
L["DEBUG_CACHE"] = "Debug Cache"
L["CLEAR_DEBUG_LOGS"] = "Clear Logs"
L["CLEAR_DEBUG_LOGS_DESC"] = "Clears the logs."
L["DEBUG_LOGS"] = "Logs"

-- Player is cheating. These should not be localized to other languages than the primary language since they are shared with other players.
L["ALERT_MESSAGE_GUILD_CHAT_START"] = "Opsies, %s is equipped!"
L["ALERT_MESSAGE_GUILD_CHAT_ENDED"] = "I'm cheating no more, I promise!"
-- Scanned character is cheating, definitely localize.
L["ALERT_MESSAGE_SELF"] = "has %s, view more info in %s."