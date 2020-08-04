local L = LibStub("AceLocale-3.0"):NewLocale("GuildGearRules", "enUS", true, true) 
if not L then return end

L["ATTRIBUTE_SPELLPOWER"] = "Equip: Increases damage and healing done by magical spells and effects by up to ."
L["ATTRIBUTE_ATTACKPOWER"] = "Equip: + Attack Power."

-- NOTE: If a string does not need to be translated, remove the line entirely and it will use the default language instead.

-- General.
L["GUILD_GEAR_RULES"] = "Guild Gear Rules"
L["GGR"] = "GGR"
L["CONFIG_COMMAND"] = "ggr"
L["CONFIG_COMMAND_LONG"] = "guildgearrules"
L["ADDON_LOADED"] = "Guild Gear Rules loaded (version %s). Type %s for help."
L["VERSION"] = "Version"
L["AUTHOR"] = "Author"
L["OPEN_GUI"] = "Open the GUI."
L["MESSAGE_RECEIVED"] = "|cff3ce13f[GGR-%s]|r "

L["ENABLED"] = "Enabled"
L["TOGGLE_ENABLE_DESC"] = "Activate or deactivate the function."
L["GUILD_MEMBERS"] = "guild members"
L["GUILD_CHANNEL"] = "guild channel"
L["SOUND"] = "Sound"
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
L["TEST"] = "Test"
L["OPTIONS"] = "Options"
L["YES"] = "Yes"
L["No"] = "No"
L["SEND"] = "Send"
L["MESSAGE"] = "Message"
L["ADDONS"] = "AddOns"
L["SEARCH"]= "Search"
L["SEARCH_RESULTS"] = "Search Results"
L["SEARCH_RUNNING"] = "Search is running, please wait %s seconds..."
L["LIST"] = "List"
L["NEW_VERSION_DETECTED"] = "Detected a newer version (v%s) on %s. Check %s for information on how to update."
L["WARNING"] = "Warning"
L["WARNING_DESC"] = "By default, %s will remove banned buffs from your character automatically. Be sure to check the rules thoroughly, as used consumables might otherwise be wasted.\n\nThis can be turned off in the settings.\n\n"
L["DONT_SHOW_AGAIN"] = "Don't show again"
L["OPEN_SETTINGS"] = "Open settings"

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

-- Minimap button.
L["MINIMAP_BUTTON_DESC"] = "Icon lights up when cheaters are detected."

L["LEFT_CLICK"] = "Left Click"
L["MIDDLE_CLICK"] = "Middle Click"
L["RIGHT_CLICK"] = "Right Click"
L["RIGHT_CLICK_CTRL"] = "Right Click + Ctrl"

L["TOGGLE_FRAME"] = "Toggle Frame"
L["OPEN_RULES"] = "Open Rules"
L["OPEN_CHEATERS"] = "Open Cheaters"
L["HIDE_MINIMAP_BUTTON"] = "Hide Minimap Button"

-- Core tab.
L["CORE"] = "Core"
L["CORE_INFO"] = "Information"
L["CORE_INFO_DESC"] = "%s at its core:\n- Alerts you if %s break the rules.\n- Announces in %s if you break the rules and when you abide them again.\n\nBefore you start exploring Azeroth, make sure to check the rules for your %s in the %s tab."
L["CORE_INFO_UPDATES"] = "Get updates in the Twitch app or the link below:"

L["CORE_ALERT"] = "Alert"
L["CORE_ALERT_DESC"] = "This is the alert that plays if %s break the rules."
L["CORE_ALERT_TEST_DESC"] = "Play an alert the same way it would do if a cheater was detected."

L["CORE_REMOVE_BANNED_BUFFS"] = "Remove Banned Buffs"
L["CORE_REMOVE_BANNED_BUFFS_DESC"] = "Automatically removes any banned buffs. Be sure to check the rules thoroughly, as used consumables might otherwise be wasted."
L["CORE_RECEIVE_DATA"] = "Receive Data"
L["CORE_RECEIVE_DATA_DESC"] = "Receive data from other users.\nIf disabled, you will only gain information on nearby cheaters."
L["CORE_MINIMAP_BUTTON"] = "Minimap Button"
L["CORE_MINIMAP_BUTTON_DESC"] = "Show or hide the Minimap Button."
L["CORE_STARTUP_WARNING"] = "Hide Startup Warning"
L["CORE_STARTUP_WARNING_DESC"] = "Hide the warning that informs you about automatically removing buffs."

L["INSPECTION"] = "Distant Inspection"
L["INSPECTION_NOTIFY"] = "Notify"
L["INSPECTION_NOTIFY_DESC"] = "Get notified when people successfully inspect you."
L["INSPECTION_DESC"] = "Allows players to inspect you by whispering |cffff7eff%s|r regardless if they have the addon themselves."
L["INSPECTION_FOOTER"] = "This replies with a item link to each of your equipped items."
L["INSPECTION_COOLDOWN_DESC"] = "Limit possible spam by setting a cooldown on replies."

-- Rules tab.
L["RULES"] = "Rules"
L["RULES_NOT_IN_GUILD"] = "Not in a guild."
L["RULES_LOADED"] = "Rules loaded for %s"

L["RULES_LIMITATIONS"] = "Limitations"
L["RULES_LIMITATIONS_LEVEL"] = "From Level %s"
L["RULES_LIMITATIONS_ALL_LEVELS"] = "All Levels"
L["RULES_LIMITATIONS_WORLD"] = "World"
L["RULES_LIMITATIONS_DUNGEONS"] = "Dungeons"
L["RULES_LIMITATIONS_RAIDS"] = "Raids"
L["RULES_LIMITATIONS_BATTLEGROUNDS"] = "Battlegrounds"

L["RULES_ITEMS"] = "Items"
L["RULES_ITEMS_MAX_QUALITY"] = "Max Item Quality"
L["RULES_ITEMS_BANNED_ATTRIBUTES"] = "Banned Attributes"
L["RULES_ITEMS_EXCEPTIONS_ALLOWED"] = "Exceptions Allowed"
L["RULES_ITEMS_ALWAYS_ALLOWED"] = "Always Allowed"

L["RULES_BUFFS"] = "Buffs"
L["RULES_BANNED_BUFFS"] = "Banned Buffs:"
L["RULES_BANNED_BUFFS_LEVEL"] = "Banned Buffs from level %i:"

L["RULES_TAG_SP"] = "Generic spell power"
L["RULES_TAG_AP"] = "Attack Power"

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
L["CHEATER_VIEW"] = "View Character"
L["CHEATERS_DESC"] = "Information about cheaters is remembered until the interface is reloaded or cleared manually.\nIf a player who has the AddOn is reported by another player, but has not reported itself, one of the players is likely using a hacked version of the AddOn. Thus you should only trust reports either by players on themselves, or reports with several sources."
L["CHEATERS_SELECT"] = "Select a character to view information about."
L["CHEATERS_REMOVE"] = "Remove"
L["CHEATERS_REMOVE_DESC"] = "Removes all information about the selected character. This does not prevent it from being scanned again."
L["CHEATERS_REFRESH"] = "Refresh"
L["CHEATERS_REFRESH_DESC"] = "Refresh shown information about characters."
L["CHEATER_REPORTER"] = "Reporter"
L["CHEATER_REPORTER_DESC"] = "Choose whose report to view."
L["CHEATER_REPORTER_IGNORE"] = "Ignore"
L["CHEATER_REPORTER_IGNORE_DESC"] = "Ignore reports from this player if you believe them to be false, view all ignored in the %s tab."
L["CHEATER_NIL_SELECTED"] = "Select a character to view information"
L["CHEATER_INFORMATION_BANNED_ITEMS"] = "Banned Items"
L["CHEATER_INFORMATION_BANNED_BUFFS"] = "Banned Buffs"
L["CHEATER_INFORMATION_ITEM_SEEN"] = "%s last seen %s."
L["CHEATER_STATUS_CHEATING"] = "(Cheating)"
L["CHEATER_STATUS_CLEARED"] = "(Cleared)"
L["CHEATER_STATUS_MIXED"] = "(Mixed)"
L["CHEATER_ITEMS_EQUIPPED_CURRENTLY"] = "Currently equipped:"
L["CHEATER_ITEMS_EQUIPPED_PREVIOUSLY"] = "Previously equipped:"
L["CHEATER_BUFFS_ACTIVE_CURRENTLY"] = "Currently active:"
L["CHEATER_BUFFS_ACTIVE_PREVIOUSLY"] = "Previously active:"

-- Advanced tab.
L["ADVANCED"] = "Advanced"

L["ADVANCED_USERS"] = "Users"
L["ADVANCED_STATUS"] = "Status"

L["ADVANCED_VERSIONS_NOTIFY"] = "Notify Non-users"
L["ADVANCED_VERSIONS_NOTIFY_DESC"] = "Whisper players who do not have the AddOn installed and enabled.\nLimited to one whisper per player per reload."
L["SCAN_GGR_MESSAGE"] = "has v%s."
L["SCAN_GGR_MESSAGE_NOT_INSTALLED"] = "doesn't have GGR."
L["SCAN_GGR_MESSAGE_NOTIFIED"] = "doesn't have GGR, but has been notified by you."
L["SCAN_GGR_LOGGED_OFF"] = "(Logged off)"

L["SEARCH_ADDONS_DESC"] = "Check if specified AddOns are enabled in the guild. Retrieves one result per argument.\nSeparate AddOn names by comma.\nE.g. |cffffff00WeakAuras, DBM-Core|r.\n|cffffff00guild|r will match GuildGearRules|r."
L["SEARCH_ADDONS_INPUT"] = "AddOn Names"
L["SEARCH_ADDONS_MESSAGE"] = "has %s enabled."
L["SEARCH_ADDONS_MESSAGE_NO_MATCH"] = "has no matching AddOns enabled."
L["SEARCH_ADDONS_MESSAGE_NOT_ALLOWED"] = "couldn't be searched."

L["DISPLAYING_MEMBERS"] = "Displaying %i members."

L["IGNORED_REPORTERS"] = "Ignored reporters"
L["IGNORED_REPORTERS_DESC"] = "Ignore reports from selected players, this is useful if you believe someone is using a hacked version of the AddOn sending false reports.\nOne character name per line."

-- Debugging tab.
L["DEBUGGING"] = "Debugging"
L["DEBUGGING_LEVEL"] = "Debug Level"
L["DEBUGGING_LEVEL_DESC"] = "Decides which logs are printed. Turn off for best performance."
L["DEBUGGING_LEVEL_0"] = "None"
L["DEBUGGING_LEVEL_1"] = "Errors"
L["DEBUGGING_LEVEL_2"] = "Errors and Warnings"
L["DEBUGGING_LEVEL_3"] = "All"
L["DEBUG_CACHE"] = "Cache"
L["DEBUG_DATA"] = "Data"
L["DEBUG_NETWORK"] = "Network"
L["CLEAR_DEBUG_LOGS"] = "Clear Logs"
L["CLEAR_DEBUG_LOGS_DESC"] = "Clears the logs."
L["DEBUG_LOGS"] = "Logs"

-- Player is cheating. These should not be localized to other languages than the primary language since they are shared with other players.
L["ALERT_MESSAGE_GUILD_CHAT_START"] = "Opsies, I'm using %s!"
L["ALERT_MESSAGE_GUILD_CHAT_ENDED"] = "I'm cheating no more. Check %s to make sure."
-- Scanned character is cheating, definitely localize.
L["ALERT_MESSAGE_SELF"] = "has %s, view more info in %s."
L["ALERT_MESSAGE_STOPPED"] = "%s stopped cheating."