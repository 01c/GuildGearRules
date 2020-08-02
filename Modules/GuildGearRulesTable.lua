GuildGearRulesTable = { };
function GuildGearRulesTable:New(table)
    return setmetatable(table, {__index = GuildGearRulesTable})
end

function GuildGearRulesTable:Contains(val)
    for index, value in ipairs(self) do
        if (value == val) then
            return index;
        end
    end
end

function GuildGearRulesTable:ContainsElement(key, val)
    for index, table in pairs(self) do
        for innerIndex, innerValue in pairs(table) do
            if (innerIndex == key and innerValue == val) then
                return index, table;
            end
        end
    end
    return nil;
end

function GuildGearRulesTable:Add(val)
    table.insert(self, val);
end

function GuildGearRulesTable:Remove(id)
    table.remove(self, id);
end

function GuildGearRulesTable:Find(key, val)
    for index, table in pairs(self) do
        for innerIndex, innerValue in pairs(table) do
            if (innerIndex == key and innerValue == val) then
                return index, table;
            end
        end
    end
    return nil, nil;
end

function GuildGearRulesTable:FindAll(key, val)
    local indexes = { };
    local values = { };
    for index, table in pairs(self) do
        for innerIndex, innerValue in pairs(table) do
            if (innerIndex == key and innerValue == val) then
                table.insert(indexes, index);
                table.insert(values, innerValue);
            end
        end
    end
    return indexes, values;
end

function GuildGearRulesTable:RemoveByKey(key, val)
    for index, table in pairs(self) do
        for innerIndex, innerValue in pairs(table) do
            if (innerIndex == key and innerValue == val) then
                self:Remove(index);
                return true;
            end
        end
    end
    return false;
end