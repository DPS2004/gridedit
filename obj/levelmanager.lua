LevelManager = class('LevelManager',Entity)

function LevelManager:initialize(params)
  
  
	self.skiprender = true
	self.skipupdate = true
	
	
  Entity.initialize(self,params)
end

function LevelManager:loadproperties_txt(filename,rawtext)
	local levelstring = ''
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

function LevelManager:loadlevel_txt(filename,grid,static,rawtext,editor)
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
	
	local mapper = {}
	for k,v in pairs(cs.tiles) do
		if v.script.char then
			mapper[v.script.char] = k
		end
	end
	
	
	
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
				if mapper[c] then
					grid:add(mapper[c],x,y,layer)
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


function LevelManager:loadlevel_json(filename,grid,static,rawtext,editor)
	grid.static = static or grid.static
	
	local levelstring = ''
	if rawtext then
		print('loading raw')
		levelstring = rawtext
	else
		
		levelstring = love.filesystem.read(cs.basedir..'levels/'..filename..".json")
		
	end
	local ltable = json.decode(levelstring)
	
	
	local level = {}
	level.filename = filename 
	
	--example
	--[[
	example = {
		properties = {
			name = 'test',
			width = 6,
			height = 6,
			camera = {
				width = 6,
				height = 6,
			}
		}
		grid = {
			{x=0,y=0,z=0,tile='empty'}
		}
	}
	]]--
	
	level.name = ltable.properties.name
	level.width = ltable.properties.width
	level.height = ltable.properties.height
	if ltable.properties.camera then
		level.usecamera = true
		level.camwidth = ltable.properties.camera.width
		level.camheight = ltable.properties.camera.height
	end
	
	
	
	
	grid:setup(level,cs.config.layers,editor)
	
	for i,v in ipairs(ltable.grid) do
		grid:add(v.tile,v.x,v.y,v.z)
	end
	
		
	
	return level
	
	
end

function LevelManager:resizelevel(grid,level)
	--This function is only for the level editor, if we need to resize grids in-game, a different solution will be needed.
	local newgrid = em.init('gridmanager',{static = true})
	newgrid.scaler.intscaling = false
	newgrid:setup(level,2)
	newgrid.scalex = cs.config.tilesize.x
	newgrid.scaley = cs.config.tilesize.y
	
	for y=0,level.height-1 do
		for x=0,level.width-1 do
			for z=0,1 do
				local tile = grid:get(x,y,z)
				if tile then
					newgrid:add(tile,x,y,z)
				else
					newgrid:add('empty',x,y,z)
				end
				
			end
			
		end
	end
	return newgrid
	
end

function LevelManager:savelevel_txt(grid,level,filename)
	
	
	local mapper_inv = {}
	for k,v in pairs(cs.tiles) do
		if v.script.char then
			mapper_inv[k] = v.script.char
		end
	end
	
	local layerstr = {}
	layerstr[0] = ''
	layerstr[1] = ''
	
	for y=0,level.height-1 do
		for z=0,1 do
			for x =0,level.width-1 do
				local t = grid:get(x,y,z)
				local c = mapper_inv[t]
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


function LevelManager:savelevel_json(grid,level,filename)
	
	
	
	local ltable = {}
	ltable.properties = {}
	
	ltable.grid = {}
	for y=0,level.height-1 do
		for z=0,1 do
			for x =0,level.width-1 do
				local t = grid:get(x,y,z)
				if t ~= 'empty' then
					table.insert(ltable.grid,{x=x,y=y,z=z,tile=t})
				end
			end
		end
	end
	
	
	
	ltable.properties.name = level.name
	ltable.properties.width = level.width
	ltable.properties.height = level.height
	
	if level.usecamera then
		ltable.properties.camera = {
			width = level.camwidth,
			height = level.camheight
		}
	end
		
	
	
	print('saving level!')
	love.filesystem.createDirectory(cs.basedir..'levels')
	
	dpf.savejson(cs.basedir..'levels/'..filename .. '.json',ltable)
	--love.filesystem.write(cs.basedir..'levels/'..filename .. '.json',json.encode(ltable))
	
	
end




function LevelManager:update(dt)
end

function LevelManager:draw()
end

return LevelManager