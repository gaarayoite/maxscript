---------------------------------------------------------------------------------------------------
-- Global Code
---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	-- Declarations
	---------------------------------------------------------------------------------------------------
	-- functions
		global scriptMngr_saveSet, scriptMngr_LoadSet, scriptMngr_clearSet, scriptMngr_itemCount

	--variables
		global scriptMngr_INIPath = (getDir #scripts) + "\\new\\Script Launcher\\settings.ini"
		
	-- rollouts
		global baseRollout, ro1
	
	-- floater
		global scriptMngrFloater

	---------------------------------------------------------------------------------------------------
	-- Functions
	---------------------------------------------------------------------------------------------------
	fn scriptMngr_saveSet roName =
	(
		setINISetting scriptMngr_INIPath "Modelling" "keys" (ro1.lbxList.items.count as String)
		for i = 1 to ro1.lbxList.items.count do
		(
			setINISetting scriptMngr_INIPath "Modelling" ("item_" + i as String) ro1.lbxList.items[i]
		)
	)

	fn scriptMngr_LoadSet roName =
	(
		tempArray = #()
		items = (getINISetting scriptMngr_INIPath "Modelling" "keys") as Integer
		for i = 1 to items do
		( 
			append tempArray (getINISetting scriptMngr_INIPath "Modelling" ("item_" + i as String))
		)
		ro1.lbxList.items = tempArray
	)

	fn scriptMngr_clearSet roName =
	(
		for i = 1 to ro1.lbxList.items.count do
		(
			setINISetting scriptMngr_INIPath "Modelling" ("item_" + i as String) ""
		)
		setINISetting scriptMngr_INIPath "Modelling" "keys" "0"
		ro1.lbxList.items = #()
	)

	fn scriptMngr_itemCount roName=
	(
		x = execute (roName + ".lbxList.items.count as String")
		return x
	)


---------------------------------------------------------------------------------------------------
-- Local Code
---------------------------------------------------------------------------------------------------

rollout baseRollout "Base Rollout" width:160 height:311
(
	---------------------------------------------------------------------------------------------------
	-- Declarations
	---------------------------------------------------------------------------------------------------
	local tempItems = #()

	---------------------------------------------------------------------------------------------------
	-- Interface
	---------------------------------------------------------------------------------------------------
	edittext edtInput ""  pos:[4,8] width:132 height:16 across:2
	button btnInput ">"  pos:[136,8] width:16 height:16

	---------------------------------------------------------------------------------------------------
	-- Handlers
	---------------------------------------------------------------------------------------------------
	on btnInput pressed do
	(
		tempItems = ro1.lbxList.items
		append tempItems edtInput.text
		ro1.lbxList.items = tempItems
		edtInput.text = ""
		ro1.lblItems.text = scriptMngr_itemCount "ro1"
	)

	on baseRollout open do
	(
		x = (getINISetting scriptMngr_INIPath "UserPrefs" "x") as Integer
		y = (getINISetting scriptMngr_INIPath "UserPrefs" "y") as Integer
		h = (getINISetting scriptMngr_INIPath "UserPrefs" "h") as Integer

		if x < 10 then x = 10
		if y < 10 then y = 10
		if h < 24 then h = 24

		scriptMngrFloater.pos.x = x
		scriptMngrFloater.pos.y = y
		scriptMngrFloater.size.y = h


	)
	on baseRollout close do
	(
		setINISetting scriptMngr_INIPath "UserPrefs" "x" (scriptMngrFloater.pos.x as String)
		setINISetting scriptMngr_INIPath "UserPrefs" "y" (scriptMngrFloater.pos.y as String)
		setINISetting scriptMngr_INIPath "UserPrefs" "h" (scriptMngrFloater.size.y as String)
	)

)


rollout ro1 "Rollout 1" width:160 height:311
(
	---------------------------------------------------------------------------------------------------
	-- declarations
	---------------------------------------------------------------------------------------------------

	local lbxHeight = ((getINISetting scriptMngr_INIPath "Modelling" "keys") as Integer) + 3

	---------------------------------------------------------------------------------------------------
	-- Interface
	---------------------------------------------------------------------------------------------------
	
	listbox lbxList "ListBox" width:144 height:lbxHeight  items:#("arse", "two", "three", "four", "five") align:#center

	button btnSave "Save" width:48 height:16 across:3
	button btnLoad "Load" width:48 height:16
	button btnClear "Clear" width:48 height:16

	label lblItems "Items: " width:144 height:16

	---------------------------------------------------------------------------------------------------
	-- Functions
	---------------------------------------------------------------------------------------------------


	---------------------------------------------------------------------------------------------------
	-- Handlers
	---------------------------------------------------------------------------------------------------

	on btnSave pressed do scriptMngr_saveSet ro1
	on btnLoad pressed do scriptMngr_LoadSet ro1
	on btnClear pressed do scriptMngr_clearSet ro1

	on lbxList selected val do print lbxList.items[val]

	on ro1 open do scriptMngr_LoadSet ro1

)

if scriptMngrFloater != undefined then closerolloutfloater scriptMngrFloater
	scriptMngrFloater = newRolloutFloater "My Floater" 188 500 
addRollout baseRollout scriptMngrFloater
addRollout ro1 scriptMngrFloater
--addRollout ro2 scriptMngrFloater
