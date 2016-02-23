local RFPacket = {}  
RFPacket.__index = RFPacket -- failed table lookups on the instances should fallback to the class table, to get methods

local RFPacket.MAX_BUFFER_SIZE = 256

-- vermutlich keine verwendung... erstmal
--RFReceiver*	RFReceiver::pInstance = NULL;

-- constructor
setmetatable(RFPacket, {
  __call = function (cls, ...)
    return cls.init(...)
  end,
})

function RFPacket:init()

	reset();
end

function RFPacket:append(nValue)

	if(self.m_nPosition + 1 >= self.MAX_BUFFER_SIZE) then
		return false
	end

	self.m_Buffer[self.m_nPosition] = nValue
	
	self.m_nPosition = self.m_nPosition+1;
	self.m_nSize = self.m_nSize+1;

	return true
end

function RFPacket:getPosition()

	return self.m_nPosition
end

function RFPacket:getSize()
	return self.m_nSize
end

function RFPacket:reset()
	
	self.m_Buffer = {}
	self.m_nPosition = 0
	self.m_nSize = 0
end

function RFPacket:rewind()

	self.m_nPosition = 0
end

function RFPacket:hasNext()

	return (m_nPosition < m_nSize);
end

function RFPacket:next()
	
	self.m_nPosition = self.m_nPosition+1

	return m_Buffer[m_nPosition-1]
end

function RFPacket:get(nIndex)

	return self.m_Buffer[nIndex]
end

function RFPacket:set(nIndex, nValue)

	self.m_Buffer[nIndex] = nValue
end

function RFPacket:print()

	print("Size: "..self.m_nSize)
	print("Next: "..self.m_nPosition)

	-- /*if(m_nSize != 50)
	-- 	return;*/

	for i = 0, m_nSize do
		print(i..": "..m_Buffer[i])
	end
end