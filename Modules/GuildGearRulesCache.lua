GuildGearRulesCache = GuildGearRules:NewModule("GuildGearRulesCache", "AceEvent-3.0")

function GuildGearRulesCache:Initialize(core)
    self.Core = core
    self.Queue = {}
    self.Queue.Insert = tinsert

    self:RegisterEvent("GET_ITEM_INFO_RECEIVED", "OnItemInfoReceived");
end

function GuildGearRulesCache:Log(text, msgType)
    if (self.Core.db.profile.DebugCache) then
        self.Core:Log("Cache: " .. text, msgType)
    end
end

function GuildGearRulesCache:Update()
    -- Iterate backwards so can we safely remove items.
    for i = #self.Queue, 1, -1  do
        local item = self.Queue[i];
        if (item ~= nil) then
            if (item.Validate and item.Received) then
                if (time() - item.Received >= 1) then
                    -- Validate item two times.
                    self.Core.Inspector:HasIllegalAttributes(item.ItemID, item.Meta.ItemLink, item.Meta.SlotID, item.Meta.CharacterInfo);
                    item.TimesChecked = item.TimesChecked + 1
                    if (item.TimesChecked < 2) then
                        item.Received = time();
                    else
                        table.remove(self.Queue, i);
                    end
                end
            else
                table.remove(self.Queue, i);
            end
        end
    end
end

function GuildGearRulesCache:New(itemID, validate, onReceive, meta)
    local cacheItem = {
        ItemID = itemID, 
        Validate = validate or false,
        Received = nil,
        TimesChecked = 0,
        Meta = meta,
	}
    return cacheItem;
end

function GuildGearRulesCache:Load(itemID, cacheItem)
    -- Will be nil if not cached and start a GET_ITEM_INFO_RECEIVED request.
	local itemName = GetItemInfo(itemID);

    local isCached = itemName ~= nil;

    -- Add item to queue if is not cached or if we want to validate it.
    if (cacheItem ~= nil and (not isCached or cacheItem.Validate)) then
        if (cacheItem.Validate) then cacheItem.Received = time(); end
        self.Queue:Insert(cacheItem);
        self:Log("Adding " .. itemID .. " to queue.");
    end
end

function GuildGearRulesCache:GetQueuedCacheItem(itemID)
    for i =1 , #self.Queue do
        local cacheItem = self.Queue[i];
        if (cacheItem.ItemID == itemID) then
            return i, cacheItem;
        end
    end
    return nil, nil;
end

function GuildGearRulesCache:OnItemInfoReceived(event, itemID, success)
    if (not success) then
        return;
    end
    local itemName = GetItemInfo(itemID)
    self:Log("Received item info on " .. itemName .. ".");

    local index, cacheItem = self:GetQueuedCacheItem(itemID);
    -- Array contains received item.
    if (cacheItem ~= nil) then
        self:Log("Resolved " .. itemID .. ".");
        if (cacheItem.Validate) then
            cacheItem.Received = time();
        else
            -- If we don't want to validate it, remove directly.
            table.remove(self.Queue, index);
        end
    else
        self:Log("Could not resolve " .. itemID .. ".");
    end
end