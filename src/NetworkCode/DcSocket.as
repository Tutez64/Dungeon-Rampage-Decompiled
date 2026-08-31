package NetworkCode
{
   import Brain.Clock.GameClock;
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Facade.DBFacade;
   import GeneratedCode.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.net.Socket;
   import flash.utils.ByteArray;
   
   public class DcSocket extends Socket
   {
      
      private static const PING_INTERVAL:Number = 10;
      
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
      
      private var mDisconnecttext:String = "NotSet";
      
      public function DcSocket(facade:DBFacade, host:String, port:int, validationToken:String, demographics:String, accountid:uint)
      {
         Logger.debug("Creating new Socket " + host + " " + port + " " + accountid);
         super();
         mValidationToken = validationToken;
         mDemographics = demographics;
         mAccountid = accountid;
         this.endian = "littleEndian";
         input_double_buffer = new DcNetworkPacket();
         mDBFacade = facade;
         Doid_NetInterfaces = {};
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"DcSocket");
         configureListeners();
         Logger.debug("Starting Conection ");
         mDBFacade.metrics.log("DcSocketCreate");
         mDBFacade.loadingBarTick();
         this.connect(host,port);
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
      
      public function pass2Init(networkid:uint, noderules:uint) : void
      {
         mNetworkID = networkid;
         mNodeRules = noderules;
      }
      
      public function get facade() : DBFacade
      {
         return mDBFacade;
      }
      
      private function configureListeners() : void
      {
         addEventListener("close",closeHandler);
         addEventListener("connect",connectHandler);
         addEventListener("ioError",ioErrorHandler);
         addEventListener("securityError",securityErrorHandler);
         addEventListener("socketData",socketDataHandler);
      }
      
      private function unconfigureListeners() : void
      {
         removeEventListener("connect",connectHandler);
         removeEventListener("close",closeHandler);
         removeEventListener("ioError",ioErrorHandler);
         removeEventListener("securityError",securityErrorHandler);
         removeEventListener("socketData",socketDataHandler);
      }
      
      private function closeHandler(event:Event) : void
      {
         var _loc2_:uint = 601;
         if(mDisconnectCode == 60 || mDisconnectCode == 61)
         {
            _loc2_ = uint(mDisconnectCode);
         }
         Logger.warn("DcSocket closeHandler: " + event.toString());
         mDBFacade.metrics.log("DcSocketClose",{
            "errorCode":_loc2_.toString(),
            "subcode":mDisconnectCode.toString(),
            "subtext":mDisconnecttext
         });
         mDBFacade.mDistributedObjectManager.enterSocketErrorState(_loc2_,mDisconnecttext);
      }
      
      private function connectHandler(event:Event) : void
      {
         Logger.debug("connectHandler: " + event);
         mDBFacade.loadingBarTick();
         mDBFacade.metrics.log("DcSocketConnect");
         mLogicalWorkComponent.doEverySeconds(10,StartPingFunction);
         SendLogin();
      }
      
      public function StartPingFunction(gameClock:GameClock) : void
      {
         SendHeartBeat();
      }
      
      private function ioErrorHandler(event:IOErrorEvent) : void
      {
         var _loc2_:uint = 602;
         Logger.warn("DcSocket ioErrorHandler: " + event.toString());
         mDBFacade.metrics.log("DcSocketClose",{"errorCode":_loc2_.toString()});
         mDBFacade.mDistributedObjectManager.enterSocketErrorState(_loc2_,event.text);
      }
      
      private function securityErrorHandler(event:SecurityErrorEvent) : void
      {
         var _loc2_:uint = 603;
         Logger.warn("DcSocket securityErrorHandler: " + event.toString());
         mDBFacade.metrics.log("DcSocketClose",{"errorCode":_loc2_.toString()});
         mDBFacade.mDistributedObjectManager.enterSocketErrorState(_loc2_,event.text);
      }
      
      private function socketDataHandler(event:ProgressEvent) : void
      {
         ProcessMoreSocketData();
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
         writeShort(pck.length);
         writeBytes(pck);
         flush();
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
      
      private function ProcessMoreSocketData() : void
      {
         var _loc4_:* = 0;
         var _loc2_:DcNetworkPacket = null;
         var _loc1_:uint = input_double_buffer.length;
         readBytes(input_double_buffer,input_double_buffer.length);
         var _loc3_:uint = input_double_buffer.length;
         while(input_double_buffer.bytesAvailable >= 2)
         {
            _loc4_ = input_double_buffer.readUnsignedShort();
            if(_loc4_ > input_double_buffer.bytesAvailable)
            {
               input_double_buffer.position -= 2;
               break;
            }
            _loc2_ = new DcNetworkPacket();
            input_double_buffer.readBytes(_loc2_,0,_loc4_);
            ProcessPacketFromWire(_loc2_);
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
            unconfigureListeners();
            mDBFacade.mDistributedObjectManager.enterSocketErrorState(mDisconnectCode,mDisconnecttext);
         }
         else
         {
            Logger.info("Process_CLIENT_LOGOUT_RESP[" + mDisconnectCode + "] Server Text[" + mDisconnecttext + "]");
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
         Logger.debug("DcSocket destroy");
         if(mDBFacade.metrics)
         {
            mDBFacade.metrics.log("DcSocketDestroy");
         }
         this.close();
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
         unconfigureListeners();
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

