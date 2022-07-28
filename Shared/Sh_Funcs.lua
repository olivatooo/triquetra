

function table_count(t)
    local count = 0
    for k, v in pairs(t) do count = count + 1 end
    return count
end

function IsValid(obj)
    if obj and obj:IsValid() then
      return true
    end
    return false
end