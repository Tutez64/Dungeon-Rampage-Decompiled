package GeneratedCode
{
   import DistributedObjects.DistributedDungeonFloor;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class DistributedDungeonFloorNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:DistributedDungeonFloor;
      
      public const FLID_mapNodeId:uint = 192;
      
      public const FLID_coliseumTierConstant:uint = 193;
      
      public const FLID_tileLibrary:uint = 194;
      
      public const FLID_tiles:uint = 195;
      
      public const FLID_baseLining:uint = 196;
      
      public const FLID_introMovieSwfFilePath:uint = 197;
      
      public const FLID_introMovieAssetClassName:uint = 198;
      
      public const FLID_currentFloorNum:uint = 199;
      
      public const FLID_activeDungeonModifiers:uint = 200;
      
      public const FLID_show_text:uint = 201;
      
      public const FLID_play_sound:uint = 202;
      
      public const FLID_trigger_camera_zoom:uint = 203;
      
      public const FLID_trigger_camera_shake:uint = 204;
      
      public function DistributedDungeonFloorNetworkComponent(Inst:DistributedDungeonFloor, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : DistributedDungeonFloorNetworkComponent
      {
         var _loc5_:DistributedDungeonFloor = new DistributedDungeonFloor(gs.facade,doid);
         var _loc4_:DistributedDungeonFloorNetworkComponent = new DistributedDungeonFloorNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentDistributedDungeonFloor(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 192)
         {
            case 0:
               recv_mapNodeId(packet);
               break;
            case 1:
               recv_coliseumTierConstant(packet);
               break;
            case 2:
               recv_tileLibrary(packet);
               break;
            case 3:
               recv_tiles(packet);
               break;
            case 4:
               recv_baseLining(packet);
               break;
            case 5:
               recv_introMovieSwfFilePath(packet);
               break;
            case 6:
               recv_introMovieAssetClassName(packet);
               break;
            case 7:
               recv_currentFloorNum(packet);
               break;
            case 8:
               recv_activeDungeonModifiers(packet);
               break;
            case 9:
               recv_show_text(packet);
               break;
            case 10:
               recv_play_sound(packet);
               break;
            case 11:
               recv_trigger_camera_zoom(packet);
               break;
            case 12:
               recv_trigger_camera_shake(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_mapNodeId(packet);
         recv_coliseumTierConstant(packet);
         recv_tileLibrary(packet);
         recv_tiles(packet);
         recv_baseLining(packet);
         recv_introMovieSwfFilePath(packet);
         recv_introMovieAssetClassName(packet);
         recv_currentFloorNum(packet);
         recv_activeDungeonModifiers(packet);
         recvByIdLoop(packet);
      }
      
      override public function destroy() : void
      {
         the_instance.destroy();
      }
      
      public function recv_mapNodeId(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.mapNodeId = _loc2_;
      }
      
      public function recv_coliseumTierConstant(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.coliseumTierConstant = _loc2_;
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
      
      public function recv_baseLining(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         the_instance.baseLining = _loc2_;
      }
      
      public function recv_introMovieSwfFilePath(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.introMovieSwfFilePath = _loc2_;
      }
      
      public function recv_introMovieAssetClassName(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.introMovieAssetClassName = _loc2_;
      }
      
      public function recv_currentFloorNum(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedShort();
         the_instance.currentFloorNum = _loc2_;
      }
      
      public function recv_activeDungeonModifiers(packet:DcNetworkPacket) : void
      {
         var v_activeDungeonModifiers:Vector.<DungeonModifier> = (function(param1:DcNetworkPacket):Vector.<DungeonModifier>
         {
            var _loc5_:DungeonModifier = null;
            var _loc3_:Vector.<DungeonModifier> = new Vector.<DungeonModifier>();
            var _loc2_:uint = param1.readUnsignedShort();
            var _loc4_:uint = _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = DungeonModifier.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.activeDungeonModifiers = v_activeDungeonModifiers;
      }
      
      public function recv_show_text(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.show_text(_loc2_);
      }
      
      public function recv_play_sound(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.play_sound(_loc2_);
      }
      
      public function recv_trigger_camera_zoom(packet:DcNetworkPacket) : void
      {
         var _loc2_:Number = packet.readFloat();
         the_instance.trigger_camera_zoom(_loc2_);
      }
      
      public function recv_trigger_camera_shake(packet:DcNetworkPacket) : void
      {
         var _loc2_:Number = packet.readFloat();
         var _loc3_:Number = packet.readFloat();
         var _loc4_:uint = packet.readUnsignedByte();
         the_instance.trigger_camera_shake(_loc2_,_loc3_,_loc4_);
      }
   }
}

