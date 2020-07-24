--[[
    GD50
    Breakout Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

-- global patterns (used to make the entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1           -- all colors the same in this row
ALTERNATE = 2       -- alternate colors
SKIP = 3            -- skip every other block
NONE = 4            -- no blocks this row

LevelMaker = Class{}

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]
function LevelMaker.createMap(level)
    local bricks = {}

    -- randomly choose the number of rows
    local numRows = math.random(1, 5)

    -- randomly choose the number of columns, ensuring odd
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    -- highest possible spawned brick color in this level; ensure we
    -- don't go above 3
    local highestTier = math.min(3, math.floor(level / 5))

    -- highest color of the highest tier, no higher than 5
    local highestColor = math.min(5, level % 5 + 3)

    -- lay out bricks such that they touch each other and fill the space
    for y = 1, numRows do
        -- whether we want to enable skipping for this row
        local skipPattern = math.random(1, 2) == 1 and true or false

        -- whether we want to enable alternating colors for this row
        local alternatePattern = math.random(1, 2) == 1 and true or false
        
        -- choose two colors to alternate between
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)
        
        -- used only when we want to skip a block, for skip pattern
        local skipFlag = math.random(2) == 1 and true or false

        -- used only when we want to alternate a block, for alternate pattern
        local alternateFlag = math.random(2) == 1 and true or false

        -- solid color we'll use if we're not skipping or alternating
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do
            -- if skipping is turned on and we're on a skip iteration...
            if skipPattern and skipFlag then
                -- turn skipping off for the next iteration
                skipFlag = not skipFlag

                -- Lua doesn't have a continue statement, so this is the workaround
                goto continue
            else
                -- flip the flag to true on an iteration we don't use it
                skipFlag = not skipFlag
            end

            -- x-coordinate
            local xCoordinate = (x-1)                   -- decrement x by 1 because tables are 1-indexed, coords are 0
                        * 32                            -- multiply by 32, the brick width
                        + 8                             -- the screen should have 8 pixels of padding; we can fit 13 cols + 16 pixels total
                        + (13 - numCols) * 16           -- left-side padding for when there are fewer than 13 columns
            local yCoordinate = y * 16                  -- just use y * 16, since we need top padding anyway

            -- power ups
            local powerUps = {}

            -- random 0-3, a 25% chance for the occuring brick to have a power up
            local shouldHaveExtraBallPowerUp = math.random(0, 3) == 0
            if shouldHaveExtraBallPowerUp then
                local randomXPosition = xCoordinate + math.random(4, 12)
                local extraBallPowerUp = PowerUp('extra-ball', randomXPosition, yCoordinate)
                table.insert(powerUps, extraBallPowerUp)
            end

            -- random 0-4, a 20% chance for the occuring brick to have a key power up
            local shouldHaveKeyPowerUp = math.random(0, 4) == 0
            if shouldHaveKeyPowerUp then
                local randomXPosition = xCoordinate + math.random(4, 12)
                local keyPowerUp = PowerUp('key', randomXPosition, yCoordinate)
                table.insert(powerUps, keyPowerUp)
            end

            b = Brick(
                xCoordinate + ((32 - 16) / 2),          -- 32=brick's width, 16=ball's width. Align to center of the brick
                yCoordinate,
                powerUps                                -- powerups
            )

            -- if we're alternating, figure out which color/tier we're on
            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            -- if not alternating and we made it here, use the solid color/tier
            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end 

            table.insert(bricks, b)

            -- Lua's version of the 'continue' statement
            ::continue::
        end
    end 

    -- random 0-9, a 10% chance for this occuring brick to be a key power up
    local shouldBeAPowerUpBrick = math.random(0, 9) == 0
    if shouldBeAPowerUpBrick then
        local brickToReplaceIndex = math.random(1, #bricks) - 1         -- -1 to convert it to index
        local brickToReplace = bricks[brickToReplaceIndex]

        -- create a key power up
        local powerUps = {}
        powerUps[0] = PowerUp('key', brickToReplace.x + ((32 - 16) / 2), brickToReplace.y)
        brickToReplace.powerUps = powerUps
    end

    -- in the event we didn't generate any bricks, try again
    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks
    end
end