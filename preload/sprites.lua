local sprites = {}


sprites.cobblestone = love.graphics.newImage('assets/cobblestone.png')

sprites.box = love.graphics.newImage('assets/box.png')
sprites.nullbox = love.graphics.newImage('assets/nullbox.png')
sprites.chainbox = love.graphics.newImage('assets/chainbox.png')
sprites.pickybox = love.graphics.newImage('assets/pickybox.png') --TEMP
sprites.floor = love.graphics.newImage('assets/floor.png')
sprites.nova = love.graphics.newImage('assets/nova.png')
sprites.pit = love.graphics.newImage('assets/pit.png')
sprites.wall = love.graphics.newImage('assets/wall.png')
sprites.wall_bottom = love.graphics.newImage('assets/wall_bottom.png')
sprites.wall_top = love.graphics.newImage('assets/wall_top.png')
--sprites.laser = love.graphics.newImage('assets/laser.png')
sprites.cross = love.graphics.newImage('assets/cross.png')

sprites.goal = {}
sprites.goal.idle = love.graphics.newImage('assets/goal_idle.png')
sprites.goal.ready = love.graphics.newImage('assets/goal_ready.png')
sprites.goal.fail = love.graphics.newImage('assets/goal_fail.png')

sprites.editorproperties = love.graphics.newImage('assets/editorproperties.png')



sprites.editorpalette = {}
sprites.editorpalette.empty = {sprites.cross,43}
sprites.editorpalette.box = {sprites.box,48}
sprites.editorpalette.nullbox = {sprites.nullbox,48}
sprites.editorpalette.chainbox = {sprites.chainbox,48}
sprites.editorpalette.pickybox = {sprites.pickybox,48}
sprites.editorpalette.floor = {sprites.floor,38}
sprites.editorpalette.playerspawn = {sprites.nova,48}
sprites.editorpalette.pit = {sprites.pit,38}
sprites.editorpalette.wall = {sprites.wall,64}
sprites.editorpalette.goal = {sprites.goal.idle,38}
sprites.editorpalette.properties = {sprites.editorproperties,48}

return sprites