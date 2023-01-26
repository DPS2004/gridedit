Button = class('Button',Entity)

function Button:initialize(params)
  
  self.skiprender = true
	self.skipupdate = true
  
	self.onclick = function() print('undefined button click') end
	
	self.x = 100
	self.y = 100
	self.width = 100
	self.height = 100
	self.text = 'button'
	self.visible = true
	self.active = true
	
  Entity.initialize(self,params)
	
	
	
end


function Button:update(dt,mx,my)
  prof.push("button update")
  
	if mouse.pressed == 1 and helpers.inrect(self.x,self.width+self.x,self.y,self.height+self.y,mx,my) then

	
		self:onclick()
	end
	
  prof.pop("button update")
end

function Button:draw()
  prof.push("button draw")
  color('white')
	love.graphics.setLineWidth(1)
  love.graphics.rectangle('line',self.x,self.y,self.width,self.height)
	love.graphics.printf(self.text,self.x,(self.y*2+self.height)/2-8,self.width,"center")
  prof.pop("button draw")
end

return Button