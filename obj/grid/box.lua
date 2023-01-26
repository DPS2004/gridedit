Box = class('Box', Gridobject)

function Box:initialize(params)


	Gridobject.initialize(self, params)

	self.height = 48
	self.sprite = animations.box:instance('unlit')
	
	self.name = 'box'
	self.has = {
        afterAction = 1,
        afterEase = 1,
		endAnimate = 1,
		
		update = 1,
	}
	
	self.lastlit = false

	self.linkable = true

    self.links = {}
    self.linkCount = 0

	-- names of objects this box is not supposed to connect to
	-- this is a set - has type {string: boolean}
	self.linkBlacklist = {} 
	self.gatheringPushes = false
end

function Box:setanim(lit)
	if self.name == 'box' then-- skip box variants for now
		if lit ~= self.lastlit then
			self.lastlit = lit
			if lit then
				self.sprite:play('lit')
			else
				self.sprite:play('unlit')
			end
		end
	end
end

function Box:gatherPushes(direction)
    if self.gatheringPushes then
        return {}
    end

	self.gatheringPushes = true
	local next = self.grid:get(self.x + direction.x, self.y + direction.y, self.z)
	if not next then 
		self.gatheringPushes = false
		return nil 
	end
	
	local pushes = next:gatherPushes(direction)
    if pushes == nil then
		self.gatheringPushes = false
        return nil
	end

	table.insert(pushes, self)

	self.gatheringPushes = false
	return pushes
end

local CallFunctionCommand = require 'obj/commands/CallFunctionCommand'

-- remove old links
function Box:afterAction()
    local _additions, removals = self:checklinks(false)

    if #removals == 0 then return end
    local cmd = CallFunctionCommand(
        function() -- execute
            for _, link in ipairs(removals) do
                self.links[link] = nil
                self.linkCount = self.linkCount - 1
            end
						self:setanim(self.linkCount ~= 0)
        end,
        function() -- undo
            for _, link in ipairs(removals) do
                self.links[link] = true
                self.linkCount = self.linkCount + 1
            end
						self:setanim(self.linkCount ~= 0)
        end,
        'remove old box links'
    )

    self.grid:appendLastAction(cmd)
end

-- fully update links
function Box:afterEase()
    local additions, removals = self:checklinks(true)
    if #additions == 0 and #removals == 0 then return end
    
    local cmd = CallFunctionCommand(
        function() -- execute
            for _, link in ipairs(additions) do
                self.links[link] = true
                self.linkCount = self.linkCount + 1
            end
            for _, link in ipairs(removals) do
                self.links[link] = nil
                self.linkCount = self.linkCount - 1
            end
						self:setanim(self.linkCount ~= 0)
        end,
        function() -- undo
            for _, link in ipairs(additions) do
                self.links[link] = nil
                self.linkCount = self.linkCount - 1
            end
            for _, link in ipairs(removals) do
                self.links[link] = true
                self.linkCount = self.linkCount + 1
            end
						self:setanim(self.linkCount ~= 0)
        end,
        'update box links'
    )
    self.grid:appendLastAction(cmd)
end

-- returns a list additions and a list of removals in this box's links
function Box:checklinks(killPlayer)
    local newLinks = {}
	local vecs = {
		{ 0, -1 },
		{ 0, 1 },
		{ -1, 0 },
		{ 1, 0 }
	}

	for _, vec in ipairs(vecs) do
		local obj, list, dist = self:scan(vec, { 'player', 'laser', 'cross' })
		if obj then
			if obj.linkable and not self.linkBlacklist[obj.name] then
				newLinks[obj] = true

				for _, v in ipairs(list) do
					if killPlayer and v.name == 'player' then
						--eventually there will probably be a death animation, but this works for now
						v:replace('cross')
					end
					if v.name == 'empty' then
						v.lasered = true
					end
				end
			end
		end
    end
	
    -- i dont like this part
	--
    -- since state changes require commands,
    -- we cant just remove the old links and add the new ones
    -- we need to calculate the differences between the
	-- old and new links, and then use a command to add or remove them
    local additions = {}
    local removals = {}
	for link, _ in pairs(self.links) do
		if not newLinks[link] then
			removals[#removals+1] = link
		end
    end
	for link, _ in pairs(newLinks) do
		if not self.links[link] then
			additions[#additions+1] = link
		end
    end

    return additions, removals
end

function Box:update(dt)
	if self.name == 'box' then --skip box variants for now
		self.sprite:update(dt)
	end
end


function Box:draw()
	self:animate()
	
	self.sprite:draw(
		self.dx * self.grid.scalex,
		(self.dy + 1) * self.grid.scaley - self.height
	)
	
	color('yellow')
    love.graphics.setLineWidth(10)

    for v, _ in pairs(self.links) do
		love.graphics.line(
			(self.dx + 0.5) * self.grid.scalex,
			(self.dy + 0.5) * self.grid.scaley - 10,
			(v.dx + 0.5) * self.grid.scalex,
			(v.dy + 0.5) * self.grid.scaley - 10
		)
	end
end

function Box:olddraw() -- for other box variants that dont have animated sprites yet
	self:animate()
	
	Gridobject.draw(self)
	
	color('yellow')
    love.graphics.setLineWidth(10)

    for v, _ in pairs(self.links) do
		love.graphics.line(
			(self.dx + 0.5) * self.grid.scalex,
			(self.dy + 0.5) * self.grid.scaley - 10,
			(v.dx + 0.5) * self.grid.scalex,
			(v.dy + 0.5) * self.grid.scaley - 10
		)
	end
end

return Box
