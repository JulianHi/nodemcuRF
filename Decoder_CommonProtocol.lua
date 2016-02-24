require "RFPacket"


Decoder_CommonProtocol = {}
Decoder_CommonProtocol.__index = Decoder_CommonProtocol


function Decoder_CommonProtocol.init()
	local deco = {}
	setmetatable(deco, Decoder_CommonProtocol)
	deco.m_nPulseLength = 0
	return deco
end


function Decoder_CommonProtocol:decode(pPacket)

	if(pPacket:getSize() ~= 50) then
		return false
	end
	
	-- Pulse length should be end-gap divided by 31
	self.m_nPulseLength = pPacket:get(pPacket:getSize() - 1) / 31
	self.m_nCode = 0

	-- 50% tolerance, quite a lot, could/ be implemented more efficient
	local nTolerance = self.m_nPulseLength * 0.5;
	local nMin1 = self.m_nPulseLength - nTolerance;
	local nMax1 = self.m_nPulseLength + nTolerance;
	local nMin3 = 3*self.m_nPulseLength - nTolerance;
	local nMax3 = 3*self.m_nPulseLength + nTolerance;
	local nHighPulse = 0;

	-- 24 bit => 48 pulses on/off
	--for(int i = 0; i < 24; i++)
	for i = 0, 23 do

		nHighPulse = pPacket:next()

		-- Simply skip low pulse, for more accurate decoding this could be checked too
		pPacket:next()

		-- Zero bit
		if(nHighPulse >= nMin1 and nHighPulse <= nMax1) then
			--; nothing to do
		elseif(nHighPulse >= nMin3 and nHighPulse <= nMax3) then
			self.m_nCode = self.m_nCode+1
		else
			self.m_nCode = 0
			break
		end
		
		self.m_nCode = bit.lshift(self.m_nCode,1)
		--m_nCode <<= 1;
	end

	--m_nCode >>= 1;
	self.m_nCode = bit.rshift(self.m_nCode,1)

	return (self.m_nCode ~= 0)
end

-- void Decoder_CommonProtocol::fillPacket(NinjaPacket* pPacket)
-- {
-- 	pPacket->setEncoding(ENCODING_COMMON);
-- 	pPacket->setTiming(m_nPulseLength);
-- 	pPacket->setType(TYPE_DEVICE);
-- 	pPacket->setGuid(0);
-- 	pPacket->setDevice(ID_ONBOARD_RF);
-- 	pPacket->setData(m_nCode);
-- }

-- parameter: pPacket
function Decoder_CommonProtocol:fillPacket()
	
	local pResult = {}
	pResult.encoding = "ENCODING_COMMON"
	pResult.timing = self.m_nPulseLength	
	pResult.data = self.m_nCode
	
	return pResult
end