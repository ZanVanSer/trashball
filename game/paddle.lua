-- Paddle Class
-- Player-controlled paddle for hitting the ball

local Paddle = {}
Paddle.__index = Paddle

function Paddle:new(config)
    local instance = setmetatable({}, self)
    
    -- Default configuration
    instance.x = 350
    instance.y = config.y or 550
    instance.width = config.width or 100
    instance.height = config.height or 15
    instance.speed = config.speed or 400
    
    -- Movement state
    instance.moveLeft = false
    instance.moveRight = false
    
    -- Game bounds
    instance.minX = 0
    instance.maxX = 800 - instance.width
    
    return instance
end

-- Update paddle position
function Paddle:update(dt)
    local movement = 0
    
    if self.moveLeft then
        movement = movement - self.speed
    end
    if self.moveRight then
        movement = movement + self.speed
    end
    
    self.x = self.x + movement * dt
    
    -- Clamp to screen bounds
    if self.x < self.minX then
        self.x = self.minX
    elseif self.x > self.maxX then
        self.x = self.maxX
    end
end

-- Draw the paddle
function Paddle:draw()
    love.graphics.setColor(0.3, 0.7, 0.9, 1) -- Light blue
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Add a highlight on top
    love.graphics.setColor(0.5, 0.8, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, 3)
end

-- Start moving left
function Paddle:moveLeftStart()
    self.moveLeft = true
end

-- Stop moving left
function Paddle:moveLeftStop()
    self.moveLeft = false
end

-- Start moving right
function Paddle:moveRightStart()
    self.moveRight = true
end

-- Stop moving right
function Paddle:moveRightStop()
    self.moveRight = false
end

-- Get center X position (for ball spawn)
function Paddle:getCenterX()
    return self.x + self.width / 2
end

-- Get top Y position (for ball spawn)
function Paddle:getTopY()
    return self.y
end

-- Reset paddle position
function Paddle:reset(centerX)
    self.x = centerX - self.width / 2
end

return Paddle
