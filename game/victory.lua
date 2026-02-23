-- Victory State
-- Displayed when player wins the game

local State = require("game.state")

local Victory = setmetatable({}, {__index = State})
Victory.__index = Victory

function Victory:new()
    local instance = State.new(self)
    instance.timer = 0
    return instance
end

function Victory:enter()
    self.timer = 0
end

function Victory:update(dt)
    self.timer = self.timer + dt
end

function Victory:draw()
    -- Background with celebration color
    love.graphics.setColor(0.1, 0.2, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Victory text
    love.graphics.setColor(0.2, 0.8, 0.2, 1)
    love.graphics.setNewFont(56)
    local titleWidth = love.graphics.getFont():getWidth("VICTORY!")
    love.graphics.print("VICTORY!", 400 - titleWidth / 2, 200)
    
    -- Score
    local game = require("main")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setNewFont(28)
    local scoreText = "Final Score: " .. game.score
    local scoreWidth = love.graphics.getFont():getWidth(scoreText)
    love.graphics.print(scoreText, 400 - scoreWidth / 2, 300)
    
    -- Lives bonus
    local bonus = game.lives * 100
    if bonus > 0 then
        love.graphics.setColor(0.8, 0.8, 0.2, 1)
        love.graphics.setNewFont(20)
        local bonusText = "Lives Bonus: " .. bonus
        local bonusWidth = love.graphics.getFont():getWidth(bonusText)
        love.graphics.print(bonusText, 400 - bonusWidth / 2, 350)
    end
    
    -- Instructions
    love.graphics.setColor(0.5, 0.5, 0.6, 1)
    love.graphics.setNewFont(18)
    local instructionText = "Press ENTER to play again, ESC to return to menu"
    local instructionWidth = love.graphics.getFont():getWidth(instructionText)
    love.graphics.print(instructionText, 400 - instructionWidth / 2, 450)
    
    -- Animated stars
    self:drawStars()
end

function Victory:drawStars()
    love.graphics.setColor(1, 1, 0.5, 1)
    local time = self.timer * 2
    
    for i = 1, 20 do
        local x = (i * 73 + time * 50) % 800
        local y = (i * 47 + math.sin(time + i) * 20) % 600
        local size = 2 + (math.sin(time * 3 + i) + 1)
        love.graphics.circle("fill", x, y, size)
    end
end

function Victory:keypressed(key, scancode, isrepeat)
    local game = require("main")
    
    if key == "return" or key == "enter" then
        game:resetGame()
        game:switchState("play")
    elseif key == "escape" then
        game:switchState("menu")
    end
end

return Victory
