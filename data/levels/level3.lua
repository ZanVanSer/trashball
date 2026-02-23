-- Level 3 Configuration
-- Most challenging level with hard blocks and explosives

return {
    -- Paddle configuration
    paddle = {
        width = 90,
        height = 15,
        speed = 500,
        y = 550,
    },
    
    -- Ball configuration
    ball = {
        radius = 8,
        speed = 400,
        startAngle = -math.pi / 2,
    },
    
    -- Block configuration
    block = {
        width = 55,
        height = 20,
        padding = 5,
        offsetX = 55,
        offsetY = 50,
    },
    
    -- Grid configuration
    grid = {
        cols = 12,
        rows = 8,
    },
}
