--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local __G            = require( "libs.globals" )
local vectorImporter = require( "libs.vectorimporter" )
local storyboard     = require( "storyboard" )
local scene          = storyboard.newScene()

--------------------------------------------------------------
-- FUNCTIONS -------------------------------------------------

--------------------------------------------------------------
-- STORYBOARD ------------------------------------------------

function scene:createScene( event )

	local sceneGroup = self.view

	-- Create the ice cream polygon object
	local icecream = vectorImporter:new{
		file                = "assets/icecream.json",
		parent              = sceneGroup,
		bezierSubdivisions  = 5,
		strokeWidthScalar   = 2,
		makeOpenShapesLines = false,
		autoCenter          = true,
		x                   = __G.screenWidth * 0.3,
		y                   = __G.screenHeight / 2,
	}

	-- Create the face polygon object
	local face = vectorImporter:new{
		file               = "assets/face.json",
		parent             = sceneGroup,
		bezierSubdivisions = 15,
		autoCenter         = true,
		x                  = __G.screenWidth * 0.7,
		y                  = __G.screenHeight / 2,
		scale              = 0.8,
		rotation           = -10,
	}

end

--------------------------------------------------------------
-- STORYBOARD LISTENERS --------------------------------------

scene:addEventListener( "createScene", scene )

--------------------------------------------------------------
-- RETURN STORYBOARD OBJECT ----------------------------------

return scene