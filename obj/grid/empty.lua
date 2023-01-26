Empty = class('Empty',Gridobject)

function Empty:initialize(params)
	
	
	Gridobject.initialize(self,params)
	
	self.name = 'empty'
	self.has = {
		beforeAction = 0,
		moveend = 0,
	}
	self.lasered = false
end

function Empty:beforeAction()
	self.lasered = false
end

function Empty:gatherPushes(direction)
	return {}
end

function Empty:draw()
	self:animate()

end


return Empty