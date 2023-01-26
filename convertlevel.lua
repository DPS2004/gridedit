lines = {}
for line in io.lines('input.txt') do
	table.insert(lines,line)
end

levelname = string.sub(table.remove(lines,1),9,-1)
table.remove(lines,1)

levelheight = #lines
levelwidth = #lines[1]
larray = {}
layer0 = {}
layer1 = {}

for i,v in ipairs(lines) do
	local y = i - 1 
	for _x = 1,#v do
		local x = _x - 1
		local c = string.sub(v,_x,_x)
		larray[x] = larray[x] or {}
		larray[x][y] = c
		
		layer0[x] = layer0[x] or {}
		layer0[x][y] = "~"
		
		layer1[x] = layer1[x] or {}
		layer1[x][y] = "~"
	end
	
end

local _WALL = '#'
local _FLOOR = '.'
local _PIT_IN = 'x'
local _PIT_OUT = 'X'
local _BLANK = ' '
local _PLAYER = 'p'
local _GOAL = '?'
local _BOX = 'b'
local _NULLBOX = 'n'
local _CHAINBOX = 'c'
local _PICKYBOX = 'k'

for x = 0,levelwidth - 1 do
	for y = 0,levelheight - 1 do
		local c = larray[x][y]
		
		if c == _WALL then
			layer0[x][y] = _FLOOR
			layer1[x][y] = _WALL
		end
		
		if c == _PIT_IN then
			layer0[x][y] = _PIT_OUT
			layer1[x][y] = _BLANK
		end
		
		if c == _FLOOR then
			layer0[x][y] = _FLOOR
			layer1[x][y] = _BLANK
		end
		
		if c == _PLAYER then
			layer0[x][y] = _FLOOR
			layer1[x][y] = _PLAYER
		end
		
		if c == _GOAL then
			layer0[x][y] = _GOAL
			layer1[x][y] = _BLANK
		end
		
		if c == _BOX then
			layer0[x][y] = _FLOOR
			layer1[x][y] = _BOX
		end
		
		if c == _NULLBOX then
			layer0[x][y] = _FLOOR
			layer1[x][y] = _NULLBOX
		end
		
		if c == _CHAINBOX then
			layer0[x][y] = _FLOOR
			layer1[x][y] = _CHAINBOX
		end
		
		if c == _PICKYBOX then
			layer0[x][y] = _FLOOR
			layer1[x][y] = _PICKYBOX
		end
		
	end

end


--actually save the file

file = io.open(levelname..'.txt','w')

function wr(str)
	file:write(str..'\n')
end

wr('NAME='..levelname..';')
wr('')
wr('SIZE='..levelwidth..'x'..levelheight..';')
wr('')
wr('LAYER0=')

for y = 0,levelheight-1 do
	local linestring = ''
	for x = 0,levelwidth - 1 do
		linestring = linestring .. layer0[x][y]
	end
	wr(linestring)
end

wr(';')

wr('')
wr('LAYER1=')

for y = 0,levelheight-1 do
	local linestring = ''
	for x = 0,levelwidth - 1 do
		linestring = linestring .. layer1[x][y]
	end
	wr(linestring)
end

wr(';')
file:close()