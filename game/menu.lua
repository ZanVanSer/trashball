-- Menu State
-- Main menu with New Game and Exit buttons

local State = require("game.state")
local Menu = setmetatable({}, {__index = State})
Menu.__index = Menu

-- Button definitions
Menu.buttons = {}

function Menu:new()
    local instance = State.new(self)
    
    instance.buttons = {
        {
            text = "New Game",
            x = 300,
            y = 250,
            width = 200,
            height = 50,
            hover = false,
            action = function()
                local game = require("main")
                game:switchState("levelselect")
            end
        },
        {
            text = "Exit",
            x = 300,
            y = 320,
            width = 200,
            height = 50,
            hover = false,
            action = function()
                love.event.quit()
            end
        }
    }
    
    instance.titleY = 100
    instance.titleTargetY = 100
    
    return instance
end

function Menu:enter()
    -- Reset animation
    self.titleY = -50
    self.titleTargetY = 100
end

function Menu:update(dt)
    -- Animate title
    self.titleY = self.titleY + (self.titleTargetY - self.titleY) * 5 * dt
    
    -- Check button hover
    local mouseX, mouseY = love.mouse.getPosition()
    
    for _, button in ipairs(self.buttons) do
        button.hover = mouseX >= button.x and mouseX <= button.x + button.width
                   and mouseY >= button.y and mouseY <= button.y + button.height
    end
end

function Menu:draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Title
    love.graphics.setColor(0.3, 0.7, 1, 1)
    love.graphics.setNewFont(48)
    local titleWidth = love.graphics.getFont():getWidth("Trashball")
    
    -- NES-style border around title
    local borderPadding = 50
    local borderX = 400 - titleWidth / 2 - borderPadding
    local borderY = self.titleY - borderPadding
    local borderWidth = titleWidth + borderPadding * 2
    local borderHeight = love.graphics.getFont():getHeight() + borderPadding * 2
    
    -- Draw border (outer rectangle)
    love.graphics.setColor(0.8, 0.2, 0.2, 1)  -- Red border like NES
    love.graphics.rectangle("line", borderX - 2, borderY - 2, borderWidth + 4, borderHeight + 4)
    love.graphics.rectangle("line", borderX - 1, borderY - 1, borderWidth + 2, borderHeight + 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", borderX, borderY, borderWidth, borderHeight)
    
    -- Draw title
    love.graphics.setColor(0.3, 0.7, 1, 1)
    love.graphics.print("Trashball", 400 - titleWidth / 2, self.titleY)
    
    -- Subtitle
    love.graphics.setColor(0.5, 0.5, 0.6, 1)
    love.graphics.setNewFont(18)
    local subtitleWidth = love.graphics.getFont():getWidth("Destroy all blocks to win!")
    love.graphics.print("Destroy all blocks to win!", 400 - subtitleWidth / 2, self.titleY + 50)
    
    -- Draw buttons
    for _, button in ipairs(self.buttons) do
        self:drawButton(button)
    end
    
    -- Instructions
    love.graphics.setColor(0.4, 0.4, 0.5, 1)
    love.graphics.setNewFont(14)
    local instructionWidth = love.graphics.getFont():getWidth("Use LEFT/RIGHT arrows or A/D to move, SPACE to launch")
    love.graphics.print("Use LEFT/RIGHT arrows or A/D to move, SPACE to launch", 
                       400 - instructionWidth / 2, 500)
end

function Menu:drawButton(button)
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
    love.graphics.setNewFont(24)
    local textWidth = love.graphics.getFont():getWidth(button.text)
    love.graphics.print(button.text, button.x + (button.width - textWidth) / 2, 
                       button.y + (button.height - love.graphics.getFont():getHeight()) / 2)
end

function Menu:mousepressed(x, y, button, istouch, presses)
    for _, btn in ipairs(self.buttons) do
        if btn.hover and btn.action then
            btn.action()
            break
        end
    end
end

function Menu:keypressed(key, scancode, isrepeat)
    -- Allow Enter to go to level select
    if key == "return" or key == "enter" then
        local game = require("main")
        game:switchState("levelselect")
    end
    
    -- Allow Escape to quit
    if key == "escape" then
        love.event.quit()
    end
end

return Menu
