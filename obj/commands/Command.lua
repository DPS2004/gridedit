Command = class("Command")

function Command:initialize(info)
    self.info = info
end

function Command:execute()
    error(self.class.name .. ":execute() not implemented!")
end

function Command:undo()
    error(self.class.name .. ":undo() not implemented!")
end

function Command:__tostring()
    return self.class.name .. (self.info and (" --> " .. self.info) or "")
end

return Command