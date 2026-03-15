local Service = { Name = "ExampleService" }

function Service:Init()
    self:Log("Initializing...")
    print("The Test is initializing")
end

function Service:Start()
    self:Log("Starting...")
    print("The Test is Starting")
    self:PrintTest()
end

function Service:PrintTest()
    print("Test")
end
return Service