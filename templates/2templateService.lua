
local Service = { Name = "ExampleService" }

Service.Client = {
    MyEvent    = "Event",    
    MyFunction = "Function", 
}


function Service:Init()
    self:Log("Initializing...")
end

function Service:Start()
    self:Log("Starting...")
end

function Service:Client_MyEvent(player, someArg)
    self:Log(player.Name .. " fired MyEvent with: " .. tostring(someArg))
end

function Service:Client_MyFunction(player)
    return "Response from Server"
end

function Service:DoSomething()
end

return Service