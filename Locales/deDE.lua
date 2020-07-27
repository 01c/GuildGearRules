local L = LibStub("AceLocale-3.0"):NewLocale("GuildGearRules", "deDE") 
if not L then return end

L['ATTRIBUTE_SPELLPOWER'] = ".*Erh�ht durch Zauber und magische Effekte zugef�gten Schaden und Heilung um bis zu .*." 

-- CREDITS: Trismegistos.
-- NOTE: If a string does not need to be translated, remove the line entirely and it will use the default language instead.

-- General.
L["GUILD_GEAR_RULES"] = "Gildenausr�stungsregeln"
L["CONFIG_COMMAND"] = "ggr"
L["ADDON_LOADED"] = "Gildenausr�stungsregeln geladen (Version %s). Schreibe %s f�r die Hilfe."
L["VERSION"] = "Version"
L["OPEN_GUI"] = "�ffne die Benutzeroberfl�che"

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
L["COOLDOWN_SECONDS_5"] = "F�nf Sekunden."
L["COOLDOWN_SECONDS_10"] = "Zehn Sekunden."
L["COOLDOWN_SECONDS_30"] = "Dreissig Sekunden."

-- Sounds.
L["SOUND_RAID_WARNING"] = "Raid Warnung"
L["SOUND_ALARM_CLOCK_WARNING"] = "Wecker"
L["SOUND_RAGNAROS"] = "Ragnaros"
L["SOUND_KELTHUZAD"] = "Kel'Thuzad"
L["SOUND_RANDOM_PEASANT_GREETINGS"] = "zuf�lliger Bauerngru�"
L["SOUND_RANDOM_PEON_GREETINGS"] = "zuf�lliger Peongru�"
L["SOUND_LEVEL_UP"] = "Stufenaufstieg"
L["SOUND_PVP_VICTORY_ALLIANCE"] = "PVP Sieg der Allianz"
L["SOUND_PVP_VICTORY_HORDE"] = "PVP Sieg der Horde"

-- Basics tab.
L["BASICS"] = "Funktionen"
L["GEAR_CHECKER_DESC"] = "Alarmiert falls sich in der N�he befindliche %s die Regeln brechen.\n\nGibt im %s bekannt falls du die Regeln brichst und ob du sie wieder einh�lst."
L["GEAR_CHECKER_FOOTER"] = "Dies ist eine Kernfunktionalit�t und kann nicht deaktiviert werden."
L["GEAR_CHECKER_TEST_ALERT"] = "Teste Alarm"
L["GEAR_CHECKER_TEST_ALERT_DESC"] = "Spielt einen Test-Alarm ab der einem Alarm entspricht, der beim Finden eines Cheaters abgespielt werden w�rde."

L["RULES"] = "Regeln"
L["RULES_NOT_IN_GUILD"] = "Nicht in einer Gilde."
L["RULES_LOADED"] = "Regeln geladen f�r %s."
L["RULES_MAX_ITEM_QUALITY"] = "Maximale Gegenstandsqualit�t"
L["RULES_ALWAYS_ALLOWED"] = "Ausnahmen"
L["RULES_EXTRAS"] = "Zus�tzlich"
L["RULES_TAG_SP"] = "Kein genereller Zauberkraft"

L["INSPECTION"] = "Fern-Untersuchung"
L["INSPECTION_DESC"] = "Erlaube Spielern dich via Fl�stern |cffff7eff%s|r zu untersuchen, unabh�ngig davon ob sie das Addon installiert haben."
L["INSPECTION_FOOTER"] = "Dies wird eine Antwort veranlassen die s�mtliche Gegenstand-Links enth�lt."
L["INSPECTION_COOLDOWN_DESC"] = "Beschr�nke spam durch eine Abklingzeit f�r Antworten."

-- Social tab.
L["SOCIAL"] = "Sozial"
L["NEW_MEMBER_ALERT"] = "Willkommen"
L["NEW_MEMBER_ALERT_DESC"] = "Alarmiert falls ein neuer Spieler der %s beitritt."

L["LEVEL_UP_ALERT"] = "Gratulieren"
L["LEVEL_UP_ALERT_DESC"] = "Alarmiert mit einem Ton falls ein Spieler 'ding' in den aufgef�hrten Kan�len schreibt."
L["GUILD_ONLY"] = "Nur Gilde"
L["GUILD_ONLY_DESC"] = "Erlaube nur Mitgliedern der gleichen Gilde dich zu untersuchen."
L["REACT_ON_PARTY_CHANNEL"] = "Reagiere im Gruppen-Kanal."
L["REACT_ON_GUILD_CHANNEL"] = "Reagiere im Gilden-Kanal."

-- Cheaters tab
L["CHEATERS"] = "Cheaters"
L["CHEATER_VIEW"] = "Betrachte Cheater"
L["CHEATERS_DESC"] = "Informationen �ber Cheater bleiben bestehen solange du eingeloggt bist, selbst wenn die Items abgelegt werden. Ausnahme: manuelles Bereinigen."
L["CHEATERS_SELECT"] = "W�hle einen Cheater aus um Informationen �ber sie/ihn zu erhalten."
L["CHEATERS_CLEAR"] = "Bereinigen"
L["CHEATERS_CLEAR_DESC"] = "Bereinigt alle Informationen �ber den ausgew�hlten Charakter. Dies verhindert nicht das diese Spieler erneut untersucht werden."
L["CHEATERS_REFRESH"] = "Aktualisieren."
L["CHEATERS_REFRESH_DESC"] = "Aktualisiere angezeigte Informationen �ber Cheater."
L["CHEATER_NIL_SELECTED"] = "W�hle einen Cheater aus um Informationen �ber sie/ihn zu erhalten."
L["CHEATER_INFORMATION"] = "Stufe %s %s %s\nIllegale Gegenst�nde: (%i):"
L["CHEATER_INFORMATION_ITEM_SEEN"] = "%s gesehen %s."

-- Advanced tab.
L["ADVANCED"] = "Erweitert"
L["SCAN_GGR"] = "Untersuche Gildenmitglieder"
L["SCAN_GGR_DESC"] = "Untersucht die Addon Nutzung der Gildenmitgliedern und berichtet welche Version sie einsetzen falls es installiert ist. Die Ergebnisse werden im Ergebnis Bereich ausgegeben."
L["SCAN_GGR_MESSAGE"] = "hat v%s installiert."
L["SCAN_GGR_MESSAGE_NOT_INSTALLED"] = "kein GGR installiert"

L["SCAN_RESULTS"] = "Ergebnisse der Untersuchung"
L["SCAN_STARTED"] = "Suche nach anderen Nutzern in der Gilde - bitte warte %s Sekunden..."
L["SCAN_ALREADY_RUNNING"] = "Suche l�uft schon, bitte warten."
L["SCAN_COMPLETED"] = "%i Mitglieder wurden untersucht."

-- Debugging tab.
L["DEBUGGING_LEVEL"] = "Stufe der Fehlersuche"
L["DEBUGGING_LEVEL_DESC"] = "Bestimmt welche Meldungen im Protokolldatei-Bereich angezeigt werden. F�r die beste Leistung, auf 'aus' setzen. "
L["DEBUGGING_LEVEL_0"] = "Aus"
L["DEBUGGING_LEVEL_1"] = "Fehler"
L["DEBUGGING_LEVEL_2"] = "Fehler und Warnung"
L["DEBUGGING_LEVEL_3"] = "Alles"

L["CLEAR_DEBUG_LOGS"] = "Protokoldatei bereinigen"
L["CLEAR_DEBUG_LOGS_DESC"] = "bereinigt die Protokoldatei."

L["DEBUG_LOGS"] = "Fehlersuche Protokoldatei"

-- Scanned character is cheating, definitely localize.
L["ALERT_MESSAGE_SELF"] = "Benutzt %s! F�r mehr Info: %s Oberfl�che"