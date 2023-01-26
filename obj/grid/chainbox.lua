ChainBox = class('ChainBox',Box)

function ChainBox:initialize(params)
	
	
	Box.initialize(self,params)
	
	self.name = 'chainbox'
	self.sprite = sprites.chainbox
	
    self.links = {}
end

function ChainBox:gatherPushes(direction)
	if self.gatheringPushes then
		return {}
	end
    self.gatheringPushes = true

	-- push whatever is in the way
	local next = self.grid:get(self.x + direction.x, self.y + direction.y, self.z)
	
	if not next then 
		self.gatheringPushes = false
		return nil 
	end
	

	-- push all the linked boxes
    local connected = {  }
	for v, _ in pairs(self.links) do
		connected[#connected+1] = v
    end
	
	if next.name ~= 'empty' then
		table.insert(connected, next)
	end
	
    local pushes = {}

	-- get the pushes from all connected boxes
    for _, v in ipairs(connected) do
		local newPushes = v:gatherPushes(direction)
        if newPushes == nil then
            self.gatheringPushes = false
            return nil
		end
		for _, v in ipairs(newPushes) do
			table.insert(pushes, v)
		end
	end

    table.insert(pushes, self)
	self.gatheringPushes = false
	return pushes
end

function ChainBox:draw()
	Box.olddraw(self)
end



return ChainBox