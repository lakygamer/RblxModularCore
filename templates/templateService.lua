--[[
    SERVICE TEMPLATE
    Use this as a base for new Services.
    
    FEATURES:
    - Lifecycle: Init() runs first, Start() runs after all services are initialized.
    - Injection: self:Log(), self:Warn(), self:SafeCall(), self:GetConfig() are auto-added.
    - Networking: Define remotes in .Client table. Handlers use Client_Prefix (needed when client calls remote or function).
]]

-- 1. Define Service Name
local Service = { Name = "ExampleService" }

-- 2. Define Network Interface (Optional)
-- MasterController will automatically create these Remotes in ReplicatedStorage/Remotes
Service.Client = {
    MyEvent    = "Event",    -- One-way communication (FireClient / FireServer)
    MyFunction = "Function", -- Two-way communication (InvokeServer)
}

--[[
    LIFECYCLE: INIT
    Called once at startup. Used for internal setup.
    Do NOT access other services here (they might not be ready).
]]
function Service:Init()
    self:Log("Initializing...")
    -- Example Load Config
end

--[[
    LIFECYCLE: START
    Called after all services have Init().
    Safe to access other services via self.Services.
]]
function Service:Start()
    self:Log("Starting...")

    -- Example: Access another service
    -- local Economy = self.Services.EconomyService
    
    -- Example: Fire a Remote to a client
    -- self.Client.MyEvent:FireAllClients("Hello World")
end

--[[
    NETWORK HANDLERS
    To handle Client -> Server calls, define functions with "Client_" prefix.
    The framework automatically binds these to the Remotes defined in Service.Client.
]]
-- Handles: Service.Client.MyEvent:FireServer()
function Service:Client_MyEvent(player, someArg)
    self:Log(player.Name .. " fired MyEvent with: " .. tostring(someArg))
end


-- Handles: Service.Client.MyFunction:InvokeServer()
-- MUST return a value
function Service:Client_MyFunction(player)
    return "Response from Server"
end

--[[
    PUBLIC API
    Methods intended to be used by other Server Scripts/Services.
]]
function Service:DoSomething()
    -- Use SafeCall for critical logic to prevent crashes
    self:SafeCall(function()
        -- Complex logic here
    end)
end

return Service