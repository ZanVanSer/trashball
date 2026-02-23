-- Base State Class
-- Used as a foundation for all game states

local State = {}
State.__index = State

function State:new()
    local instance = setmetatable({}, self)
    return instance
end

-- Called when entering this state
function State:enter()
end

-- Called when leaving this state
function State:leave()
end

-- Called every frame to update state
function State:update(dt)
end

-- Called every frame to draw state
function State:draw()
end

-- Called when a key is pressed
function State:keypressed(key, scancode, isrepeat)
end

-- Called when a key is released
function State:keyreleased(key, scancode)
end

-- Called when mouse is pressed
function State:mousepressed(x, y, button, istouch, presses)
end

-- Called when mouse is released
function State:mousereleased(x, y, button, istouch, presses)
end

return State
