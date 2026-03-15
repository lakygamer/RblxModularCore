local MasterController = {}
local Services = {}
local Utilities = require(game.ServerScriptService.Core.Utilities)
local NonReplicatedCSGDictionaryService = game:GetService("NonReplicatedCSGDictionaryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Generate Global Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
RemotesFolder.Name = "Remotes"
RemotesFolder.Parent = ReplicatedStorage

--[[**
    Public Access for other scripts
    Usage: require(MasterController):GetService("EconomyService")
    @param name
    @return service: tabel | nil if no service is found
]]
function MasterController:GetService(name: string): any
	local service = Services[name]
	if not service then
		Utilities:Log(
			"MasterController",
			"Attempt to get non-existent service: " .. tostring(name),
			Utilities.LogLevels.WARN
		)
	end
	return service
end

--[[**
    Injects helper methods into service table
    This gives every service access to self:Log(), etc.
    
    Extendable to other methods
    @param service: string
]]
local function InjectDependencies(service): any
	service.Services = Services -- Inject Services Tabel into module (Callable via self.Services["XYZ])

	-- Logging Utilitie
	function service:Log(msg)
		Utilities:Log(service.Name, msg, Utilities.LogLevels.INFO)
	end
	function service:Warn(msg)
		Utilities:Log(service.Name, msg, Utilities.LogLevels.WARN)
	end
	function service:Error(msg)
		Utilities:Log(service.Name, msg, Utilities.LogLevels.ERROR)
	end
	function service:Fatal(msg)
		Utilities:Log(service.Name, msg, Utilities.LogLevels.FATAL)
	end

	function service:SafeCall(func, ...)
		return Utilities:SafeCall(service.Name, func, ...) --Return function outcome
	end

	-- Remotes Injection
	if service.Client then
		service.Client.Server = service
		for key, val in pairs(service.Client) do
			local remoteName = service.Name .. "_" .. key -- RemoteEventName (expl. EconomyService_AddGold)
			
            if val == "Event" then -- Remote Event
				local re = Instance.new("RemoteEvent")
				re.Name = remoteName
				re.Parent = RemotesFolder
				-- Handle Client -> Server
				re.OnServerEvent:Connect(function(player, ...)
					local handlerName = "Client_" .. key
					local handler = service[handlerName]

					if type(handler) == "function" then
						handler(service, player, ...) -- Call handler in service to handle response
					else
						service:Warn("Client called remote Event '" .. key .. "'but handler is not implemented.")
					end
				end)
				service.Client[key] = re

			elseif val == "Function" then -- Remote Function
				local rf = Instance.new("RemoteFunction")
				rf.Name = remoteName
				rf.Parent = RemotesFolder
				rf.OnServerInvoke = function(player, ...)
					local handlerName = "Client_" .. key
					local handler = service[handlerName]

					if type(handler) == "function" then
						return handler(service, player, ...) -- Call handler in service to handle response
					else
						service:Warn("Client invoked remote Function '" .. key .. "'but handler is not implemented.")
						return nil
					end
				end
				service.Client[key] = rf
			end
		end
	end
	return nil
end

--[[**
    Initiates MasterController
    Loads Services and Injects Dependencies

]]
function MasterController:Startup() : nil
    Utilities:Log("MasterController", "Booting Framework...")

    local servicesFolder = game.ServerScriptService:WaitForChild("Services")
    
    -- Define Search Paths for Services (Can be inserted with needed Service paths on runtime)
    local searchPaths = {
        servicesFolder,
    }
    --[[ Optional Loading of SearchPaths for multi Place setups.
    -- Loading place specific Services
	local optionalRoots = {"Game", "Hub", "Place"}
	for _,rootName in ipairs(optionalRoots) do
		local root = game.ServerScriptService:FindFirstChild(rootName)
		if root and root:FindFirstChild("Services") then
			table.insert(searchPahts, root.Services)
			Utilities:Log("MasterController", "Detected Context: "..rootName, Utilities.LogLevels.INFO)
		end
	end
    ]]

    -- Load Modules
    for _, folder in ipairs(searchPaths) do
        for _, module in ipairs(folder:GetChildren()) do
            if module:IsA("ModuleScript") then
                local success, result = Utilities:SafeCall("Loader", require, module) -- Require module in safe call
                if success and type(result) == "table" then
                    result.Name = result.Name or module.Name
                    if Services[result.Name] then
                        Utilities:Log("MasterController", "Duplicate Service Name: "..result.Name.." dropping second occurance", Utilities.LogLevels.ERROR)
                    else
                        InjectDependencies(result)
                        Services[result.Name] = result -- Insert Service into Service Table
                        Utilities:Log("MasterController", "Loaded "..result.Name)
                    end
                end
            end
        end
    end

    -- Call Init methods on all Services
    for _,service in pairs(Services) do
        if type(service.Init) == "function" then
            Utilities:SafeCall(service.Name, function()
                service:Init()
            end)
        end
    end

    -- Call Start once all Modules are correctly Initialized. This can be used for Cross dependencies
    for _,service in pairs(Services) do
        if type(service.Start) == "function" then
            task.spawn(function()
                Utilities:SafeCall(service.Name, function()
                    service:Start()
                end)
            end)
        end
    end

    Utilities:Log("MasterController", "Framework Started Successfully.")
    return nil
end

return MasterController
    