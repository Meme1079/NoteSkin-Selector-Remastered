local math = math

--- Rounds the number either up or down depending on the value.
--- It also specifies the amount of fraction digits it should keep. 
---@param num number The given number to round to.
---@param digits? number The amount of fraction digits it will keep.
---@return number
function math.round(num, digits)
     local mult = 10^(digits or 0)
     return math.floor(num * mult + 0.5) / mult
end

--- Check whether the given number is real or not. (I stole this code stole lmao)
---@param num number The given number or its equation to determin its validity.
---@return boolean
function math.isReal(num)
     return (type(num) == "number") and (num == num) and (math.abs(num) ~= math.huge)
end

return math