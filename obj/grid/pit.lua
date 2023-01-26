Pit = class('Pit', Gridobject)

function Pit:initialize(params)


	Gridobject.initialize(self, params)

	self.name = 'pit'
	
	self.sprite = animations.pitwalls

	self.has = {
		afterEase = 0
	}
end

function Pit:afterEase()
	local top = self.grid:get(self.x, self.y, 1)
	if top then
		if top.name == 'player' then
			--eventually there will probably be a death animation, but this works for now
			top:replace('cross')
		end
		if top.linkable then
			top:replace('cross')
		end
		if top.name == 'nullbox' then
			top:replace('empty')
		end
	end
end

function Pit:draw(spr,editor)
	self:animate()
	
	if editor then 
		Gridobject.draw(self,sprites.pit)
	else
		local vecs = {{0,1},{0,-1},{1,0},{-1,0}}
		
		for i,v in ipairs(vecs) do
			local obj = self:getlocal(v) 
			if obj and (obj.name ~= 'pit') and (obj.name ~= 'empty') then
				self.sprite:draw(i - 1,
					self.dx * self.grid.scalex,
					(self.dy + 1) * self.grid.scaley - self.height
				)
			end
		end
	end
		
	
end


return Pit
