require "RFPacket"


Decoder_bOutDProtocol = {}
Decoder_bOutDProtocol.__index = Decoder_bOutDProtocol


function Decoder_bOutDProtocol.init()
	local deco = {}
	setmetatable(deco, Decoder_bOutDProtocol)
	deco.m_nPulseLength = 0
	return deco
end



function Decoder_bOutDProtocol:decode(pPacket)

	if(pPacket:getSize() ~= 96) then
		return false
	end
	
	--pPacket->print();
	self.m_nPulseLength = 300
	self.m_nCode = 0

	-- 30% tolerance, quite a lot, could/ be implemented more efficient
	local nTolerance = self.m_nPulseLength * 0.3
	local nMin1 = self.m_nPulseLength - nTolerance
	local nMax1 = self.m_nPulseLength + nTolerance
	local nMin2 = 2*self.m_nPulseLength - nTolerance
	local nMax2 = 2*self.m_nPulseLength + nTolerance
	local nHighPulse = 0
	
	 --48 bits 
	 --for(int i = 1; i < 49; i++)
	for i = 1, 48 do
		nHighPulse = pPacket:next()
		-- Simply skip low pulse, for more accurate decoding this could be checked too
		pPacket:next()

		-- Zero bit
		if(nHighPulse >= nMin1 and nHighPulse <= nMax1) then
			--; nothing to do
		elseif(nHighPulse >= nMin2 and nHighPulse <= nMax2) then
			self.m_nCode = self.m_nCode+1
		else
			self.m_nCode = 0
			break
		end
		
		--m_nCode <<= 1;
		self.m_nCode = bit.lshift(self.m_nCode,1)
	end

	--m_nCode >>= 1;
	self.m_nCode = bit.rshift(self.m_nCode,1)

	return (self.m_nCode ~= 0)
end

-- void Decoder_bOutDProtocol::fillPacket(NinjaPacket* pPacket)
-- {
-- 	pPacket->setEncoding(ENCODING_BOUTD);
-- 	pPacket->setTiming(m_nPulseLength);
-- 	pPacket->setType(TYPE_DEVICE);
-- 	pPacket->setGuid(0);
-- 	pPacket->setDevice(ID_ONBOARD_RF);
-- 	pPacket->setData(m_nCode);
-- }

-- parameter: pPacket
function Decoder_bOutDProtocol:fillPacket()

	local pResult = {}
	pResult.encoding = "ENCODING_BOUTD"
	pResult.timing = self.m_nPulseLength	
	pResult.data = self.m_nCode
	
	return pResult
end