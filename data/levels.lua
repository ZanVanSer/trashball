-- Level Loader
-- Loads level data from text files and Lua configuration

local BlockTypes = require("data.blocks")

local LevelLoader = {}

-- Default level settings
local defaultSettings = {
    paddle = {
        width = 100,
        height = 15,
        speed = 400,
        y = 550,
    },
    ball = {
        radius = 8,
        speed = 300,
        startAngle = -math.pi / 2, -- Upward
    },
    block = {
        width = 60,
        height = 20,
        padding = 5,
        offsetX = 50,
        offsetY = 50,
    },
    grid = {
        cols = 10,
        rows = 8,
    },
}

-- Load level configuration from Lua file
function LevelLoader.loadConfig(levelNum)
    local success, config = pcall(function()
        return require("data.levels.level" .. levelNum)
    end)
    
    if not success then
        -- Return default config if level file doesn't exist
        return defaultSettings
    end
    
    -- Merge with defaults
    local merged = {}
    for key, value in pairs(defaultSettings) do
        if config[key] then
            merged[key] = {}
            for k, v in pairs(value) do
                merged[key][k] = config[key][k] or v
            end
        else
            merged[key] = value
        end
    end
    
    return merged
end

-- Load level layout from text file
function LevelLoader.loadLayout(levelNum)
    local filename = string.format("data/levels/level%d.txt", levelNum)
    
    -- Try to read the file
    local success, layout = pcall(love.filesystem.read, filename)
    
    if not success or not layout then
        -- Return default empty layout if file doesn't exist
        return nil
    end
    
    -- Parse the layout into a 2D array
    local rows = {}
    for line in layout:gmatch("[^\r\n]+") do
        local row = {}
        for i = 1, #line do
            local char = line:sub(i, i)
            row[i] = char
        end
        table.insert(rows, row)
    end
    
    return rows
end

-- Create blocks from layout
function LevelLoader.createBlocks(layout, config)
    if not layout then
        return {}
    end
    
    local blocks = {}
    local blockConfig = config.block
    local gridConfig = config.grid
    
    for rowIndex, row in ipairs(layout) do
        for colIndex, char in ipairs(row) do
            local blockType = BlockTypes:getTypeFromChar(char)
            
            if blockType and blockType.id ~= "empty" then
                local x = blockConfig.offsetX + (colIndex - 1) * (blockConfig.width + blockConfig.padding)
                local y = blockConfig.offsetY + (rowIndex - 1) * (blockConfig.height + blockConfig.padding)
                
                local block = {
                    x = x,
                    y = y,
                    width = blockConfig.width,
                    height = blockConfig.height,
                    type = blockType,
                    hitPoints = blockType.hitPoints,
                    destroyed = false,
                    -- For rendering, store original color
                    color = {unpack(blockType.color)},
                }
                
                table.insert(blocks, block)
            end
        end
    end
    
    return blocks
end

-- Load complete level data
function LevelLoader.loadLevel(levelNum)
    local config = LevelLoader.loadConfig(levelNum)
    local layout = LevelLoader.loadLayout(levelNum)
    local blocks = LevelLoader.createBlocks(layout, config)
    
    return {
        config = config,
        blocks = blocks,
    }
end

return LevelLoader
