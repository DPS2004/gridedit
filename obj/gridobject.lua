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

function Gridobject:animate()
	self.dx = helpers.lerp(self.ox, self.x, self.grid.easer)
	self.dy = helpers.lerp(self.oy, self.y, self.grid.easer)
end

-- called once on each gridobject
-- before an action is executed
-- i dont think theres actually much need for this right now?
-- but i'll keep it just in case
function Gridobject:beforeAction()
	-- nothing ...
end

-- called after an action is finished
-- if more commands are appended, this is called again
-- try not to cause an infinite loop
function Gridobject:afterAction()

end

-- called after easing is finished, except when undoing
-- if more commands are appended, this is called again
function Gridobject:afterEase()

end

-- called once after all afterAction and afterEase callbacks are finished
-- including when undoing
function Gridobject:endAnimate()
	self.ox = self.x
	self.oy = self.y
end

function Gridobject:scan(vec, skip, list, distance)
	skip = skip or {}

	if list then
		table.insert(list, self)
	else
		list = {}
	end


	distance = distance or 0

	distance = distance + 1

	local other = self:getlocal(vec)
	if other then
		if other.name == 'empty' or helpers.tablematch(other.name, skip) then
			return other:scan(vec, skip, list, distance)
		else
			return other, list, distance
		end
	end
	return nil, list, distance

end

-- returns all the tiles that will move
-- when this tile is pushed.
-- return `nil` if pushing is impossible
-- note that this function can be called recursively,
-- for example, if you push a box into a chainbox.....
-- so make sure to avoid infinite recursion - check `Box:gatherPushes` for an exampple
function Gridobject:gatherPushes(direction)
	error(self.class.name .. ':gatherPushes not implemented !!')
end

function Gridobject:replace(obj)
	local ReplaceTileCommand = require 'obj/commands/ReplaceTileCommand'
	self.grid:appendLastAction(ReplaceTileCommand(self.grid, self.x, self.y, self.z, obj))
end

function Gridobject:push(direction, skip)
	skip = skip or {}
	skip[self.id] = true
	return self.grid:push({ x = self.x, y = self.y, z = self.z }, direction, skip)
end

function Gridobject:remove()
	for k, v in pairs(self.grid.callbacks) do
		v[self.id] = nil
	end
	for k, v in pairs(self.grid.tempcallbacks) do
		v[self.id] = nil
	end
	self.grid.otypes[self.name][self.id] = nil
end

function Gridobject:simpledistance(other)
	return math.max(math.abs(self.x - other.x),math.abs(self.y-other.y))
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
