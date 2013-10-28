--------------------------------------------------------------
-- UTILITIES LIBRARY -----------------------------------------

-- Set up 
local class = {}

--------------------------------------------------------------
-- OVERRIDE / EXTEND FUNCTIONS -------------------------------

-- Override print() function to improve performance when running on device
local _print = print
if ( system.getInfo("environment") == "device" ) then
	print = function() end
else
	print = function( ... )

		-- Parse through the items
		local printStr = ""
		local args     = #arg
		if args == 0 then args = 1 ; end
		for i = 1, args do
			local value = arg[ i ]
			if value == nil then value = "nil" ; end

			if type( value ) == "table" then
				local tableStr = false
				for k, v in pairs( value ) do
					if tableStr == false then tableStr = "\t" .. tostring( k ) .. " = " .. tostring( v )
					else                      tableStr = tableStr .. "\n\t" .. tostring( k ) .. " = " .. tostring( v ) ; end
				end
				if tableStr == false then tableStr = tostring( value ) .. "\n\t<empty>"
				else                      tableStr = tostring( value ) .. "\n" .. tostring( tableStr ) ; end
				if i == 1 then printStr = tableStr
				else           printStr = printStr .. "\n" .. tableStr ; end
				if i < args then printStr = printStr .. "\n" ; end
			else
				printStr = printStr .. tostring( value )
				if i < args then printStr = printStr .. "\t" ; end
			end
		end

		_print( "\r                                                   \r" .. printStr )
	end
end

-- Extend string library to include catalisation
function string.capitalise( str )

	return (str:gsub("^%l", string.upper))

end

-- Extend string library to include other bits I use a lot
function string.keyValues( str, pat )

	pat         = pat or '[;:]'
	local pos   = str:find( pat, 1 )
	if not pos then return false, str ; end

	local key   = str:sub( 1, pos - 1 )
	local value = str:sub( pos + 1 )

	return key, value		

end
function string.trim( str )

   return ( str:gsub("^%s*(.-)%s*$", "%1") )
   
end
function string.replaceChar( pos, str, r )

    return str:sub(1, pos-1) .. r .. str:sub(pos+1)

end
function string.replaceStr( pos, str, r )

    return str:sub(1, pos-1) .. r .. str:sub(pos+r:len())

end

--------------------------------------------------------------
-- NEW FUNCTIONS ---------------------------------------------

function class.freeMemory()

	local function garbage ( event )
		collectgarbage( "collect" )
	end
	garbage()
	timer.performWithDelay( 1, garbage )

end

--------------------------------------------------------------
-- RETURN CLASS DEFINITION -----------------------------------

return class
