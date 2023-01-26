NullBox = class('NullBox',Box)

function NullBox:initialize(params)
	
	
	Box.initialize(self,params)
	
	self.name = 'nullbox'
	self.sprite = sprites.nullbox

	self.linkable = false
	self.links = {}
	
end

function NullBox:checklinks()
	return {}, {}
end

function NullBox:draw()
	Box.olddraw(self)
end


return NullBox