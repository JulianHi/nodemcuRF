require "RFPacket"


local Decoder_WT450Protocol = {}
Decoder_WT450Protocol.__index = Decoder_WT450Protocol


-- constructor
setmetatable(Decoder_WT450Protocol, {
  __call = function (cls, ...)
    return cls.init(...)
  end,
})

function Decoder_WT450Protocol:init()
	self.m_nPulseLength = 0
end


function Decoder_WT450Protocol:decode(pPacket)

	--if(pPacket->getSize() != 64)  //RF Packet size for WT450 varies with value of the payload
	--	return false;

	self.m_nPulseLength = 1000
	self.m_nCode = 0

	--30% tolerance is still a quite a lot, could/ be implemented more efficient
	nTolerance = self.m_nPulseLength * 0.3
	nMin1 = self.m_nPulseLength - nTolerance
	nMax1 = self.m_nPulseLength + nTolerance
	nMin2 = 2*self.m_nPulseLength - nTolerance
	nMax2 = 2*self.m_nPulseLength + nTolerance
	nHighPulse = 0


	for i = 0, 36 do
		nHighPulse = pPacket.next()


		-- Zero bit
		if(nHighPulse >= nMin2 and nHighPulse <= nMax2) then				--long pulse
			--; nothing to do
		elseif(nHighPulse >= nMin1 and nHighPulse <= nMax1) then			--short pulse
			self.m_nCode = self.m_nCode+1
			pPacket.next()										--skip the second short pulse
		else
			self.m_nCode = 0
			break
		end
		
		--m_nCode <<= 1;
		self.m_nCode = bit.lshift(self.m_nCode, 1)
	end

	--m_nCode >>= 1;
	self.m_nCode = bit.rshift(self.m_nCode, 1)
	return (m_nCode ~= 0)
end

-- void Decoder_WT450Protocol::fillPacket(NinjaPacket* pPacket)
-- {
-- 	pPacket->setEncoding(ENCODING_WT450);
-- 	pPacket->setTiming(m_nPulseLength);
-- 	pPacket->setType(TYPE_DEVICE);
-- 	pPacket->setGuid(0);
-- 	pPacket->setDevice(ID_ONBOARD_RF);
-- 	pPacket->setData(m_nCode);
-- }

-- parameter: pPacket
function Decoder_WT450Protocol:fillPacket()

	pResult = {}
	pResult.encoding = "ENCODING_WT450"
	pResult.timing = self.m_nPulseLength	
	pResult.data = self.m_nCode
	
	return pResult
end