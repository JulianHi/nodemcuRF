require "RFPacket"

RFReceiver = {m_PacketReceive = nil, m_bCapture=false, m_bDataAvailable=false}  


function RFReceiver:init(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.m_PacketReceive = RFPacket:init()
	o.m_bCapture = false
	o.m_bDataAvailable = false
	return o
end

function RFReceiver:start(pin)
	self:purge()
	self.nReceiverInterrupt = pin
	
	function handleInterrupt()
		--if RFReceiverInstance ~= nil then
			self:onInterrupt()
			--end
	end
	
	
	gpio.mode(self.nReceiverInterrupt, gpio.INT)
	gpio.trig(self.nReceiverInterrupt, "both", handleInterrupt)
end

function RFReceiver:stop()

	if self.nReceiverInterrupt then
		gipo.mode(self.nReceiverInterrupt, gpio.FLOAT)
		self.nReceiverInterrupt = nil
	end
end

function RFReceiver:purge()
	self.m_PacketReceive:reset()
	self.m_bCapture = false
	self.m_bDataAvailable = false
end

function RFReceiver:getPacket()

	if (self.m_bDataAvailable ~= true) then
		return nil
	end
		
	return self.m_PacketReceive
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

