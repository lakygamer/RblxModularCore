local Utilities = {}
local Players = game:GetService("Players")

Utilities.IsEmergency = false
Utilities.LogLevels = {
    INFO = "INFO",
    WARN = "WARN",
    ERROR = "ERROR",
    FATAL = "FATAL"
}

--[[**
    Standardized Logging
    @param source string
    @param message string
    @param level string
    @return nil
]]
function Utilities:Log(source:string, message:string, loglevel:string?) : nil
    local level = loglevel or self.LogLevels.INFO

    local timestamp = os.date("%X")
    local formattedMsg = string.format("[%s] [%s] [%s]: %s", timestamp,level,source,tostring(message))

    if level == self.LogLevels.INFO then
        print(formattedMsg)
    elseif level == self.LogLevels.WARN or level == self.LogLevels.ERROR then
        -- Warn and Error will only end in Warn as safe guard. Otherwise the whole execution loop will stop
        -- For Errors making the game unstable / unplayable Fatal is to be used.
        warn(formattedMsg) 
    end

    if level == self.LogLevels.FATAL then
        if not self.IsEmergency then
            self:TriggerEmergency(formattedMsg) -- Triggers try for gracefull exit
        end
        error(formattedMsg, 0)
    end
    return
end

--[[**
    Wraps function in protected call
    @param source
    @param func
    @param ... arguments
    @return (boolean, result)
]]
function Utilities:SafeCall(source:string, func, ...) : (boolean, any)
    if type(func) ~= "function" then
        self:Log(source,"Protected Call recived a non-function value.",self.LogLevels.ERROR)
        return false, "Protected Call recived a non-function value."
    end

	local success,result = xpcall(func, debug.traceback, ...)
	if not success then
		self:Log(source,result, self.LogLevels.ERROR)
		return false, result
	end
	return true,result
end

--[[**
 Triggers a server lockdown used when critical system failures occur
 @param reason 
 @return nil
**--]]
function Utilities:TriggerEmergency(reason) : nil
	if self.IsEmergency then return end
	self.IsEmergency = true
	for _,player in ipairs(Players:GetPlayers()) do
		player:Kick("Server Emergency: ".. reason .. "\n Unsaved Data might be lost. Contact Support on issues.")
	end

	Players.PlayerAdded:Connect(function(p)
		p:Kick("Server is in Emergency Mode. No new Joins are Allowed. Please try to rejoin a diffrent Server")
	end)
	return
end

return Utilities