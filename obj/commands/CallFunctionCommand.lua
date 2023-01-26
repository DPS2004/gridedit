local Command = require 'obj/commands/Command'
CallFunctionCommand = class("CallFunctionCommand", Command)

function CallFunctionCommand:initialize(execute, undo, info)
    CallFunctionCommand.super.initialize(self, info)
    self.onexecute = execute
    self.onundo = undo
end

function CallFunctionCommand:execute()
    self.onexecute()
end

function CallFunctionCommand:undo()
    self.onundo()
end


return CallFunctionCommand