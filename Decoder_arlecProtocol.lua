require "RFPacket"

local Decoder_arlecProtocol = {}
Decoder_arlecProtocol.__index = Decoder_arlecProtocol


-- constructor
setmetatable(Decoder_arlecProtocol, {
  __call = function (cls, ...)
    return cls.init(...)
  end,
})

function Decoder_arlecProtocol:init()
	self.m_nPulseLength = 0
end

function Decoder_arlecProtocol:decode(pPacket)

	if(pPacket.getSize() ~= 26) then
		return false
	end
	
	self.m_nPulseLength = 330 --500;
	self.m_nCode = 0

	-- 50% tolerance, quite a lot, could/ be implemented more efficient
	nTolerance = self.m_nPulseLength * 0.35
	nMin1 = self.m_nPulseLength - nTolerance
	nMax1 = self.m_nPulseLength + nTolerance
	nMin2 = 2*self.m_nPulseLength - nTolerance
	nMax2 = 2*self.m_nPulseLength + nTolerance
	nHighPulse = 0
	
	--skip the three initial pulse changes because they don't seem to be valid data
	pPacket.next()
	pPacket.next()
	pPacket.next()

	  
	-- 11 bit => 22 pulses on/off
	--for(int i = 1; i < 12; i++)  //for(int i = 1; i < 25; i++)
	for i = 1, 12 do
		nHighPulse = pPacket.next()
		-- Simply skip low pulse, for more accurate decoding this could be checked too
		pPacket.next()

		-- Zero bit
		if(nHighPulse >= nMin1 and nHighPulse <= nMax1) then
			--; nothing to do
		elseif(nHighPulse >= nMin2 and nHighPulse <= nMax2) then
			self.m_nCode = self.m_nCode+1
		else
			self.m_nCode = 0
			break
		end
		
		self.m_nCode = bit.lshift(self.m_nCode, 1)
	end

	--m_nCode >>= 1;
	self.m_nCode = bit.rshift(self.m_nCode, 1)

	return (self.m_nCode ~= 0)
end

-- parameter: pPacket
function Decoder_arlecProtocol:fillPacket()

	--pPacket.setEncoding(ENCODING_ARLEC);
	--pPacket.setTiming(self.m_nPulseLength);
	--pPacket.setType(TYPE_DEVICE);
	--pPacket.setGuid(0);
	--pPacket.setDevice(ID_ONBOARD_RF);
	--pPacket.setData(self.m_nCode);
	
	pResult = {}
	pResult.encoding = "ENCODING_ARLEC"
	pResult.timing = self.m_nPulseLength	
	pResult.data = self.m_nCode
	
	return pResult
end