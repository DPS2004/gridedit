local st = Gamestate:new('editor')

st:setinit(function(self)
	
	self.grid = em.init('gridmanager')
	self.grid.scalex = self.config.tilesize.x
	self.grid.scaley = self.config.tilesize.y
	
	self.scaler = em.init('scaler')
	self.scaler.intscaling = false
	self.scaler:setup(640,360)
	
	self.levelmanager = em.init('levelmanager')
	
	
	--dps2004 writes "worst ui code ever"
	--asked to leave bubbletabby
	
	self.ui = {}
	local function newui(ent,params)
		local btn = em.init(ent,params)
		table.insert(self.ui,btn)
		return btn
	end
	
	self.focused = true
	self.unfocusedthisframe = false
	
	self.loaded = false
	
	self.databutton = newui('button',{x=380,y=0,width=80,height=20,text='open data folder'})
	self.savebutton = newui('button',{x=460,y=0,width=80,height=20,text='save'})
	self.loadbutton = newui('button',{x=540,y=0,width=80,height=20,text='load'})
	self.newbutton = newui('button',{x=620,y=0,width=20,height=20,text='new'})
	self.layerbutton = newui('button',{x=0,y=70,width=40,height=20,text='Layer 1',visible = false})
	
	self.filenametext = newui('textbox',{x=0,y=0,width=200,height=20,prompt = 'filename: ',text='filename',visible = false,clickaway = false})
	self.nametext = newui('textbox',{x=520,y=40,width=120,height=20,prompt  = 'name: ', text = 'My Level',visible = false})
	
	
	self.areasizetext = newui('button',{x=470,y=80,width = 50, height = 20, text = 'area size', onclick = function() end,visible = false})
	self.widthtext = newui('textbox',{x=520,y=80,width=60,height=20,prompt = 'x: ', text = 16, visible = false, numberonly = true, intonly = true})
	self.heighttext = newui('textbox',{x=580,y=80,width=60,height=20,prompt = 'y: ', text = 9, visible = false, numberonly = true, intonly = true})
	
	self.cambutton = newui('button',{x=470,y=100,width = 50, height = 20, text = 'Cam OFF',visible = false})
	self.camwidthtext = newui('textbox',{x=520,y=100,width=60,height=20,prompt = 'x: ', text = 6, visible = false, numberonly = true, intonly = true})
	self.camheighttext = newui('textbox',{x=580,y=100,width=60,height=20,prompt = 'y: ', text = 6, visible = false, numberonly = true, intonly = true})
	
	self.databutton.onclick = function(button)
		love.system.openURL("file://"..love.filesystem.getSaveDirectory())
	end
	
	self.layerbutton.onclick = function(button)
		
		local oldindex = self.selectedindex
		self.selectedindex = self.selectedindex_last
		self.selectedindex_last = oldindex
		
		self.edlayer = (self.edlayer + 1) % self.config.layers
		
		button.text = 'Layer ' .. self.edlayer
	end
	
	self.savebutton.onclick = function(button) 
		
		if self.level then
			self.filenametext:clear()
			
			self.filenametext.input = self.level.filename or ''
			
			self.filenametext.onexit = function(textbox)
				print('save '.. textbox.input)
				textbox.visible = false
				self.level.filename = textbox.input
				self.levelmanager:savelevel(self.grid,self.level,self.filenametext.input)
				
			end
			
			self.filenametext.visible = true
			self.filenametext:focus()
		else
			print('no level to save!')
		end
		
	end
	
	self.loadbutton.onclick = function(button) 
		
		self.filenametext:clear()
		
		self.filenametext.text = ''
		
		self.filenametext.onexit = function(textbox)
			print('load '.. textbox.input)
			textbox.visible = false
			
			if love.filesystem.read(self.basedir..'levels/'..textbox.input..".txt")then
				self:loadlevel(textbox.input)
				self:showeditorui()
			else
				print('no level to load!')
			end
			
		end
		
		self.filenametext.visible = true
		self.filenametext:focus()
		
	end
	
	self.newbutton.onclick = function(button) 
		
		print('new level')
		
		self:loadlevel('newlevel',love.filesystem.read("data/leveltemplate.txt"))
		self:showeditorui()
		
	end
	
	if self.config.camera then
		self.cambutton.onclick = function(button)
			if self.level.usecamera then
				self.level.usecamera = false
				self.camwidthtext.visible = false
				self.camheighttext.visible = false
				self.cambutton.text = 'Cam OFF'
			else
				self.level.usecamera = true
				self.camwidthtext.visible = true
				self.camheighttext.visible = true
				self.cambutton.text = 'Cam ON'
			end
			self.grid:updatecamera(self.level)
		end
		
		self.camwidthtext.onexit = function(textbox)
			print('updating cam width')
			
			self.level.camwidth = tonumber(textbox.input)
			self.grid:updatecamera(self.level)
		end
		
		self.camheighttext.onexit = function(textbox)
			print('updating cam height')
			
			self.level.camheight = tonumber(textbox.input)
			self.grid:updatecamera(self.level)
		end
			
		
	else
		self.cambutton.visible = false
		self.camwidthtext.visible = false
		self.camheighttext.visible = false
	end
	
	self.nametext.onexit = function(textbox)
		print('updating level name')
		self.level.name = textbox.input
	end
	
	self.widthtext.onexit = function(textbox)
		print('updating level width')
		
		self.level.width = tonumber(textbox.input)
		self:resizelevel()
	end
	
	self.heighttext.onexit = function(textbox)
		print('updating level height')
		
		self.level.height = tonumber(textbox.input)
		self:resizelevel()
	end
	
	
	
	
	
	
	
	--[[
	self.palette = {}
	self.palette[0] = {
		'empty',
		'properties',
		'floor',
		'pit',
		'goal'
	}
	
	self.palette[1] = {
		'empty',
		'properties',
		'wall',
		'playerspawn',
		'box',
		'nullbox',
		'chainbox',
		'pickybox'
	}
	]]--
	self.edlayer = 1
	
	self.showpalettes = false
	
	self.selectedindex = 1
	self.selectedindex_last = 1
	
	self.lastplaced = {x=-1,y=-1}
	
	
end)


function st:showeditorui()
	self.layerbutton.visible = true
	self.nametext.visible = true
	self.widthtext.visible = true
	self.heighttext.visible = true
	self.areasizetext.visible = true
	self.cambutton.visible = true
	self.showpalettes = true
end


function st:stopinput()
	self.focused = true
	self.unfocusedthisframe = true
end

function st:startinput()
	if not self.unfocusedthisframe then
		self.focused = false
	end
end

function st:loadlevel(filename,raw)
	self.level = self.levelmanager:loadlevel(filename,self.grid,true,raw,true)
	self.grid:updatescale(854,480)
	
	self.nametext.input = self.level.name
	
	self.widthtext.input = self.level.width
	self.heighttext.input = self.level.height
	
	self.camwidthtext.input = self.level.camwidth
	self.camheighttext.input = self.level.camheight
	
	if self.level.usecamera then
		self.level.usecamera = true
		self.camwidthtext.visible = true
		self.camheighttext.visible = true
		self.cambutton.text = 'Cam ON'
		
		
	else
		self.level.usecamera = false
		self.camwidthtext.visible = false
		self.camheighttext.visible = false
		self.cambutton.text = 'Cam OFF'
	end
	
	self.loaded = true
end

function st:resizelevel(width,height)
	
	self.grid = self.levelmanager:resizelevel(self.grid,self.level)
	self.grid:updatescale(854,480)
	
end


st:setupdate(function(self,dt)
	self.focusedthisframe = false
	local mousex, mousey = mouse.x*1280,mouse.y*720
	for i,v in ipairs(self.ui) do
		if v.visible and v.active then
			v:update(dt,mousex/2,mousey/2)
		end
	end
	
	if self.focused then
		self.grid:update(dt,true)
		
		if self.showpalettes then
			print(self.edlayer)
			if helpers.inrect(0,#self.palette[self.edlayer]*60,660,660+60,mousex,mousey) then
				if mouse.pressed == 1 then
					self.selectedindex = math.floor(mousex / 60) + 1
				end
			end
		end
		
		if self.loaded then
			
			if self.grid.usecamera then
				if maininput:down('up') then
					self.grid.camy = self.grid.camy + 1
				end
				if maininput:down('down') then
					self.grid.camy = self.grid.camy - 1
				end
				if maininput:down('left') then
					self.grid.camx = self.grid.camx + 1
				end
				if maininput:down('right') then
					self.grid.camx = self.grid.camx - 1
				end
				
				self.grid.camx = math.max(math.min(0,self.grid.camx),(self.grid.width * self.grid.scaler.scalesize * -1) + math.floor(self.grid.camwidth * self.grid.scaler.scalesize))
				self.grid.camy = math.max(math.min(0,self.grid.camy),(self.grid.height * self.grid.scaler.scalesize * -1) + math.floor(self.grid.camheight * self.grid.scaler.scalesize))
			end
				
			
			if helpers.inrect(0,854,180,180+480,mousex,mousey) then
				
				
				if self.palette[self.edlayer][self.selectedindex] ~= 'properties' then
					if mouse.pressed >= 1 then
						if (self.lastplaced.x ~= self.grid.cursor.x) or (self.lastplaced.y ~= self.grid.cursor.y) then
							self.lastplaced.x = self.grid.cursor.x
							self.lastplaced.y = self.grid.cursor.y
							self.grid:add(self.palette[self.edlayer][self.selectedindex],self.grid.cursor.x,self.grid.cursor.y,self.edlayer)
						end
					else
						if mouse.altpress >= 1 then
							if (self.lastplaced.x ~= self.grid.cursor.x) or (self.lastplaced.y ~= self.grid.cursor.y) then
								self.lastplaced.x = self.grid.cursor.x
								self.lastplaced.y = self.grid.cursor.y
								local toadd = 'empty'
								if self.edlayer == 0 then
									toadd = 'pit'
								end
								self.grid:add(toadd,self.grid.cursor.x,self.grid.cursor.y,self.edlayer)
							end
						end
					end
				else
					if mouse.pressed >= 1 then
						if (self.lastplaced.x ~= self.grid.cursor.x) or (self.lastplaced.y ~= self.grid.cursor.y) then
							self.lastplaced.x = self.grid.cursor.x
							self.lastplaced.y = self.grid.cursor.y
							print('properties on '..self.grid.cursor.x..', '..self.grid.cursor.y)
						end
					end
					
				end
				
				if mouse.pressed == -1 or mouse.altpress == -1 then
					self.lastplaced = {x=-1,y=-1}
				end
				
			end
			
			
			
		end
		
	end
	
end)

function st:resize(x,y)
	self.scaler:updatescale()
	self.grid:updatescale(854,480)
	
end

st:setbgdraw(function(self)
  color('black')
  love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
end)
--entities are drawn here
st:setfgdraw(function(self)
  
	
	
	color('grey')
	love.graphics.setLineWidth(2)
	love.graphics.rectangle('line',0,180,854,480)
	
	color()
	
  self.grid:draw(true)
	
	
	
	
  self.scaler:startcanvas()
	
		love.graphics.clear(0, 0, 0, 0)
		color()
		for i,v in ipairs(self.ui) do
			if v.visible then
				v:draw()
			end
		end
		
		
  self.scaler:endcanvas()
	self.scaler:drawcanvas()
	if self.showpalettes then
		local distance = 60
		local spritescale = distance / self.grid.scalex 
		for i,v in ipairs(self.palette[self.edlayer]) do
			love.graphics.draw(sprites.editorpalette[v][1],(i-1)*distance,660,0,spritescale,spritescale)
			if self.selectedindex == i then
				love.graphics.setLineWidth(2)
				love.graphics.rectangle('line',(i-1)*distance,660,distance,distance)
			end
		end
	end
	
  
end)

return st