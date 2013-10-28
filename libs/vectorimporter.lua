--------------------------------------------------------------
-- VECTOR FILE IMPORTER --------------------------------------

-- Set up libraries
local JSON = require( "json" )

-- Set up module
local class = {}

-- Set up prototypes
local loadJSON
local createBezier
local loadFile, getDirectory

local mMin, mMax = math.min, math.max

--------------------------------------------------------------
-- SETUP -----------------------------------------------------

-- Create a new object
function class:new( params )

	-- Create the object
	obj = display.newGroup()

	-- Copy across the parameters
	for k, v in pairs( params ) do
		obj[ k ] = v
	end

	-- Copy across the functions, ignoring 'new()'
	for k, v in pairs( class ) do
		if k ~= "new" then obj[ k ] = v ; end
	end

	-- Set properties if it is passed
	if params.parent then params.parent:insert( obj ) ; end
	obj.x        = params.x or 0
	obj.y        = params.y or 0
	obj.rotation = params.rotation or 0
	obj.xScale   = params.scale or 1
	obj.yScale   = params.scale or 1

	-- Load the file if there is one
	if obj.file then loadJSON( obj ) ; end

	-- Return the object
	return obj

end

--------------------------------------------------------------
-- JSON ------------------------------------------------------

function loadJSON( self )

	-- Load raw data
	local rawData = loadFile( self.file, self.directory )
	if rawData == false then return false ; end

	-- Decode
	local data = JSON.decode( rawData )
	if data == nil then return false ; end

	-- Set up some values
	local strokeWidthScalar   = self.strokeWidthScalar or 1
	local makeOpenShapesLines = self.makeOpenShapesLines or false

	-- Process all the data
	local shapes = {}
	for i = 1, #data do
		local properties = {}
		local polyData   = data[ i ]
		local points     = {}
		for j = 1, #polyData do

			-- What type of data is this?
			for k, v in pairs( polyData[ j ] ) do
				if k == "line" then

					-- Start if needed
					if #points == 0 then
						points[ 1 ] = v[ 1 ]
						points[ 2 ] = v[ 2 ]
					end

					-- End
					points[ #points+ 1 ] = v[ 3 ]
					points[ #points+ 1 ] = v[ 4 ]

				elseif k == "bezier" then

					-- Subdivide
					local segs, bounds = createBezier( self, v )

					-- Start if needed
					if #points == 0 then
						points[ 1 ] = segs[ 1 ]
						points[ 2 ] = segs[ 2 ]
					end

					-- Adds in the bezier segments except the first point
					for l = 3, #segs do
						points[ #points+ 1 ] = segs[ l ]
					end
				else
					properties[ k ] = v
				end
			end
		end

		-- Create the shape if it exists
		if #points >= 4 then

			-- Is this a line or a filled shape?
			local isLine = false
			if properties.fill == nil or #points == 4 then isLine = true ; end

			-- Remove last point if it matches
			if points[ 1 ] == points[ #points - 1 ] and points[ 2 ] == points[ #points ] then
				table.remove( points, #points )
				table.remove( points, #points )
			elseif makeOpenShapesLines == true then
				properties.fill = nil
				isLine          = true
			end

			-- Find the minimum values (else everything ends up in the same damn spot )
			local xMin, yMin = points[ 1 ], points[ 2 ]
			local xMax, yMax = points[ 1 ], points[ 2 ]
			for i = 3, #points, 2 do
				xMin = mMin( xMin, points[ i ] )
				yMin = mMin( yMin, points[ i + 1 ] )
				xMax = mMax( xMax, points[ i ] )
				yMax = mMax( yMax, points[ i + 1 ] )
			end

			-- Store the shape
			shapes[ #shapes + 1 ] = {
				points     = points, 
				properties = properties, 
				isLine     = isLine,
				bounds     = { xMin = xMin, yMin = yMin, xMax = xMax, yMax = yMax },
			}
		end
	end

	-- Work out the object center
	local xMin, yMin = 1000000000, 1000000000
	local xMax, yMax = -1000000000, -1000000000
	for i = 1, #shapes do
		local bounds = shapes[ i ].bounds
		xMin         = mMin( xMin, bounds.xMin )
		yMin         = mMin( yMin, bounds.yMin )
		xMax         = mMax( xMax, bounds.xMax )
		yMax         = mMax( yMax, bounds.yMax )
	end

	-- If autoCenter is true, then move all the points in every shape, offset by the bounds
	if self.autoCenter == true then
		local xOffset = -( xMin + xMax ) / 2
		local yOffset = -( yMin + yMax ) / 2

		-- Change the boundaries
		xMin = xMin + xOffset
		yMin = yMin + yOffset
		xMax = xMax + xOffset
		yMax = yMax + yOffset		

		-- Change the shapes
		for i = 1, #shapes do
			
			-- Offset the points
			local points = shapes[ i ].points
			for j = 1, #points, 2 do
				points[ j ]     = points[ j ] + xOffset
				points[ j + 1 ] = points[ j + 1 ] + yOffset
			end

			-- Offset the bounds
			local bounds = shapes[ i ].bounds
			bounds.xMin  = bounds.xMin + xOffset
			bounds.yMin  = bounds.yMin + yOffset
			bounds.xMax  = bounds.xMax + xOffset
			bounds.yMax  = bounds.yMax + yOffset
		end
	end

	-- Store the bounds
	self.bounds = {
		xMin = xMin,
		yMin = yMin,
		xMax = xMax,
		yMax = yMax,
	}

	-- Create the shapes
	for i = 1, #shapes do
		local shapeData  = shapes[ i ]
		local points     = shapeData.points
		local properties = shapeData.properties
		local isLine     = shapeData.isLine
		local bounds     = shapeData.bounds

		-- Create the shape
		local shape
		if isLine == true then
			shape = display.newLine( self, points[ 1 ], points[ 2 ], points[ 3 ], points[ 4 ] )
			if #points > 4 then
				local newPoints = {}
				for j = 5, #points do
					newPoints[ #newPoints + 1 ] = points[ j ]
				end
				shape:append( unpack( newPoints ) )
			end
		else            
			shape = display.newPolygon( self, ( bounds.xMin + bounds.xMax ) / 2, ( bounds.yMin + bounds.yMax ) / 2, points)
		end

		-- Store bounds
		shape.bounds = bounds

		-- Set the fill
		if isLine == false then
			local color = properties.fill
			if color then
				color[ 1 ] = color[ 1 ] / 255
				color[ 2 ] = color[ 2 ] / 255
				color[ 3 ] = color[ 3 ] / 255
				shape:setFillColor( unpack( color ) )
			else
				shape.fill = nil
			end
		end

		-- Set the stroke
		local color = properties.stroke
		if color then
			color[ 1 ] = color[ 1 ] / 255
			color[ 2 ] = color[ 2 ] / 255
			color[ 3 ] = color[ 3 ] / 255
			if isLine then
				shape.strokeWidth = properties.strokeWidth * strokeWidthScalar or 0
				shape:setStrokeColor( unpack( color ) )
			else
			    shape.strokeWidth = properties.strokeWidth * strokeWidthScalar or 0
				shape:setStrokeColor( unpack( color ) )
			end
		end

		-- Set the alpha
		local opacity = properties.opacity
		if opacity then opacity = opacity / 100 ; end
		shape.alpha = opacity or self.alpha or 1
	end

	-- Return success
	return true

end

--------------------------------------------------------------
-- INTERNAL --------------------------------------------------

function createBezier( self, points )

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
	local subdivisions = self.bezierSubdivisions or 5
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
function loadFile( fileName, directory )	

	-- Get file path and check it exists
	local fullPath = system.pathForFile( fileName, getDirectory( directory ) )
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
function getDirectory( directory )

	-- Allow for missed parameter
	if directory == nil then directory = "resource" ; end

	-- Return the correct path
	if type( directory) ~= "string" then                        return directory
	elseif directory == "docs" or directory == "documents" then return system.DocumentsDirectory
	else                                                        return system.ResourceDirectory ; end

end

--------------------------------------------------------------
-- CLASS -----------------------------------------------------

function class:getCenter()

	return ( self.bounds.xMin + self.bounds.xMax ) / 2, ( self.bounds.yMin + self.bounds.yMax ) / 2
	
end
function class:getSize()

	return self.bounds.xMax - self.bounds.xMin, self.bounds.yMax - self.bounds.yMin

end

--------------------------------------------------------------
-- RETURN MODULE ---------------------------------------------

-- Return value
return class