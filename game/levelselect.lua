-- Level Selector State
-- Allows player to select a level before starting the game

local State = require("game.state")
local LevelSelect = setmetatable({}, {__index = State})
LevelSelect.__index = LevelSelect

-- Available levels
LevelSelect.levels = {
    {
        id = 1,
        name = "Level 1",
        description = "Beginner",
    },
    {
        id = 2,
        name = "Level 2",
        description = "Intermediate",
    },
    {
        id = 3,
        name = "Level 3",
        description = "Advanced",
    },
}

function LevelSelect:new()
    local instance = State.new(self)
    
    instance.buttons = {}
    instance.titleY = 80
    instance.titleTargetY = 80
    
    -- Create level buttons
    local startY = 200
    local spacing = 80
    
    for i, level in ipairs(LevelSelect.levels) do
        table.insert(instance.buttons, {
            text = level.name,
            subtext = level.description,
            x = 250,
            y = startY + (i - 1) * spacing,
            width = 300,
            height = 60,
            hover = false,
            levelId = level.id,
        })
    end
    
    -- Back button
    table.insert(instance.buttons, {
        text = "Back",
        x = 300,
        y = startY + #LevelSelect.levels * spacing + 30,
        width = 200,
        height = 50,
        hover = false,
        action = "back",
    })
    
    return instance
end

function LevelSelect:enter()
    -- Reset animation
    self.titleY = -50
    self.titleTargetY = 80
end

function LevelSelect:update(dt)
    -- Animate title
    self.titleY = self.titleY + (self.titleTargetY - self.titleY) * 5 * dt
    
    -- Check button hover
    local mouseX, mouseY = love.mouse.getPosition()
    
    for _, button in ipairs(self.buttons) do
        button.hover = mouseX >= button.x and mouseX <= button.x + button.width
                   and mouseY >= button.y and mouseY <= button.y + button.height
    end
end

function LevelSelect:draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Title
    love.graphics.setColor(0.3, 0.7, 1, 1)
    love.graphics.setNewFont(36)
    local titleWidth = love.graphics.getFont():getWidth("Select Level")
    love.graphics.print("Select Level", 400 - titleWidth / 2, self.titleY)
    
    -- Draw buttons
    for _, button in ipairs(self.buttons) do
        self:drawButton(button)
    end
    
    -- Instructions
    love.graphics.setColor(0.4, 0.4, 0.5, 1)
    love.graphics.setNewFont(14)
    local instructionWidth = love.graphics.getFont():getWidth("Click on a level to start playing")
    love.graphics.print("Click on a level to start playing", 
                       400 - instructionWidth / 2, 550)
end

function LevelSelect:drawButton(button)
    local r, g, b
    
    if button.hover then
        r, g, b = 0.3, 0.6, 0.9
    else
        r, g, b = 0.2, 0.4, 0.6
    end
    
    -- Button background
    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
    
    -- Button border
    love.graphics.setColor(r + 0.2, g + 0.2, b + 0.2, 1)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
    
    -- Button text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setNewFont(22)
    local textWidth = love.graphics.getFont():getWidth(button.text)
    love.graphics.print(button.text, button.x + (button.width - textWidth) / 2, 
                       button.y + 10)
    
    -- Subtext (if exists)
    if button.subtext then
        love.graphics.setColor(0.8, 0.8, 0.9, 1)
        love.graphics.setNewFont(14)
        local subtextWidth = love.graphics.getFont():getWidth(button.subtext)
        love.graphics.print(button.subtext, button.x + (button.width - subtextWidth) / 2, 
                           button.y + 35)
    end
end

function LevelSelect:mousepressed(x, y, button, istouch, presses)
    for _, btn in ipairs(self.buttons) do
        if btn.hover then
            if btn.action == "back" then
                -- Go back to menu
                local game = require("main")
                game:switchState("menu")
            elseif btn.levelId then
                -- Start game with selected level
                local game = require("main")
                game:resetGame()
                game.currentLevel = btn.levelId
                game:switchState("play")
            end
            break
        end
    end
end

function LevelSelect:keypressed(key, scancode, isrepeat)
    -- Allow Escape to go back to menu
    if key == "escape" then
        local game = require("main")
        game:switchState("menu")
    end
    
    -- Allow number keys to select level
    if key == "1" or key == "2" or key == "3" then
        local levelNum = tonumber(key)
        local game = require("main")
        game:resetGame()
        game.currentLevel = levelNum
        game:switchState("play")
    end
end

return LevelSelect
