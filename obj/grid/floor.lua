Floor = class('Floor',Gridobject)

function Floor:initialize(params)
	
	
	Gridobject.initialize(self,params)
	self.sprite = sprites.floor
	
	self.name = 'floor'
end



return Floor