-- Block Class
-- Individual block that can be destroyed

local Block = {}
Block.__index = Block

function Block:new(x, y, width, height, blockType)
    local instance = setmetatable({}, self)
    
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.type = blockType
    instance.hitPoints = blockType.hitPoints
    instance.destroyed = false
    
    -- Visual properties
    instance.color = {unpack(blockType.color)}
    instance.flashTimer = 0
    
    return instance
end

-- Hit the block and return true if destroyed
function Block:hit()
    self.hitPoints = self.hitPoints - 1
    self.flashTimer = 0.1 -- Flash white briefly
    
    if self.hitPoints <= 0 then
        self.destroyed = true
        return true
    end
    
    return false
end

-- Update block (for animations)
function Block:update(dt)
    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
    end
end

-- Draw the block
function Block:draw()
    if self.destroyed then
        return
    end
    
    -- Flash white when hit
    if self.flashTimer > 0 then
        love.graphics.setColor(1, 1, 1, 1)
    else
        -- Darken based on remaining hit points
        local darken = self.hitPoints / self.type.hitPoints
        local r = self.color[1] * darken
        local g = self.color[2] * darken
        local b = self.color[3] * darken
        love.graphics.setColor(r, g, b, 1)
    end
    
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw cracks or details based on type
    self:drawDetails()
end

-- Draw block-specific details
function Block:drawDetails()
    local typeId = self.type.id
    
    if typeId == "explosive" then
        -- Draw explosion symbol
        love.graphics.setColor(1, 1, 0.5, 1)
        love.graphics.circle("fill", self.x + self.width / 2, self.y + self.height / 2, 4)
    elseif typeId == "bonus" then
        -- Draw heart symbol
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.circle("fill", self.x + self.width / 2, self.y + self.height / 2, 3)
    elseif typeId == "points" then
        -- Draw star symbol
        love.graphics.setColor(1, 1, 0.8, 1)
        love.graphics.circle("fill", self.x + self.width / 2, self.y + self.height / 2, 3)
    end
end

-- Get center position for explosion effect
function Block:getCenterX()
    return self.x + self.width / 2
end

function Block:getCenterY()
    return self.y + self.height / 2
end

-- Get grid position for explosive blocks
function Block:getGridPosition(blockConfig, offsetX, offsetY)
    local col = math.floor((self.x - offsetX) / (blockConfig.width + blockConfig.padding)) + 1
    local row = math.floor((self.y - offsetY) / (blockConfig.height + blockConfig.padding)) + 1
    return col, row
end

return Block
