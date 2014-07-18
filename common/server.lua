

--[[!
	\file
	\brief Este es un script que debe ser incluido en todos los recursos a excepción
	del recurso module
]]

-- Añadimos una tabla de módulos cargados para evitar errores en dependencias circulares.
local __modules = {};

function loadModule(modulePath, environment)
	if not __modules[modulePath] then  
		if not environment then 
			environment = _G;
		end;
		local code = call(getResourceFromName("module"), "getModule", modulePath);
		local success, chunk = pcall(loadstring, code, nil, "t", environment);
		if not success then error("Failed to load script \"" .. modulePath .. ".lua\": " .. chunk); end;
		
		__modules[modulePath] = true;
		
		local msg;
		success, msg = pcall(chunk);
		if not success then error("Failed to load module \"" .. modulePath .. "\": " .. msg); end;
	end;
end;

importModule = loadModule;


-- Ejecutamos los scripts esenciales.
loadModule("core/server_loader");
