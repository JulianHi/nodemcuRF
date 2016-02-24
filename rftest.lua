require("RFManager")  

local mymanager = RFManager.init()
mymanager:setup(4) 

local function test()
	mymanager:check()
end

tmr.stop(6)
tmr.alarm(6, 1000, 1, test)