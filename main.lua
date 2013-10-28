------------------------------------------------------------------------------
-- Performance!
------------------------------------------------------------------------------

--[[
-- Performance meter
local performance = require( "libs.performance" )
performance:newPerformanceMeter()
--]]

--------------------------------------------------------------
-- SET UP EVERYTHING -----------------------------------------

display.setStatusBar( display.HiddenStatusBar )
system.activate("multitouch")

-- Only the bare minimum setup here, just enough to make this scene function - the rest is set up in 'setup'

local utils      = require( "libs.utils" )
local __G        = require( "libs.globals" )
local storyboard = require( "storyboard" )

-- What platform?
__G.isSimulator = ( system.getInfo( "environment" ) == "simulator" )
if system.getInfo( "platformName" ) == "iPhone OS" then __G.platform = "apple"
else                                                    __G.platform = "android" ; end

-- Set up some globals
__G.screenWidth  = display.actualContentWidth
__G.screenHeight = display.actualContentHeight

-- Set up storyboard effects
__G.sbFade = { effect = "fade", time = 200 }

-- Set up groups 'sandwich'
__G.groups = {
	root       = display.newGroup(), 
	storyboard = storyboard.stage, 
}
__G.groups.root:insert( __G.groups.storyboard )	

-- Start it all!
storyboard.gotoScene( "code.setup", __G.sbFade )
