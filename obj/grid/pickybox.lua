PickyBox = class('PickyBox',Box)

function PickyBox:initialize(params)
	
	
	Box.initialize(self,params)
	
	self.name = 'pickybox'
	self.sprite = sprites.pickybox
	
    self.links = {}
	self.linkBlacklist = {pickybox = true}
end

function PickyBox:draw()
	Box.olddraw(self)
end


return PickyBox