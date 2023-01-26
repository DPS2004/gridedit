Player = class('Player',Gridobject)

function Player:initialize(params)
	
	
	Gridobject.initialize(self,params)
	
	self.height = 58
	
	self.sprite = animations.nova
	
	self.name = 'player'
	self.has = {
        update = 1,
		endAnimate = 1
	}
	
	self.anim = {
		direction = 0,
		state = 0,
		leg = 0,
	}
end

function Player:gatherPushes(direction)
	-- this feels weird. is this gonna work?
	return Box.gatherPushes(self, direction)
end


function Player:update(dt)
    prof.push("Player update")

	-- the actual pushing is done in Gridmanager:update
	local newDirection = nil
	if maininput:pressed('up') then
		newDirection = 2
	elseif maininput:pressed('down') then
		newDirection = 0
	elseif maininput:pressed('left') then
		newDirection = 1
	elseif maininput:pressed('right') then
		newDirection = 3
	end

    if newDirection ~= nil then
		self.anim.direction = newDirection
		self.anim.leg = (self.anim.leg + 1) % 2
		self.anim.state = 1
	end
	
	self:animate()
	
  prof.pop("Player update")
end


function Player:endAnimate()
	self.ox = self.x
	self.oy = self.y
	self.anim.state = 0
end

function Player:draw(spr)
	self:animate()
	self.sprite:draw(self.anim.direction * 3 + (self.anim.state * (self.anim.leg + 1)),
		self.dx * self.grid.scalex,
		(self.dy + 1) * self.grid.scaley - self.height
	)
end

return Player