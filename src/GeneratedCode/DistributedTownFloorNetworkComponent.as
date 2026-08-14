package GeneratedCode
{
   import DistributedObjects.DistributedTownFloor;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class DistributedTownFloorNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:DistributedTownFloor;
      
      public const FLID_tileLibrary:uint = 205;
      
      public const FLID_tiles:uint = 206;
      
      public function DistributedTownFloorNetworkComponent(Inst:DistributedTownFloor, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : DistributedTownFloorNetworkComponent
      {
         var _loc5_:DistributedTownFloor = new DistributedTownFloor(gs.facade,doid);
         var _loc4_:DistributedTownFloorNetworkComponent = new DistributedTownFloorNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentDistributedTownFloor(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 205)
         {
            case 0:
               recv_tileLibrary(packet);
               break;
            case 1:
               recv_tiles(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_tileLibrary(packet);
         recv_tiles(packet);
         recvByIdLoop(packet);
      }
      
      override public function destroy() : void
      {
         the_instance.destroy();
      }
      
      public function recv_tileLibrary(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.tileLibrary(_loc2_);
      }
      
      public function recv_tiles(packet:DcNetworkPacket) : void
      {
         var tiles:Vector.<DungeonTileUsage> = (function(param1:DcNetworkPacket):Vector.<DungeonTileUsage>
         {
            var _loc5_:DungeonTileUsage = null;
            var _loc3_:Vector.<DungeonTileUsage> = new Vector.<DungeonTileUsage>();
            var _loc2_:uint = param1.readUnsignedShort();
            var _loc4_:uint = _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = DungeonTileUsage.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.tiles(tiles);
      }
   }
}

