--------------------------------------------------------------------------------------------------
-- getCameraTransform:	gets the camera transform matrix

-- arguments:
	-- cam:			a camera node

-- returns:			a matrix

	fn getCameraTransform cam =
	(
		--this will return a camera transform matrix, ignoring perspective for now:
			local ct	= cam.transform
			local ctd	= cam.target_distance
			local f		= cam.fov
			local d		= cam.dir
			local p		= cam.pos
			
			local row1	= ct.row1*((2*tan(f/2))*ctd)
			local row2	= (ct.row2*((2*tan(f/2))*ctd))*(renderheight/renderwidth as float)/renderpixelaspect
			local row3	= d * ctd
			
			local ctx	= inverse (matrix3 row1 row2 row3 p)
			
			return ctx
	)


--------------------------------------------------------------------------------------------------
-- worldToCam:		gets the camera-coords of a single world-space point3

-- arguments:
	-- pt3:			a world-space point3 value
	-- cam:			a camera node
	-- ctx:			the camera's transform matrix. 
	--				Calculate and pass in separately when doing multiple points in the same frame / viewpoint
	-- outputSize:	an altenative output size to the render settings dialog

-- returns:			a single camera-space Point2 value
	
	fn worldToCam pt3 cam ctx:undefined outputSize:[renderwidth, renderheight] =
	(
		-- get camera transform
			if ctx == undefined then ctx = getCameraTransform cam
		
		--this will transform your point into camera space, still sans perspective:
			pt3			*= ctx
	
		--this will sort out the perspective:
			pt3.x		/= pt3.z
			pt3.y		/= pt3.z
		
		--this will get you a pixel location:
			local pt2 = ([-pt3.x, pt3.y] + 0.5) * outputSize
	
		--and a Z-depth if you need one:
			local zDepth = pt3.z * cam.target_distance
	
		-- return
			--return pt2
			return [pt2.x, pt2.y, zDepth]
	)



--------------------------------------------------------------------------------------------------
-- getCamPointsArr:	gets the camera coords of multiple world-space point3 arrays

-- arguments:
	-- arr:			a 2D array of world-space point3 arrays
	--				array (time) > array (point3) > point3
	-- 				array[time][point3]
	-- cam:			a camera node
	-- start:		an integer
	-- end:			an integer

-- returns:			a 2D array of transformed camera-space Point2s over time
	--				array (time) > array (point2) > point2
	--				array[time][point2]

	fn getCamPointsArr arr cam start end =
	(
		
		--format "% % % %\n" arr.count cam.name start end

		
		for t = start to end do
		(
			local i			= (t - start + 1) as integer / ticksperframe
			local arrVerts	= arr[i]
			at time t
			(
				local ctx		= getCameraTransform cam
				for v = 1 to arrVerts.count do
				(
					arrVerts[v]	= worldToCam arrVerts[v] cam ctx:ctx
				)
			)
			arr[i]			= arrVerts
		)
		return arr
	)


fn testCam =
(
	cam = cameras[1]
	pos = geometry[1].pos
	pt2 = worldToCam pos cam
	pt3 = [pt2.x, pt2.y, 0]
	
	gw.setTransform(Matrix3 1)
	gw.enlargeUpdateRect #whole
	gw.wMarker pt3 #PlusSign color:white
	gw.updateScreen()
)
