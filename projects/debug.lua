local project = {}

project.release = false

project.name = 'GridEdit'

project.initstate = 'projectselect'

--project.frameadvance = true

project.res = {}

project.res.x = 1280
project.res.y = 720


project.fullscreen = false

project.intscale = 2

-- project.res.x = 352 * 3
-- project.res.y = 198 * 3
-- project.res.s = 1

project.ctrls = {
  left = {"key:a","key:left",  "axis:leftx-", "button:dpleft"},
  right = {"key:d","key:right",  "axis:leftx+", "button:dpright"},
  up = {"key:w","key:up", "axis:lefty-", "button:dpup"},
  down = {"key:s", "key:down","axis:lefty+", "button:dpdown"},
  accept = {"key:space", "key:return", "button:a"},
  back = {"key:z", "button:b", "button:leftshoulder", "axis:triggerleft+"},
  restart = { "key:r" },
  undo = { "key:z" },
  quit = {"key:escape"},
  
  
  ctrl = {"key:lctrl"},
  l = {"key:l"},
  enter = {"key:return"},
  backspace = {"key:backspace"},
  c = {"key:c"},
  v = {"key:v"},
  escape = {"key:escape"},
  
  mouse1 = {"mouse:1"},
  mouse2 = {"mouse:2"},
  mouse3 = {"mouse:3"}
}


project.acdelt = true


project.projdirectory = "My Projects"


return project