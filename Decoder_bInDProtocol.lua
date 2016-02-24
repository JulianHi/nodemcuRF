require "RFPacket"
Decoder_bInDProtocol = {}


function Decoder_bInDProtocol:init(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	self.m_nPulseLength = 0

	return o
end


function Decoder_bInDProtocol:decode(pPacket)
	if(pPacket:getSize() ~= 50) then
		return false
	end
	
	--pPacket->print();
	self.m_nPulseLength = 500
	self.m_nCode = 0

	-- 20% tolerance, quite a lot, could/ be implemented more efficient
	local nTolerance = self.m_nPulseLength * 0.2
	local nMin1 = self.m_nPulseLength - nTolerance
	local nMax1 = self.m_nPulseLength + nTolerance
	local nMin2 = 2*self.m_nPulseLength - nTolerance
	local nMax2 = 2*self.m_nPulseLength + nTolerance
	local nHighPulse = 0
	
	 --24 bits 
	 --for(int i = 1; i < 25; i++)  
	for i = 1, 24 do
		nHighPulse = pPacket:next()
		-- Simply skip low pulse, for more accurate decoding this could be checked too
		pPacket:next()

		-- Zero bit
		if(nHighPulse >= nMin1 and nHighPulse <= nMax1) then
			--; nothing to do
		elseif(nHighPulse >= nMin2 and nHighPulse <= nMax2) then
			self.m_nCode = self.m_nCode+ 1
		else
			self.m_nCode = 0
			break
		end
		
		--m_nCode <<= 1;
		self.m_nCode = bit.lshift(self.m_nCode, 1)
	end

	--m_nCode >>= 1;
	self.m_nCode = bit.rshift(self.m_nCode, 1)

	return (self.m_nCode ~= 0)
end

-- function Decoder_bInDProtocol::fillPacket(NinjaPacket* pPacket)
-- {
-- 	pPacket->setEncoding(ENCODING_BIND);
-- 	pPacket->setTiming(m_nPulseLength);
-- 	pPacket->setType(TYPE_DEVICE);
-- 	pPacket->setGuid(0);
-- 	pPacket->setDevice(ID_ONBOARD_RF);
-- 	pPacket->setData(m_nCode);
-- }


-- parameter: pPacket
function Decoder_bInDProtocol:fillPacket()
	
	local pResult = {}
	pResult.encoding = "ENCODING_BIND"
	pResult.timing = self.m_nPulseLength	
	pResult.data = self.m_nCode
	
	return pResult
end