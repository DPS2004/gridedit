Goal = class('Goal', Gridobject)

function Goal:initialize(params)


	Gridobject.initialize(self, params)

	self.name = 'goal'
	self.state = 'idle'

	self.has = {
		afterEase = 2
	}
end

function Goal:updatestate()
    -- as with Box, we can't change the state directly
    -- have to use commands for it instead
    -- here it's just a matter of saving the old state
	-- and comparing it to the new state
	local lastState = self.state
	local newState = lastState
	local foundcross = false
	for k, v in pairs(self.grid.otypes.cross) do
		foundcross = true
	end

	if foundcross then
		newState = 'fail'
	else
        local linked = true
		for k, v in pairs(self.grid.otypes.box) do
			if v.linkCount == 0 then
				linked = false
			end
		end

		newState = linked and 'ready' or 'idle'
	end

	if newState ~= lastState then
		local CallFunctionCommand = require 'obj/commands/CallFunctionCommand'
		local cmd = CallFunctionCommand(
			function()
				self.state = newState
			end,
			function()
				self.state = lastState
            end,
			'change goal state from '.. lastState .. ' to ' .. newState
		)

		self.grid:appendLastAction(cmd)
	end
end

function Goal:checkplayer()
	if self.state == 'ready' then
		local top = self.grid:get(self.x, self.y, 1)
		if top then
			if top.name == 'player' then
				cs:clearlevel()
			end
		end
	end
end

function Goal:afterEase()
	if self.grid.hasPendingCommands then
		return
	end
    self:updatestate()
	if self.grid.hasPendingCommands then
		return
	end
	self:checkplayer()
end


function Goal:draw()
	Gridobject.draw(self,sprites.goal[self.state])
end

return Goal
