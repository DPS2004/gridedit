Gridmanager = class('Gridmanager', Entity)

function Gridmanager:initialize(params)

	self.layer = 0 -- lower layers draw first
	self.uplayer = 0 --lower uplayer updates first

	self.x = 0
	self.y = 0
	self.dx = 0
	self.dy = 0

	self.skiprender = true
	self.skipupdate = true

	self.scalex = 48
	self.scaley = 38

	Entity.initialize(self, params)

	self.objcount = 0

	self.easer = 0
	self.easing = false
	self.curease = nil

	self.callbacks = {}

	self.otypes = {}

	self.moved = false

	self.undoStack = {}

	self.scaler = em.init('scaler')
	self.scaler.intscaling = false
	
	self.cursor = {}
	self.cursor.x = 0
	self.cursor.y = 0
	self.editorlayer = 1
	
    self.doAfterEase = nil
	self.hasPendingCommands = false

end

function Gridmanager:setup(level, layers,editor)
	self.width = level.width
	self.height = level.height
	self.layers = layers
	self.g = {}
	
	self.usecamera = level.usecamera
	
	if self.usecamera then
		self.camwidth = level.camwidth
		self.camheight = level.camheight
	else
		self.camwidth = self.width
		self.camheight = self.height
	end

	self.objcount = 0
	self.callbacks = {
		update = {},
		beforeAction = {},
        afterAction = {},
        finalAction = {},
        afterEase = {},
		endAnimate = {}
	}


	self.otypes = {
		box = {},
		cross = {},
		empty = {},
		floor = {},
		goal = {},
		laser = {},
		pit = {},
		player = {},
		playerspawn = {},
		wall = {},
		nullbox = {},
		chainbox = {},
		pickybox = {}
	}


	for x = 0, self.width - 1 do
		self.g[x] = {}
		for y = 0, self.height - 1 do
			self.g[x][y] = {}
			for z = 0, layers - 1 do
				self:add('empty', x, y, z)
			end
		end
	end


	
	self.cwidth = self.width * self.scalex
	self.cheight = self.height * self.scaley
	local resx = nil
	local resy = nil
	if editor then
		resx = 854
		resy = 480
	end
	--self.canvas = love.graphics.newCanvas(self.cwidth, self.cheight)
	if self.usecamera then
		self.camscale = self.scaler:getscale(self.camwidth*self.scalex,self.camheight*self.scaley,resx,resy)
		print('using camera')
		print(resx,resy)
		self.scaler:setup(self.cwidth,self.cheight,self.camscale,resx,resy)
		
		self.camx = 0
		self.camy = 0
		self.camtarget = 'player'
	else
		self.scaler:setup(self.cwidth, self.cheight,nil,resx,resy)
		
	end

end

function Gridmanager:updatecamera(level)
	self.usecamera = level.usecamera
	
	if self.usecamera then
		self.camwidth = level.camwidth
		self.camheight = level.camheight
	else
		self.camwidth = self.width
		self.camheight = self.height
	end
	
	
	local resx = 854
	local resy = 480
	
	if self.usecamera then
		self.camscale = self.scaler:getscale(self.camwidth*self.scalex,self.camheight*self.scaley,resx,resy)
		self.scaler:setup(self.cwidth,self.cheight,self.camscale,resx,resy)
		
		self.camx = 0
		self.camy = 0
		self.camtarget = 'player'
	else
		self.scaler:setup(self.cwidth, self.cheight,nil,resx,resy)
		
	end
	
end



function Gridmanager:updatescale(resx,resy)
	if self.usecamera then
		local camscale = self.scaler:getscale(self.camwidth*self.scalex,self.camheight*self.scaley,resx,resy)
		self.scaler:setup(self.cwidth,self.cheight,camscale,resx,resy)
	else
		self.scaler:updatescale(nil,resx,resy)
	end
end
	

function Gridmanager:add(obj, x, y, z)
	local new = em.init('ge_' .. obj, { grid = self, x = x, y = y, z = z, id = self.objcount })
	self.objcount = self.objcount + 1

	
	if self.g[x] and self.g[x][y] then
    self.g[x][y][z] = new
	end
end

function Gridmanager:onInit()
    -- add an empty action, to run all the afterAction handlers
	-- can't be undone - check Gridmanager:undo()
    self:runAction({})
end

-- removes a gridobject from the grid
function Gridmanager:pluck(x, y, z)
    local obj = self.g[x][y][z]
	self.otypes[obj.name][obj.id] = nil
    self.g[x][y][z] = nil
	for k, v in pairs(self.callbacks) do
		v[obj.id] = nil
    end

	return obj
end

-- places an existing gridobject into the grid
function Gridmanager:emplace(obj, x, y, z)
	self.g[x][y][z] = obj
    self.otypes[obj.name][obj.id] = obj
	for k, v in pairs(obj.has) do
		if self.callbacks[k] then
			self.callbacks[k][obj.id] = obj
		end
	end
end


function Gridmanager:get(x, y, z)
	if self.g[x] and self.g[x][y] then
		if z then
			return self.g[x][y][z]
		else
			return pairs(self.g[x][y])
		end
	end
end






function Gridmanager:update(dt)
	prof.push("Gridmanager update")
	

	
    -- move each player on directional button push
	


	if self.scaler.canvas then
		
		local x,y = nil,nil
		if self.usecamera then
			x,y = self.scaler:getmouse(0,180,856,480,self.camx,self.camy)
		else
			x,y = self.scaler:getmouse(0,180,856,480)
		end
		self.cursor.x = math.floor(x / self.scalex)
		self.cursor.y = math.floor(y / self.scaley)
	end

	prof.pop("Gridmanager update")
end

function Gridmanager:drawlayer(z,c,ctrans,editor)
	
	local queue = deeper.init()
	for x = 0, self.width - 1 do
		for y = 0, self.height - 1 do
			
			local obj = self:get(x, y, z)
			queue.queue(obj.dy,function() 
				if ctrans and self.cursor.x == x and self.cursor.y == y and z == cs.edlayer then
					color(1,1,1,0.5)
				else
					color(c)
				end
					
				obj:draw(nil,editor) 
			end)
			--self:get(x,y,z):dbdraw()
		end
	end
	queue.execute()
end

function Gridmanager:drawtocanvas(editor)
	self.scaler:startcanvas()
	

	if self.layers then
		
		love.graphics.clear(0, 0, 0, 0)
		
		self:drawlayer(0,nil,true,editor)
		if cs.edlayer == 1 then
			
			self:drawlayer(1,nil,true,editor)
		else
			self:drawlayer(1,{1,1,1,0.5},true,editor)
		end
		
		color('black')
		love.graphics.setLineWidth(1)
		for x=0,self.width-1 do
			love.graphics.line(x*self.scalex,0,x*self.scalex,self.height*self.scaley)
		end
		for y=0,self.height-1 do
			love.graphics.line(0,y*self.scaley,self.width*self.scalex,y*self.scaley)
		end
		
		color()
		
		if cs.selectedindex then
			local spr = sprites.editorpalette[cs.layerpalettes[cs.edlayer][cs.selectedindex]]
			love.graphics.draw(spr[1],self.cursor.x*self.scalex,(self.cursor.y+1)*self.scaley-spr[2])
		end
		love.graphics.setLineWidth(1)
		love.graphics.rectangle('line',self.cursor.x*self.scalex,self.cursor.y*self.scaley,self.scalex,self.scaley)
		
		
	end
	self.scaler:endcanvas()
	
end




function Gridmanager:draw(editor)
	editor = true
	self:drawtocanvas(editor)
	if self.usecamera then
		
		love.graphics.setScissor(0,180,854,480)
		--(c,camx,camy,ox,oy,resx,resy)
		self.scaler:drawcanvas(nil,(self.camx)*self.scalex,(self.camy)*self.scaley,0,180,854,480,true)
		love.graphics.setScissor()
	else
		self.scaler:drawcanvas(nil,nil,nil,0,180)
	end
end


function Gridmanager:undo()
    print('<<<<<<<<<<<<< UNDO')

	-- dont want to undo the action added in Gridmanager:onInit
    if #self.undoStack <= 1 then return end
	
	self:endEase()
	local last = self.undoStack[#self.undoStack]
	for i = #last, 1, -1 do
		print(' - undoing command ' .. tostring(last[i]))
		last[i]:undo()
    end
	self:startease(false)
	table.remove(self.undoStack, #self.undoStack)
end

function Gridmanager:runAction(action)
	if self.runningAction then
        error('you\'re trying to run an action while an action is already running....'
            .. 'this is very wrong and will definitely break my already fragile code\n'
			.. 'use Gridmanager:appendAction if you want to add a new command to the most recently run action')
		return
	end
	self.runningAction = true
    table.insert(self.undoStack, action)
	self:endEase()
	self:startease(true)
	print('>>>>>>>>>>>>> ACTION')
    self:docallback('beforeAction')
	
    -- an empty action should still run afterAction
    -- maybe it's possible to rewrite the loop to make it happen
	-- without doing it explicitly here. i have no idea. i'm tired
	if #action == 0 then print("(empty action - calling afterAction)") self:docallback('afterAction') end
    local index = 1

    -- run each command, then run afterAction when we're out of them
	-- more commands can be appended in afterAction, in which case we run afterAction again
    while index <= #action do
        local command = action[index]
		print(' - running command: '.. tostring(command))
        command:execute()
        if index == #action then
			self.hasPendingCommands = false
			print(' -> calling afterAction')
			self:docallback('afterAction')
        end
		index = index + 1
	end
	
	self:docallback('finalAction') --for the really really really last minute stuff, no recursion though!
	while index <= #action do
		local command = action[index]
		print(' - running command: '.. tostring(command))
		command:execute()
		index = index + 1
	end
	
	
	self.runningAction = false
end

-- add a command to the most recently run action
-- only call this while an action is running..
function Gridmanager:appendLastAction(command)
	if not self.runningAction then
		error('you\'re trying to append a command even though there is no action running...'
		    ..'you probably meant to run a new action with Gridmanager:runAction')
	end
	if #self.undoStack <= 0 then error('undo stack is empty ]:') end
	self.hasPendingCommands = true

	print('   ++ appending command: ' .. tostring(command))
	local last = self.undoStack[#self.undoStack]
    table.insert(last, command)
end

local MoveTilesCommand = require('obj/commands/MoveTilesCommand')
function Gridmanager:push(from, direction)
	self:endEase()
    local pushes = self:get(from.x, from.y, from.z):gatherPushes(direction)
	
    if pushes == nil then return end

	local tileToTarget = {}

    for _, v in ipairs(pushes) do
		tileToTarget[v] = {
			x = v.x + direction.x,
			y = v.y + direction.y,
			z = v.z,
		}
	end

	local command = MoveTilesCommand(self, tileToTarget)
    self:runAction({ command })
end

return Gridmanager
