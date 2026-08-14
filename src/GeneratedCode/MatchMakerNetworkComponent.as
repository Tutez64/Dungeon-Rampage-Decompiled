package GeneratedCode
{
   import DistributedObjects.MatchMaker;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class MatchMakerNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:MatchMaker;
      
      public const FLID_InfiniteDetails:uint = 295;
      
      public const FLID_ClientRequestEntry:uint = 296;
      
      public const FLID_ClientRequestEntryResponce:uint = 297;
      
      public const FLID_RequestExit:uint = 298;
      
      public const FLID_ClientExitComplete:uint = 299;
      
      public const FLID_ClientDataFlushExit:uint = 300;
      
      public const FLID_ClientRequestPartyMemberInvite:uint = 301;
      
      public const FLID_RequestPartyMemberInvite:uint = 302;
      
      public const FLID_ClientRequestLeaveParty:uint = 303;
      
      public const FLID_ClientInformPartyComposition:uint = 304;
      
      public const FLID_Proxy_ClientRequestEntryResponce:uint = 305;
      
      public const FLID_RequestEntry:uint = 306;
      
      public const FLID_AreaManagerStatus:uint = 307;
      
      public const FLID_AreaStatus:uint = 308;
      
      public const FLID_MatchMaker_Newgame:uint = 309;
      
      public const FLID_RequestExitProxy:uint = 310;
      
      public const FLID_AreaExit:uint = 311;
      
      public const FLID_ForceAreaExit:uint = 312;
      
      public const FLID_PlayerExit:uint = 313;
      
      public const FLID_ReportAreaOutcome:uint = 314;
      
      public const FLID_TimingProbResp:uint = 315;
      
      public function MatchMakerNetworkComponent(Inst:MatchMaker, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : MatchMakerNetworkComponent
      {
         var _loc5_:MatchMaker = new MatchMaker(gs.facade,doid);
         var _loc4_:MatchMakerNetworkComponent = new MatchMakerNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentMatchMaker(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 295)
         {
            case 0:
               recv_InfiniteDetails(packet);
               break;
            case 2:
               recv_ClientRequestEntryResponce(packet);
               break;
            case 4:
               recv_ClientExitComplete(packet);
               break;
            case 9:
               recv_ClientInformPartyComposition(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_InfiniteDetails(packet);
         recvByIdLoop(packet);
      }
      
      override public function destroy() : void
      {
         the_instance.destroy();
      }
      
      public function recv_InfiniteDetails(packet:DcNetworkPacket) : void
      {
         var value_0:Vector.<InfiniteMapNodeDetail> = (function(param1:DcNetworkPacket):Vector.<InfiniteMapNodeDetail>
         {
            var _loc5_:InfiniteMapNodeDetail = null;
            var _loc3_:Vector.<InfiniteMapNodeDetail> = new Vector.<InfiniteMapNodeDetail>();
            var _loc2_:uint = param1.readUnsignedShort();
            var _loc4_:uint = _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = InfiniteMapNodeDetail.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.InfiniteDetails(value_0);
      }
      
      public function send_ClientRequestEntry(demographics:String, sCode:uint, mapnode:uint, friendtoJoin:uint, mapid:uint, onlyfriends:uint, Grouping:String) : void
      {
         var _loc8_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc8_,296);
         _loc8_.writeUTF(demographics);
         _loc8_.writeUnsignedInt(sCode);
         _loc8_.writeUnsignedInt(mapnode);
         _loc8_.writeUnsignedInt(friendtoJoin);
         _loc8_.writeUnsignedInt(mapid);
         _loc8_.writeByte(onlyfriends);
         _loc8_.writeUTF(Grouping);
         Send_packet(_loc8_);
      }
      
      public function recv_ClientRequestEntryResponce(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedShort();
         var _loc3_:uint = packet.readUnsignedInt();
         the_instance.ClientRequestEntryResponce(_loc2_,_loc3_);
      }
      
      public function send_RequestExit(account:uint) : void
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,298);
         _loc2_.writeUnsignedInt(account);
         Send_packet(_loc2_);
      }
      
      public function recv_ClientExitComplete(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedShort();
         the_instance.ClientExitComplete(_loc2_);
      }
      
      public function send_ClientRequestPartyMemberInvite(demographics:String, partyInviteId:uint) : void
      {
         var _loc3_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc3_,301);
         _loc3_.writeUTF(demographics);
         _loc3_.writeUnsignedInt(partyInviteId);
         Send_packet(_loc3_);
      }
      
      public function recv_ClientInformPartyComposition(packet:DcNetworkPacket) : void
      {
         var partyMembers:Vector.<GameServerPartyMember> = (function(param1:DcNetworkPacket):Vector.<GameServerPartyMember>
         {
            var _loc3_:* = 0;
            var _loc5_:GameServerPartyMember = null;
            var _loc4_:Vector.<GameServerPartyMember> = new Vector.<GameServerPartyMember>();
            var _loc2_:uint = 4;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc5_ = GameServerPartyMember.readFromPacket(param1);
               _loc4_.push(_loc5_);
               _loc3_++;
            }
            return _loc4_;
         })(packet);
         the_instance.ClientInformPartyComposition(partyMembers);
      }
   }
}

