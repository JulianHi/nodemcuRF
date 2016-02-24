require "RFPacket"

RFReceiver = {}  
RFReceiver.__index = RFReceiver -- failed table lookups on the instances should fallback to the class table, to get methods

local instance=nil

function RFReceiver.init()
	local rec = {}
	setmetatable(rec,RFReceiver)
	rec.m_PacketReceive = RFPacket.init()
	rec.m_bCapture = false
	rec.m_bDataAvailable = false
	instance=rec
	return rec
end

function RFReceiver:start(pin)

	--pInstance = this;

	self:purge()

	--attachInterrupt(0, onInterrupt, CHANGE);
	
	self.nReceiverInterrupt = pin
	
	gpio.mode(self.nReceiverInterrupt, gpio.INT)
	gpio.trig(self.nReceiverInterrupt, "both", handleInterrupt)
end

function RFReceiver:stop()

	if self.nReceiverInterrupt then
		
		gipo.mode(self.nReceiverInterrupt, gpio.FLOAT)
		self.nReceiverInterrupt = nil;
	end

end

function RFReceiver:purge()
	self.m_PacketReceive:reset();
	self.m_bCapture = false;
	self.m_bDataAvailable = false;
end

function RFReceiver:getPacket()

	if (self.m_bDataAvailable ~= true) then
		return nil
	end

	return self.m_PacketReceive
end

function handleInterrupt()
	if instance ~= nil then
		instance:onInterrupt()
	end
end

function RFReceiver:onInterrupt()


	
	-- Data available and not processed, drop new data
	if(self.m_bDataAvailable) then
		return
	end
	
	if self.nCurrentTime ==nil then self.nCurrentTime=0 end
	if self.nDuration == nil then  self.nDuration=0 end
	if self.nLastInterrupt == nil then self.nLastInterrupt=0 end

	self.nCurrentTime = tmr.now()
	self.nDuration = self.nCurrentTime - self.nLastInterrupt;
	self.nLastInterrupt = self.nCurrentTime;

	-- Sanity check
	if(self.nDuration > 75000) then
		return
	end
	
	-- End-gap?
	if(self.nDuration > 3720) then
	
		if(self.m_bCapture) then
		
			-- Data in packet buffer and possible end-gap: Try to analyze the packet
			if(self.m_PacketReceive:getSize() > 0) then
				self.m_PacketReceive:append(self.nDuration)
				self.m_PacketReceive:rewind()
				
				self.m_bDataAvailable = true
			end
		else
			self.m_bCapture = true -- Start capturing
		end
	elseif(self.m_bCapture) then

		-- If appending fails, assume garbage was received
		if(self.m_PacketReceive:append(self.nDuration) ~= true) then
			self.m_PacketReceive:reset()
			self.m_bCapture = false
		end
	end
end

