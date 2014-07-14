

--[[!
	\file
	\brief Este script define utilidades para trabajar con tablas.
]]


--[[!
	Es un iterador para iterar sobre los elementos de una tabla de derecha a
	izquierda. Es igual que ipairs solo que iteramos comenzando desde el final
	y vamos en dirección opuesta.
]]
function ripairs(t) 
	if #t == 0 then
		return function() end, nil, nil;
	end;
	
	local function ripairs_it(t, index)
		index = index - 1;
		if (index > 0) then 
			return index, t[index];
		end;
	end;
	return ripairs_it, t, #t + 1;
end;




--[[!
	Iterador para iterar en una tabla recursivamente. Si un elemento es una tabla,
	si itera también sobre los elementos de dicha tabla. En cada iteración se devolverá
	un par de valores: Una tabla con las claves que hemos necesitado para llegar hasta dicho elemento, y el valor del elemento.
	Es igual que si iterasemos sobre los elementos de un árbol (en profundidad). Por cada nodo (tabla),
	se analizan primero los hijos (elementos de la tabla), antes de analizar el siguiente elemento que antecede 
	a esta tabla.
	@note Como pairs, el orden en que se analizan los elementos en el mismo nivel, no está definido.
	@note tdpairs = "tree deep pairs"
]] 
function tdpairs(t)
	-- Devolver un iterador tonto si no hay elementos.
	if #t == 0 then 
		return function() end, nil, nil;
	end;
	
	local function tdpairs_it(trace, index_trace) 
		-- Obtener el anterior elemento de la tabla que se estaba
		-- analizando.
		local t = trace[#trace];
		local index = index_trace[#index_trace];
		local value = t[index];
		
		-- El anterior elemento era una tabla no vacía ? 
		if (type(value) == "table") and next(value, nil) then 
			-- Descender de nivel.
			trace[#trace+1] = value;
			local index, value = next(value, nil);
			index_trace[#index_trace+1] = index;
			return index_trace, value;
		end;
		
		-- Tabla acabada ? 
		if not next(t, index) then 
			if #trace > 1 then 
				-- Subir de nivel.
				
				local level = trace[#trace];
				trace[#trace] = nil;
				index_trace[#index_trace] = nil;
				while (#trace > 1) and (not next(trace[#trace], index_trace[#index_trace])) do
					level = trace[#trace];
					trace[#trace] = nil;
					index_trace[#index_trace] = nil;
				end;
				--return nil;
				local index, value = next(trace[#trace], index_trace[#index_trace]);
				if index then 
					index_trace[#index_trace] = index;
					return index_trace, value;
				end;
				return nil;
			end;
			return nil;
		end; 
		
		index, value = next(t, index);
		if index then
			if #index_trace == 0 then 
				index_trace[1] = index;
			else
				index_trace[#index_trace] = index;
			end;
			return index_trace, value;
		end; 
		return nil;
	end; 
	return tdpairs_it, {t}, {};
end;


--[[!
	Igual que tdpairs, solo que las tablas que poseen elementos se iteran pero no se muestran en el resultado.
	(Al iterar, solo aparecerán las hojas del árbol (Elementos que no son tablas o tablas vacías)). Las tablas no vacías
	no saldrán, pero si se iterará sobre los elementos contenidos por dichas tablas.
	@note tdlpairs = "tree deep leaf pairs"
]]
function tdlpairs(t)
	-- Devolver un iterador tonto si no hay elementos.
	if #t == 0 then 
		return function() end, nil, nil;
	end;
	
	local function tdlpairs_it(trace, index_trace) 
		-- Obtener el anterior elemento de la tabla que se estaba
		-- analizando.
		local t = trace[#trace];
		local index = index_trace[#index_trace];
		local value = t[index];
		
		-- Tabla acabada ? 
		if not next(t, index) then 
			if #trace > 1 then 
				-- Subir de nivel.
				
				local level = trace[#trace];
				trace[#trace] = nil;
				index_trace[#index_trace] = nil;
				while (#trace > 1) and (not next(trace[#trace], index_trace[#index_trace])) do
					level = trace[#trace];
					trace[#trace] = nil;
					index_trace[#index_trace] = nil;
				end;
				--return nil;
				local index, value = next(trace[#trace], index_trace[#index_trace]);
				if index then 
					index_trace[#index_trace] = index;
					return index_trace, value;
				end;
				return nil;
			end;
			return nil;
		end; 
		
		index, value = next(t, index);
		if index then
			if #index_trace == 0 then 
				index_trace[1] = index;
			else
				index_trace[#index_trace] = index;
			end;
			-- El anterior elemento era una tabla no vacía ? 
			if (type(value) == "table") and next(value, nil) then 
				-- Descender de nivel.
				trace[#trace+1] = value;
				local index, value = next(value, nil);
				index_trace[#index_trace+1] = index;
				return index_trace, value;
			end;
			return index_trace, value;
		end; 
		return nil;
	end; 
	return tdlpairs_it, {t}, {};
end;


--[[!
	Igual que table.find solo que devuelve el primer elemento "v" tal que predicate(v) == true.
]]
function table.match(t, predicate)
	local index, value = next(t, nil);
	while index and (not predicate(value)) do 
		index, value = next(t, index);
	end;
	if (not predicate(value)) then 
		return nil;
	end;
	return index;
end;

--[[! Busca en una tabla uno o varios valores indicados como argumentos. 
Devuelve la primera coincidencia del valor en la tabla (La clave mediante la cual 
se obtiene el valor) o nil, si la busqueda no fue exitosa.
@note Se usa el iterador next para buscar el elemento. (El orden en el que se itera sobre
los elementos no está definido, y por consiguiente, si existieran varias coincidencias, no está 
definido cual sería la primera)
]]
function table.find(t, ...)
	local values = {...};
	if #values > 1 then 
		return table.match(t, function(value) return table.find(values, value); end);
	end;
	return table.match(t, function(value) return value == values[1]; end);
end;


--[[! Igual que table.match, solo que la busqueda es recursiva; Si se encuentra una tabla, se buscará también
en esta tabla los valores (si la tabla no es en sí una ocurrencia) 
Si se encuentra algún valor, es decir, si predicate(value) == true, la función devuelve la traza de índices que es necesaria
para acceder al elemento desde la raíz o nil si no ha habido coincidencias.
@note Se usa el iterador tdpairs, luego no se garantiza el orden en el que aparecen las ocurrencias de los valores
buscados en la tabla.
]]
function table.deep_match(t, predicate)
	local it, s, index_trace = tdpairs(t);
	local value;
	index_trace, value = it(s, index_trace);
	while index_trace and (not predicate(value)) do 
		index_trace, value = it(s, index_trace);
	end;
	if (not predicate(value)) then 
		return nil;
	end;
	return index_trace;
end;

--[[!
	table.recursive_match es un alias de table.deep_match
]]
table.recursive_match = table.deep_match;

--[[!
	Igual que table.find solo que la búsqueda es recursiva (para la búsqueda, se usa la funcion table.deep_match)
]]
function table.deep_find(t, ...)
	local values = {...};
	if #values > 1 then 
		return table.deep_match(t, function(value) return table.find(values, value); end);
	end;
	return table.deep_match(t, function(value) return value == values[1]; end);
end;

--[[!
	table.recursive_find es un alias de table.deep_find
]]
table.recursive_find = table.deep_find;



--[[!
	Igual que table.deep_match solo que no se consideran las ocurrencias de los valores que son tablas no vacías.
	Se busca dentro de las tablas no vacías pero estas no se consideran como solución para la búsqueda. 
	@note Se usa, en vez del iterador tdpairs, el iterador tdlpairs.
]]
function table.deep_tail_match(t, predicate)
	local it, s, index_trace = tdlpairs(t);
	local value;
	index_trace, value = it(s, index_trace);
	while index_trace and (not predicate(value)) do 
		index_trace, value = it(s, index_trace);
	end;
	if (not predicate(value)) then 
		return nil;
	end;
	return index_trace;
end;

function table.deep_tail_find(t, ...)
	local values = {...};
	if #values > 1 then 
		return table.deep_tail_match(t, function(value) return table.find(values, value); end);
	end;
	return table.deep_tail_match(t, function(value) return value == values[1]; end);
end;

--[[!
	table.recursive_tail_match es un alias de table.deep_tail_match
]]
table.recursive_tail_match = table.deep_tail_match;

--[[
	table.recursive_tail_find es un alias de tail.deep_tail_find
]]
table.recursive_tail_find = table.deep_tail_find;

