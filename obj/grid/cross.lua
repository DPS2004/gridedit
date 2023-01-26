Cross = class('Cross',Gridobject)

function Cross:initialize(params)
	
	
	Gridobject.initialize(self,params)
	self.height = 48
	self.name = 'cross'
	self.sprite = sprites.cross
	
end

function Cross:gatherPushes(direction)
	return nil
end



return Cross