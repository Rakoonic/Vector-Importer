--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local __G        = require( "libs.globals" )
local polygons   = require( "libs.polygons" )
local storyboard = require( "storyboard" )
local scene      = storyboard.newScene()

--------------------------------------------------------------
-- FUNCTIONS -------------------------------------------------

--------------------------------------------------------------
-- STORYBOARD ------------------------------------------------

function scene:createScene( event )

	local sceneGroup = self.view

	-- Create the face polygon object
	local face = polygons:new{
		file               = "assets/face.json",
		parent             = sceneGroup,
		bezierSubdivisions = 15,
	}

	-- An example of how to find the center of all what you created
	local x, y   = face:getCenter()
	face.group.x = -x + __G.screenWidth * 0.7
	face.group.y = -y + __G.screenHeight / 2

	-- Create the ice cream polygon object
	local icecream = polygons:new{
		file                = "assets/icecream.json",
		parent              = sceneGroup,
		bezierSubdivisions  = 5,
		strokeWidthScalar   = 2,
		makeOpenShapesLines = true,
	}

	-- An example of how to find the center of all what you created
	local x, y       = icecream:getCenter()
	icecream.group.x = -x + __G.screenWidth * 0.3
	icecream.group.y = -y + __G.screenHeight / 2

end

--------------------------------------------------------------
-- STORYBOARD LISTENERS --------------------------------------

scene:addEventListener( "createScene", scene )

--------------------------------------------------------------
-- RETURN STORYBOARD OBJECT ----------------------------------

return scene
