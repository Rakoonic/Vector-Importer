--------------------------------------------------------------
-- POLYGON FILE LOADER ---------------------------------------

-- Set up libraries
local JSON = require( "json" )

-- Set up 
local class = {}
local class_tm = { __index = class }

local mMin, mMax = math.min, math.max

--------------------------------------------------------------
-- SETUP -----------------------------------------------------

-- Create a new object
function class:new( params )

	-- Create the object
	obj = {}
	setmetatable( obj, class_tm )

	-- Copy across the parameters
	for k, v in pairs( params ) do
		obj[ k ] = v
	end

	-- Set properties if it is passed
	local group    = display.newGroup()
	obj.group      = group
	group.x        = params.x or 0
	group.y        = params.y or 0
	group.rotation = params.rotation or 0
	group.xScale   = params.scale or 1
	group.yScale   = params.scale or 1
	if params.parent then params.parent:insert( group ) ; end

	-- Load the file if there is one
	if obj.file then obj:loadJSON() ; end

	-- Return the object
	return obj

end

--------------------------------------------------------------
-- JSON ------------------------------------------------------

function class:loadJSON()

	-- Load raw data
	local rawData = class.loadFile( self.file, self.directory )
	if rawData == false then return false ; end

	-- Decode
	local data = JSON.decode( rawData )
	if data == nil then return false ; end

	-- Do something with it!
	for i = 1, #data do
		local properties = {}
		local polyData   = data[ i ]
		local lines      = {}
		for j = 1, #polyData do

			-- What type of data is this?
			for k, v in pairs( polyData[ j ] ) do
				if k == "line" then

--[[
					-- Start if needed
					if #lines == 0 then
						lines[ 1 ] = v[ 1 ]
						lines[ 2 ] = v[ 2 ]
					end
--]]

					-- End
					lines[ #lines + 1 ] = v[ 3 ]
					lines[ #lines + 1 ] = v[ 4 ]

				elseif k == "bezier" then

					-- Subdivide
					local segs, bounds = self:createBezier( v )

--[[
					-- Start if needed
					if #lines == 0 then
						lines[ 1 ] = segs[ 1 ]
						lines[ 2 ] = segs[ 2 ]
					end
--]]

					-- Adds in the bezier segments except the first point
					for l = 3, #segs do
						lines[ #lines + 1 ] = segs[ l ]
					end
				else
					properties[ k ] = v
				end
			end
		end

		-- Create the shape if it exists
		local points = #lines / 2
		if points >= 2 then

			-- Find the minimum values (else everything ends up in the same damn spot )
			local xMin, yMin = 1000000000, 1000000000
			local xMax, yMax = -1000000000, -1000000000
			for i = 1, points do
				xMin = mMin( xMin, lines[ i * 2 - 1 ] )
				yMin = mMin( yMin, lines[ i * 2 ] )
				xMax = mMax( xMax, lines[ i * 2 - 1 ] )
				yMax = mMax( yMax, lines[ i * 2 ] )
			end

			-- Create the shape
			local isLine = ( points == 2 )
			local shape
			if isLine == true then shape = display.newLine( self.group, lines[ 1 ], lines[ 2 ], lines[ 3 ], lines[ 4 ] )
			else                   shape = display.newPolygon( self.group, ( xMin + xMax ) / 2, ( yMin + yMax ) / 2, lines ) ; end

			-- Store bounds
			shape.bounds = { xMin = xMin, yMin = yMin, xMax = xMax, yMax = yMax }

			-- Set the fill
			local color = properties.fill
			if color then
				color[ 1 ] = color[ 1 ] / 255
				color[ 2 ] = color[ 2 ] / 255
				color[ 3 ] = color[ 3 ] / 255
			end
			if isLine == true then shape:setStrokeColor( unpack( color or self.fillColor or { 1, 0, 1 } ) )
			else                   shape:setFillColor( unpack( color or self.fillColor or { 1, 0, 1 } ) ) ; end

			-- Set the stroke
			local color = properties.stroke
			if color then
				color[ 1 ] = color[ 1 ] / 255
				color[ 2 ] = color[ 2 ] / 255
				color[ 3 ] = color[ 3 ] / 255
			end
			shape:setStrokeColor( unpack( color or self.strokeColor or { 1, 1, 1 } ) )
			if isLine then shape.width       = properties.strokeWidth or self.strokeWidth or 0
			else           shape.strokeWidth = properties.strokeWidth or self.strokeWidth or 0 ; end

			-- Set the alpha
			local opacity = properties.opacity
			if opacity then opacity = opacity / 100 ; end
			shape.alpha = opacity or self.alpha or 1
		end
	end

	-- Create the bounds
	self:setbounds()

	-- Return success
	return true

end

--------------------------------------------------------------
-- SVG -------------------------------------------------------

function class:loadSVG( params )

end

--------------------------------------------------------------
-- MISC ------------------------------------------------------

function class:setbounds()

	local xMin, yMin  = 1000000000, 1000000000
	local xMax, yMax  = -1000000000, -1000000000

	for i = 1, self.group.numChildren do
		local bounds = self.group[ i ].bounds
		xMin         = mMin( xMin, bounds.xMin )
		yMin         = mMin( yMin, bounds.yMin )
		xMax         = mMax( xMax, bounds.xMax )
		yMax         = mMax( yMax, bounds.yMax )
	end

	-- Store the bounds
	self.bounds = {
		xMin = xMin,
		yMin = yMin,
		xMax = xMax,
		yMax = yMax,
	}

end
function class:getCenter()

	return ( self.bounds.xMin + self.bounds.xMax ) / 2, ( self.bounds.yMin + self.bounds.yMax ) / 2
	
end
function class:getSize()

	return self.bounds.xMax - self.bounds.xMin, self.bounds.yMax - self.bounds.yMin

end

function class:createBezier( points )

	-- Create the line sections
	local startX       = points[ 1 ] -- p0
	local startY       = points[ 2 ]
	local endX         = points[ 7 ] -- p3
	local endY         = points[ 8 ]
	local cp1x         = points[ 3 ] -- p1
	local cp1y         = points[ 4 ]
	local cp2x         = points[ 5 ] -- p2
	local cp2y         = points[ 6 ]
	local segStartX    = startX
	local segStartY    = startY
	local segs         = { startX, startY }
	local subdivisions = self.bezierSubdivisions or 0
	local segEndX, segEndY
	for i = 1, subdivisions do
		local t   = i / ( subdivisions + 1 )
		local tt  = t * t
		local ttt = tt * t
		local u   = 1 - t
		local uu  = u * u
		local uuu = uu * u

		-- Calculate the end points
		segEndX =
			uuu * startX +
			3 * uu * t * cp1x +
			3 * u * tt * cp2x +
			ttt * endX
		segEndY =
			uuu * startY +
			3 * uu * t * cp1y +
			3 * u * tt * cp2y +
			ttt * endY

		-- Store the end points
		segs[ #segs + 1 ] = segEndX
		segs[ #segs + 1 ] = segEndY							

		-- Swap values for next segment
		segStartX, segStartY = segEndX, segEndY
	end

	-- Add last points
	segs[ #segs + 1 ] = endX
	segs[ #segs + 1 ] = endY

	-- Find bounds of the segments
	local bounds = {}

	-- Return the curve
	return segs, bounds

end

--------------------------------------------------------------
-- FILE IO ---------------------------------------------------

-- Load data from a file, returning a table
function class.loadFile( fileName, directory )	

	-- Get file path and check it exists
--	local fullPath = system.pathForFile( filePath, self.getDirectory( directory ) )
	local fullPath = system.pathForFile( fileName, system.ResourceDirectory )
	if fullPath == nil then return false ; end

	-- Load file
	local file = io.open( fullPath, "r" )		
	if file then
		local data = file:read( "*a" )
		io.close( file )
		return data
	end

	-- Some sort of error, so return false
	return false
	
end

-- Get correct path
function class.getDirectory( directory )

	-- Allow for missed parameter
	if directory == nil then directory = "resource" ; end

	-- Return the correct path
	if directory == "docs" or directory == "documents" then return system.DocumentsDirectory
	else                                                    return system.ResourceDirectory ; end

end

-- Return value
return class