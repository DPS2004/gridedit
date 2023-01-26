local Command = require('obj/commands/Command')
ReplaceTileCommand = class("ReplaceTileCommand", Command)

function ReplaceTileCommand:initialize(grid, x, y, z, new)
    self.grid = grid
    self.x = x
    self.y = y
    self.z = z
    self.original = nil
    self.new = new
    self.info = 'replacing at (' .. x .. ', ' .. y .. ', ' .. z .. ') with `' .. new .. '`'
end

function ReplaceTileCommand:execute()
    local tile = self.grid:pluck(self.x, self.y, self.z)
    self.original = tile
    self.grid:add(self.new, self.x, self.y, self.z)
end

function ReplaceTileCommand:undo()
    self.grid:pluck(self.x, self.y, self.z)
    self.grid:emplace(self.original, self.x, self.y, self.z)
end

return ReplaceTileCommand

