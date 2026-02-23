-- Defeat State
-- Displayed when player loses all lives

local State = require("game.state")

local Defeat = setmetatable({}, {__index = State})
Defeat.__index = Defeat

function Defeat:new()
    local instance = State.new(self)
    instance.timer = 0
    return instance
end

function Defeat:enter()
    self.timer = 0
end

function Defeat:update(dt)
    self.timer = self.timer + dt
end

function Defeat:draw()
    -- Background with defeat color
    love.graphics.setColor(0.2, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Game Over text
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.setNewFont(56)
    local titleWidth = love.graphics.getFont():getWidth("GAME OVER")
    love.graphics.print("GAME OVER", 400 - titleWidth / 2, 200)
    
    -- Score
    local game = require("main")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setNewFont(28)
    local scoreText = "Final Score: " .. game.score
    local scoreWidth = love.graphics.getFont():getWidth(scoreText)
    love.graphics.print(scoreText, 400 - scoreWidth / 2, 300)
    
    -- Encouragement
    love.graphics.setColor(0.6, 0.6, 0.7, 1)
    love.graphics.setNewFont(18)
    local encouragementText = "Don't give up! Try again!"
    local encouragementWidth = love.graphics.getFont():getWidth(encouragementText)
    love.graphics.print(encouragementText, 400 - encouragementWidth / 2, 360)
    
    -- Instructions
    love.graphics.setColor(0.5, 0.5, 0.6, 1)
    love.graphics.setNewFont(18)
    local instructionText = "Press ENTER to try again, ESC to return to menu"
    local instructionWidth = love.graphics.getFont():getWidth(instructionText)
    love.graphics.print(instructionText, 400 - instructionWidth / 2, 450)
    
    -- Animated particles
    self:drawParticles()
end

function Defeat:drawParticles()
    local time = self.timer * 2
    
    for i = 1, 30 do
        local x = (i * 67 + time * 30) % 800
        local y = (i * 89 + math.cos(time + i * 0.5) * 30) % 600
        local r = 0.6 + math.sin(time + i) * 0.2
        local g = 0.2 + math.sin(time * 1.5 + i) * 0.1
        local b = 0.2
        love.graphics.setColor(r, g, b, 1)
        love.graphics.circle("fill", x, y, 3)
    end
end

function Defeat:keypressed(key, scancode, isrepeat)
    local game = require("main")
    
    if key == "return" or key == "enter" then
        game:resetGame()
        game:switchState("play")
    elseif key == "escape" then
        game:switchState("menu")
    end
end

return Defeat
