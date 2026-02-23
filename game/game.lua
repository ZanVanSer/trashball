-- Game State (Play State)
-- Main gameplay with paddle, ball, and blocks

local State = require("game.state")
local Paddle = require("game.paddle")
local Ball = require("game.ball")
local Block = require("game.block")
local LevelLoader = require("data.levels")
local BlockTypes = require("data.blocks")

local GamePlay = setmetatable({}, {__index = State})
GamePlay.__index = GamePlay

function GamePlay:new()
    local instance = State.new(self)
    
    -- Game objects
    instance.paddle = nil
    instance.ball = nil
    instance.blocks = {}
    
    -- Level data
    instance.levelData = nil
    instance.levelConfig = nil
    
    -- Game state
    instance.gameOver = false
    instance.victory = false
    instance.respawnTimer = 0
    instance.waitingForLaunch = true  -- Ball is on paddle, waiting to be launched
    
    -- Explosion effect
    instance.explosions = {}
    
    return instance
end

function GamePlay:enter()
    local game = require("main")
    
    -- Load level
    self.levelData = LevelLoader.loadLevel(game.currentLevel)
    self.levelConfig = self.levelData.config
    
    -- Create paddle
    self.paddle = Paddle:new(self.levelConfig.paddle)
    
    -- Create ball
    self.ball = Ball:new(self.levelConfig.ball)
    self.ball:resetToPaddle(self.paddle:getCenterX(), self.paddle:getTopY())
    
    -- Create blocks
    self.blocks = {}
    for _, blockData in ipairs(self.levelData.blocks) do
        local block = Block:new(blockData.x, blockData.y, blockData.width, blockData.height, blockData.type)
        table.insert(self.blocks, block)
    end
    
    -- Reset state
    self.gameOver = false
    self.victory = false
    self.respawnTimer = 0
    self.explosions = {}
    self.waitingForLaunch = true
end

function GamePlay:update(dt)
    if self.gameOver or self.victory then
        return
    end
    
    local game = require("main")
    
    -- Update paddle
    self.paddle:update(dt)
    
    -- Move ball with paddle if waiting for launch
    if self.waitingForLaunch then
        self.ball:resetToPaddle(self.paddle:getCenterX(), self.paddle:getTopY())
    end
    
    -- Update ball
    self.ball:update(dt)
    
    -- Update blocks
    for _, block in ipairs(self.blocks) do
        block:update(dt)
    end
    
    -- Update explosions
    for i = #self.explosions, 1, -1 do
        self.explosions[i].timer = self.explosions[i].timer - dt
        if self.explosions[i].timer <= 0 then
            table.remove(self.explosions, i)
        end
    end
    
    -- Check for ball-paddle collision
    self.ball:checkPaddleCollision(self.paddle)
    
    -- Check for ball-block collisions
    for _, block in ipairs(self.blocks) do
        if self.ball:checkBlockCollision(block) then
            local destroyed = block:hit()
            
            if destroyed then
                -- Add score
                game.score = game.score + block.type.scoreValue
                
                -- Handle special block effects
                self:handleBlockDestruction(block)
                
                -- Check victory
                self:checkVictory()
            end
        end
    end
    
    -- Check for life loss: ball dropped below screen
    -- Ball marks itself inactive when it goes past the bottom edge.
    if not self.waitingForLaunch and self.respawnTimer <= 0 and not self.ball:isActive() then
        self:handleLifeLost()
    end
    
    -- Check for respawn
    if self.respawnTimer > 0 then
        self.respawnTimer = self.respawnTimer - dt
        if self.respawnTimer <= 0 then
            self:respawnBall()
        end
    end
end

function GamePlay:handleBlockDestruction(block)
    local typeId = block.type.id
    
    -- Bonus block gives extra life
    if typeId == "bonus" and block.type.bonusType == "life" then
        local game = require("main")
        game.lives = math.min(game.lives + 1, game.MAX_LIVES)
    end
    
    -- Points block gives extra points
    if typeId == "points" and block.type.bonusType == "points" then
        local game = require("main")
        game.score = game.score + block.type.bonusValue
    end
    
    -- Explosive block destroys nearby blocks
    if typeId == "explosive" then
        self:triggerExplosion(block)
    end
end

function GamePlay:triggerExplosion(explosiveBlock)
    -- Get grid position
    local blockConfig = self.levelConfig.block
    local offsetX = blockConfig.offsetX
    local offsetY = blockConfig.offsetY
    local spacingX = blockConfig.width + blockConfig.padding
    local spacingY = blockConfig.height + blockConfig.padding
    
    local centerX = explosiveBlock:getCenterX()
    local centerY = explosiveBlock:getCenterY()
    local radius = (explosiveBlock.type.explosionRadius or 2) * spacingX
    
    -- Add explosion effect
    table.insert(self.explosions, {
        x = centerX,
        y = centerY,
        radius = radius,
        timer = 0.3,
    })
    
    -- Destroy nearby blocks
    for _, block in ipairs(self.blocks) do
        if not block.destroyed and block ~= explosiveBlock then
            local bx = block:getCenterX()
            local by = block:getCenterY()
            local dist = math.sqrt((bx - centerX)^2 + (by - centerY)^2)
            
            if dist <= radius then
                block.destroyed = true
                local game = require("main")
                game.score = game.score + block.type.scoreValue
                self:handleBlockDestruction(block)
            end
        end
    end
    
    explosiveBlock.destroyed = true
end

function GamePlay:handleLifeLost()
    local game = require("main")
    game.lives = game.lives - 1
    
    if game.lives <= 0 then
        self.gameOver = true
        game:switchState("defeat")
    else
        self.respawnTimer = 1.5 -- 1.5 seconds before respawn
    end
end

function GamePlay:respawnBall()
    self.ball:resetToPaddle(self.paddle:getCenterX(), self.paddle:getTopY())
    self.waitingForLaunch = true
end

function GamePlay:checkVictory()
    local allDestroyed = true
    for _, block in ipairs(self.blocks) do
        if not block.destroyed then
            allDestroyed = false
            break
        end
    end
    
    if allDestroyed then
        self.victory = true
        local game = require("main")
        game:switchState("victory")
    end
end

function GamePlay:draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Draw blocks
    for _, block in ipairs(self.blocks) do
        block:draw()
    end
    
    -- Draw paddle
    self.paddle:draw()
    
    -- Draw ball
    self.ball:draw()
    
    -- Draw explosions
    for _, explosion in ipairs(self.explosions) do
        love.graphics.setColor(1, 0.5, 0, 0.5)
        love.graphics.circle("fill", explosion.x, explosion.y, explosion.radius)
        love.graphics.setColor(1, 0.8, 0, 0.8)
        love.graphics.circle("fill", explosion.x, explosion.y, explosion.radius * 0.7)
    end
    
    -- Draw UI
    self:drawUI()
    
    -- Draw respawn message
    if self.respawnTimer > 0 then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setNewFont(24)
        local text = "Get Ready!"
        local textWidth = love.graphics.getFont():getWidth(text)
        love.graphics.print(text, 400 - textWidth / 2, 300)
    end
end

function GamePlay:drawUI()
    local game = require("main")
    
    -- Score
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setNewFont(20)
    love.graphics.print("Score: " .. game.score, 20, 20)
    
    -- Lives
    love.graphics.print("Lives: " .. game.lives, 20, 50)
    
    -- Level
    love.graphics.print("Level: " .. game.currentLevel, 20, 80)
end

function GamePlay:keypressed(key, scancode, isrepeat)
    if key == "left" or key == "a" or key == "A" then
        self.paddle:moveLeftStart()
    elseif key == "right" or key == "d" or key == "D" then
        self.paddle:moveRightStart()
    elseif key == "space" then
        if self.waitingForLaunch then
            self.ball:launch()
            self.waitingForLaunch = false
        end
    elseif key == "escape" then
        local game = require("main")
        game:switchState("menu")
    end
end

function GamePlay:keyreleased(key, scancode)
    if key == "left" or key == "a" or key == "A" then
        self.paddle:moveLeftStop()
    elseif key == "right" or key == "d" or key == "D" then
        self.paddle:moveRightStop()
    end
end

return GamePlay
