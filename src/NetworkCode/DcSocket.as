package NetworkCode
{
   import Brain.Clock.GameClock;
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Facade.DBFacade;
   import GeneratedCode.*;
   import NetworkCode.Transport.ConnectDiagnostics;
   import NetworkCode.Transport.GameEndpoints;
   import NetworkCode.Transport.GameTransportEvent;
   import NetworkCode.Transport.IGameTransport;
   import NetworkCode.Transport.SessionCredential;
   import NetworkCode.Transport.TransportCandidate;
   import NetworkCode.Transport.TransportFailureText;
   import NetworkCode.Transport.TransportSelector;
   import NetworkCode.Transport.TransportSettings;
   import flash.errors.*;
   import flash.events.*;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   
   public class DcSocket
   {
      
      private static const RETRY_PASS_DELAY_MS:int = 1500;
      
      private var input_double_buffer:DcNetworkPacket;
      
      protected var Doid_NetInterfaces:Object;
      
      protected var mDBFacade:DBFacade;
      
      protected var mValidationToken:String;
      
      protected var mAccountid:uint;
      
      protected var mNetworkID:uint;
      
      protected var mNodeRules:uint;
      
      protected var mDemographics:String;
      
      public var CLIENT_HEART_BEAT:uint = 52;
      
      public var CLIENT_LOGIN_DUNGEONBUSTER:uint = 118;
      
      public var CLIENT_OBJECT_UPDATE_FIELD:uint = 124;
      
      public var CLIENT_OBJECT_DISABLE_RESP:uint = 125;
      
      public var CLIENT_OBJECT_DISABLE_OWNER_RESP:uint = 126;
      
      public var CLIENT_OBJECT_DELETE_RESP:uint = 127;
      
      public var CLIENT_CREATE_OBJECT_REQUIRED_RESP:uint = 134;
      
      public var CLIENT_CREATE_OBJECT_REQUIRED_OTHER_RESP:uint = 135;
      
      public var CLIENT_CREATE_OBJECT_REQUIRED_OTHER_OWNER_RESP:uint = 136;
      
      public var CLIENT_LOGOUT:uint = 137;
      
      public var CLIENT_LOGOUT_RESP:uint = 140;
      
      public var CLIENT_INTEREST_CONTEXT:uint = 148;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mDisconnectCode:int = 0;
      
      private var mDisconnecttext:String;
      
      private var mEndpoints:GameEndpoints;
      
      private var mSelector:TransportSelector;
      
      private var mTransport:IGameTransport;
      
      private var mCandidateIndex:int = -1;
      
      private var mHasConnected:Boolean = false;
      
      private var mFailureReported:Boolean = false;
      
      private var mAttemptStartedAt:int = 0;
      
      private var mAttempts:Array = [];
      
      private var mDiagnosticsLogged:Boolean = false;
      
      private var mReconnecting:Boolean = false;
      
      private var mRetriedPass:Boolean = false;
      
      public function DcSocket(facade:DBFacade, host:String, port:int, validationToken:String, demographics:String, accountid:uint)
      {
         super();
         mDisconnectCode = 0;
         mDisconnecttext = "NotSet";
         Logger.debugch("WS","Creating new Socket " + host + " " + port + " " + accountid);
         mValidationToken = validationToken;
         mDemographics = demographics;
         mAccountid = accountid;
         input_double_buffer = new DcNetworkPacket();
         mDBFacade = facade;
         Doid_NetInterfaces = {};
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"DcSocket");
         mEndpoints = new GameEndpoints(host,port);
         mDBFacade.metrics.log("DcSocketCreate");
         mDBFacade.loadingBarTick();
      }
      
      private static function fromArray(array:ByteArray, colons:Boolean = false) : String
      {
         var _loc4_:* = 0;
         var _loc3_:String = "";
         _loc4_ = 0;
         while(_loc4_ < array.length)
         {
            _loc3_ += ("0" + array[_loc4_].toString(16)).substr(-2,2);
            if(colons)
            {
               if(_loc4_ < array.length - 1)
               {
                  _loc3_ += ":";
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      private static function sorter(x:DcNetworkClass, y:DcNetworkClass) : Number
      {
         return y.creationOrder - x.creationOrder;
      }
      
      public function beginConnect(endpoints:GameEndpoints, experimentalWebSocketReconnects:Boolean) : void
      {
         if(endpoints != null)
         {
            mEndpoints = endpoints;
         }
         mSelector = new TransportSelector(mEndpoints,experimentalWebSocketReconnects,currentCredential);
         mFailureReported = false;
         mCandidateIndex = -1;
         mHasConnected = false;
         mAttempts = [];
         mDiagnosticsLogged = false;
         mRetriedPass = false;
         Logger.infoch("WS","DcSocket connecting, candidates: " + mSelector.describe());
         tryNextCandidate();
      }
      
      private function currentCredential() : SessionCredential
      {
         var _loc1_:String = mValidationToken;
         if(mDBFacade != null && mDBFacade.validationToken != null && mDBFacade.validationToken != "")
         {
            _loc1_ = mDBFacade.validationToken;
         }
         return new SessionCredential(String(mAccountid),_loc1_,mDBFacade?.initialLoginTraceId);
      }
      
      public function pass2Init(networkid:uint, noderules:uint) : void
      {
         mNetworkID = networkid;
         mNodeRules = noderules;
      }
      
      public function get facade() : DBFacade
      {
         return mDBFacade;
      }
      
      public function get connected() : Boolean
      {
         return mTransport != null && mTransport.connected;
      }
      
      public function get transport() : IGameTransport
      {
         return mTransport;
      }
      
      private function tryNextCandidateIfAny() : Boolean
      {
         if(!mHasConnected && mCandidateIndex + 1 < mSelector.count)
         {
            tryNextCandidate();
            return true;
         }
         return false;
      }
      
      private function retryPassIfStalled() : Boolean
      {
         if(mHasConnected || mRetriedPass || !ConnectDiagnostics.looksLikeStall(mAttempts))
         {
            return false;
         }
         mRetriedPass = true;
         mCandidateIndex = -1;
         setTimeout(retryPass,1500);
         return true;
      }
      
      private function retryPass() : void
      {
         if(mDBFacade == null)
         {
            return;
         }
         tryNextCandidate();
      }
      
      private function tryNextCandidate() : void
      {
         detachTransport(true);
         mCandidateIndex = mCandidateIndex + 1;
         var _loc1_:TransportCandidate = mSelector.candidateAt(mCandidateIndex);
         if(_loc1_ == null)
         {
            reportFailure(602,"No usable WorldServer endpoint: " + mEndpoints);
            return;
         }
         logTransport("attempt",_loc1_.name,null);
         mTransport = mSelector.createTransport(mCandidateIndex);
         configureListeners();
         mAttemptStartedAt = getTimer();
         mTransport.connect();
      }
      
      private function attemptElapsedMs() : int
      {
         return getTimer() - mAttemptStartedAt;
      }
      
      private function recordAttempt(elapsedMs:int, code:int, text:String, cert:String, certDetail:String, closed:Boolean) : void
      {
         mAttempts.push({
            "name":transportName(),
            "elapsedMs":elapsedMs,
            "code":code,
            "text":text,
            "cert":cert,
            "certDetail":certDetail,
            "closed":closed
         });
      }
      
      private function logConnectFailureDiagnostics() : void
      {
         if(mHasConnected || mDiagnosticsLogged)
         {
            return;
         }
         mDiagnosticsLogged = true;
         ConnectDiagnostics.run(mAttempts,mEndpoints,mDBFacade?.webServicesUrl);
      }
      
      private function configureListeners() : void
      {
         mTransport.addEventListener("gameTransportConnected",connectHandler);
         mTransport.addEventListener("gameTransportData",socketDataHandler);
         mTransport.addEventListener("gameTransportClosed",closeHandler);
         mTransport.addEventListener("gameTransportFailed",failedHandler);
         mTransport.addEventListener("gameTransportReconnecting",reconnectingHandler);
         mTransport.addEventListener("gameTransportReconnectAttempt",reconnectAttemptHandler);
         mTransport.addEventListener("gameTransportResumed",resumedHandler);
      }
      
      private function detachTransport(closeIt:Boolean) : void
      {
         if(mTransport == null)
         {
            return;
         }
         mTransport.removeEventListener("gameTransportConnected",connectHandler);
         mTransport.removeEventListener("gameTransportData",socketDataHandler);
         mTransport.removeEventListener("gameTransportClosed",closeHandler);
         mTransport.removeEventListener("gameTransportFailed",failedHandler);
         mTransport.removeEventListener("gameTransportReconnecting",reconnectingHandler);
         mTransport.removeEventListener("gameTransportReconnectAttempt",reconnectAttemptHandler);
         mTransport.removeEventListener("gameTransportResumed",resumedHandler);
         if(closeIt)
         {
            mTransport.close();
         }
         mTransport = null;
         clearReconnectIndicator();
      }
      
      private function clearReconnectIndicator() : void
      {
         if(!mReconnecting)
         {
            return;
         }
         mReconnecting = false;
         if(mDBFacade != null)
         {
            mDBFacade.onConnectionReconnectFailed();
         }
      }
      
      private function logTransport(phase:String, transportName:String, closeEvent:GameTransportEvent, elapsedMs:int = -1) : void
      {
         if(mDBFacade == null || mDBFacade.metrics == null)
         {
            return;
         }
         var _loc5_:Object = {
            "phase":phase,
            "transport":transportName,
            "candidate":mCandidateIndex.toString()
         };
         if(elapsedMs >= 0)
         {
            _loc5_["elapsedMs"] = elapsedMs.toString();
         }
         if(closeEvent != null)
         {
            _loc5_["wsCode"] = closeEvent.code.toString();
            _loc5_["wsReason"] = closeEvent.reason;
            _loc5_["initiator"] = closeEvent.initiator;
         }
         mDBFacade.metrics.log("DcSocketTransport",_loc5_);
      }
      
      private function closeHandler(event:GameTransportEvent) : void
      {
         var _loc5_:int = attemptElapsedMs();
         Logger.warnch("WS","DcSocket closeHandler: " + event.toString() + (mHasConnected ? "" : " after " + _loc5_ + "ms"));
         if(!mHasConnected)
         {
            recordAttempt(_loc5_,event.code,event.reason,"","",true);
         }
         logTransport("closed",transportName(),event,mHasConnected ? -1 : _loc5_);
         endReconnect(event);
         if(!event.terminal && tryNextCandidateIfAny())
         {
            return;
         }
         var _loc2_:uint = wellKnownDisconnectCode();
         var _loc3_:uint = _loc2_ != 0 ? _loc2_ : 601;
         if(mDBFacade.metrics)
         {
            mDBFacade.metrics.log("DcSocketClose",{
               "errorCode":_loc3_.toString(),
               "subcode":mDisconnectCode.toString(),
               "subtext":mDisconnecttext
            });
         }
         detachTransport(false);
         logConnectFailureDiagnostics();
         var _loc4_:String = event.gaveUp ? TransportFailureText.forGiveUp(event) : TransportFailureText.forClose(event);
         mDBFacade.mDistributedObjectManager.enterSocketErrorState(_loc3_,TransportFailureText.withServerText(mDisconnecttext,_loc4_));
      }
      
      private function connectHandler(event:GameTransportEvent) : void
      {
         Logger.infoch("WS","DcSocket connected [" + transportName() + "]");
         mHasConnected = true;
         logTransport("connected",transportName(),null);
         mDBFacade.loadingBarTick();
         mDBFacade.metrics.log("DcSocketConnect",{"transport":transportName()});
         mLogicalWorkComponent.doEverySeconds(TransportSettings.heartbeatSeconds,StartPingFunction);
         SendLogin();
      }
      
      public function StartPingFunction(gameClock:GameClock) : void
      {
         SendHeartBeat();
      }
      
      private function reconnectingHandler(event:GameTransportEvent) : void
      {
         Logger.warnch("WS","DcSocket reconnecting [" + transportName() + "]: " + event.code + " " + event.reason);
         mReconnecting = true;
         logTransport("reconnecting",transportName(),event);
         mDBFacade.onConnectionReconnecting(event.reason);
      }
      
      private function reconnectAttemptHandler(event:GameTransportEvent) : void
      {
         mDBFacade.onConnectionReconnectAttempt(event.attempts,event.elapsedMilliseconds,event.graceMilliseconds);
      }
      
      private function resumedHandler(event:GameTransportEvent) : void
      {
         Logger.infoch("WS","DcSocket resumed [" + transportName() + "] after " + event.elapsedMilliseconds + "ms and " + event.attempts + " attempt(s)");
         mReconnecting = false;
         logResume("resumed",event.attempts,event.elapsedMilliseconds);
         mDBFacade.onConnectionResumed();
      }
      
      private function endReconnect(event:GameTransportEvent) : void
      {
         if(!mReconnecting)
         {
            return;
         }
         logResume("gaveUp",event.attempts,event.elapsedMilliseconds);
         clearReconnectIndicator();
      }
      
      private function logResume(outcome:String, attempts:int, elapsedMilliseconds:int) : void
      {
         if(mDBFacade == null || mDBFacade.metrics == null)
         {
            return;
         }
         mDBFacade.metrics.log("DcSocketResume",{
            "outcome":outcome,
            "attempts":attempts.toString(),
            "elapsedMs":elapsedMilliseconds.toString(),
            "stateChanged":mDBFacade.reconnectChangedMainState.toString()
         });
      }
      
      private function failedHandler(event:GameTransportEvent) : void
      {
         var _loc3_:int = attemptElapsedMs();
         Logger.warnch("WS","DcSocket transport failed [" + transportName() + "]: " + event.errorCode + " " + event.text + (mHasConnected ? "" : " after " + _loc3_ + "ms") + (event.certificateStatus == "" ? "" : " cert=" + event.certificateStatus) + (event.certificateDetail == "" ? "" : " [" + event.certificateDetail + "]"));
         if(!mHasConnected)
         {
            recordAttempt(_loc3_,event.errorCode,event.text,event.certificateStatus,event.certificateDetail,false);
         }
         logTransport("failed",transportName(),null,mHasConnected ? -1 : _loc3_);
         endReconnect(event);
         if(tryNextCandidateIfAny())
         {
            return;
         }
         detachTransport(false);
         var _loc2_:uint = wellKnownDisconnectCode();
         if(_loc2_ != 0)
         {
            reportFailure(_loc2_,mDisconnecttext);
            return;
         }
         if(retryPassIfStalled())
         {
            return;
         }
         logConnectFailureDiagnostics();
         reportFailure(event.errorCode,TransportFailureText.forFailure(event));
      }
      
      private function wellKnownDisconnectCode() : uint
      {
         if(mDisconnectCode == 60 || mDisconnectCode == 61)
         {
            return mDisconnectCode;
         }
         return 0;
      }
      
      private function reportFailure(errorCode:uint, text:String) : void
      {
         if(mFailureReported)
         {
            return;
         }
         mFailureReported = true;
         setTimeout(deliverFailure,0,errorCode,text);
      }
      
      private function deliverFailure(errorCode:uint, text:String) : void
      {
         if(mDBFacade == null)
         {
            return;
         }
         mDBFacade.metrics.log("DcSocketClose",{"errorCode":errorCode.toString()});
         mDBFacade.mDistributedObjectManager.enterSocketErrorState(errorCode,text);
      }
      
      private function transportName() : String
      {
         return mTransport != null ? mTransport.name : "none";
      }
      
      private function socketDataHandler(event:GameTransportEvent) : void
      {
         ProcessMoreSocketData(event.bytes);
      }
      
      public function BuildPacketHeartBeat() : DcNetworkPacket
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         _loc2_.writeShort(CLIENT_HEART_BEAT);
         var _loc3_:Date = new Date();
         var _loc1_:String = _loc3_.valueOf().toString();
         _loc2_.writeUTF(_loc1_);
         return _loc2_;
      }
      
      private function BuildPacketLogin() : DcNetworkPacket
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         _loc2_.writeShort(CLIENT_LOGIN_DUNGEONBUSTER);
         _loc2_.writeUTF(mValidationToken);
         var _loc3_:String = "development";
         _loc2_.writeUTF(_loc3_);
         var _loc1_:uint = getDcHash();
         _loc2_.writeUnsignedInt(_loc1_);
         _loc2_.writeUnsignedInt(4);
         _loc2_.writeUnsignedInt(mAccountid);
         _loc2_.writeUnsignedInt(mNetworkID);
         _loc2_.writeUnsignedInt(mNodeRules);
         return _loc2_;
      }
      
      public function sendpacket(pck:DcNetworkPacket) : void
      {
         if(mTransport == null)
         {
            return;
         }
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.endian = "littleEndian";
         _loc2_.writeShort(pck.length);
         _loc2_.writeBytes(pck,0,pck.length);
         _loc2_.position = 0;
         mTransport.send(_loc2_);
      }
      
      public function SendLogout() : void
      {
         mDBFacade.metrics.log("DcSocketSendLogout");
         Logger.debug("SendLogout");
         var _loc1_:DcNetworkPacket = new DcNetworkPacket();
         _loc1_.writeShort(CLIENT_LOGOUT);
         sendpacket(_loc1_);
      }
      
      private function SendLogin() : void
      {
         mDBFacade.metrics.log("DcSocketSendLogin");
         Logger.debug("SendLogin");
         sendpacket(BuildPacketLogin());
         SendHeartBeat();
      }
      
      private function SendHeartBeat() : void
      {
         sendpacket(BuildPacketHeartBeat());
      }
      
      private function ProcessPacketFromWire(game_packet:DcNetworkPacket) : void
      {
         var _loc2_:int = int(game_packet.readUnsignedShort());
         switch(_loc2_)
         {
            case CLIENT_HEART_BEAT:
               Process_CLIENT_HEART_BEAT(game_packet);
               break;
            case CLIENT_CREATE_OBJECT_REQUIRED_OTHER_OWNER_RESP:
               Process_CLIENT_CREATE_OBJECT_REQUIRED_OTHER_OWNER_RESP(game_packet);
               break;
            case CLIENT_CREATE_OBJECT_REQUIRED_OTHER_RESP:
               Process_CLIENT_CREATE_OBJECT_REQUIRED_OTHER_RESP(game_packet);
               break;
            case CLIENT_CREATE_OBJECT_REQUIRED_RESP:
               Process_CLIENT_CREATE_OBJECT_REQUIRED_RESP(game_packet);
               break;
            case CLIENT_OBJECT_UPDATE_FIELD:
               Process_CLIENT_OBJECT_UPDATE_FIELD(game_packet);
               break;
            case CLIENT_OBJECT_DISABLE_RESP:
               Process_CLIENT_OBJECT_DISABLE_RESP(game_packet);
               break;
            case CLIENT_OBJECT_DISABLE_OWNER_RESP:
               Process_CLIENT_OBJECT_DISABLE_OWNER_RESP(game_packet);
               break;
            case CLIENT_OBJECT_DELETE_RESP:
               Process_CLIENT_OBJECT_DELETE_RESP(game_packet);
               break;
            case CLIENT_LOGIN_DUNGEONBUSTER:
               Process_CLIENT_LOGIN_DUNGEONBUSTER(game_packet);
               break;
            case CLIENT_INTEREST_CONTEXT:
               Process_CLIENT_INTEREST_CONTEXT(game_packet);
               break;
            case CLIENT_LOGOUT_RESP:
               Process_CLIENT_LOGOUT_RESP(game_packet);
               break;
            default:
               Logger.error("-------------------------------------Weird not processing function code=" + _loc2_);
         }
      }
      
      private function Process_CLIENT_OBJECT_UPDATE_FIELD(game_packet:DcNetworkPacket) : void
      {
         var _loc3_:uint = game_packet.readUnsignedInt();
         var _loc2_:uint = game_packet.readUnsignedShort();
         var _loc4_:DcNetworkInterface = Doid_NetInterfaces[_loc3_];
         if(_loc4_ == null)
         {
            Logger.warn("Process_CLIENT_OBJECT_UPDATE_FIELD DcNetworkInterface is null " + _loc4_ + " " + _loc3_ + " " + _loc2_);
         }
         else
         {
            _loc4_.recvById(game_packet,_loc2_);
         }
      }
      
      private function InformParentOfNewObject(parent_do_id:uint, child_do_id:uint) : void
      {
         var _loc3_:GameObject = null;
         var _loc4_:GameObject = mDBFacade.gameObjectManager.getReferenceFromId(child_do_id);
         if(_loc4_ == null)
         {
            Logger.warn("InformParentOfNewObject: newObject does not exist " + child_do_id);
         }
         else if(parent_do_id != 0)
         {
            _loc3_ = mDBFacade.gameObjectManager.getReferenceFromId(parent_do_id);
            if(_loc3_ != null)
            {
               _loc3_.newNetworkChild(_loc4_.getTrueObject());
            }
         }
      }
      
      private function Process_CLIENT_CREATE_OBJECT_REQUIRED_RESP(game_packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = game_packet.readUnsignedInt();
         var _loc4_:uint = game_packet.readUnsignedInt();
         var _loc3_:uint = game_packet.readUnsignedShort();
         var _loc6_:uint = game_packet.readUnsignedInt();
         (this as DcSocketGenerate).ObjectFactoryVisible(_loc3_,_loc6_,game_packet);
         var _loc5_:GameObject = mDBFacade.gameObjectManager.getReferenceFromId(_loc6_);
         InformParentOfNewObject(_loc2_,_loc6_);
      }
      
      private function Process_CLIENT_CREATE_OBJECT_REQUIRED_OTHER_RESP(game_packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = game_packet.readUnsignedInt();
         var _loc4_:uint = game_packet.readUnsignedInt();
         var _loc3_:uint = game_packet.readUnsignedShort();
         var _loc5_:uint = game_packet.readUnsignedInt();
         (this as DcSocketGenerate).ObjectFactoryVisible(_loc3_,_loc5_,game_packet);
         InformParentOfNewObject(_loc2_,_loc5_);
      }
      
      private function Process_CLIENT_CREATE_OBJECT_REQUIRED_OTHER_OWNER_RESP(game_packet:DcNetworkPacket) : void
      {
         var _loc3_:uint = game_packet.readUnsignedShort();
         var _loc5_:uint = game_packet.readUnsignedInt();
         var _loc2_:uint = game_packet.readUnsignedInt();
         var _loc4_:uint = game_packet.readUnsignedInt();
         (this as DcSocketGenerate).ObjectFactoryOwner(_loc3_,_loc5_,game_packet);
         InformParentOfNewObject(_loc2_,_loc5_);
      }
      
      private function ProcessMoreSocketData(chunk:ByteArray) : void
      {
         var _loc3_:* = 0;
         var _loc2_:DcNetworkPacket = null;
         if(chunk == null || chunk.length == 0)
         {
            return;
         }
         var _loc4_:uint = input_double_buffer.position;
         input_double_buffer.position = input_double_buffer.length;
         input_double_buffer.writeBytes(chunk,0,chunk.length);
         input_double_buffer.position = _loc4_;
         while(input_double_buffer.bytesAvailable >= 2)
         {
            _loc3_ = input_double_buffer.readUnsignedShort();
            if(_loc3_ == 0)
            {
               Logger.warn("DcSocket discarding a zero-length packet from the wire");
            }
            else
            {
               if(_loc3_ > input_double_buffer.bytesAvailable)
               {
                  input_double_buffer.position -= 2;
                  break;
               }
               _loc2_ = new DcNetworkPacket();
               input_double_buffer.readBytes(_loc2_,0,_loc3_);
               ProcessPacketFromWire(_loc2_);
            }
         }
         input_double_buffer.do_slide();
      }
      
      private function Process_CLIENT_OBJECT_DISABLE_RESP(game_packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = game_packet.readUnsignedInt();
         var _loc3_:DcNetworkInterface = Doid_NetInterfaces[_loc2_];
         if(_loc3_ == null)
         {
            Logger.warn("Process_CLIENT_OBJECT_DISABLE_RESP: Received Remove ID for object not in memory " + _loc2_);
         }
         else
         {
            _loc3_.destroy();
            delete Doid_NetInterfaces[_loc2_];
         }
      }
      
      private function Process_CLIENT_HEART_BEAT(game_packet:DcNetworkPacket) : void
      {
         var _loc2_:String = null;
         var _loc4_:Number = NaN;
         var _loc5_:Date = null;
         var _loc3_:Number = NaN;
         if(mDBFacade.dbAccountInfo != null)
         {
            _loc2_ = game_packet.readUTF();
            _loc4_ = Number(_loc2_);
            _loc5_ = new Date();
            _loc3_ = _loc5_.valueOf();
            mDBFacade.dbAccountInfo.SocketPingMilsecs = _loc3_ - _loc4_;
         }
      }
      
      private function Process_CLIENT_OBJECT_DISABLE_OWNER_RESP(game_packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = game_packet.readUnsignedInt();
         var _loc3_:DcNetworkInterface = Doid_NetInterfaces[_loc2_];
         if(_loc3_ == null)
         {
            Logger.warn("Process_CLIENT_OBJECT_DISABLE_OWNER_RESP: Received Remove ID for object not in memory " + _loc2_);
         }
         else
         {
            _loc3_.destroy();
            delete Doid_NetInterfaces[_loc2_];
         }
      }
      
      private function Process_CLIENT_OBJECT_DELETE_RESP(game_packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = game_packet.readUnsignedInt();
         var _loc3_:DcNetworkInterface = Doid_NetInterfaces[_loc2_];
         if(_loc3_ == null)
         {
            Logger.warn("Process_CLIENT_OBJECT_DISABLE_OWNER_RESP: Received Remove ID for object not in memory " + _loc2_);
         }
         else
         {
            _loc3_.destroy();
            delete Doid_NetInterfaces[_loc2_];
         }
      }
      
      private function Process_CLIENT_INTEREST_CONTEXT(game_packet:DcNetworkPacket) : void
      {
         var _loc4_:uint = game_packet.readUnsignedShort();
         var _loc3_:uint = game_packet.readUnsignedInt();
         var _loc2_:GameObject = mDBFacade.gameObjectManager.getReferenceFromId(_loc3_);
         if(_loc2_ == null)
         {
            Logger.warn("Process_CLIENT_INTEREST_CONTEXT: Object does not exist - should never see this id=" + _loc3_);
         }
         else
         {
            _loc2_.InterestClosure();
         }
      }
      
      private function Process_CLIENT_LOGOUT_RESP(game_packet:DcNetworkPacket) : void
      {
         mDisconnectCode = game_packet.readShort();
         mDisconnecttext = game_packet.readUTF();
         if(mDisconnectCode == 60)
         {
            detachTransport(true);
            mDBFacade.mDistributedObjectManager.enterSocketErrorState(mDisconnectCode,mDisconnecttext);
         }
         else
         {
            Logger.infoch("WS","Process_CLIENT_LOGOUT_RESP[" + mDisconnectCode + "] Server Text[" + mDisconnecttext + "]");
            mDBFacade.metrics.log("ClientLogoutResp",{
               "code":mDisconnectCode.toString(),
               "text":mDisconnecttext
            });
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:Object = null;
         var _loc2_:* = 0;
         Logger.debugch("WS","DcSocket destroy");
         if(mDBFacade.metrics)
         {
            mDBFacade.metrics.log("DcSocketDestroy");
         }
         detachTransport(true);
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         if(mDBFacade.dbAccountInfo)
         {
            mDBFacade.dbAccountInfo.SocketPingMilsecs = -1;
         }
         var _loc4_:Vector.<DcNetworkClass> = new Vector.<DcNetworkClass>();
         for(var _loc3_:String in Doid_NetInterfaces)
         {
            _loc1_ = Doid_NetInterfaces[_loc3_];
            if(_loc1_ is DcNetworkClass)
            {
               _loc4_.push(Doid_NetInterfaces[_loc3_]);
            }
            else
            {
               _loc1_.destroy();
            }
         }
         _loc4_.sort(sorter);
         _loc2_ = 0;
         while(_loc2_ < _loc4_.length)
         {
            _loc4_[_loc2_].destroy();
            _loc2_++;
         }
         Doid_NetInterfaces = null;
         input_double_buffer.clear();
         mDBFacade = null;
         mValidationToken = null;
      }
      
      private function Process_CLIENT_LOGIN_DUNGEONBUSTER(game_packet:DcNetworkPacket) : void
      {
      }
      
      public function getDcHash() : uint
      {
         return 4294967295;
      }
   }
}

