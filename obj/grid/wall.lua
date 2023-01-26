Wall = class('Wall',Gridobject)

function Wall:initialize(params)
	
	
	Gridobject.initialize(self,params)
	
	self.name = 'wall'
	self.sprite = sprites.wall
	self.height = 64
	
	self.visibilitystate = 0
	-- 0: not faded
	-- 1: going from not faded to faded
	-- 2: faded
	-- 3: going from faded to not faded
	self.has = {
		finalAction = 0
	}
	
	
end

local CallFunctionCommand = require 'obj/commands/CallFunctionCommand'

function Wall:finalAction()
	local betransparent = false
	local docommand = false
	local newstate = nil
	
	local above = self:getlocal({0,-1})
	
	if above then
		if self.grid.player and above.name == 'empty' and above:simpledistance(self.grid.player) <= 1 then
			betransparent = true
		elseif ((not(above.name == 'wall' or above.name == 'empty')) and self.grid.player )  then
			betransparent = true
		elseif above.name == 'empty' then
			if self.visibilitystate == 0 and (not above.lasered) then
				return
			end
			if above.lasered then
				betransparent = true
			end
		else
			return
		end
	else
		return
	end
	
	
	if betransparent then
		if self.visibilitystate == 0 or self.visibilitystate == 3 then
			newstate = 1
		elseif self.visibilitystate == 1 then
			newstate = 2
		end
	else
		if self.visibilitystate == 2 or self.visibilitystate == 1 then
			newstate = 3
		elseif self.visibilitystate == 3 then
			newstate = 0
		end
	end
	
	if newstate then
		local cmd = CallFunctionCommand(
			function() -- execute
				self.visibilitystate = newstate
				print(newstate)
			end,
			function() -- undo
				
				
				
				if self.visibilitystate == 3 or self.visibilitystate == 1 then
					self.visibilitystate = 0
				elseif self.visibilitystate == 2 then
					self.visibilitystate = 3
				end
				
			end,
			'update wall visibility'
		)
		self.grid:appendLastAction(cmd)
	end
end

function Wall:gatherPushes(direction)
	return nil
end

function Wall:draw()
	
	local drawnormal = true
	if self.visibilitystate == 0 then
		Gridobject.draw(self)
	elseif self.visibilitystate == 1 then
		Gridobject.draw(self,sprites.wall_bottom)
		color(1,1,1,1 - (self.grid.easer*0.5))
		Gridobject.draw(self,sprites.wall_top)
	elseif self.visibilitystate == 3 then
		Gridobject.draw(self,sprites.wall_bottom)
		color(1,1,1,0.5 + (self.grid.easer*0.5))
		Gridobject.draw(self,sprites.wall_top)
	else
		Gridobject.draw(self,sprites.wall_bottom)
		color(1,1,1,0.5)
		Gridobject.draw(self,sprites.wall_top)
	end
		
		
	--Gridobject.dbdraw(self,self.visibilitystate)
end


return Wall