local L = LibStub("AceLocale-3.0"):GetLocale("GuildGearRules");
local _cstr = string.format;

local Core = GuildGearRules;
local Network;

GuildGearRulesCharacter = { };

function GuildGearRulesCharacter:SetPointers()
    Network = Core:GetModule("GuildGearRulesNetwork");
end

function GuildGearRulesCharacter:New(characterInfo)
    local newCharacter = {
        GUID = characterInfo.GUID,
        UID = characterInfo.UID,
        Name = characterInfo.Name,
        Level = characterInfo.Level,
        ClassID = characterInfo.ClassID,
        HasAlerted = false,
        LastSendTime = time(),
        LastSendMessage = nil,
        Data = GuildGearRulesTable:New{ },
	};

    setmetatable(newCharacter, {__index = GuildGearRulesCharacter});
    return newCharacter;
end

function GuildGearRulesCharacter:GetDataByGUID(guid)
    for key, data in pairs(self.Data) do
        if (data.Capturer.GUID == guid) then
            return data;
        end
    end
    return nil;
end

function GuildGearRulesCharacter:HasCheatedDataCount()
    local count = 0;
    for key, data in pairs(self.Data) do
        if (data.HasCheated) then
            count = count + 1;
        end
    end
    return count;
end

function GuildGearRulesCharacter:CheatingDataCount()
    local count = 0;
    for key, data in pairs(self.Data) do
        if (data:IsCheating()) then
            count = count + 1;
        end
    end
    return count;
end

function GuildGearRulesCharacter:GetData(capturer)
    local data = self:GetDataByGUID(capturer.GUID);
    if (data ~= nil) then
        return data;
    end

    -- No data exists for this capturer, create one.
    data = GuildGearRulesCharacterData:New(self, capturer);
    self.Data:Add(data);
    return data;
end

function GuildGearRulesCharacter:DataUpdated(data)
    -- If this is client origin scan data, set flag to potentially send data.
    if (data.Capturer.GUID == Core.Player.GUID) then
        self.HasUpdate = true;
    end

    if (self:CheatingDataCount() == 0) then
        if (self.HasAlerted) then
            Core.Inspector:AlertStopped(self.Name, self.ClassID, nil);

            if (Core.Player.GUID == self.GUID) then
                SendChatMessage(Core.Constants.MessagePrefix .. _cstr(L["ALERT_MESSAGE_GUILD_CHAT_ENDED"], Core.ViewCheatersCommand), "PARTY");
            end
        end
        -- Not breaking rules, reset alert to fire again.
        self.HasAlerted = false;
    end
end


function GuildGearRulesCharacter:RemoveData(capturer)
    for index, data in pairs(self.Data) do
        if (data.Capturer.GUID == capturer.GUID) then
            self.Data:Remove(index);
            return;
        end
    end

    Core.UI:UpdateCharacterView();
end

function GuildGearRulesCharacter:GetLastSendTime()
    -- If has no update, then this should not be considered for transmission.
    local data = self:GetData(Core.Player);
    if (not self.HasUpdate or data == nil) then return nil; end
    return self.LastSendTime;
end

function GuildGearRulesCharacter:SendData()
    if (self:GetLastSendTime() ~= nil) then
        local data = self:GetData(Core.Player);
        if (data ~= nil and data.HasCheated) then
            return data:Send();
        end
    end
    return false;
end