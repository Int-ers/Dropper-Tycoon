return {

	newPlayer = true,
	Tix = 0 :: number,
	Rebirths = 0 :: number,

	BoughtButtons = {} :: {number}, -- 0 = default
	PlayerSellingInventory = {} :: {[string] : number},

	Gamepasses = {
		["Auto Collect"] = false,
		["Auto Rebirth"] = false,
		["Auto Sell"] = false,
		["x2 Item Drop"] = false,
		["x2 Items"] = false,
		["x2 Luck"] = false,
		["x2 Rebirths"] = false,
		["x2 Sell Speed"] = false,
		["x2 Tix"] = false, 
	} :: {
		["Auto Collect"]: boolean,
		["Auto Rebirth"]: boolean,
		["Auto Sell"]: boolean,
		["x2 Item Drop"]: boolean,
		["x2 Items"]: boolean,
		["x2 Luck"]: boolean,
		["x2 Rebirths"]: boolean,
		["x2 Sell Speed"]: boolean,
		["x2 Tix"]: boolean,
	}
}





