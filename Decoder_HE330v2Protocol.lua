require "RFPacket"
Decoder_HE330v2Protocol = {}

function Decoder_HE330v2Protocol:init(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	self.m_nPulseLength = 0

	return o
end



function Decoder_HE330v2Protocol:decode(pPacket)

	if(pPacket:getSize() ~= 132) then  --RF Packet size for WT450 varies with value of the payload
		return false
	end

	local m_nPluseLow0 = 275
	local m_nPulseLow1 = 1225
	self.m_nCode = 0

	-- 30% tolerance is still a quite a lot, could/ be implemented more efficient
	local nTolerance = m_nPluseLow0 * 0.3
	local nMin0 = m_nPluseLow0 - nTolerance
	local nMax0 = m_nPluseLow0 + nTolerance
	local nMin1 = m_nPulseLow1 - nTolerance
	local nMax1 = m_nPulseLow1 + nTolerance
	local nLowPulse = 0	
	
	--First pulse is just sync. 
	pPacket:next()
	pPacket:next()
	
	--Every bit starts with a shirt high pulse. Skipping that.
	pPacket:next()
	
	--pPacket->print();
	--for(int i = 0; i < 32; i++)
	for i = 0, 31 do

		nLowPulse = pPacket:next()
		--Serial.println(nLowPulse);


		-- Zero bit
		if(nLowPulse >= nMin0 and nLowPulse <= nMax0) then				--long pulse
			--; nothing to do
		elseif(nLowPulse >= nMin1 and nLowPulse <= nMax1)then 			--short pulse
			self.m_nCode = self.m_nCode+1
		else
			self.m_nCode = 0
			break
		end
		
		--m_nCode <<= 1;
		self.m_nCode = bit.lshift(self.m_nCode,1)
		
		--From there on, go to every 4th pulse, because every bit is repeated once to the wire
		-- Data 0 = Wire 01				// Data 1 = Wire 10
		
		pPacket:next()										
		pPacket:next()
		pPacket:next()
	end

	self.m_nCode = bit.rshift(self.m_nCode,1)
	return (self.m_nCode ~= 0)
end

-- void Decoder_HE330v2Protocol::fillPacket(NinjaPacket* pPacket)
-- {
-- 	pPacket->setEncoding(ENCODING_HE330);
-- 	pPacket->setTiming(m_nPulseLength);
-- 	pPacket->setType(TYPE_DEVICE);
-- 	pPacket->setGuid(0);
-- 	pPacket->setDevice(ID_ONBOARD_RF);
-- 	pPacket->setData(m_nCode);
-- }

-- parameter: pPacket
function Decoder_HE330v2Protocol:fillPacket()

	local pResult = {}
	pResult.encoding = "ENCODING_HE330"
	pResult.timing = self.m_nPulseLength	
	pResult.data = self.m_nCode
	
	return pResult
end

