local L = LibStub("AceLocale-3.0"):GetLocale("GuildGearRules");
local _cstr = string.format;

GuildGearRulesCharacterData = { };
local Core = GuildGearRules;

local BooleanToNumber = { 
    [true] = 1, 
    [false] = 0, 
};

local NumberToBoolean = { 
    [1] = true,
    [0] = false, 
};

function GuildGearRulesCharacterData:Log(text, msgType)
    if (Core.db.profile.DebugData) then
        Core:Log("Data: " .. text, msgType)
    end
end

function GuildGearRulesCharacterData:New(character, capturer)
    local newCheater = {
        HasCheated = false,
        Character = character,
        Capturer = capturer,
        Buffs = GuildGearRulesTable:New{ },
        Items = GuildGearRulesTable:New{ },
	};
    
    setmetatable(newCheater, {__index = GuildGearRulesCharacterData});
    return newCheater;
end

function GuildGearRulesCharacterData:Clear()
    self.Buffs = GuildGearRulesTable:New{ };
    self.Items = GuildGearRulesTable:New{ };
end

function GuildGearRulesCharacterData:IsCheating()
    local equippedCount = 0;
    for key, item in pairs(self.Items) do
        if (item.Equipped) then
            equippedCount = equippedCount + 1;
        end
    end

    local activeBuffs = 0;
    for key, buff in pairs(self.Buffs) do
        if (buff.Active) then
            activeBuffs = activeBuffs + 1;
        end
    end
    return (equippedCount > Core.Rules.Items.ExceptionsAllowed or activeBuffs > 0);
end

function GuildGearRulesCharacterData:ClearBuffs()
    for key, buff in pairs(self.Buffs) do
        buff.Active = false;
    end
end

function GuildGearRulesCharacterData:BuffsUpdated()
    self.Character:DataUpdated(self);
end

function GuildGearRulesCharacterData:ClearItemSlot(slot)
    for index, item in pairs(self.Items) do
        if (item.SlotID == slot and item.Equipped) then
            item.Equipped = false
            self:Log("Unequipped item previously on slot " .. slot .. " for " .. self.Character.Name .. ", " .. item.Link .. ".")
            self.Character:DataUpdated(self);
            break;
        end
    end
end

function GuildGearRulesCharacterData:NewBuff(spellID)
    local index, buff = self.Buffs:ContainsElement("SpellID", spellID);
    -- Buff exists, only update time.
    if (index ~= nil) then
        buff.Active = true;
        buff.Time = date("%H:%M:%S");
    -- Buff doesn't exist, create it.
    else
        local buff = {
            SpellID = spellID,
            Active = true,
            Time = date("%H:%M:%S"),
	    };
        self.Buffs:Add(buff);
    end

    self:OnUpdate(nil, spellID);
end

function GuildGearRulesCharacterData:NewItem(itemID, itemLink, slot, equipped)
    -- Check if item exists unequipped, equip it again.
    local itemExists = false;
    for index, item in pairs(self.Items) do
        if (item.SlotID == slot and item.ID == itemID and item.Link == itemLink) then

            item.Time = date("%H:%M:%S");
            -- Item exists unequipped, equip it again.
            if (not item.Equipped) then
                self:Log("Re-equipping item previously on slot " .. slot .. " for " .. self.Character.Name .. ", " .. item.Link .. ".")
                item.Equipped = true;
            end

            itemExists = true;
            break;
        end
    end

    if (not itemExists) then
        -- Unequip item previously on this slot.
        self:ClearItemSlot(slot);
        self:Log("Adding new item on slot " .. slot .. " for " .. self.Character.Name .. ", " .. itemLink .. ".")

        local item = {
            ID = itemID,
            Link = itemLink,
            SlotID = slot,
            Equipped = equipped,
            Time = date("%H:%M:%S")
	    };
        self.Items:Add(item);
    end

    self:OnUpdate(itemLink, nil);
end

function GuildGearRulesCharacterData:OnUpdate(itemLink, spellID)
    if (self:IsCheating()) then
        self.HasCheated = true;
        -- Alert the first time seen cheating.
        if (not self.Character.HasAlerted) then           
            self.Character.HasAlerted = true;

            local bannedThingSelf = itemLink;
            local bannedThingSend = itemLink;
            -- Since colors cannot be sent in messages apart from links, we have to parse buffs specifically.
            if (itemLink == nil) then
                bannedThingSelf = Core.UI:Buff(spellID);
                local name = GetSpellInfo(spellID);
                bannedThingSend = "[" .. name .. "]";
            end

            -- Announce self is cheating in guildchat to tell non-addOn users too.
            if (Core.Player.GUID == self.Character.GUID) then
                SendChatMessage(Core.Constants.MessagePrefix .. _cstr(L["ALERT_MESSAGE_GUILD_CHAT_START"], bannedThingSend), Core.AnnounceChannel);
            end
            
            Core.Inspector:Alert(self.Character.Name, self.Character.ClassID, bannedThingSelf, self.Capturer);
        end
    end

    self.Character:DataUpdated(self);
end

function GuildGearRulesCharacterData:Send()
    -- Dont send data not captured by this client.
    if (self.Capturer.GUID ~= Core.Player.GUID) then return; end

    local data = self.Character.UID .. "&";

    -- Separate values by dot since commas can occur in items names, e.g. [Lok'delar, Stave of the Ancient Keepers].
    for key, item in ipairs(self.Items) do
        data = data .. item.Link .. "." .. item.ID .. "." .. BooleanToNumber[item.Equipped] .. "." .. item.SlotID .. ".";
    end
    data = data .. "&";
    for key, buff in ipairs(self.Buffs) do
        data = data .. buff.SpellID .. ".";
    end

    self.Character.HasUpdate = false;

    if (self.Character.LastSendMessage ~= data) then
        Core.Network:Send("05", data, "GUILD");

        self.Character.LastSendTime = time();
        self.Character.LastSendMessage = data;
        return true;
    end
    return false;
end

function GuildGearRulesCharacterData:Read(message)
    self:Clear();
    self.HasCheated = true;

    local itemData = string.match(message, "(.+)&");
    local buffData = string.match(message, "&([%d,]+)");

    if (itemData ~= nil and itemData:len() > 0) then
        local index = 0;
        local itemID, itemLink, slotID, equipped = nil;
        for arg in itemData:gmatch('[^%.]+') do
            if (index == 0) then itemLink = arg;
            elseif (index == 1) then itemID = tonumber(arg);
            elseif (index == 2) then equipped = NumberToBoolean[tonumber(arg)];
            elseif (index == 3) then slotID = tonumber(arg);
                self:NewItem(itemID, itemLink, slotID, equipped);
                index = -1;
            end
            index = index + 1;
        end
    end
    if (buffData ~= nil and buffData:len() > 0) then
        local index = 0;
        local spellID = nil;
        for arg in buffData:gmatch('[^%.]+') do
            if (index == 0) then spellID = tonumber(arg);
                self:NewBuff(spellID);
                index = -1;
            end
            index = index + 1;
        end
    end

    -- Call this to allow the cheating stop alert to play.
    self.Character:DataUpdated(self);
end