require "RFPacket"

Decoder_arlecProtocol = {}
Decoder_arlecProtocol.__index = Decoder_arlecProtocol


function Decoder_arlecProtocol.init()
	local deco = {}
	setmetatable(deco, Decoder_arlecProtocol)
	deco.m_nPulseLength = 0
	return deco
end

function Decoder_arlecProtocol:decode(pPacket)

	if(pPacket:getSize() ~= 26) then
		return false
	end
	
	self.m_nPulseLength = 330 --500;
	self.m_nCode = 0

	-- 50% tolerance, quite a lot, could/ be implemented more efficient
	local nTolerance = self.m_nPulseLength * 0.35
	local nMin1 = self.m_nPulseLength - nTolerance
	local nMax1 = self.m_nPulseLength + nTolerance
	local nMin2 = 2*self.m_nPulseLength - nTolerance
	local nMax2 = 2*self.m_nPulseLength + nTolerance
	local nHighPulse = 0
	
	--skip the three initial pulse changes because they don't seem to be valid data
	pPacket:next()
	pPacket:next()
	pPacket:next()

	  
	-- 11 bit => 22 pulses on/off
	--for(int i = 1; i < 12; i++)  //for(int i = 1; i < 25; i++)
	for i = 1, 11 do
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
		
		self.m_nCode = bit.lshift(self.m_nCode, 1)
	end

	--m_nCode >>= 1;
	self.m_nCode = bit.rshift(self.m_nCode, 1)

	return (self.m_nCode ~= 0)
end

-- parameter: pPacket
function Decoder_arlecProtocol:fillPacket()
	
	local pResult = {}
	pResult.encoding = "ENCODING_ARLEC"
	pResult.timing = self.m_nPulseLength	
	pResult.data = self.m_nCode
	
	return pResult
end