--[[
/***************************************************************************************************************
*
*  PROJECT:     dxGUI
*  LICENSE:     See LICENSE in the top level directory
*  FILE:        components/dxEdit.lua
*  PURPOSE:     All edit functions.
*  DEVELOPERS:  Skyline <xtremecooker@gmail.com>
*
*  dxGUI is available from http://community.mtasa.com/index.php?p=resources&s=details&id=4871
*
****************************************************************************************************************/
]]

local cornerSize = 12;
local lastClickedEditBox;

-- It won't work.Because It doesn't add to the render. No, now it works! Thanks octoplatypus
--[[!
	Crea un campo de texto editable.
	@param x Es la coordenada x de la posición del campo
	@param y Es la coordenada y de la posición del campo
	@param width Es la anchura del campo
	@param height Es la altura del campo
	@param text Es el texto que posee inicialmente el campo
	@param relative Indica si la posición y las dimensiones indicadas son relativas al elemento padre
	@param parent Es el elemento padre de este campo editable, por defecto dxGetRootPane()
	@param color Es el color del campo, por defecto white
	@param font Es la fuente de texto, por defecto "default"
	@param theme Es el estilo, por defecto, dxGetDefaultTheme()
]]
function dxCreateEdit(x,y,width,height,text,relative,parent,color,font,theme)
	-- check args
	checkargs("dxCreateEdit", 1, "number", x, "number", y, "number", width, "number", height, "string", text, "boolean", relative);
	checkoptionalcontainer("dxCreateEdit", 7, parent);
	checkoptionalargs("dxCreateEdit", 8, "number", color, "string", font, {"string", "dxTheme"}, theme);
	
	x, y, width, height = trimPosAndSize(x, y, width, height, relative, parent);
	
	if not parent then
		parent = dxGetRootPane()
	end
	
	if not font then
		font = "default"
	end
	
	if not color then
		color = tocolor(255,255,255,255)
	end
	
	if not theme then
		theme = dxGetDefaultTheme()
	end
	
	if type(theme) == "string" then
		theme = dxGetTheme(theme)
	end
	
	assert(theme, "dxCreateEdit din´t find the main theme");
	
	local index;
	if text:len() > 0 then 
		index = 1;
	else 
		index = 0;
	end;
	
	local edit = createElement("dxEdit")
	setElementParent(edit,parent)
	setElementData(edit,"resource",sourceResource)
	setElementData(edit,"x",x)
	setElementData(edit,"y",y)
	setElementData(edit,"width",width)
	setElementData(edit,"height",height)
	setElementData(edit,"color",color)
	setElementData(edit,"font",font)
	setElementData(edit,"theme",theme)
	setElementData(edit,"visible",true)
	setElementData(edit,"text",text)
	setElementData(edit,"hover",false)
	setElementData(edit,"parent",parent)
	setElementData(edit,"readonly",false)
	setElementData(edit,"caret",-1)
	setElementData(edit,"index",index)
	setElementData(edit,"masked",false)
	setElementData(edit,"maxlength",-1)
	setElementData(edit,"postGUI",false)
	setElementData(edit,"ZOrder",getElementData(parent,"ZIndex")+1)
	setElementData(parent,"ZIndex",getElementData(parent,"ZIndex")+1)
	
	-- what to do if edit box text change ? 
	addEventHandler("onClientDXPropertyChanged", edit, 
		function(dataName, dataValue)
			if dataName == "text" then 
				triggerEvent("onClientDXChanged", edit, edit);
			end;
		end, false);
	
	-- handle clicks on this edit box
	addEventHandler("onClientDXClick", edit, 
		function(clickButton, clickState, absoluteX, absoluteY)
		
			if clickButton ~= "left" then return; end;
			guiSetInputEnabled(true);
		
			local function removeEditBoxInput()
				-- lose input
				if not getElementData(lastClickedEditBox, "clicked") then 
					guiSetInputEnabled(false);
				end;
				removeEventHandler("onClientClick", root, removeEditBoxInput);
			end;
			lastClickedEditBox = source;
			addEventHandler("onClientClick", root, removeEditBoxInput);
			
			local tx, ty = dxGetPosition(source, false);
			local px, py = dxGetPosition(getElementParent(source), false);
			local w = getElementData(source, "width");
			local x, y = absoluteX-px-tx, absoluteY-py-ty;
			local offset = x - cornerSize;
			
			-- now, move the cursor of the edit box...
			local text = getElementData(source, "text");
			if text:len() > 0 then 
				local index = getElementData(source, "index");
				
				if offset <= 0 then 
					setElementData(source, "caret", 1);
					triggerEvent("onClientDXPropertyChanged",source,"caret",caret)
				else 
					-- Added 2 units so that user can click between two caracters and the caret would point to the character on
					-- the right.
					local leftSideText = getEmbeddedText(text:sub(index), offset+2, font, 1); 

					setElementData(source, "caret", leftSideText:len() + 1);
					triggerEvent("onClientDXPropertyChanged",source,"caret",caret)
				end;
			else 
				setElementData(source, "caret", 0);
				triggerEvent("onClientDXPropertyChanged",source,"caret",caret)
			end;
			
		end, false);
	return edit
end

--[[!
	@return Devuelve la posición del caret(cursor de texto) o -1 si el caret no está posicionado
	en el texto. Devuelve 0 si el cursor está posicionado en el campo pero no hay texto.
]]
function dxEditGetCaret(dxElement)
	-- check args
	checkargs("dxEditGetCaret", 1, "dxEdit", dxElement);
	return getElementData(dxElement,"caret")
end

--[[!
	@return Devuelve un valor booleano indicando si bién este campo es de solo lectura.
]]
function dxEditIsReadOnly(dxElement)
	-- check args
	checkargs("dxEditIsReadOnly", 1, "dxEdit", dxElement);

	return getElementData(dxElement,"readonly")
end

--[[!
	@return Devuelve un valor booleano indicando si se usa una máscara para el texto de este
	campo editable.
]]
function dxEditIsMasked(dxElement)
	-- check args
	checkargs("dxEditIsMasked", 1, "dxEdit", dxElement);
	return getElementData(dxElement,"masked")
end

--[[!
	@return Devuelve la longitud máxima del texto de un campo editable.
]]
function dxEditGetMaxLength(dxElement)
	checkargs("dxEditGetMaxLength", 1, "dxEdit", dxElement);
	return getElementData(dxElement,"maxlength")
end


--[[!
	Establece la posición del cursor de texto.
	@param dxElement Es el campo editable
	@param caret Es la nueva posición del caret, que debe ser un número mayor que 0.
	@note Si la nueva posición del caret es mayor que la longitud máxima del texto + 1, el caret tendrá valor 
	igual a la longitud máxima + 1 del texto. 
	@note Si el texto del campo editable, es una cadena vacía, el valor del caret será 0 (el caret aparecerá
	en el campo pero no hay texto)
]]
function dxEditSetCaret(dxElement,caret)
	checkargs("dxEditSetCaret", 1, "dxEdit", dxElement, "number", caret);
	assert(caret >= 0, "Text cursor position must be a non negative number");
	local text = getElementData(dxElement, "text");
	local index = getElementData(dxElement, "index");
	if text:len() > 0 then 
		caret = math.min(caret, text:len());
	else 
		caret = 0;
	end;
	-- change index if needed... 
	if caret < index then 
		setElementData(dxElement, "index", caret);
		triggerEvent("onClientDXPropertyChanged",dxElement,"index",caret)
	elseif caret > index then 
		local newIndex = index;
	
		while dxGetTextWidth(text:sub(newIndex, caret), 1, font) >= (w-2*cornerSize) do 
			newIndex = newIndex + 1;
		end;
		if newIndex ~= index then 
			setElementData(dxElement, "index", newIndex);
			triggerEvent("onClientDXPropertyChanged",dxElement,"index",newIndex)
		end;
	end;
	
	setElementData(dxElement,"caret", caret)
	triggerEvent("onClientDXPropertyChanged",dxElement,"caret",caret)
end

--[[!
	Indica si el campo editable será solo lectura.
	@param dxElement Es el campo
	@param readonly Valor booleano indicando si el campo será solo lectura.
]]
function dxEditSetReadOnly(dxElement,readonly)
	-- check args.
	checkargs("dxEditSetReadOnly", 1, "dxEdit", dxElement, "boolean", readonly);

	setElementData(dxElement,"readonly",readonly)
	triggerEvent("onClientDXPropertyChanged",dxElement,"readonly",readonly)
end

--[[!
	Indica si el texto del campo editable usa una máscara
	@param dxElement Es el campo
	@param masked Valor booleano que indica si el texto usará una máscara.
]]
function dxEditSetMasked(dxElement,masked)
	checkargs("dxEditSetMasked", 1, "dxEdit", dxElement, "boolean", masked);

	setElementData(dxElement,"masked",masked)
	triggerEvent("onClientDXPropertyChanged",dxElement,"masked",masked)
end

--[[!
	Establece la longitud máxima del texto de un campo editable
	@param dxElement Es el campo editable
	@param maxlen Es la nueva longitud máxima del texto. Debe ser un número no negativo
	@note Si la nueva longitud máxima es inferior a la longitud del texto actual, el texto actual
	será recortado.
]]
function dxEditSetMaxLength(dxElement,maxlen)
	checkargs("dxEditSetMaxLength", 1, "dxEdit", dxElement, "number", maxlen);
	assert(maxlen >= 0, "EditBox text maximum length must be a non-negative number");
	local text = getElementData(dxElement, "text");
	if maxlen < text:len() then 
		text = text:sub(maxlen);
		setElementData(dxElement, "text", text);
	end;
	
	setElementData(dxElement,"maxlength",maxlength)
	triggerEvent("onClientDXPropertyChanged",dxElement,"maxlength",maxlen)
end

-- render edit box
function dxEditRender(component, cpx, cpy, cpg, alphaFactor)
	local x, y = getElementData(component, "x")+cpx, getElementData(component, "y")+cpy;
	local w, h = getElementData(component, "width"), getElementData(component, "height");
	local color = multiplyalpha(getElementData(component, "color"), alphaFactor);
	local alpha = extractalpha(color);
	local font = getElementData(component, "font");
	local masked = getElementData(component, "masked");
	local editable = not getElementData(component, "readonly");
	local cTheme = getElementData(component, "theme");
	local caret = getElementData(component, "caret");
	local text = getElementData(component, "text");
	local index = getElementData(component, "index");

	w = math.max(w, 2*cornerSize);
	h = math.max(h, 2*cornerSize);
	
	-- Draw top left rounded corner.
	dxDrawImageSection(x, y, cornerSize, cornerSize,
		getElementData(cTheme,"EditBoxTopLeftCorner:X"),getElementData(cTheme,"EditBoxTopLeftCorner:Y"),
		getElementData(cTheme,"EditBoxTopLeftCorner:Width"),getElementData(cTheme,"EditBoxTopLeftCorner:Height"),
		getElementData(cTheme,"EditBoxTopLeftCorner:images"),0,0,0,tocolor(255,255,255,alpha), cpg) 
	-- Draw top right rounded corner.
	dxDrawImageSection(x+w-cornerSize, y, cornerSize, cornerSize,
		getElementData(cTheme,"EditBoxTopRightCorner:X"),getElementData(cTheme,"EditBoxTopRightCorner:Y"),
		getElementData(cTheme,"EditBoxTopRightCorner:Width"),getElementData(cTheme,"EditBoxTopRightCorner:Height"),
		getElementData(cTheme,"EditBoxTopRightCorner:images"),0,0,0,tocolor(255,255,255,alpha), cpg) 	
	-- Draw bottom left rounded corner
	dxDrawImageSection(x, y+h-cornerSize, cornerSize, cornerSize,
		getElementData(cTheme,"EditBoxBottomLeftCorner:X"),getElementData(cTheme,"EditBoxBottomLeftCorner:Y"),
		getElementData(cTheme,"EditBoxBottomLeftCorner:Width"),getElementData(cTheme,"EditBoxBottomLeftCorner:Height"),
		getElementData(cTheme,"EditBoxBottomLeftCorner:images"),0,0,0,tocolor(255,255,255,alpha), cpg) 	
	-- Draw bottom right rounded corner
	dxDrawImageSection(x+w-cornerSize, y+h-cornerSize, cornerSize, cornerSize,
		getElementData(cTheme,"EditBoxBottomRightCorner:X"),getElementData(cTheme,"EditBoxBottomRightCorner:Y"),
		getElementData(cTheme,"EditBoxBottomRightCorner:Width"),getElementData(cTheme,"EditBoxBottomRightCorner:Height"),
		getElementData(cTheme,"EditBoxBottomRightCorner:images"),0,0,0,tocolor(255,255,255,alpha), cpg) 	
	-- Draw background.
	dxDrawImageSection(x+cornerSize, y+cornerSize, w-2*cornerSize, h-2*cornerSize,
		getElementData(cTheme,"EditBoxBackground:X"),getElementData(cTheme,"EditBoxBackground:Y"),
		getElementData(cTheme,"EditBoxBackground:Width"),getElementData(cTheme,"EditBoxBackground:Height"),
		getElementData(cTheme,"EditBoxBackground:images"),0,0,0,tocolor(255,255,255,alpha), cpg) 
		
	-- Draw top border
	dxDrawImageSection(x+cornerSize, y, w-2*cornerSize, cornerSize,
		getElementData(cTheme,"EditBoxTopBorder:X"),getElementData(cTheme,"EditBoxTopBorder:Y"),
		getElementData(cTheme,"EditBoxTopBorder:Width"),getElementData(cTheme,"EditBoxTopBorder:Height"),
		getElementData(cTheme,"EditBoxTopBorder:images"),0,0,0,tocolor(255,255,255,alpha), cpg) 
	-- Draw left border
	dxDrawImageSection(x, y+cornerSize, cornerSize, h-2*cornerSize,
		getElementData(cTheme,"EditBoxLeftBorder:X"),getElementData(cTheme,"EditBoxLeftBorder:Y"),
		getElementData(cTheme,"EditBoxLeftBorder:Width"),getElementData(cTheme,"EditBoxLeftBorder:Height"),
		getElementData(cTheme,"EditBoxLeftBorder:images"),0,0,0,tocolor(255,255,255,alpha), cpg) 
	-- Draw right border.
	dxDrawImageSection(x+w-cornerSize, y+cornerSize, cornerSize, h-2*cornerSize,
		getElementData(cTheme,"EditBoxRightBorder:X"),getElementData(cTheme,"EditBoxRightBorder:Y"),
		getElementData(cTheme,"EditBoxRightBorder:Width"),getElementData(cTheme,"EditBoxRightBorder:Height"),
		getElementData(cTheme,"EditBoxRightBorder:images"),0,0,0,tocolor(255,255,255,alpha), cpg)
	-- Draw bottom border.
	dxDrawImageSection(x+cornerSize, y+h-cornerSize, w-2*cornerSize, cornerSize,
		getElementData(cTheme,"EditBoxBottomBorder:X"),getElementData(cTheme,"EditBoxBottomBorder:Y"),
		getElementData(cTheme,"EditBoxBottomBorder:Width"),getElementData(cTheme,"EditBoxBottomBorder:Height"),
		getElementData(cTheme,"EditBoxBottomBorder:images"),0,0,0,tocolor(255,255,255,alpha), cpg) 
	-- Draw the text on the background.
	if text:len() > 0 then 
		dxDrawText(text:sub(index), x+cornerSize, y+cornerSize, x+w-cornerSize, y+h-cornerSize, color, 1, font, "left", "center", 
					true, false, cpg); 
	end;
	
	-- Draw caret
	local caretHeight = 1.3 * dxGetFontHeight(scale, font);
	if caretHeight > (2*cornerSize) then caretHeight = 2*cornerSize; end;
	local space = (h - caretHeight) / 2;

	if(getElementData(component,"clicked") and (caret ~= -1)) then 
		local offset = cornerSize; 
		if (text:len() > 0) and (caret > 1) then 
			offset = offset + dxGetTextWidth(text:sub(index, caret - 1), 1,font);
		end;
		dxDrawLine(x+offset, y+space, x+offset, y+h-space, tocolor(0, 0, 0, 255), 2, cpg);
	end;
end;

--// Events
local function findClickedEditBox()
		local editBoxes = getElementsByType("dxEdit", root);
		if #editBoxes > 0 then 
			local i = 1;
			while (i < #editBoxes) and (not getElementData(editBoxes[i], "clicked")) do 
				i = i + 1;
			end;
			if getElementData(editBoxes[i], "clicked") then
				return editBoxes[i];
			end;
		end;
end;

addEventHandler("onClientCharacter", root, 
	function(character) 
		local clickedEditBox = findClickedEditBox();
		-- check if there is some edit box clicked and non-read-only
		if (not clickedEditBox) or getElementData(clickedEditBox, "readonly") then return; end;
		
		local x, w = getElementData(clickedEditBox, "x"), getElementData(clickedEditBox, "width");
		local index = getElementData(clickedEditBox, "index");
		local caret = getElementData(clickedEditBox, "caret");
		local text = getElementData(clickedEditBox, "text");
		local maxLength = getElementData(clickedEditBox, "maxlength");
		local font = getElementData(clickedEditBox, "font");
		
		if (maxLength ~= -1) and (text:len() == maxLength) then return; end;
		
		if text:len() > 0 then 
			text = text:sub(1,caret-1) .. character .. text:sub(caret);
		else
			text = character;
		end;
		caret = caret + 1;
		local newIndex = index;
		
		while dxGetTextWidth(text:sub(newIndex, caret), 1, font) >= (w-2*cornerSize) do 
			newIndex = newIndex + 1;
		end;
		if newIndex ~= index then 
			setElementData(clickedEditBox, "index", newIndex);
			triggerEvent("onClientDXPropertyChanged",clickedEditBox,"index",newIndex)
		end;
		setElementData(clickedEditBox, "caret", caret);
		setElementData(clickedEditBox, "text", text);
		triggerEvent("onClientDXPropertyChanged",clickedEditBox,"caret",caret)
		triggerEvent("onClientDXPropertyChanged",clickedEditBox,"text",text)
	end);
	
	

local function onKeyPressed(clickedEditBox, button)	
	local x, w = getElementData(clickedEditBox, "x"), getElementData(clickedEditBox, "width");
	local index = getElementData(clickedEditBox, "index");
	local caret = getElementData(clickedEditBox, "caret");
	local text = getElementData(clickedEditBox, "text");
	local font = getElementData(clickedEditBox, "font");
	
	
	if (button == "backspace") or (button == "arrow_l") then 
		if caret <= 1 then return; end;
		if button == "backspace" then 
			text = text:sub(1, caret - 2) .. text:sub(caret);
			setElementData(clickedEditBox, "text", text);
			triggerEvent("onClientDXPropertyChanged",clickedEditBox,"text",text)
		end;
		caret = caret - 1;
		if index > caret then 
			setElementData(clickedEditBox, "index", caret);
			triggerEvent("onClientDXPropertyChanged",clickedEditBox,"index",caret)
		end;
		setElementData(clickedEditBox, "caret", caret);
		triggerEvent("onClientDXPropertyChanged",clickedEditBox,"caret",caret)
	elseif button == "arrow_r" then 
		if caret > text:len() then return; end;

		caret = caret + 1;
		local newIndex = index;
		
		while dxGetTextWidth(text:sub(newIndex, caret), 1, font) >= (w-2*cornerSize) do 
			newIndex = newIndex + 1;
		end;
		if newIndex ~= index then 
			setElementData(clickedEditBox, "index", newIndex);
			triggerEvent("onClientDXPropertyChanged",clickedEditBox,"index",newIndex)
		end;
		setElementData(clickedEditBox, "caret", caret);
		triggerEvent("onClientDXPropertyChanged",clickedEditBox,"caret",caret)
	elseif button == "enter" then
		triggerEvent("onClientDXAccepted", clickedEditBox, clickedEditBox);
	end;
end



	
local keyRepetitionTimer;
local keyRepetitionInitTimer;

addEventHandler("onClientKey", root,
	function(key, pressed) 
		if not pressed then 
			if (key == "backspace") or (key == "arrow_l") or (key == "arrow_r") then 
				if isTimer(keyRepetitionInitTimer) then 
					killTimer(keyRepetitionInitTimer);
				elseif isTimer(keyRepetitionTimer) then 
					killTimer(keyRepetitionTimer);
				end;
			end;
		else
			local clickedEditBox = findClickedEditBox(); 
			-- check if there is some clicked edit box and non-read-only
			if (not clickedEditBox) or getElementData(clickedEditBox, "readonly") then return; end;	
			if (key == "backspace") or (key == "arrow_l") or (key == "arrow_r") then 
				onKeyPressed(clickedEditBox, key);
				if isTimer(keyRepetitionInitTimer) then 
					killTimer(keyRepetitionInitTimer);
				elseif isTimer(keyRepetitionTimer) then 
					killTimer(keyRepetitionTimer);
				end;
				keyRepetitionInitTimer = setTimer( 
					function(clickedEditBox, key) 
						if isElement(clickedEditBox) and getElementData(clickedEditBox, "clicked") then 
							keyRepetitionTimer = setTimer( 
								function(clickedEditBox)
									if isElement(clickedEditBox) and getElementData(clickedEditBox, "clicked") then 
										-- backsapce repetition !
										onKeyPressed(clickedEditBox, key);
									end;
								end, 50, 0, clickedEditBox, key);
							
						end;
					end, 510, 1, clickedEditBox, key);
			else
				onKeyPressed(clickedEditBox, key);
			end;
		end;
	end);