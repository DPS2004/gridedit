Textbox = class('Textbox',Entity)

function Textbox:initialize(params)
  
  self.skiprender = true
	self.skipupdate = true
  
	self.onclick = function()  print('textbox clicked') end
	
	self.onexit = function() end
	self.oncancel = function(textbox) textbox.visible = false end
	
	self.x = 100
	self.y = 100
	self.width = 100
	self.height = 100
	self.prompt = ''
	self.text = 'textbox'
	self.input = ''
	self.visible = true
	self.active = true
	
	self.numberonly = false
	self.intonly = false
	self.multiline = false
	self.clickaway = true
	self.cancellable = true
	
	
	
  Entity.initialize(self,params)
	
	self.focused = false
	self.cursortimer = 0
	self.cursor = false
	
	self.ignoreothers = 0
	
	
	
end

function Textbox:clear()
	self.input = ''
end

function Textbox:focus()
	self.focused = true
	cs:stopinput()
	self.ignoreothers = 1
end

function Textbox:update(dt,mx,my)
  prof.push("textbox update")
  
	if mouse.pressed == 1 then
		if helpers.inrect(self.x,self.width+self.x,self.y,self.height+self.y,mx,my) then
			self:onclick()
			self.focused = true
			cs:stopinput()
		elseif self.clickaway and (self.ignoreothers == 0) and self.focused then
			self.focused = false
			self:onexit()
			cs:startinput()
		end
	end
	
	if self.focused and maininput:pressed('enter') and (not self.multiline) then
		self.focused = false
		self:onexit()
		cs:startinput()
	end
	
	if self.focused and maininput:pressed('escape') and self.cancellable then
		self.focused = false
		self:oncancel()
		cs:startinput()
	end
	
	if self.focused then
		if tinput then
			if self.numberonly then
				if (tonumber(tinput) ~= nil or tinput == ".") or tinput == "-" then
					if (tonumber(tinput) ~= nil) or (not self.intonly) then
						self.input = self.input .. tinput
					end
				end
			else
				self.input = self.input .. tinput
			end
		end
		if texthelpers.backspacepressed then
			local byteoffset = utf8.offset(self.input, -1)
			if byteoffset then
				self.input = string.sub(self.input, 1, byteoffset - 1)
			end
		end
		if self.multiline and texthelpers.returnpressed then
			self.input = self.input .. '\n'
		end
		
		
		if maininput:down('ctrl') and maininput:pressed('c') then
			love.system.setClipboardText(self.input)
		end
		
		if maininput:down('ctrl') and maininput:pressed('v') then
			self.input = self.input .. love.system.getClipboardText()
		end
		
	end
	
	self.cursortimer = self.cursortimer + dt
	if self.cursortimer >= 30 then
		self.cursortimer = self.cursortimer - 30
		self.cursor = not self.cursor
	end
	if self.ignoreothers > 0 then
		self.ignoreothers = self.ignoreothers - 1
	end
	
  prof.pop("textbox update")
	
end

function Textbox:draw()
  prof.push("textbox draw")
  color('grey')
  love.graphics.rectangle('line',self.x,self.y,self.width,self.height)
	
	local mytext = self.input
	
	if mytext == '' then
		mytext = self.text
	end
	
	
	if self.focused then
		color()
		mytext = self.input
		if self.cursor then
			mytext = mytext .. '|'
		end
	end
	
	love.graphics.printf(self.prompt..mytext,self.x,self.y, self.width,"left")
	color('grey')
	love.graphics.printf(self.prompt,self.x,self.y, self.width,"left")
	
  prof.pop("textbox draw")
end

return Textbox