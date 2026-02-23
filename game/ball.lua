-- Ball Class
-- Ball with physics for bouncing off walls, paddle, and blocks

local Ball = {}
Ball.__index = Ball

function Ball:new(config)
    local instance = setmetatable({}, self)
    
    -- Default configuration
    instance.x = 400
    instance.y = 500
    instance.radius = config.radius or 8
    instance.speed = config.speed or 300
    instance.startAngle = config.startAngle or -math.pi / 2
    
    -- Velocity
    instance.vx = 0
    instance.vy = 0
    
    -- State
    instance.active = false -- Not moving until launched
    instance.launched = false
    
    -- Game bounds
    instance.minX = instance.radius
    instance.maxX = 800 - instance.radius
    instance.minY = instance.radius
    instance.maxY = 600 - instance.radius
    
    return instance
end

-- Launch the ball
function Ball:launch()
    if not self.launched then
        local angle = self.startAngle
        self.vx = math.cos(angle) * self.speed
        self.vy = math.sin(angle) * self.speed
        self.launched = true
        self.active = true
    end
end

-- Reset ball to paddle position
function Ball:resetToPaddle(paddleX, paddleY)
    self.x = paddleX
    self.y = paddleY - self.radius - 2
    self.vx = 0
    self.vy = 0
    self.active = false
    self.launched = false
end

-- Update ball position
function Ball:update(dt)
    if not self.active then
        return
    end
    
    -- Move ball
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    
    -- Wall collisions
    self:checkWallCollisions()
end

-- Check and handle wall collisions
function Ball:checkWallCollisions()
    -- Left wall
    if self.x < self.minX then
        self.x = self.minX
        self.vx = -self.vx
    end
    
    -- Right wall
    if self.x > self.maxX then
        self.x = self.maxX
        self.vx = -self.vx
    end
    
    -- Top wall
    if self.y < self.minY then
        self.y = self.minY
        self.vy = -self.vy
    end
    
    -- Bottom (ball lost)
    if self.y > self.maxY then
        self.active = false
        self.launched = false
    end
end

-- Check paddle collision
function Ball:checkPaddleCollision(paddle)
    if not self.active then
        return false
    end
    
    -- Simple AABB collision with circle
    local closestX = math.max(paddle.x, math.min(self.x, paddle.x + paddle.width))
    local closestY = math.max(paddle.y, math.min(self.y, paddle.y + paddle.height))
    
    local distanceX = self.x - closestX
    local distanceY = self.y - closestY
    local distanceSquared = distanceX * distanceX + distanceY * distanceY
    
    if distanceSquared < self.radius * self.radius then
        -- Collision detected - reflect ball
        self:reflectOnPaddle(paddle)
        return true
    end
    
    return false
end

-- Reflect ball off paddle with angle based on hit position
function Ball:reflectOnPaddle(paddle)
    -- Calculate hit position (-1 to 1)
    local hitPos = (self.x - (paddle.x + paddle.width / 2)) / (paddle.width / 2)
    
    -- Clamp hit position
    hitPos = math.max(-1, math.min(1, hitPos))
    
    -- Calculate reflection angle (between -60 and 60 degrees from vertical)
    local maxAngle = math.pi / 3 -- 60 degrees
    local angle = hitPos * maxAngle
    
    -- Set new velocity
    local currentSpeed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
    self.vx = math.sin(angle) * currentSpeed
    self.vy = -math.cos(angle) * currentSpeed
    
    -- Ensure ball is moving upward
    if self.vy > 0 then
        self.vy = -self.vy
    end
    
    -- Position ball above paddle
    self.y = paddle.y - self.radius - 1
end

-- Check block collision
function Ball:checkBlockCollision(block)
    if not self.active or block.destroyed then
        return false
    end
    
    -- Simple AABB collision with circle
    local closestX = math.max(block.x, math.min(self.x, block.x + block.width))
    local closestY = math.max(block.y, math.min(self.y, block.y + block.height))
    
    local distanceX = self.x - closestX
    local distanceY = self.y - closestY
    local distanceSquared = distanceX * distanceX + distanceY * distanceY
    
    if distanceSquared < self.radius * self.radius then
        -- Collision detected - determine reflection direction
        self:reflectOnBlock(block, closestX, closestY)
        return true
    end
    
    return false
end

-- Reflect ball off block
function Ball:reflectOnBlock(block, closestX, closestY)
    -- Determine which side was hit
    local dx = self.x - closestX
    local dy = self.y - closestY
    
    if math.abs(dx) > math.abs(dy) then
        -- Hit left or right side
        self.vx = -self.vx
    else
        -- Hit top or bottom
        self.vy = -self.vy
    end
    
    -- Position ball outside block to prevent multiple collisions
    if dx > 0 then
        self.x = block.x + block.width + self.radius
    elseif dx < 0 then
        self.x = block.x - self.radius
    end
    
    if dy > 0 then
        self.y = block.y + block.height + self.radius
    elseif dy < 0 then
        self.y = block.y - self.radius
    end
end

-- Draw the ball
function Ball:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

-- Check if ball is active (for life loss)
function Ball:isActive()
    return self.active
end

-- Check if ball is launched
function Ball:isLaunched()
    return self.launched
end

-- Get Y position for death check
function Ball:getY()
    return self.y
end

-- Add speed (for bonus or difficulty)
function Ball:addSpeed(amount)
    local currentSpeed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
    local newSpeed = currentSpeed + amount
    local angle = math.atan2(self.vy, self.vx)
    self.vx = math.cos(angle) * newSpeed
    self.vy = math.sin(angle) * newSpeed
end

return Ball
