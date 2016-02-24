require "RFReceiver"
require "RFPacket"
require "Decoder_arlecProtocol"
require "Decoder_bInDProtocol"
require "Decoder_bOutDProtocol"
require "Decoder_CommonProtocol"
require "Decoder_HE330v2Protocol"
require "Decoder_WT450Protocol"


RFManager = {}
RFManager.__index = RFManager


-- constructor
--setmetatable(RFManager, {
--  __call = function (cls, ...)
--    return cls:init(...)
--  end,
--})

function RFManager.init()
	local man = {}
	setmetatable(man,RFManager) 
	man.m_Receiver = RFReceiver.init()
	return man
end



function RFManager:setup(pin)

	--TODO add transmitter
	--m_Transmitter.setup(TRANSMIT_PIN);

	self.m_Receiver:start(pin)
end

function RFManager:check()
	
	
	
	local pReceivedPacket = self.m_Receiver:getPacket()

	--TODO: move this to decoder..
	-- Check for unhandled RF data first
	if(pReceivedPacket ~= nil) then
		print("check")
		pReceivedPacket:print()
	
		package = self:getEachDecoderToAttemptToDecodeThePacketAndGetDecoderThatManagedToDecodeThePacketIfItExists(pReceivedPacket);

		if (package ~= nil) then
	
			print("huhu: "..package.data.." encoding: "..package.encoding)
		end
		-- Purge 
		self.m_Receiver:purge()
	end

end


--if a decoder successfully decodes the packet it needs to be deleted elsewhere
function RFManager:getEachDecoderToAttemptToDecodeThePacketAndGetDecoderThatManagedToDecodeThePacketIfItExists(packet)
	local result = nil

	--TODO set it as global or something like this
	local NUM_DECODERS = 6

	for i = 0, NUM_DECODERS do
		local decoder = self:createDecoder(i + 1);
		
		if decoder == nil then break end
		
		local canDecoderDecodeThePacket = decoder:decode(packet)

		if (canDecoderDecodeThePacket) then
			result = decoder:fillPacket()
		else 
			packet:rewind()
		end
	end

	return result
end

function RFManager:createDecoder(index)

	if index == 1 then
		return Decoder_CommonProtocol.init()
	elseif index == 2 then
		return Decoder_WT450Protocol.init()
	elseif index == 3 then
		return Decoder_arlecProtocol.init()
	elseif index == 4 then
		return Decoder_HE330v2Protocol.init()
	elseif index == 5 then
		return nil
		 --return OSv2ProtocolDecoder.init()
	elseif index == 6 then	
		return Decoder_bInDProtocol.init()
	elseif index == 7 then	
		return Decoder_bOutDProtocol.init()
	else
		return nil
	end
	
end


-- function RFManager:handle(NinjaPacket* pPacket)
-- {
-- 	if (pPacket->getGuid() != 0) { //TODO: extract constant..
-- 		return;
-- 	}
--
-- 	if(pPacket->getDevice() == ID_STATUS_LED)
-- 		leds.setStatColor(pPacket->getData());
-- 	else if(pPacket->getDevice() == ID_NINJA_EYES)
-- 		leds.setEyesColor(pPacket->getData());
-- 	else if(pPacket->getDevice() == ID_ONBOARD_RF)
-- 	{
-- 		m_Receiver.stop();
--
-- 		char encoding = pPacket->getEncoding();
--
-- 		//TODO: add support for OSv2ProtocolEncoder...
-- 		//TODO: reduce duplication between OSv2ProtocolEncoder and CommonProtocolEncoder e.g. make CommonProtocolEncoder more general..l
-- 		switch (encoding)
-- 		{
-- 			case ENCODING_COMMON:
-- 				m_encoder = new CommonProtocolEncoder(pPacket->getTiming());
-- 				break;
-- 			case ENCODING_ARLEC:
-- 				m_encoder = new arlecProtocolEncoder(pPacket->getTiming());
-- 				break;
-- 			case ENCODING_HE330:
-- 				m_encoder = new HE330v2ProtocolEncoder(pPacket->getTiming());
-- 				break;
-- 			case ENCODING_OSV2:
-- 				m_encoder = new OSv2ProtocolEncoder(pPacket->getTiming());
-- 				break;
-- 			case ENCODING_BIND:
-- 				m_encoder = new bInDProtocolEncoder(pPacket->getTiming());
-- 				break;
-- 			case ENCODING_BOUTD:
-- 				m_encoder = new bOutDProtocolEncoder(pPacket->getTiming());
-- 				break;
-- 		}
--
-- 		if(pPacket->isDataInArray())
-- 			m_encoder->setCode(pPacket->getDataArray(), pPacket->getArraySize());
-- 		else
-- 			m_encoder->setCode(pPacket->getData());
--
-- 		//m_encoder->setCode(pPacket->getData());
--
-- 		m_encoder->encode(&m_PacketTransmit);
--
-- 		m_Transmitter.send(&m_PacketTransmit, 5);
-- 		delete m_encoder;
-- 		m_Receiver.start();
-- 	}
--
-- 	pPacket->setType(TYPE_ACK);
-- 	pPacket->printToSerial();
-- }