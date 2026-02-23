-- Block Type Definitions
-- Data-driven block configuration

local BlockTypes = {}

-- Block type definitions with their properties
BlockTypes.types = {
    -- Empty space (no block)
    EMPTY = {
        id = "empty",
        hitPoints = 0,
        scoreValue = 0,
        color = {0, 0, 0, 0},
        passThrough = true,
    },
    
    -- Standard block - 1 hit to destroy
    STANDARD = {
        id = "standard",
        hitPoints = 1,
        scoreValue = 10,
        color = {0.2, 0.6, 0.8, 1}, -- Light blue
        passThrough = false,
    },
    
    -- Strong block - 2 hits to destroy
    STRONG = {
        id = "strong",
        hitPoints = 2,
        scoreValue = 30,
        color = {0.8, 0.4, 0.2, 1}, -- Orange
        passThrough = false,
    },
    
    -- Very strong block - 3 hits to destroy
    HARD = {
        id = "hard",
        hitPoints = 3,
        scoreValue = 50,
        color = {0.6, 0.2, 0.2, 1}, -- Dark red
        passThrough = false,
    },
    
    -- Bonus block - gives extra life or points
    BONUS = {
        id = "bonus",
        hitPoints = 1,
        scoreValue = 20,
        color = {0.2, 0.8, 0.2, 1}, -- Green
        passThrough = false,
        bonusType = "life", -- Can be "life" or "points"
        bonusValue = 1,
    },
    
    -- Points bonus block
    POINTS = {
        id = "points",
        hitPoints = 1,
        scoreValue = 50,
        color = {0.8, 0.8, 0.2, 1}, -- Yellow
        passThrough = false,
        bonusType = "points",
        bonusValue = 100,
    },
    
    -- Explosive block - destroys nearby blocks
    EXPLOSIVE = {
        id = "explosive",
        hitPoints = 1,
        scoreValue = 25,
        color = {0.8, 0.2, 0.8, 1}, -- Purple
        passThrough = false,
        explosionRadius = 2, -- In grid cells
    },
}

-- Mapping from characters in level file to block types
BlockTypes.charMap = {
    [" "] = "EMPTY",
    ["."] = "EMPTY",
    ["S"] = "STANDARD",
    ["2"] = "STRONG",
    ["3"] = "HARD",
    ["B"] = "BONUS",
    ["P"] = "POINTS",
    ["X"] = "EXPLOSIVE",
}

-- Get block type by key
function BlockTypes:getType(key)
    return self.types[key]
end

-- Get block type from character
function BlockTypes:getTypeFromChar(char)
    local key = self.charMap[char] or "EMPTY"
    return self.types[key]
end

-- Get all block types for iteration
function BlockTypes:getAllTypes()
    return self.types
end

return BlockTypes
