Gridobject = class('Gridobject', Entity)

function Gridobject:initialize(params)

	self.layer = 0 -- lower layers draw first
	self.uplayer = 0 --lower uplayer updates first

	self.x = 0
	self.y = 0
	
	self.height = 38
	self.sprite = sprites.cross

	self.skiprender = true
	self.skipupdate = true
	self.name = 'gridobject'

	self.has = {}

	Entity.initialize(self, params)

	self.dx = self.x
	self.dy = self.y

	self.ox = self.x
	self.oy = self.y

end

function Gridobject:update(dt)
	prof.push("Gridobject update")

	prof.pop("Gridobject update")
end

function Gridobject:getlocal(vec, z)
	z = z or self.z
	return self.grid:get(self.x + vec[1], self.y + vec[2], z)
end

function Gridobject:replace(obj)
	local ReplaceTileCommand = require 'obj/commands/ReplaceTileCommand'
	self.grid:appendLastAction(ReplaceTileCommand(self.grid, self.x, self.y, self.z, obj))
end


function Gridobject:remove()

end


function Gridobject:draw(spr)
	self:animate()
	
	spr = spr or self.sprite
	love.graphics.draw(
		spr,
		self.dx * self.grid.scalex,
		(self.dy + 1) * self.grid.scaley - self.height
	)
end

function Gridobject:dbdraw(text)
	color()
	text = text or self.id
	love.graphics.print(text, self.dx * self.grid.scalex, ((self.dy + 1) * self.grid.scaley - self.height) + self.z * 6)
end

return Gridobject
