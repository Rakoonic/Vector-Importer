Vector-Importer
===============

An attempt at loading JSON Illustrator files to allow for easier vector graphics use in Corona

Instructions and comments on how it works can be found here: http://forums.coronalabs.com/topic/40332-vector-graphics/

Importer options
================

Here are all the properties you can pass when creating the object.
 
file - Must be the full path from the root of your project.
directory - Must either be a standard Corona directory identifier (system.DocumentsDirectory etc), or a string. The string can be either "docs" or "documents" for system.DocumentsDirectory, or anything else for system.ResourceDirectory (although probably best to stick with "resource" for clarity). Defaults to the resource directory if not supplied.
parent - A parent group that this object will be placed into if passed.
bezierSubdivisions - How much to subdivide each bezier curve. Note that this produces 'bezierSubdivisions + 1' line segments (making 0 a valid option for no subdivision). Defaults to 5 if not supplied.
strokeWidthscalar - How much to scale up stroke width values in the file. Defaults to 1 (no change) if not supplied.
makeOpenShapesLines - Determines how to handle open filled shapes. Probably needs additional work ;) Defaults to true.
autoCenter - creates the objects at the origin - IE regardless of the actual values of the imported files, it moves all these so the object is centered at 0,0 within the object group. An example is if you look at the face JSON file - the face as a whole is located somewhere around 7000,-7000. If you placed the imported object at 0,0, you aren't going to see it because it is waaaay off screen. autoCenter can help you position things correctly. Note that this also affects where the object will rotate and scale from. Defaults to false if not supplied.
x - The x location you want the object to be drawn at. Defaults to 0 if not supplied.
y - The y location you want the object to be drawn at. Defaults to 0 if not supplied.
rotation - The rotation of the object. Defaults to 0 if not supplied.
scale - The scale of the object. Defaults to 1 (no change) if not supplied.
 
The object / display group returned also contains a few new functions:
 
obj:getCenter() -- Returns the overall center of all the vector objects drawn within the object. Note if you use autoCenter, then this will be 0, 0.
obj:getSize() -- Returns the overall width and height of all the vector objects drawn within the object.
 
These two functions are hooks into the object.bounds property which is the bounding rectangle of the entire file imported.
 
If you wish to access sub-objects, then these are merely the children of the object.

Each sub-object has an additional property called .bounds, which is the bounding rectangle of just that sub-object (similar to the object.bounds).
