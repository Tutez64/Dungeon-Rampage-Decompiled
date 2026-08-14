package GeneratedCode
{
   import DistributedObjects.DistributedDungeonSummary;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class DistributedDungeonSummaryNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:DistributedDungeonSummary;
      
      public const FLID_map_node_id:uint = 274;
      
      public const FLID_report:uint = 275;
      
      public const FLID_dungeon_name:uint = 276;
      
      public const FLID_dungeonSuccess:uint = 277;
      
      public const FLID_dungeonMod1:uint = 278;
      
      public const FLID_dungeonMod2:uint = 279;
      
      public const FLID_dungeonMod3:uint = 280;
      
      public const FLID_dungeonMod4:uint = 281;
      
      public const FLID_OpenChest:uint = 282;
      
      public const FLID_TakeChest:uint = 283;
      
      public const FLID_DropChest:uint = 284;
      
      public const FLID_TransactionResponse:uint = 285;
      
      public function DistributedDungeonSummaryNetworkComponent(Inst:DistributedDungeonSummary, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : DistributedDungeonSummaryNetworkComponent
      {
         var _loc5_:DistributedDungeonSummary = new DistributedDungeonSummary(gs.facade,doid);
         var _loc4_:DistributedDungeonSummaryNetworkComponent = new DistributedDungeonSummaryNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentDistributedDungeonSummary(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 274)
         {
            case 0:
               recv_map_node_id(packet);
               break;
            case 1:
               recv_report(packet);
               break;
            case 2:
               recv_dungeon_name(packet);
               break;
            case 3:
               recv_dungeonSuccess(packet);
               break;
            case 4:
               recv_dungeonMod1(packet);
               break;
            case 5:
               recv_dungeonMod2(packet);
               break;
            case 6:
               recv_dungeonMod3(packet);
               break;
            case 7:
               recv_dungeonMod4(packet);
               break;
            case 11:
               recv_TransactionResponse(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_map_node_id(packet);
         recv_report(packet);
         recv_dungeon_name(packet);
         recv_dungeonSuccess(packet);
         recv_dungeonMod1(packet);
         recv_dungeonMod2(packet);
         recv_dungeonMod3(packet);
         recv_dungeonMod4(packet);
         recvByIdLoop(packet);
      }
      
      override public function destroy() : void
      {
         the_instance.destroy();
      }
      
      public function recv_map_node_id(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.map_node_id = _loc2_;
      }
      
      public function recv_report(packet:DcNetworkPacket) : void
      {
         var v_report:Vector.<DungeonReport> = (function(param1:DcNetworkPacket):Vector.<DungeonReport>
         {
            var _loc5_:DungeonReport = null;
            var _loc3_:Vector.<DungeonReport> = new Vector.<DungeonReport>();
            var _loc2_:uint = param1.readUnsignedShort();
            var _loc4_:uint = _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = DungeonReport.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.report = v_report;
      }
      
      public function recv_dungeon_name(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.dungeon_name = _loc2_;
      }
      
      public function recv_dungeonSuccess(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         the_instance.dungeonSuccess = _loc2_;
      }
      
      public function recv_dungeonMod1(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.dungeonMod1 = _loc2_;
      }
      
      public function recv_dungeonMod2(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.dungeonMod2 = _loc2_;
      }
      
      public function recv_dungeonMod3(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.dungeonMod3 = _loc2_;
      }
      
      public function recv_dungeonMod4(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.dungeonMod4 = _loc2_;
      }
      
      public function send_OpenChest(account_id:uint, slot:uint) : void
      {
         var _loc3_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc3_,282);
         _loc3_.writeUnsignedInt(account_id);
         _loc3_.writeUnsignedInt(slot);
         Send_packet(_loc3_);
      }
      
      public function send_TakeChest(account_id:uint, slot:uint) : void
      {
         var _loc3_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc3_,283);
         _loc3_.writeUnsignedInt(account_id);
         _loc3_.writeUnsignedInt(slot);
         Send_packet(_loc3_);
      }
      
      public function send_DropChest(account_id:uint, slot:uint) : void
      {
         var _loc3_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc3_,284);
         _loc3_.writeUnsignedInt(account_id);
         _loc3_.writeUnsignedInt(slot);
         Send_packet(_loc3_);
      }
      
      public function recv_TransactionResponse(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         var _loc4_:uint = packet.readUnsignedByte();
         var _loc3_:uint = packet.readUnsignedInt();
         var _loc5_:uint = packet.readUnsignedInt();
         the_instance.TransactionResponse(_loc2_,_loc4_,_loc3_,_loc5_);
      }
   }
}

