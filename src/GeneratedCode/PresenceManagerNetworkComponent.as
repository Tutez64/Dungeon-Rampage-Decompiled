package GeneratedCode
{
   import DistributedObjects.PresenceManager;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class PresenceManagerNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:PresenceManager;
      
      public const FLID_friendState:uint = 188;
      
      public const FLID_addFriends:uint = 189;
      
      public function PresenceManagerNetworkComponent(Inst:PresenceManager, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : PresenceManagerNetworkComponent
      {
         var _loc5_:PresenceManager = new PresenceManager(gs.facade,doid);
         var _loc4_:PresenceManagerNetworkComponent = new PresenceManagerNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentPresenceManager(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 188)
         {
            case 0:
               recv_friendState(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recvByIdLoop(packet);
      }
      
      override public function destroy() : void
      {
         the_instance.destroy();
      }
      
      public function recv_friendState(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         var _loc4_:uint = packet.readUnsignedInt();
         var _loc3_:uint = packet.readUnsignedInt();
         the_instance.friendState(_loc2_,_loc4_,_loc3_);
      }
      
      public function send_addFriends(who:Vector.<uint>) : void
      {
         var whofunc:Function;
         var outpacket:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(outpacket,189);
         whofunc = function():void
         {
            var _loc2_:* = 0;
            var _loc3_:uint = who.length;
            var _loc1_:DcNetworkPacket = outpacket;
            outpacket = new DcNetworkPacket();
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               outpacket.writeUnsignedInt(who[_loc2_]);
               _loc2_++;
            }
            _loc1_.writeShort(outpacket.length);
            _loc1_.writeBytes(outpacket);
            outpacket = _loc1_;
         };
         whofunc();
         Send_packet(outpacket);
      }
   }
}

