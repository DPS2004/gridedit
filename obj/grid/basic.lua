Basic = class('Basic',Gridobject)

function Basic:initialize(params)
	
	
	Gridobject.initialize(self,params)
	
	self.name = 'basic'

end

function Basic:beforeAction()
	self.lasered = false
end

function Basic:gatherPushes(direction)
	return {}
end

function Basic:draw()
	error("draw!")
	love.graphics.draw(
		self.spr,
		self.dx * self.grid.scalex,
		(self.dy + 1) * self.grid.scaley - self.height
	)

end


return Basic