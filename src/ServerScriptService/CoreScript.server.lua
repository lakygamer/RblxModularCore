local MasterController = require(game.ServerScriptService.Core.MasterController)

local success, err = pcall(function()
    MasterController:Startup()
end)

if not success then
    error("Critical Framework Failure: "..tostring(err))
end