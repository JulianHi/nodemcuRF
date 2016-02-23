require "RFPacket"


local Decoder_bInDProtocol = {}
Decoder_bInDProtocol.__index = Decoder_bInDProtocol


-- constructor
setmetatable(Decoder_bInDProtocol, {
  __call = function (cls, ...)
    return cls.init(...)
  end,
})

function Decoder_bInDProtocol:init()
	self.m_nPulseLength = 0
end



function Decoder_bInDProtocol:decode(pPacket)
{
	if(pPacket.getSize() ~= 50) then
		return false
	end
	
	--pPacket->print();
	self.m_nPulseLength = 500
	self.m_nCode = 0

	-- 20% tolerance, quite a lot, could/ be implemented more efficient
	nTolerance = self.m_nPulseLength * 0.2
	nMin1 = self.m_nPulseLength - nTolerance
	nMax1 = self.m_nPulseLength + nTolerance
	nMin2 = 2*self.m_nPulseLength - nTolerance
	nMax2 = 2*self.m_nPulseLength + nTolerance
	nHighPulse = 0
	
	 --24 bits 
	for i = 1, 25 do
		nHighPulse = pPacket.next()
		-- Simply skip low pulse, for more accurate decoding this could be checked too
		pPacket.next()

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
	
	pResult = {}
	pResult.encoding = "ENCODING_BIND"
	pResult.timing = self.m_nPulseLength	
	pResult.data = self.m_nCode
	
	return pResult
end