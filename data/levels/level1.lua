-- Level 1 Configuration
-- This file defines level-specific settings

return {
    -- Paddle configuration
    paddle = {
        width = 100,
        height = 15,
        speed = 400,
        y = 550,
    },
    
    -- Ball configuration
    ball = {
        radius = 8,
        speed = 300,
        startAngle = -math.pi / 2,
    },
    
    -- Block configuration
    block = {
        width = 60,
        height = 20,
        padding = 5,
        offsetX = 55,
        offsetY = 50,
    },
    
    -- Grid configuration
    grid = {
        cols = 11,
        rows = 6,
    },
}
