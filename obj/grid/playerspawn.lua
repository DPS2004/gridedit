Playerspawn = class('Playerspawn',Gridobject)

function Playerspawn:initialize(params)
	
	
	Gridobject.initialize(self,params)
    self.has = {
		afterAction = 1
	}
	
	self.height = 48
	self.sprite = sprites.nova
	self.name = 'playerspawn'
    self.spawned = false
end

function Playerspawn:afterAction()
	if self.spawned then return end
	local ReplaceTileCommand = require('obj/commands/ReplaceTileCommand')
	self.grid:appendLastAction(ReplaceTileCommand(self.grid, self.x, self.y, self.z, 'player'))
end




return Playerspawn