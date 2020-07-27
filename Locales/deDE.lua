local L = LibStub("AceLocale-3.0"):NewLocale("GuildGearRules", "deDE") 
if not L then return end

L['ATTRIBUTE_SPELLPOWER'] = ".*Erhöht durch Zauber und magische Effekte zugefügten Schaden und Heilung um bis zu .*." 

-- CREDITS: Trismegistos.
-- NOTE: If a string does not need to be translated, remove the line entirely and it will use the default language instead.

-- General.
L["GUILD_GEAR_RULES"] = "Gildenausrüstungsregeln"
L["CONFIG_COMMAND"] = "ggr"
L["ADDON_LOADED"] = "Gildenausrüstungsregeln geladen (Version %s). Schreibe %s für die Hilfe."
L["VERSION"] = "Version"
L["OPEN_GUI"] = "Öffne die Benutzeroberfläche"

L["ENABLED"] = "Aktiv"
L["TOGGLE_ENABLE_DESC"] = "Aktiviere oder deaktiviere diese Funktion."
L["GUILD_MEMBERS"] = "Gildenmitglieder"
L["GUILD_CHANNEL"] = "Gildenkanal"
L["ALERT_SOUND"] = "Alarmton"
L["SOUND_TO_PLAY"] = "abgespielter Ton"
L["PARTY"] = "Gruppe"
L["GUILD"] = "Gilde"
L["LEVEL"] = "Stufe"
L["COOLDOWN"] = "Abklingzeit"
L["COOLDOWN_NONE"] = "Keiner."
L["COOLDOWN_SECONDS_1"] = "Eine Sekunde."
L["COOLDOWN_SECONDS_5"] = "Fünf Sekunden."
L["COOLDOWN_SECONDS_10"] = "Zehn Sekunden."
L["COOLDOWN_SECONDS_30"] = "Dreissig Sekunden."

-- Sounds.
L["SOUND_RAID_WARNING"] = "Raid Warnung"
L["SOUND_ALARM_CLOCK_WARNING"] = "Wecker"
L["SOUND_RAGNAROS"] = "Ragnaros"
L["SOUND_KELTHUZAD"] = "Kel'Thuzad"
L["SOUND_RANDOM_PEASANT_GREETINGS"] = "zufälliger Bauerngruß"
L["SOUND_RANDOM_PEON_GREETINGS"] = "zufälliger Peongruß"
L["SOUND_LEVEL_UP"] = "Stufenaufstieg"
L["SOUND_PVP_VICTORY_ALLIANCE"] = "PVP Sieg der Allianz"
L["SOUND_PVP_VICTORY_HORDE"] = "PVP Sieg der Horde"

-- Basics tab.
L["BASICS"] = "Funktionen"
L["GEAR_CHECKER_DESC"] = "Alarmiert falls sich in der Nähe befindliche %s die Regeln brechen.\n\nGibt im %s bekannt falls du die Regeln brichst und ob du sie wieder einhälst."
L["GEAR_CHECKER_FOOTER"] = "Dies ist eine Kernfunktionalität und kann nicht deaktiviert werden."
L["GEAR_CHECKER_TEST_ALERT"] = "Teste Alarm"
L["GEAR_CHECKER_TEST_ALERT_DESC"] = "Spielt einen Test-Alarm ab der einem Alarm entspricht, der beim Finden eines Cheaters abgespielt werden würde."

L["RULES"] = "Regeln"
L["RULES_NOT_IN_GUILD"] = "Nicht in einer Gilde."
L["RULES_LOADED"] = "Regeln geladen für %s."
L["RULES_MAX_ITEM_QUALITY"] = "Maximale Gegenstandsqualität"
L["RULES_EXCEPTIONS_ALLOWED"] = "erlaubte Ausnahmen"
L["RULES_ALWAYS_ALLOWED"] = "Ausnahmen"
L["RULES_EXTRAS"] = "Zusätzlich"
L["RULES_TAG_SP"] = "Keine generelle Zauberkraft"
L["RULES_TAG_PVP"] = "Schlachtfelder ausgenommen"
L["RULES_TAG_PVE"] = "Nur in Schlachtzügen und Gruppeninstanzen"

L["INSPECTION"] = "Fern-Untersuchung"
L["INSPECTION_DESC"] = "Erlaube Spielern dich via Flüstern |cffff7eff%s|r zu untersuchen, unabhängig davon ob sie das Addon installiert haben."
L["INSPECTION_FOOTER"] = "Dies wird eine Antwort veranlassen die sämtliche Gegenstand-Links enthält."
L["INSPECTION_COOLDOWN_DESC"] = "Beschränke spam durch eine Abklingzeit für Antworten."

-- Social tab.
L["SOCIAL"] = "Sozial"
L["NEW_MEMBER_ALERT"] = "Willkommen"
L["NEW_MEMBER_ALERT_DESC"] = "Alarmiert falls ein neuer Spieler der %s beitritt."

L["LEVEL_UP_ALERT"] = "Gratulieren"
L["LEVEL_UP_ALERT_DESC"] = "Alarmiert mit einem Ton falls ein Spieler 'ding' in den aufgeführten Kanälen schreibt."
L["GUILD_ONLY"] = "Nur Gilde"
L["GUILD_ONLY_DESC"] = "Erlaube nur Mitgliedern der gleichen Gilde dich zu untersuchen."
L["REACT_ON_PARTY_CHANNEL"] = "Reagiere im Gruppen-Kanal."
L["REACT_ON_GUILD_CHANNEL"] = "Reagiere im Gilden-Kanal."

-- Cheaters tab
L["CHEATERS"] = "Cheaters"
L["CHEATER_VIEW"] = "Betrachte Cheater"
L["CHEATERS_DESC"] = "Informationen über Cheater bleiben bestehen solange du eingeloggt bist, selbst wenn die Items abgelegt werden. Ausnahme: manuelles Bereinigen."
L["CHEATERS_SELECT"] = "Wähle einen Cheater aus um Informationen über sie/ihn zu erhalten."
L["CHEATERS_CLEAR"] = "Bereinigen"
L["CHEATERS_CLEAR_DESC"] = "Bereinigt alle Informationen über den ausgewählten Charakter. Dies verhindert nicht das diese Spieler erneut untersucht werden."
L["CHEATERS_REFRESH"] = "Aktualisieren."
L["CHEATERS_REFRESH_DESC"] = "Aktualisiere angezeigte Informationen über Cheater."
L["CHEATER_NIL_SELECTED"] = "Wähle einen Cheater aus um Informationen über sie/ihn zu erhalten."
L["CHEATER_INFORMATION"] = "Stufe %s %s %s\nIllegale Gegenstände: (%i):"
L["CHEATER_INFORMATION_ITEM_SEEN"] = "%s gesehen %s."

-- Advanced tab.
L["ADVANCED"] = "Erweitert"
L["SCAN_GGR"] = "Untersuche Gildenmitglieder"
L["SCAN_GGR_DESC"] = "Untersucht die Addon Nutzung der Gildenmitgliedern und berichtet welche Version sie einsetzen falls es installiert ist. Die Ergebnisse werden im Ergebnis Bereich ausgegeben."
L["SCAN_GGR_MESSAGE"] = "hat v%s installiert."
L["SCAN_GGR_MESSAGE_NOT_INSTALLED"] = "kein GGR installiert"

L["SCAN_ADDONS"] = "Überprüfe Addons"
L["SCAN_ADDONS_DESC"] = "Verifiziere ob spezifizierte AddOns in der Gilde verwendet werden. Liefert ein Ergebnis pro Suchbegriff zurück."
L["SCAN_ADDONS_INPUT"] = "AddOn Namen"
L["SCAN_ADDONS_INPUT_DESC"] = "Trenne AddOn Namen durch Komma.\nZ.B. |cffffff00WeakAuras, DBM-Core|r.\n|cffffff00guild|r führt zu einem Treffer bei GildenAusrüstungsRegeln|r."
L["SCAN_ADDONS_MESSAGE"] = "hat %s installiert."
L["SCAN_ADDONS_MESSAGE_NO_MATCH"] = "hat keine passenden Addons installiert."
L["SCAN_ADDONS_MESSAGE_NOT_ALLOWED"] = "Das Untersuchen der installierten Addons des Ziels ist entweder nicht erlaubt, oder die installierte GGR Version des Ziels ist zu niedrig."

L["SCAN_RESULTS"] = "Ergebnisse der Untersuchung"
L["SCAN_STARTED"] = "Suche nach anderen Nutzern in der Gilde - bitte warte %s Sekunden..."
L["SCAN_ALREADY_RUNNING"] = "Suche läuft schon, bitte warten."
L["SCAN_COMPLETED"] = "%i Mitglieder wurden untersucht."

-- Debugging tab.
L["DEBUGGING"] = "Fehlersuche"
L["DEBUGGING_LEVEL"] = "Stufe der Fehlersuche"
L["DEBUGGING_LEVEL_DESC"] = "Bestimmt welche Meldungen im Protokolldatei-Bereich angezeigt werden. Für die beste Leistung, auf 'aus' setzen. "
L["DEBUGGING_LEVEL_0"] = "Aus"
L["DEBUGGING_LEVEL_1"] = "Fehler"
L["DEBUGGING_LEVEL_2"] = "Fehler und Warnung"
L["DEBUGGING_LEVEL_3"] = "Alles"
L["DEBUG_CACHE"] = "Debug Cache"
L["CLEAR_DEBUG_LOGS"] = "Protokoldatei bereinigen"
L["CLEAR_DEBUG_LOGS_DESC"] = "bereinigt die Protokoldatei."
L["DEBUG_LOGS"] = "Fehlersuche Protokoldatei"
L["DEBUG_CACHE"] = "Fehler Puffer"

-- Scanned character is cheating, definitely localize.
L["ALERT_MESSAGE_SELF"] = "Benutzt %s! FÃƒÂ¼r mehr Info: %s OberflÃƒÂ¤che"
