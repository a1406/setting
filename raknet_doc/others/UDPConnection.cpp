#include "UDPConnection.h"
#include "PlatformInterface.h"
#include "OgreScriptLuaVM.h"
#include "MessageIdentifiers.h"
#include "UDPProxyCommon.h"
#include "BitStream.h"
#include "GetTime.h"
#include "PacketLogger.h"
#include "GameNetDefine.h"
#include "GameEvent.h"
#include "ClientAccount.h"
#include "IMiniGameProxy.h"
#include "ClientGame.h"
#include "IMiniGameProxy.h"
#include "cs_net.h"
#include <ctime>
#include <cstdio>
#include <algorithm>
#include <vector>
#if OGRE_PLATFORM != OGRE_PLATFORM_WIN32
#include <sys/time.h>
#endif

#ifdef IWORLD_SERVER_BUILD
#include "ActionLoggerClient.h"
#include "ActionLogger.h"
#include "WorldManager.h"
#endif

#ifdef USE_CONSOLE_OUTPUT
#define LOG_INFO printf
#else
#include "OgreLog.h"
#endif

#include "RoomClient.h"
#include "RoomManager.h"
#include "SurviveGame.h"
#include "ClientErrCode.h"

const int LAN_SERVER_PORT		= 60008;
// 这个端口貌似没用  局域网房间用一下
const int LAN_CLIENT_PORT		= 60009;
const int RAKNET_MSGID_HEAD		= 9;
const int MYCONN_TIMEOUT		= 15;
const int PING_SERVER_INTERVAL	= 3000;
const int WAIT_KICK_INTERVAL	= 1;
const int RECONNECT_TIMEOUT		= 5;

using namespace MINIW;

//#undef LOG_INFO
//#define LOG_INFO(...)

void LogLocal(const char *fmt, ...)
{
	va_list argptr;
	char buffer[512 * 256];

	va_start(argptr, fmt);
	vsprintf(buffer, fmt, argptr);
	va_end(argptr);

	const time_t t = time(NULL);
	struct tm* curTime = localtime(&t);
	LOG_INFO("[%04d-%02d-%02d %02d:%02d:%02d]:%s", 1900 + curTime->tm_year, 1 + curTime->tm_mon, curTime->tm_mday, curTime->tm_hour, curTime->tm_min, curTime->tm_sec, buffer);
}
//#undef LogLocal
//#define LogLocal(...)

UDPConnectionResult::UDPConnectionResult(UDPConnection *udpConnection)
	:m_udpConnection(udpConnection)
{
}

void UDPConnectionResult::OnLoginProxySuccess(Packet *packet)
{
	LogLocal("time %d OnLoginProxySuccess  proxyAddress %s", (int)time(NULL), packet->systemAddress.ToString());
	OnStatisticsGameEvent("OnLoginProxySuccess", "proxy_ip", packet->systemAddress.ToString());

	// All done,waiting for new client incoming.
	m_udpConnection->onClearTimeout();
	m_udpConnection->onHostReady();
}
void UDPConnectionResult::OnProxyProxySuccess(Packet *packet)
{
	LogLocal("time %d OnProxyProxySuccess proxyAddress %s", (int)time(NULL), packet->systemAddress.ToString());
	OnStatisticsGameEvent("OnProxyProxySuccess", "proxy_ip", packet->systemAddress.ToString());

	m_udpConnection->onClearTimeout();
	m_udpConnection->onHostAuthed();
}
void UDPConnectionResult::OnProxyProxyFailed(Packet *packet)
{
	LogLocal("time %d OnProxyProxyFailed[%d] proxyAddress %s", (int)time(NULL), packet->data[1], packet->systemAddress.ToString());
	//m_udpConnection->onProxyFailed();
	OnStatisticsGameEvent("OnProxyProxyFailed", "proxy_ip", packet->systemAddress.ToString(), "reason", RakString::ToString((int64_t)packet->data[1]));
}

void UDPConnectionResult::OnNewClientIncoming(Packet *packet)
{
	LogLocal("time %d OnNewClientIncoming[%d] proxyAddress %s", (int)time(NULL), packet->data[1], packet->systemAddress.ToString());
	OnStatisticsGameEvent("OnNewClientIncoming", "proxy_ip", packet->systemAddress.ToString());

	RakNet::BitStream incomingBs(packet->data, packet->length, false);
	incomingBs.IgnoreBytes(2);
	RakNet::RakNetGUID clientGuid;
	incomingBs.Read(clientGuid);
	m_udpConnection->addNewPartner(RakNetGUID::ToUint32(clientGuid), packet->systemAddress);
}


UDPConnection::UDPConnection(ServerConfig &serverConfig)
	: m_PhraseTimeout(0), m_punchTimeout(0), m_proxyTimeout(0), m_isFini(true),
	  m_isHost(false), m_isLan(false), m_isReady(false),
	  m_connPhase(CONN_PHASE_INIT), m_passWord(""), m_punchIP(""), m_punchPort(0), m_proxyIP(""), m_proxyPort(0),
	  m_myUin(0), m_hostUin(0), m_ProxyGuid(0), m_NatPunchGuid(0), m_ProxyServerAddr(UNASSIGNED_SYSTEM_ADDRESS),
	  m_NatPunchServerAddr(UNASSIGNED_SYSTEM_ADDRESS),
	  m_rakpeerInterface(NULL), m_proxyClientPlugin(NULL), m_natpunchClient(NULL), m_udpConnectionHandler(NULL),
	  m_udpConnectionResult(NULL), m_packetLogger(NULL)

#if  __RAKNET_STATISTIC__
	, m_lastBroadCastSendLen(0)
#endif

#ifdef IWORLD_TARGET_PC
	  , m_Maxconn(40)
#else
	,m_Maxconn(6)
#endif
{
	m_serverConfig = serverConfig;
	m_lastPingTick.tv_sec = 0;
	m_lastPingTick.tv_usec = 0;
	m_kickList.clear();
}

UDPConnection::~UDPConnection()
{
	LogLocal("~UDPConnection()");
	onFini();
}

bool UDPConnection::onInit(bool isHost, int uin, int maxconn, const char *passwd, bool islan)
{
	LogLocal("UDPConnection::onInit isHost=%d, islan=%d", isHost, islan);

	m_isHost = isHost;
	m_isLan = islan;
	m_Maxconn = maxconn + 1;
	m_connPhase = CONN_PHASE_INIT;
	m_kickList.clear();
	
	uin2raknetguid(uin, m_myUin);

	if(!udpInit(maxconn + 1))
	{
		LOG_INFO("UDPConnection udpInit innel error !");
		return false;
	}

	#ifndef IWORLD_SERVER_BUILD
	if(m_isHost && !m_isLan)
	{
		setPunchIPPort(m_serverConfig.natpunch_url, m_serverConfig.natpunch_port);
		setProxyIPPort(m_serverConfig.proxy_url, m_serverConfig.proxy_port);
		connectToPunch(MYCONN_TIMEOUT);
	}
	#endif

	if(!m_isLan)
	{
		OnStatisticsGameEvent("BeginEnterRoom", "from", m_isHost?"host":"client");
	}

	setPassword(passwd);
	m_isFini = false;

	return true;
}

void UDPConnection::onFini()
{
	LogLocal("UDPConnection::onFini");

	m_connPhase = CONN_PHASE_INIT;
	m_kickList.clear();

	if (m_rakpeerInterface)
	{
		m_rakpeerInterface->Shutdown(100);

	}

	if (m_proxyClientPlugin)
	{
		if (m_rakpeerInterface)
		{
			m_rakpeerInterface->DetachPlugin(m_proxyClientPlugin);
		}
		OGRE_DELETE(m_proxyClientPlugin);
	}

	OGRE_DELETE(m_udpConnectionResult);

	if (m_natpunchClient)
	{
		if (m_rakpeerInterface)
		{
			m_rakpeerInterface->DetachPlugin(m_natpunchClient);
		}
		OGRE_DELETE(m_natpunchClient);
	}

	OGRE_DELETE(m_packetLogger);

	if (m_rakpeerInterface)
	{
		m_Mutex.Lock();
		RakPeerInterface::DestroyInstance(m_rakpeerInterface);
		m_rakpeerInterface = NULL;
		m_Mutex.Unlock();
	}

	m_isFini = true;
	m_isReady = false;
}

void UDPConnection::onTick()
{
	if (m_isFini || m_rakpeerInterface == NULL)
	{
		return;
	}

	Packet *packet;
	for (packet = m_rakpeerInterface->Receive(); packet; m_rakpeerInterface->DeallocatePacket(packet), packet = m_rakpeerInterface->Receive())
	{
		if (packet->data[0] <= ID_USER_PACKET_ENUM)
		{
			LogLocal("proto %s phase=%d, from %s, guid=%s", m_packetLogger->BaseIDTOString(packet->data[0]), m_connPhase, packet->systemAddress.ToString(true), packet->guid.ToString());
		}

		switch (packet->data[0])
		{
			case ID_NEW_INCOMING_CONNECTION:			onNewIncoming(packet);			break;
			case ID_ALREADY_CONNECTED:					onAlreadyConnected(packet);		break;
			case ID_CONNECTION_REQUEST_ACCEPTED:		onRequestAccepted(packet);		break;
			case ID_NAT_TARGET_NOT_CONNECTED:
			case ID_NAT_TARGET_UNRESPONSIVE:
			case ID_NAT_CONNECTION_TO_TARGET_LOST:
			case ID_NAT_PUNCHTHROUGH_FAILED:			onNatpunchFailed(packet);		break;
			case ID_NAT_PUNCHTHROUGH_SUCCEEDED:			onNatpunchSuccess(packet);		break;
			case ID_DISCONNECTION_NOTIFICATION:
			case ID_CONNECTION_LOST:					onConnectionLost(packet);		break;
			case ID_INCOMPATIBLE_PROTOCOL_VERSION:
			case ID_CONNECTION_ATTEMPT_FAILED:
			case ID_INVALID_PASSWORD:
			case ID_NO_FREE_INCOMING_CONNECTIONS:
			case ID_CONNECTION_BANNED:
			case ID_IP_RECENTLY_CONNECTED:				onConnectionFailed(packet);		break;
			default:									onProcessMsg(packet);			break;
		}

		if (m_isFini || m_rakpeerInterface == NULL)
		{
			return;
		}
	}

	checkTimeout();
	checkPing();
	checkKick();
}

void UDPConnection::onProxyFailed()
{
	m_PhraseTimeout = 0;
	m_proxyTimeout = time(NULL) + RECONNECT_TIMEOUT;
}

void UDPConnection::onClearTimeout()
{
	this->m_PhraseTimeout = 0;
	this->m_punchTimeout = 0;
	this->m_proxyTimeout = 0;
}

void UDPConnection::onHostReady()
{
	this->m_isReady = true;
}

void UDPConnection::onHostAuthed()
{
	if (nullptr != m_udpConnectionHandler)
	{
		if (!m_isHost)
		{
			connectionSuccess(m_hostUin);
			setPhraseWithTimeout(CONN_PHASE_CONNECTION, MYCONN_TIMEOUT + 5);
		}
	}
}

void UDPConnection::setHandler(UDPConnectionHandler *handler)
{
	m_udpConnectionHandler = handler;
}

void UDPConnection::setPunchIPPort(std::string punchIP, unsigned short punchPort)
{
	m_punchIP = punchIP;
	m_punchPort = punchPort;
}

void UDPConnection::setProxyIPPort(std::string proxyIP, unsigned short proxyPort)
{
	m_proxyIP = proxyIP;
	m_proxyPort = proxyPort;
}

void UDPConnection::setPingResponse(const char *data, int datalen)
{
	if (m_rakpeerInterface)
	{
		m_rakpeerInterface->SetOfflinePingResponse(data, datalen);
	}
}



#if  __RAKNET_STATISTIC__
int UDPConnection::getStatisitc( std::vector<std::string>& report_ )
{
	if (m_rakpeerInterface == nullptr) return 0;
	DataStructures::List<SystemAddress> addresses;
	DataStructures::List<RakNetGUID> guids;
	m_rakpeerInterface->GetSystemList(addresses, guids);

	for (unsigned int i = 0; i < guids.Size(); i++){
		RakNetStatistics *rssSender = m_rakpeerInterface->GetStatistics(m_rakpeerInterface->GetSystemAddressFromGuid( guids[i] ) );
		if (rssSender) {
			char text[4096] = { 0 };
			RakNet::StatisticsToString(rssSender, text, 3);

			std::stringstream stringstream;
			stringstream << i;
			stringstream << " ";
			stringstream << guids[i].ToString();
			stringstream << " ";
			stringstream << text;
			report_.push_back( stringstream.str() );
		}
	}
	return 0;
}
#endif


bool UDPConnection::send(int uin, char *buf, size_t len, PacketReliability reliability, PacketPriority priority, int channel)
{
	if (uin < 0 || nullptr == buf || len <= 0) return false;
	if (m_rakpeerInterface == nullptr) return false;

	RakNetGUID guid(uin);
	SystemAddress targetAddress = m_rakpeerInterface->GetSystemAddressFromGuid(guid);
	if (targetAddress == UNASSIGNED_SYSTEM_ADDRESS)
		targetAddress = m_ProxyServerAddr;

	if (targetAddress == UNASSIGNED_SYSTEM_ADDRESS)
		return false;

	RakNet::BitStream outgoingBs;
	outgoingBs.Write((MessageID)ID_HOST_CLIENT_MESSAGE);
	outgoingBs.Write((int)RakNetGUID::ToUint32(m_myUin));
	outgoingBs.Write((int)uin);
	outgoingBs.Write(buf, len);

	unsigned int ret = m_rakpeerInterface->Send(&outgoingBs, priority, reliability, 0, targetAddress, false);
	ePBMsgCode pbCode = (ePBMsgCode)(((PB_PACKDATA*)buf)->MsgCode);
#ifdef IWORLD_SERVER_BUILD	
	if (pbCode == PB_ROLE_ENTER_WORLD_HC)
	{
		LOG_INFO("UDPConnection::send PB_ROLE_ENTER_WORLD_HC uin = %d data length = %u, ret = %u", uin, len, ret);
	}
#endif
	LOG_INFO("jackdebug UDPConnection::send %d uin = %d data length = %u, ret = %u", pbCode, uin, len, ret);
	return 0 != ret;
}

int UDPConnection::getBroadcastCount()
{
	DataStructures::List<SystemAddress> addresses;
	DataStructures::List<RakNetGUID> guids;
	m_rakpeerInterface->GetSystemList(addresses, guids);
	return addresses.Size();
}

bool UDPConnection::sendBroadcast(char *buf, size_t len, PacketReliability reliability)
{
	if (nullptr == buf || len <= 0) return false;
	if (m_rakpeerInterface == nullptr) return false;

	DataStructures::List<SystemAddress> addresses;
	DataStructures::List<RakNetGUID> guids;
	unsigned int ret = 0;

	m_rakpeerInterface->GetSystemList(addresses, guids);

	RakNet::BitStream outgoingBs;
	outgoingBs.Write((MessageID)ID_HOST_CLIENT_MESSAGE);
	outgoingBs.Write((int)RakNetGUID::ToUint32(m_myUin));
	outgoingBs.Write((int)0);
	outgoingBs.Write(buf, len);

	for (unsigned int i = 0; i < addresses.Size(); i++)
	{
		if (addresses[i] == m_NatPunchServerAddr || addresses[i] == m_ProxyServerAddr)
			continue;

		ret = m_rakpeerInterface->Send(&outgoingBs, HIGH_PRIORITY, reliability, 0, addresses[i], false);

#if  __RAKNET_STATISTIC__
		m_lastBroadCastSendLen = m_lastBroadCastSendLen + len + 9;  //raknet头部长度9
#endif
	}

	if (needProxy(addresses))
	{
		// 通过proxy转发
		ret = m_rakpeerInterface->Send(&outgoingBs, HIGH_PRIORITY, reliability, 0, m_ProxyServerAddr, false);

#if  __RAKNET_STATISTIC__
		m_lastBroadCastSendLen = m_lastBroadCastSendLen + len + 9;  //raknet头部长度9
#endif
	}

	return 0 != ret;
}


void UDPConnection::connectToServer(int hostuin, RakNet::SystemAddress *addr)
{
	LogLocal("UDPConnection::connectToServer");

	if (nullptr == m_rakpeerInterface) return;

	if (CONN_PHASE_INIT != m_connPhase) return;

	uin2raknetguid(hostuin, m_hostUin);

	if (addr)
	{
		connectToHost(addr->ToString(false), addr->GetPort(), MYCONN_TIMEOUT);
	}
	else {
		connectToPunch(MYCONN_TIMEOUT);
	}
}

void UDPConnection::addNewPartner(int clientUin, SystemAddress systemAddress)
{
	if (m_isHost && (!NS_SANDBOX::IMiniGameProxy::getMiniGameProxy()->getCurGame() || !NS_SANDBOX::IMiniGameProxy::getMiniGameProxy()->getCurGame()->canAcceptClientJoin()))
	{
		// CurGame is MainMenuStage kick
		kickoffMember(clientUin, 6, false);
		OnStatisticsGameEvent("NoFreeIncomingForClient", "reason", "MainMenuStage");
		return;
	}

	if (isMemberFull())
	{
		LogLocal("No free incoming for client:[clientUin=%d,cur=%d,max=%d]", clientUin, NS_SANDBOX::IMiniGameProxy::getMiniGameProxy()->getCurGame()->getNumPlayers(), m_Maxconn);
		kickoffMember(clientUin, 4, false);
		OnStatisticsGameEvent("NoFreeIncomingForClient", "reason", "MemberFull");
		return;
	}

	if (isInBlack(RakNetGUID::ToUint32(m_myUin), clientUin))
	{
		LogLocal("Client in my blacklist:[hostUin=%d,clientUin=%d]", m_myUin, clientUin);
		kickoffMember(clientUin, 5, false);
		OnStatisticsGameEvent("NoFreeIncomingForClient", "reason", "InBlack");
		return;
	}

	LogLocal("add new part uin %d", clientUin);

	if (nullptr != m_udpConnectionHandler)
	{
		if (m_isHost)
			m_udpConnectionHandler->onRnHostAddPartner(clientUin);
		else
			m_udpConnectionHandler->onRnClientAddPartner(clientUin);
	}
}

void UDPConnection::kickoffMember(int clientUin, int cause, bool sendEvent)
{
	LogLocal("kickoffMember:[clientUin=%d]", clientUin);
	RoomManager::GetInstance().sendToClientKickInfo(cause, clientUin);
	m_kickList.insert(std::make_pair(clientUin, time(NULL)));

	if (sendEvent)
		OnStatisticsGameEvent("CheckRoomMemberNotExist");
}

bool UDPConnection::kickoffClient(int uin, bool silent)
{
	bool ret = true;
	RakNetGUID guid;
	uin2raknetguid(uin, guid);

	if (m_rakpeerInterface)
	{
		SystemAddress targetAddress = m_rakpeerInterface->GetSystemAddressFromGuid(guid);
		if (targetAddress == UNASSIGNED_SYSTEM_ADDRESS)
		{
			RakNet::BitStream outgoingBs;
			outgoingBs.Write((MessageID)ID_UDP_PROXY_GENERAL);
			outgoingBs.Write((MessageID)ID_UDP_PROXY_KICKOFF_CLIENT_FROM_PROXY);
			outgoingBs.Write(m_myUin);
			outgoingBs.Write(guid);
			m_rakpeerInterface->Send(&outgoingBs, HIGH_PRIORITY, RELIABLE_ORDERED, 0, m_ProxyServerAddr, false);
		}
		else {
			m_rakpeerInterface->CloseConnection(guid, !silent);
		}
	}

	return ret;
}

bool UDPConnection::isMemberFull()
{
	int checkMaxconn = m_Maxconn;
	if(!((SurviveGame*)NS_SANDBOX::IMiniGameProxy::getMiniGameProxy()->getCurGame())->getHaveJudge())
	{
		checkMaxconn--;				
	}
	
	if (NS_SANDBOX::IMiniGameProxy::getMiniGameProxy()->getCurGame()->getNumPlayers() >= checkMaxconn)
	{
		return true;
	}
	else
	{
		return false;
	}
}

bool UDPConnection::isInBlack(int hostUin, int clientUin)
{
	bool isBlack = false;
	MINIW::ScriptVM::game()->callFunction("Friend_Isblack", "ii>b", hostUin, clientUin, &isBlack);
	return isBlack;
}

bool UDPConnection::isHostReady()
{
	return this->m_isReady;
}

int UDPConnection::getMaxMemberNum()
{
	//return m_Maxconn;
	int checkMaxconn = m_Maxconn;
	if(!((SurviveGame*)NS_SANDBOX::IMiniGameProxy::getMiniGameProxy()->getCurGame())->getHaveJudge())
	{
		checkMaxconn--;				
	}
	return checkMaxconn;
}

void UDPConnection::uin2raknetguid(int uin, RakNetGUID &guid)
{
	char szUin[32];

	snprintf(szUin, sizeof(szUin), "%d", uin);
	guid.FromString(szUin);
}

int UDPConnection::raknetguid2uin(const RakNetGUID &guid)
{
	return guid.ToUint32(guid);
}

bool UDPConnection::udpInit(int maxconn)
{
	LogLocal("time %d udpInit start", (int)time(NULL));
	if (m_rakpeerInterface)
	{
		m_Mutex.Lock();
		RakPeerInterface::DestroyInstance(m_rakpeerInterface);
		m_rakpeerInterface = NULL;
		m_Mutex.Unlock();
	}

	OGRE_DELETE(m_packetLogger);
	m_packetLogger = new PacketLogger;
	if (NULL == m_packetLogger)
	{
		ROOM_DEBUG("packetLogger is null.")
		return false;
	}

	m_rakpeerInterface = RakPeerInterface::GetInstance();
	if (NULL == m_rakpeerInterface)
	{
		ROOM_DEBUG("rakpeerInterface is null.")
		return false;
	}

	int port = 0;
#ifndef IWORLD_SERVER_BUILD
	//if (m_isLan && m_isHost) port = LAN_SERVER_PORT;
	if (m_isHost && m_isLan) 
		port = LAN_SERVER_PORT;
	else if( !m_isLan && m_isHost)
		port = LAN_CLIENT_PORT;
#else
	port = m_serverConfig.server_port;
#endif
	SocketDescriptor sd[2];
	sd[0].port = port;
	sd[0].socketFamily = AF_INET;
	sd[1].port = port;
	sd[1].socketFamily = AF_INET6;

	//+3: natpunch + control + proxy
#ifdef __APPLE_CC__TTTTTTT
	LogLocal("Startup 2 socket");
	if (m_rakpeerInterface->Startup(maxconn + (m_isLan ? 0 : 3), sd, 2) != RakNet::RAKNET_STARTED)
	{
		LogLocal("Startup 1 socket");
		if (m_rakpeerInterface->Startup(maxconn + (m_isLan ? 0 : 3), sd, 1) != RakNet::RAKNET_STARTED) return false;
	}
#else
	int netResult = m_rakpeerInterface->Startup(maxconn + (m_isLan ? 0 : 3), sd, 1);
	if ( netResult != RakNet::RAKNET_STARTED) {
		char errDesc[128];
		snprintf(errDesc, sizeof(errDesc), "error net result:%d", netResult);
		ROOM_DEBUG(errDesc)
		return false;
	}
#endif

	m_rakpeerInterface->SetTimeoutTime(GAMENET_TIMEOUT, RakNet::UNASSIGNED_SYSTEM_ADDRESS);

#ifndef IWORLD_SERVER_BUILD
	int maxIncomming = maxconn - 1;
#else
	int maxIncomming = maxconn;
#endif
	if (maxIncomming < 0)
	{
		maxIncomming = 0;
	}
	m_rakpeerInterface->SetMaximumIncomingConnections(maxIncomming);
	m_rakpeerInterface->setMyGUID(m_myUin);

	m_rakpeerInterface->SetIncomingPassword(m_passWord.c_str(), m_passWord.length());

#ifndef IWORLD_SERVER_BUILD
	if (!m_isLan)
	{
		m_natpunchClient = new NatPunchthroughClient;
		m_rakpeerInterface->AttachPlugin(m_natpunchClient);

		m_proxyClientPlugin = new UDPProxyClient;
		m_rakpeerInterface->AttachPlugin(m_proxyClientPlugin);

		m_udpConnectionResult = new UDPConnectionResult(this);
		m_proxyClientPlugin->SetResultHandler(m_udpConnectionResult);
	}
#endif

	gettimeofday(&m_lastPingTick, NULL);

	return true;
}

void UDPConnection::setPhraseWithTimeout(ConnPhase phrase, int timeout)
{
	m_connPhase = phrase;
	m_PhraseTimeout = time(NULL) + timeout;
}

void UDPConnection::connectToProxy(int timeout/* = 0*/)
{
	m_proxyTimeout = 0;

	ConnectionAttemptResult result = m_rakpeerInterface->Connect(m_proxyIP.c_str(), m_proxyPort, 0, 0);
	if (result == CONNECTION_ATTEMPT_STARTED)
	{
		// 连接状态准备完毕，等待连接结果消息（ID_CONNECTION_REQUEST_ACCEPTED或ID_CONNECTION_ATTEMPT_FAILED）
		//m_connPhase = CONN_PHASE_PROXY_CONNNECTING;
		setPhraseWithTimeout(CONN_PHASE_PROXY_CONNNECTING, MYCONN_TIMEOUT); //解决连接失败时无限重试的问题
	}else{
		// 连接状态无效，本次联机失败，直接退出
		connectionFailed(ConnFail_ProxyConnHostFail);
	}

	LogLocal("UDPConnection::connectToProxy[%s:%d]-result:%d-from(%s)", m_proxyIP.c_str(), m_proxyPort, result, m_isHost ? "host" : "client");
}

void UDPConnection::connectToPunch(int timeout/* = 0*/)
{
	RoomClient* roomClient = GameNetManager::getInstance()->getRoomClient();
	if (roomClient && roomClient->isProxyOnly(RakNetGUID::ToUint32(m_hostUin)))
	{
		// 服务器配置，直接使用转发服
		connectToProxy(MYCONN_TIMEOUT);
		LogLocal("UDPConnection::connectToPunch[proxyOnly]");
	}else{
		m_punchTimeout = 0;

		ConnectionAttemptResult result = m_rakpeerInterface->Connect(m_punchIP.c_str(), m_punchPort, 0, 0);
		if (result == CONNECTION_ATTEMPT_STARTED)
		{
			// 连接状态准备完毕，等待连接结果消息（ID_CONNECTION_REQUEST_ACCEPTED或ID_CONNECTION_ATTEMPT_FAILED）
			m_connPhase = CONN_PHASE_PUNCH_CONNECTING;
		}else{
			// 连接状态无效，直接连接转发服
			connectToProxy(MYCONN_TIMEOUT);
		}

		LogLocal("UDPConnection::connectToPunch[%s:%d]-result:%d", m_punchIP.c_str(), m_punchPort, result);
	}
}

void UDPConnection::connectToHost(const char* host, unsigned short port, int timeout/* = 0*/)
{
	ConnectionAttemptResult result = m_rakpeerInterface->Connect(host, port, m_passWord.c_str(), m_passWord.length());
	if (timeout > 0)
	{
		setPhraseWithTimeout(CONN_PHASE_HOST_CONNECTING, timeout);
	}

	LogLocal("UDPConnection::connectToHost[%s:%d]-result:%d", host, port, result);
}

void UDPConnection::connectionSuccess(RakNetGUID target)
{
	LogLocal("UDPConnection::connectionSuccess");
	m_PhraseTimeout = 0;
	m_punchTimeout = 0;
	m_proxyTimeout = 0;

	if (nullptr != m_udpConnectionHandler)
	{
		m_udpConnectionHandler->onRnClientConnectSuccess();
	}
}

void UDPConnection::connectionFailed(int errcode)
{
	LogLocal("UDPConnection::connectionFailed: %d", errcode);
	m_PhraseTimeout = 0;
	m_punchTimeout = 0;
	m_proxyTimeout = 0;

	if (m_connPhase == CONN_PHASE_CONNECTION) return;

	if (nullptr != m_udpConnectionHandler)
	{
		if (m_isHost)
			m_udpConnectionHandler->onRnHostConnectFailed();
		else
			m_udpConnectionHandler->onRnClientConnectFailed(errcode);
	}
	onFini();
}

void UDPConnection::connectionLost(int uin)
{
	if (nullptr != m_udpConnectionHandler)
	{
		if (m_isHost)
			m_udpConnectionHandler->onRnHostConnectionLost(uin);
		else
			m_udpConnectionHandler->onRnClientConnectionLost(uin);
	}
}

void UDPConnection::openNatpunch()
{
	LogLocal("UDPConnection::openNatpunch[via %s to %s]", m_NatPunchServerAddr.ToString(), m_hostUin.ToString());
	OnStatisticsGameEvent("openNatpunch");

	m_natpunchClient->OpenNAT(m_hostUin, m_NatPunchServerAddr);
	setPhraseWithTimeout(CONN_PHASE_PUNCH_OPENNING, MYCONN_TIMEOUT);
}

bool UDPConnection::needProxy(DataStructures::List<SystemAddress> &addresses)
{
	int connectCount = 0;
	for (unsigned int i = 0; i < addresses.Size(); i++)
	{
		if (addresses[i] == m_NatPunchServerAddr || addresses[i] == m_ProxyServerAddr)
			continue;

		connectCount++;
	}

	if(NS_SANDBOX::IMiniGameProxy::getMiniGameProxy()->getCurGame() == NULL){
		return false;
	}
	int clientCount = NS_SANDBOX::IMiniGameProxy::getMiniGameProxy()->getCurGame()->getNumPlayers() - 1;
	if (connectCount < clientCount)
	{
		return true;
	}
	else {
		return false;
	}
}


//租赁服房主动态修改密码使用，普通客户端调用无任何效果
void UDPConnection::setRentPassword(const char* passwd) {
#ifdef IWORLD_SERVER_BUILD
	setPassword(passwd);
#endif
}


void UDPConnection::setPassword(const char *passwd)
{
	if(passwd && passwd[0])
	{
		m_passWord = passwd;
		if (m_rakpeerInterface)
		{
			m_rakpeerInterface->SetIncomingPassword(m_passWord.c_str(),m_passWord.length());
		}
	}
	else
	{
		m_passWord.clear();
		if (m_rakpeerInterface)
		{
			m_rakpeerInterface->SetIncomingPassword(0, 0);
		}
	}
}

void UDPConnection::doTimeout()
{
	LogLocal("m_connPhase %d time out", m_connPhase);

	this->m_PhraseTimeout = 0;
	this->m_punchTimeout = 0;
	this->m_proxyTimeout = 0;

	if (m_connPhase == CONN_PHASE_PROXY_CONNNECTING)
	{
		// 转发服连接失败，需要尝试连接
		onProxyFailed();
	}
	else if (m_connPhase != CONN_PHASE_PUNCH_CONNECTING)
	{
		// 除转发服和打洞服连接失败，退出连接
		connectionFailed(ConnFail_Timeout + m_connPhase);
	}
}

void UDPConnection::checkTimeout()
{
	if (m_PhraseTimeout != 0 && m_PhraseTimeout < time(NULL))
	{
		// On timeout.
		doTimeout();
	}

	if (m_proxyTimeout != 0 && m_proxyTimeout < time(NULL))
	{
		// Reconnect to proxy.
		connectToProxy(MYCONN_TIMEOUT);
	}
}

void UDPConnection::checkPing()
{
	if (m_rakpeerInterface == nullptr)
		return;

	struct timeval tick;
	gettimeofday(&tick, NULL);

	struct timeval stSub;
	TV_DIFF(stSub, tick, m_lastPingTick);

	int iPingMs;
	TV_TO_MS(iPingMs, stSub);

	if (iPingMs < PING_SERVER_INTERVAL)
		return;

	m_lastPingTick = tick;

	DataStructures::List<SystemAddress> addresses;
	DataStructures::List<RakNetGUID> guids;
	m_rakpeerInterface->GetSystemList(addresses, guids);

	for (unsigned int i = 0; i < addresses.Size(); i++)
	{
		m_rakpeerInterface->Ping(addresses[i]);
		int iLastPing = m_rakpeerInterface->GetLastPing(addresses[i]);

		if (addresses[i] != m_NatPunchServerAddr && addresses[i] != m_ProxyServerAddr)
		{
			int iUin = raknetguid2uin(guids[i]);
			GameEventQue::GetInstance().postLastPing(iUin, iLastPing);
		}
	}
}

void UDPConnection::checkKick()
{
	std::map<int, time_t>::iterator itr;
	for (itr = m_kickList.begin(); itr != m_kickList.end();)
	{
		if ((time(NULL) - itr->second) >= WAIT_KICK_INTERVAL)
		{
			if (NS_SANDBOX::IMiniGameProxy::getMiniGameProxy()->getCurGame())
				NS_SANDBOX::IMiniGameProxy::getMiniGameProxy()->getCurGame()->kickoff(itr->first);
			itr = m_kickList.erase(itr);
		}
		else {
			itr++;
		}
	}
}

void UDPConnection::onNewIncoming(Packet *packet)
{
	if (m_isHost)
	{
		auto uin = RakNetGUID::ToUint32(packet->guid);
		addNewPartner(uin, packet->systemAddress);
		#ifdef IWORLD_SERVER_BUILD
		ActionLoggerClient::getInstance()->recordAddr(uin, packet->systemAddress.ToString(false));
		ActionLoggerClient::getInstance()->onUinConnect(uin);

		jsonxx::Object logger_json;
		logger_json << "request_link_time" << MINIW::GetTimeStamp();
		logger_json << "request_ip" << packet->systemAddress.ToString(false);
		ActionLogger::InfoLog(uin, g_WorldMgr ? g_WorldMgr->getWorldId(): 0, "cloud_room_linked", logger_json);
		#endif
	}
}

void UDPConnection::onAlreadyConnected(Packet *packet)
{
	const char *pfrom = m_isHost ? "host" : "client";
	if (m_connPhase == CONN_PHASE_HOST_CONNECTING) OnStatisticsGameEvent("NatpunchAlreadyConnected", "from", pfrom);
	else if (m_connPhase == CONN_PHASE_PROXY_CONNNECTING) OnStatisticsGameEvent("ControlAlreadyConnected", "from", pfrom);
	else OnStatisticsGameEvent("HostAlreadyConnected", "from", pfrom);

	if (m_connPhase == CONN_PHASE_PUNCH_CONNECTING)
		onNatpunchFailed(packet);
	else if (m_connPhase == CONN_PHASE_PROXY_CONNNECTING)
		m_rakpeerInterface->Connect(packet->systemAddress.ToString(false), packet->systemAddress.GetPort(), m_passWord.c_str(), m_passWord.length());
	else
		m_rakpeerInterface->Connect(packet->systemAddress.ToString(false), packet->systemAddress.GetPort(), 0, 0);
}

void UDPConnection::onRequestAccepted(Packet *packet)
{
	if (m_connPhase == CONN_PHASE_PUNCH_CONNECTING)
	{
		LogLocal("Connected to punch:%s", packet->systemAddress.ToString());
		OnStatisticsGameEvent("NatpunchConnected", "punch_ip", packet->systemAddress.ToString(), "from", m_isHost ? "host" : "client");

		m_NatPunchServerAddr = packet->systemAddress;
		m_NatPunchGuid = packet->guid;

		if (m_isHost)
		{
			connectToProxy(MYCONN_TIMEOUT);
		}
		else {
			openNatpunch();
		}
	}
	else if (m_connPhase == CONN_PHASE_PROXY_CONNNECTING)
	{
		LogLocal("Connected to proxy:%s", packet->systemAddress.ToString());
		OnStatisticsGameEvent("ProxyConnected", "control_ip", packet->systemAddress.ToString(), "from", m_isHost ? "host" : "client");

		m_ProxyServerAddr = packet->systemAddress;
		m_ProxyGuid = packet->guid;

		if (m_isHost)
		{
			m_proxyClientPlugin->LoginToProxy(m_ProxyServerAddr, m_myUin);
			setPhraseWithTimeout(CONN_PHASE_PROXY_LOGINING, MYCONN_TIMEOUT);
		}
		else {
			m_proxyClientPlugin->ProxyToProxy(m_ProxyServerAddr, m_hostUin, m_myUin);
			setPhraseWithTimeout(CONN_PHASE_PROXY_LOGINING, MYCONN_TIMEOUT);
		}
	}
	else if (m_connPhase == CONN_PHASE_HOST_CONNECTING)
	{
		LogLocal("Connected to host:%s", packet->systemAddress.ToString());
		OnStatisticsGameEvent("PunchConnHostSucceed");

		setPhraseWithTimeout(CONN_PHASE_CONNECTION, MYCONN_TIMEOUT + 5);
		connectionSuccess(packet->guid);
	}
}

void UDPConnection::onNatpunchFailed(Packet *packet)
{
	if (!m_isHost)
	{
		// 客机打洞失败，直接连接转发服
		connectToProxy(MYCONN_TIMEOUT);
	}
}

void UDPConnection::onNatpunchSuccess(Packet *packet)
{
	if (!m_isHost)
	{
		LogLocal("onNatpunchSuccess:%s-%d", packet->systemAddress.ToString(false), packet->systemAddress.GetPort());
		OnStatisticsGameEvent("NatPunchSucceed");

		if (m_connPhase == CONN_PHASE_PUNCH_OPENNING)
		{
			// Connect to target host by UDP.
			connectToHost(packet->systemAddress.ToString(false), packet->systemAddress.GetPort(), MYCONN_TIMEOUT);
		}
		else if (m_connPhase == CONN_PHASE_CONNECTION) {
			// Connect to target host by UDP
			connectToHost(packet->systemAddress.ToString(false), packet->systemAddress.GetPort());
		}
	}
}

void UDPConnection::onConnectionLost(Packet *packet)
{
	LogLocal("onConnectionLost:%d", packet->guid.ToUint32(packet->guid));
	OnStatisticsGameEvent("ConnectionLost", "ip", packet->systemAddress.ToString(), "msg_id", m_packetLogger->BaseIDTOString(packet->data[0]), "from", m_isHost ? "host" : "client");

	LOG_INFO("GAMENET  UDPConnection::onConnectionLost");
	// 断开连接
	connectionLost((int)packet->guid.ToUint32(packet->guid));

	if (m_isHost && packet->data[0] == ID_CONNECTION_LOST && packet->systemAddress == m_ProxyServerAddr)
	{
		this->m_isReady = false;
	}
	#ifdef IWORLD_SERVER_BUILD
	ActionLoggerClient::getInstance()->releaseAddr((int)packet->guid.ToUint32(packet->guid));
	#endif
}

void UDPConnection::onConnectionFailed(Packet *packet)
{
	int detailerror = packet->data[0];

	if (m_connPhase == CONN_PHASE_PUNCH_CONNECTING) {
		detailerror = ConnFail_ConnNatpunchFail + packet->data[0];;
		OnStatisticsGameEvent("ConnectPunchFail", "code", m_packetLogger->BaseIDTOString(packet->data[0]), "from", m_isHost ? "host" : "client");
	}
	else if (m_connPhase == CONN_PHASE_PROXY_CONNNECTING) {
		detailerror = ConnFail_ProxyConnHostFail + packet->data[0];;
		OnStatisticsGameEvent("ConnecProxyFail", "code", m_packetLogger->BaseIDTOString(packet->data[0]), "from", m_isHost ? "host" : "client");
	}

	if (packet->data[0] == ID_NO_FREE_INCOMING_CONNECTIONS
		&& (m_connPhase == CONN_PHASE_PUNCH_CONNECTING || m_connPhase == CONN_PHASE_PROXY_CONNNECTING))
	{
		// 连接数不足，连接失败
		connectionFailed(ConnFail_NO_FREE_INCOMING_CONNECTIONS);
	}
	else if (packet->data[0] == ID_CONNECTION_ATTEMPT_FAILED && m_connPhase == CONN_PHASE_PUNCH_CONNECTING)
	{
		if (m_isHost && !m_isReady)
		{
			// 主机连接打洞服失败，不再进行重连尝试，直接连接转发服，以提高成功率
			connectToProxy(MYCONN_TIMEOUT);
		}
	}
	else if (packet->data[0] == ID_CONNECTION_ATTEMPT_FAILED && m_connPhase == CONN_PHASE_PROXY_CONNNECTING)
	{
		onProxyFailed();
	}
	else
	{
		// 2021-12-16 codeby:liusijia raknet内部错误，增加1000偏移，避免错误码冲突
		connectionFailed(detailerror + ERR_CODE_RAKNET_OFFSET);
	}
}

void UDPConnection::onProcessMsg(Packet *packet)
{
//#ifdef WIN32
	if (packet->length > sizeof(tagPackHead))
	{
		PB_PACKDATA* packet_data_ = (PB_PACKDATA*)(packet->data + RAKNET_MSGID_HEAD);
		ePBMsgCode pbCode = (ePBMsgCode)packet_data_->MsgCode;
		//if (pbCode == PB_ROLE_ENTER_WORLD_HC)
		{
			LOG_INFO("jackdebug recv %d UDPConnection::onProcessMsg, len = %d", pbCode, packet->length);
		}
	}
//#endif
	if (m_udpConnectionHandler && packet->data[0] >= ID_USER_PACKET_ENUM)
	{
		RakNet::BitStream incomingBs(packet->data, packet->length, true);
		incomingBs.IgnoreBytes(1);
		int fromUin;
		incomingBs.Read(fromUin);
#ifdef IWORLD_SERVER_BUILD
		//查看租赁服的uin跟信道是否有匹配
		if (fromUin != raknetguid2uin(packet->guid))
		{
			LOG_INFO("onProcessMsg Error fromuin[%d], guid[%d]",fromUin, raknetguid2uin(packet->guid));
			return;
		}
#endif
		m_udpConnectionHandler->onRnRecvPacket(fromUin, (const char*)(packet->data + RAKNET_MSGID_HEAD), packet->length - RAKNET_MSGID_HEAD);
	}
}

const char * UDPConnection::GetClientAddressByUin(int uin, bool writePort /* = false */, char portDelineator /*= ':' */) const
{
	RakNetGUID guid(uin);
	SystemAddress targetAddress = m_rakpeerInterface->GetSystemAddressFromGuid(guid);
	
	if (targetAddress == UNASSIGNED_SYSTEM_ADDRESS)
		return nullptr;
	
	return targetAddress.ToString(writePort, portDelineator);
}
