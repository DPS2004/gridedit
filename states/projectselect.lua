local st = Gamestate:new('projectselect')

st:setinit(function(self)
  self.scaler = em.init('scaler')
	
	self.scaler:setup(352,198)
	
	self.levelmanager = em.init('levelmanager')
	
	--create projects folder if it does not exist
	local info = love.filesystem.getInfo("projects")
	if not (info and info.type == 'directory') then
		love.filesystem.createDirectory('projects')
	end
	
	
	self:loadlist()
	
	self.cursor = 1
	
	
end)

function st:loadlist()
	
	--load the list of projects
	self.list = {}
	
	local files = love.filesystem.getDirectoryItems(project.projdirectory)
	for i,v in ipairs(files) do
		local config = dofile(project.projdirectory..'/'..v..'/config.lua')
		table.insert(self.list,{text = config.projectname, filename = v})
	end
	
end


st:setupdate(function(self,dt)
  if maininput:pressed('up') then
		self.cursor = self.cursor - 1
	end
	
	if maininput:pressed('down') then
		self.cursor = self.cursor + 1
	end

	
	self.cursor = ((self.cursor - 1) % #self.list) + 1
	
	
	if maininput:pressed('accept') then
		--load into a project
		print('loading '..self.list[self.cursor].filename)
		
		cs = bs.load('editor')
		
		
		
		cs.basedir = project.projdirectory .. '/' .. self.list[self.cursor].filename .. '/'
		cs.config = dofile(cs.basedir .. 'config.lua')
		
		local ftiles = love.filesystem.getDirectoryItems(cs.basedir..'tiles')
		local tiles = {}
		
		
		for i,v in ipairs(ftiles) do
			if string.sub(v,-4,-1) == '.png' then
				local tilename = string.sub(v,0,-5)
				local newtile = {}
				newtile.image = love.graphics.newImage(cs.basedir..'tiles/'..tilename..'.png')
				if love.filesystem.getInfo(cs.basedir..'tiles/'..tilename..'.lua') then
					newtile.script = dofile(cs.basedir..'tiles/'..tilename..'.lua')
				else
					newtile.script = {}
				end
				
				if newtile.script.yoffset then
					newtile.yoffset = yoffset
				else
					newtile.yoffset = 0
				end
				newtile.yoffset = newtile.yoffset + (newtile.image:getHeight() - cs.config.tilesize.y)
				tiles[tilename] = newtile
			end
		end
		
		tiles['empty'] = {
			image = love.graphics.newImage('assets/cross.png'),
			script = {
				drawfunc = function(x,y,cs,tile,editor)
					if editor then
						love.graphics.draw(tile.image,x,y,0,60/tile.image:getWidth(),60/tile.image:getHeight())
					else
						love.graphics.draw(tile.image,x,y,0,cs.grid.scalex/tile.image:getWidth(),cs.grid.scaley/tile.image:getHeight())
					end
				end,
				char = ' '
			},
			yoffset = 0
		}
		tiles['properties'] = {
			image = love.graphics.newImage('assets/editorproperties.png'),
			script = {
				drawfunc = function(x,y,cs,tile,editor)
					if editor then
						love.graphics.draw(tile.image,x,y,0,60/tile.image:getWidth(),60/tile.image:getHeight())
					else
						love.graphics.draw(tile.image,x,y,0,cs.grid.scalex/tile.image:getWidth(),cs.grid.scaley/tile.image:getHeight())
					end
				end
			},
			yoffset = 0
		}
		
		cs.tiles = tiles
		
		local pal = dofile(cs.basedir .. 'palette.lua')
		if pal[-1] then
			for i=0,cs.config.layers-1 do
				pal[i] = pal[-1]
			end
		end
		
		cs.palette = {}
		for i=0,cs.config.layers-1 do
			cs.palette[i] = {'empty','properties'}
			for _i,_v in ipairs(pal[i]) do
				table.insert(cs.palette[i],_v)
			end
		end
		
		
		
		
		cs:init()
	end
	
	
end)


function st:resize(x,y)
	self.scaler:updatescale()
end

st:setbgdraw(function(self)
  color('black')
  love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
end)

function st:drawlist()
  self.scaler:startcanvas()
	
	love.graphics.clear(0, 0, 0, 1)
	
	
	color('white')
	local offset = math.floor(self.cursor/24)
	for i,v in ipairs(self.list) do
		local text = '  ' .. v.text
		if i == self.cursor then
			love.graphics.print('>',1,i*8+100 - self.cursor * 8)
		end
		
		love.graphics.print(text,1,i*8+100 - self.cursor * 8)
		
	end
	
	color('red')
  love.graphics.print('Select a Project',1,1)
	
	
  color('red')
	
  self.scaler:endcanvas()
	
end
--entities are drawn here
st:setfgdraw(function(self)

	self:drawlist()
	
	self.scaler:drawcanvas()
end)

return st