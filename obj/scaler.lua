Scaler = class('Scaler',Entity)

function Scaler:initialize(params)
  
  
	self.skiprender = true
	self.skipupdate = true
	
	self.intscaling = true
	
  
  Entity.initialize(self,params)
	self.cwidth = 10
	self.cheight = 10
end

function Scaler:setup(cwidth, cheight,forcesize,resx,resy)
	self.cwidth = cwidth
	self.cheight = cheight
	self.canvas = love.graphics.newCanvas(cwidth,cheight)
	self:updatescale(forcesize,resx,resy)
end

function Scaler:getscale(cwidth,cheight,resx,resy)
	resx = resx or project.res.x
	resy = resy or project.res.y
	return math.min(resx / cwidth, resy / cheight)
end

function Scaler:updatescale(forcesize,resx,resy)
	local forceres = false
	if resx then
		forceres = true
	end
	resx = resx or project.res.x
	resy = resy or project.res.y
	
	if forcesize then
		self.scalesize = forcesize
	else
		self.scalesize = self:getscale(self.cwidth,self.cheight,resx,resy)
	end
	if self.intscaling then
		self.scalesize = math.floor(self.scalesize)
	end
	if not forceres then
		self.scalexoffset = math.floor((resx - (self.cwidth * self.scalesize)) * 0.5)
		self.scaleyoffset = math.floor((resy - (self.cheight * self.scalesize)) * 0.5)
	else
		self.scalexoffset = 0
		self.scaleyoffset = 0
	end
end

function Scaler:cornerscale(sc)
	self.scalesize = math.min(854 / self.cwidth, 480 / self.cheight)
	self.scalexoffset = 0
	self.scaleyoffset = 0
	
end

function Scaler:getmouse(ox,oy,resx,resy,cx,cy)
	local mx = ((mouse.x*project.res.x) - ox) / self.scalesize
	local my = ((mouse.y*project.res.y) - oy) / self.scalesize
	if cx then
		
		--print(self.scalesize)
		--cx,cy = self:calccam(cx,cy,resx,resy)
		mx = mx - (cx / self.scalesize) * 48
		my = my - (cy / self.scalesize) * 38
		--print(mx,my)
	end
		
	return mx,my
end

function Scaler:startcanvas()
	love.graphics.setCanvas(self.canvas)
end

function Scaler:endcanvas()
	love.graphics.setCanvas()
end

function Scaler:calccam(cx,cy,resx,resy)
	resx = resx or project.res.x
	resy = resy or project.res.y
	
	cx = (math.floor(cx+0.5)) 
	cy = (math.floor(cy+0.5))-- + (math.floor(self.cheight / 2)*self.scalesize)
	
	cx =  (self.scalesize * cx) - (resx / 2)
	cy =  (self.scalesize * cy) - (resy / 2)
	
	cx = math.min(math.max(0,cx),self.cwidth*self.scalesize - resx)
	cy = math.min(math.max(0,cy),self.cheight*self.scalesize - resy)
	return cx * -1, cy * -1 
end
function Scaler:drawcanvas(c,camx,camy,ox,oy,resx,resy,rawcam)
	ox = ox or 0
	oy = oy or 0
	color()
	c = c or self.canvas
	if c then
		if camx then
			if not rawcam then
				camx, camy = self:calccam(camx,camy,resx,resy)
			end
			love.graphics.draw(c, 
				camx + ox,
				camy + oy,
				0, self.scalesize, self.scalesize)
		else
			love.graphics.draw(c, self.scalexoffset+ox, self.scaleyoffset+oy, 0, self.scalesize, self.scalesize)
		end
	end
end

function Scaler:update(dt)
  prof.push("scaler update")
  prof.pop("scaler update")
end

function Scaler:draw()
  prof.push("scaler draw")
	self:drawcanvas()
  prof.pop("scaler draw")
end

return Scaler