LevelManager = class('LevelManager',Entity)

function LevelManager:initialize(params)
  
  
	self.skiprender = true
	self.skipupdate = true
	
	self.mapper = {}
	self.mapper['.'] = 'floor'
	self.mapper['X'] = 'pit'
	self.mapper['#'] = 'wall'
	self.mapper['p'] = 'playerspawn'
	self.mapper['?'] = 'goal'
	self.mapper['b'] = 'box'
	self.mapper['n'] = 'nullbox'
	self.mapper['c'] = 'chainbox'
	self.mapper['k'] = 'pickybox'
	
	
	self.mapper_inv = {}
	for k,v in pairs(self.mapper) do
		self.mapper_inv[v] = k
	end
  
	self.mapper_inv['empty'] = ' '
	
  Entity.initialize(self,params)
end

function LevelManager:loadproperties(filename,rawtext)
	if rawtext then
		print('loading raw')
		levelstring = rawtext
	else
		
		levelstring = love.filesystem.read(cs.basedir..'levels/'..filename..".txt")
	end
	
	local level = {}
	level.name = 'I AM ERROR.'
	
	if not levelstring then
		return level
	end
	
	local split = {}
	for v in string.gmatch(levelstring, '([^;]+)') do --split by ;
		v = helpers.trim(v)
		if v ~= "" then
			table.insert(split,v)
		end
	end
	
	
	for i,v in ipairs(split) do --parse the properties
		local name = helpers.startswith(v,'NAME=')
		
		if name then
			level.name = name
		end
		--add more level properties if they are added
	end
	
	return level
	
	
end

function LevelManager:loadlevel(filename,grid,static,rawtext,editor)
	grid.static = static or grid.static
	
	local levelstring = ''
	if rawtext then
		print('loading raw')
		levelstring = rawtext
	else
		
		levelstring = love.filesystem.read(cs.basedir..'levels/'..filename..".txt")
		
	end
	
	
	local split = {}
	for v in string.gmatch(levelstring, '([^;]+)') do --split by ;
		v = helpers.trim(v)
		if v ~= "" then
			table.insert(split,v)
		end
	end
	
	local level = {}
	level.filename = filename 
	level.layers = {}
	
	
	
	local function parselayer(s,layer)
		
		local lines = {}
		for v in string.gmatch(s, '([^\r\n]+)') do
			table.insert(lines,v)
		end
		
		for i,v in ipairs(lines) do
			local y = i - 1
			
			for _i=1,#v do
				local x = _i - 1
				local c = string.sub(v,_i,_i)
				if self.mapper[c] then
					grid:add(self.mapper[c],x,y,layer)
				end
			end
				
			
		end
		
	end
	
	local toparse = {
		layer0 = nil,
		layer1 = nil,
		size = nil
	}
	
	level.camwidth = 6
	level.camheight = 6
	
	for i,v in ipairs(split) do --parse the properties
		local name = helpers.startswith(v,'NAME=')
		local size = helpers.startswith(v,'SIZE=')
		local layer0 = helpers.startswith(v,'LAYER0=')
		local layer1 = helpers.startswith(v,'LAYER1=')
		local camerasize = helpers.startswith(v,'CAMERASIZE=')
		
		if name then
			level.name = name
		end
		if size then
			local w,h = string.match(size,"(.+)x(.+)")
			level.width = tonumber(w)
			level.height = tonumber(h)
			
			toparse.size = true
		end
		if layer0 then
			
			
			toparse.layer0 = layer0
		end
		if layer1 then
			toparse.layer1 = layer1
		end
		
		if camerasize then
			local w,h = string.match(camerasize,"(.+)x(.+)")
			level.camwidth = tonumber(w)
			level.camheight = tonumber(h)
			level.usecamera = true
		end
		
	end
	
	
	
	if toparse.size then
		grid:setup(level,2,editor)
	end
	if toparse.layer0 then
		parselayer(toparse.layer0,0)
	end
	if toparse.layer1 then
		parselayer(toparse.layer1,1)
	end
		
	
	return level
	
	
end

function LevelManager:resizelevel(grid,level)
	--This function is only for the level editor, if we need to resize grids in-game, a different solution will be needed.
	local newgrid = em.init('gridmanager',{static = true})
	newgrid.scaler.intscaling = false
	newgrid:setup(level,2)
	
	for y=0,level.height-1 do
		for x=0,level.width-1 do
			for z=0,1 do
				local tile = grid:get(x,y,z)
				if tile then
					newgrid:add(tile.name,x,y,z)
				end
				
			end
			
		end
	end
	return newgrid
	
end

function LevelManager:savelevel(grid,level,filename)
	

	
	local layerstr = {}
	layerstr[0] = ''
	layerstr[1] = ''
	
	for y=0,level.height-1 do
		for z=0,1 do
			for x =0,level.width-1 do
				local t = grid:get(x,y,z)
				local c = self.mapper_inv[t.name]
				layerstr[z] = layerstr[z] .. c
			end
			layerstr[z] = layerstr[z] .. '\n'
		end
	end
	
	
	local ls = ''
	
	
	ls = ls .. 'NAME=' .. level.name .. ';\n\n' 
	ls = ls .. 'SIZE=' .. level.width .. 'x' .. level.height .. ';\n\n' 
	
	if level.usecamera then
		ls = ls .. 'CAMERASIZE=' .. level.camwidth .. 'x' .. level.camheight .. ';\n\n' 
	end
		
	
	ls = ls .. 'LAYER0=\n' .. layerstr[0] .. ';\n\n' 
	ls = ls .. 'LAYER1=\n' .. layerstr[1] .. ';\n' 
	
	print('saving level!')
	love.filesystem.createDirectory(cs.basedir..'levels')
	love.filesystem.write(cs.basedir..'levels/'..filename .. '.txt',ls)
	
	
end




function LevelManager:update(dt)
end

function LevelManager:draw()
end

return LevelManager