GuildGearRulesCache = GuildGearRules:NewModule("GuildGearRulesCache", "AceEvent-3.0")

function GuildGearRulesCache:Initialize(core)
    self.Core = core;
    self.Queue = {};
    self.Queue = GuildGearRulesTable:New{ };

    self:RegisterEvent("GET_ITEM_INFO_RECEIVED", "OnItemInfoReceived");

    self.Core:Log(tostring(self) .. " initialized.");
    return self;
end

function GuildGearRulesCache:Log(text, msgType)
    if (self.Core.db.profile.DebugCache) then
        self.Core:Log("Cache: " .. text, msgType)
    end
end

function GuildGearRulesCache:Update()
    -- Iterate backwards so items can be safely removed.
    for i = #self.Queue, 1, -1  do
        local item = self.Queue[i];
        if (item ~= nil) then
            if (item.Validate and item.Received) then
                if (time() - item.Received >= 1) then
                    -- Validate item two times.
                    self.Core.Inspector:ValidateItemAttributes(item.ItemID, item.Meta.ItemLink, item.Meta.SlotID, item.Meta.CharacterInfo);
                    self:Log("Checking " .. item.Meta.ItemLink .. ".");
                    item.TimesChecked = item.TimesChecked + 1
                    if (item.TimesChecked < 2) then
                        item.Received = time();
                    else
                        self.Queue:Remove(i);
                    end
                end
            else
                self.Queue:Remove(i);
            end
        end
    end
end

function GuildGearRulesCache:New(itemID, validate)
    local cacheItem = {
        ItemID = itemID, 
        Validate = validate or false,
        Received = nil,
        TimesChecked = 0,
        Meta = nil,
	}
    return cacheItem;
end

-- New item equipped, forget about last validation.
-- Without this, items can appear unequipped if they are unequipped and equipped quickly.
function GuildGearRulesCache:Cancel(characterInfo, slotID)
    -- Iterate backwards so items can be safely removed.
    for i = #self.Queue, 1, -1  do
        local item = self.Queue[i];
        if (item ~= nil) then
            if (item.Meta ~= nil and item.Meta.CharacterInfo ~= nil and item.Meta.SlotID ~= nil) then
                if (item.Meta.CharacterInfo == characterInfo and item.Meta.SlotID == slotID) then
                    self.Queue:Remove(i);
                end
            end
        end
    end
end

function GuildGearRulesCache:Load(itemID, cacheItem)
    -- Will be nil if not cached and start a GET_ITEM_INFO_RECEIVED request.
	local itemName = GetItemInfo(itemID);

    local isCached = itemName ~= nil;

    -- Add item to queue if is not cached or if we want to validate it.
    if (cacheItem ~= nil and (not isCached or cacheItem.Validate)) then
        if (cacheItem.Validate) then cacheItem.Received = time(); end
        self.Queue:Add(cacheItem);
        local index, cacheItem = self.Queue:Find("ItemID", itemID);
        if (self.Core.db.profile.DebugCache) then
            local ending = "was already cached.";
            if (not isCached) then
                local ending = "was not cached.";
            end
            self:Log("Adding " .. itemID .. " to queue, " .. ending);
        end
    end
end

function GuildGearRulesCache:OnItemInfoReceived(event, itemID, success)
    if (not success) then return; end
    local itemName = GetItemInfo(itemID);

    local indexes, cacheItems = self.Queue:FindAll("ItemID", itemID);
    for i = 1, #indexes do
        if (cacheItems[i].Validate) then
            cacheItems[i].Received = time();
        else
            -- If we don't want to validate it, remove directly.
            self.Queue:Remove(indexes[i]);
        end
    end

    if (#indexes > 0) then
        self:Log("Resolved " .. itemID .. ".");
    else
        if (itemName ~= nil) then
            self:Log("Received information on " .. itemName .. " (" .. itemID .. ").");
        else
            self:Log("Received information on " .. itemID .. ", could not get name.");
        end
    end
end