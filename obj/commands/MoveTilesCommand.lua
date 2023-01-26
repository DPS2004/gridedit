local Command = require('obj/commands/Command')
MoveTilesCommand = class("MoveTilesCommand", Command)

local function deepSet(table, x, y, z, value)
    if table[x] == nil then
        table[x] = {}
    end
    if table[x][y] == nil then
        table[x][y] = {}
    end
    table[x][y][z] = value
end

-- tilePositionMap - a map of tiles to their target positions
function MoveTilesCommand:initialize(grid, tilePositionMap)
    self.grid = grid

    self.originPosToTargetPos = tilePositionMap -- where the tiles will be placed when executing
    self.targetPosToOriginPos = {} -- where the tiles will be placed when undoing

    local tileCount = 0
    for tilePos, targetPos in pairs(tilePositionMap) do
        local targetPosCopy = { x = targetPos.x, y = targetPos.y, z = targetPos.z }
        local tilePosCopy = { x = tilePos.x, y = tilePos.y, z = tilePos.z }
        self.targetPosToOriginPos[targetPosCopy] = tilePosCopy
        tileCount = tileCount + 1
    end

    self.info = 'moving ' .. tileCount .. ' tiles'
end

function MoveTilesCommand:doMove(tilePositionMap)
    -- after moving a tile, we need to replace
    -- the space it occupied with an `empty` tile,
    -- assuming that there was no box pushed into it
    --
    -- this table has the format {x: {y: {z: boolean}}}
    -- if the value is truthy, then the tile at that position
    -- should be replaced with an empty tile
    -- use deepSet to access this a bit more easily ..
    local nilTiles = {}

    
    -- pluck all the tiles first
    local tileToTargetMap = {}
    for tilePos, targetPos in pairs(tilePositionMap) do
        deepSet(nilTiles, tilePos.x, tilePos.y, tilePos.z, true)
        local tile = self.grid:get(tilePos.x, tilePos.y, tilePos.z)
        self.grid.g[tilePos.x][tilePos.y][tilePos.z] = nil
        tileToTargetMap[tile] = targetPos
    end

    -- then add them back at the new positions
    for tile, targetPos in pairs(tileToTargetMap) do
        deepSet(nilTiles, targetPos.x, targetPos.y, targetPos.z, nil)

        tile.ox = tile.x
        tile.oy = tile.y
        tile.x = targetPos.x
        tile.y = targetPos.y
        tile.z = targetPos.z
        self.grid.g[targetPos.x][targetPos.y][targetPos.z] = tile
    end

    -- add empty tiles where needed
    for x, yMap in pairs(nilTiles) do
        for y, zMap in pairs(yMap) do
            for z, value in pairs(zMap) do
                if value then
                    self.grid:add('empty', x, y, z)
                end
            end
        end
    end
end

function MoveTilesCommand:execute()
    self:doMove(self.originPosToTargetPos)
end

function MoveTilesCommand:undo()
    self:doMove(self.targetPosToOriginPos)
end

return MoveTilesCommand
