package GeneratedCode
{
   import DistributedObjects.DistributedDungionArea;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class DistributedDungionAreaNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:DistributedDungionArea;
      
      public const FLID_tileLibrary:uint = 211;
      
      public const FLID_cacheNpc:uint = 212;
      
      public const FLID_cacheSWC:uint = 213;
      
      public const FLID_floorReward:uint = 214;
      
      public const FLID_floorEnding:uint = 215;
      
      public const FLID_dungeonEnding:uint = 216;
      
      public const FLID_floorfailing:uint = 217;
      
      public const FLID_tellClientInfiniteRewardData:uint = 218;
      
      public function DistributedDungionAreaNetworkComponent(Inst:DistributedDungionArea, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : DistributedDungionAreaNetworkComponent
      {
         var _loc5_:DistributedDungionArea = new DistributedDungionArea(gs.facade,doid);
         var _loc4_:DistributedDungionAreaNetworkComponent = new DistributedDungionAreaNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentDistributedDungionArea(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 211)
         {
            case 0:
               recv_tileLibrary(packet);
               break;
            case 1:
               recv_cacheNpc(packet);
               break;
            case 2:
               recv_cacheSWC(packet);
               break;
            case 3:
               recv_floorReward(packet);
               break;
            case 4:
               recv_floorEnding(packet);
               break;
            case 5:
               recv_dungeonEnding(packet);
               break;
            case 6:
               recv_floorfailing(packet);
               break;
            case 7:
               recv_tellClientInfiniteRewardData(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_tileLibrary(packet);
         recv_cacheNpc(packet);
         recv_cacheSWC(packet);
         recvByIdLoop(packet);
      }
      
      override public function destroy() : void
      {
         the_instance.destroy();
      }
      
      public function recv_tileLibrary(packet:DcNetworkPacket) : void
      {
         var tileLibrary:Vector.<swrapper> = (function(param1:DcNetworkPacket):Vector.<swrapper>
         {
            var _loc5_:swrapper = null;
            var _loc3_:Vector.<swrapper> = new Vector.<swrapper>();
            var _loc2_:uint = param1.readUnsignedShort();
            var _loc4_:uint = _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = swrapper.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.tileLibrary(tileLibrary);
      }
      
      public function recv_cacheNpc(packet:DcNetworkPacket) : void
      {
         var v_cacheNpc:Vector.<uint> = (function(param1:DcNetworkPacket):Vector.<uint>
         {
            var _loc5_:* = 0;
            var _loc3_:Vector.<uint> = new Vector.<uint>();
            var _loc2_:uint = param1.readUnsignedShort();
            var _loc4_:uint = _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = param1.readUnsignedInt();
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.cacheNpc = v_cacheNpc;
      }
      
      public function recv_cacheSWC(packet:DcNetworkPacket) : void
      {
         var v_cacheSWC:Vector.<swrapper> = (function(param1:DcNetworkPacket):Vector.<swrapper>
         {
            var _loc5_:swrapper = null;
            var _loc3_:Vector.<swrapper> = new Vector.<swrapper>();
            var _loc2_:uint = param1.readUnsignedShort();
            var _loc4_:uint = _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = swrapper.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.cacheSWC = v_cacheSWC;
      }
      
      public function recv_floorReward(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.floorReward(_loc2_);
      }
      
      public function recv_floorEnding(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedShort();
         the_instance.floorEnding(_loc2_);
      }
      
      public function recv_dungeonEnding(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedShort();
         var _loc3_:uint = packet.readUnsignedByte();
         the_instance.dungeonEnding(_loc2_,_loc3_);
      }
      
      public function recv_floorfailing(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedShort();
         the_instance.floorfailing(_loc2_);
      }
      
      public function recv_tellClientInfiniteRewardData(packet:DcNetworkPacket) : void
      {
         var avId:uint = packet.readUnsignedInt();
         var avScore:uint = packet.readUnsignedShort();
         var goldReward:uint = packet.readUnsignedInt();
         var infiniteRewards:Vector.<InfiniteRewardData> = (function(param1:DcNetworkPacket):Vector.<InfiniteRewardData>
         {
            var _loc5_:InfiniteRewardData = null;
            var _loc3_:Vector.<InfiniteRewardData> = new Vector.<InfiniteRewardData>();
            var _loc2_:uint = param1.readUnsignedShort();
            var _loc4_:uint = _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = InfiniteRewardData.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.tellClientInfiniteRewardData(avId,avScore,goldReward,infiniteRewards);
      }
   }
}

