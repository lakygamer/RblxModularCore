# Roblox Modular Server Core
A Module Loader Core for Roblox Server Side Implementations

## Features
- Modular architector for services and utilities
- Centralized service management and error handeling
- Service Injection
- Remote Events hooks and handeling
- Extendable

## Structure
- [CoreScript.server.lua](src/ServerScriptService/CoreScript.server.lua): Main entry point for server-side logic
- [Services](src/ServerScriptService/Services/): Service Module Locations. Automaticly loaded by MasterController
- [MasterController.lua](src/ServerScriptService/Core/MasterController.lua): Main logic for loading and injections

## Getting Started
To get started consider using rojo as a syncing tool. For rojo a project file already exists. Scripts are usable with other synchronisations tools as well.
More infos on Rojo can be found here: [Rojo](https://rojo.space)
### Setup with Rojo
1. Clone the repository
2. Open terminal in repository root
3. Run `rojo serve`
4. Open roblox studio
5. Sync place via rojo plugin on `Port 34872`

### Non Rojo Setup
1. Clone the repository
2. Copy files into ServerScriptService
(`server.lua` are ServerScripts, `.lua` are ModuleScripts, Folders structure needs to be copied as well)


## Usage
New Services can be added by using [templateService.lua](templates/templateService.lua) <br>
By placing the file into [Services](src/ServerScriptService/Services/) the MasterController will automaticly load the Service on Start.

For eas of use there is a second template[1templateService.lua](templates/2templateService.lua) with no extensive comments

Shared Utilitie functions can be created in [Utilities.lua](src/ServerScriptService/Core/Utilities.lua) and need manual hooking in MasterController. Alternativly a service can be written with helper functions.

### Injections and Hooks
The template service [template](templates/templateService.lua) describes functionalities in depth.
Other Services can be called via 
```luau 
    local OtherService = self.Services["OtherService"]
    OtherService:Function2() -- Calls function from OtherService
```

Remote Events for Client Server Communication can be implemented over the Service.Client handle.
Remote Events and Functions need a handler implemented in the same service. If not they will be ignored by the MasterController.
```luau
Service.Client = {
    -- FunctionName = "FunctionType"
    MyEvent    = "Event",    -- One-way communication (FireClient / FireServer)
    MyFunction = "Function", -- Two-way communication (InvokeServer)
}
-- Handels MyEvent:FireServer()
function Service:Client_MyEvent(player, someArg)
    self:Log(player.Name .. " fired MyEvent with: " .. tostring(someArg))
end
-- Handles: Service.Client.MyFunction:InvokeServer()
function Service:Client_MyFunction(player)
    return "Response from Server"
end
``` 
## References
Rojo documentation: [Rojo](https://rojo.space)<br>
Roblox Engine: [Roblox Engine API](https://create.roblox.com/docs/reference/engine)

## License
This project is licensed under the GNU General Public License v3.0 (GPLv3)

See the [LICENSE](License.md) file for details.

Copyright © 2026 lakygamer