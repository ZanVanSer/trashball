-- Trashball - Main Entry Point
-- Love2D Game Framework

-- Game requires Love2D version 11.x
assert(love and love._version_major >= 11, "Love2D 11.x is required")

-- Game modules
local GameState = require("game.state")
local MenuState = require("game.menu")
local LevelSelectState = require("game.levelselect")
local PlayState = require("game.game")
local VictoryState = require("game.victory")
local DefeatState = require("game.defeat")

-- Game configuration
local Game = {
    width = 800,
    height = 600,
    states = {},
    currentState = nil,
    
    -- Game data
    score = 0,
    lives = 3,
    currentLevel = 1,
    
    -- Constants
    MAX_LIVES = 3,
}

-- Load all game states
function Game:loadStates()
    self.states.menu = MenuState:new()
    self.states.levelselect = LevelSelectState:new()
    self.states.play = PlayState:new()
    self.states.victory = VictoryState:new()
    self.states.defeat = DefeatState:new()
    
    -- Set initial state
    self.currentState = self.states.menu
end

-- Switch to a different state
function Game:switchState(stateName, ...)
    local newState = self.states[stateName]
    if newState then
        self.currentState = newState
        if newState.enter then
            newState:enter(...)
        end
    end
end

-- Reset game data for new game
function Game:resetGame()
    self.score = 0
    self.lives = self.MAX_LIVES
    self.currentLevel = 1
end

-- Love2D callbacks
function love.load()
    -- Set default graphics settings
    love.graphics.setDefaultFilter("linear", "linear")
    love.graphics.setLineStyle("smooth")
    
    -- Load game
    Game:loadStates()
    
    -- Enter menu state
    Game:switchState("menu")
end

function love.update(dt)
    if Game.currentState and Game.currentState.update then
        Game.currentState:update(dt)
    end
end

function love.draw()
    if Game.currentState and Game.currentState.draw then
        Game.currentState:draw()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if Game.currentState and Game.currentState.keypressed then
        Game.currentState:keypressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode)
    if Game.currentState and Game.currentState.keyreleased then
        Game.currentState:keyreleased(key, scancode)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if Game.currentState and Game.currentState.mousepressed then
        Game.currentState:mousepressed(x, y, button, istouch, presses)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if Game.currentState and Game.currentState.mousereleased then
        Game.currentState:mousereleased(x, y, button, istouch, presses)
    end
end

-- Return Game object for use in other modules
return Game
