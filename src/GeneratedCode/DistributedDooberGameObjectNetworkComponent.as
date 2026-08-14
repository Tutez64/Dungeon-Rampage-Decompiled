package GeneratedCode
{
   import Doobers.DistributedDooberGameObject;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   import flash.geom.Vector3D;
   
   public class DistributedDooberGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:DistributedDooberGameObject;
      
      public const FLID_type:uint = 287;
      
      public const FLID_position:uint = 288;
      
      public const FLID_layer:uint = 289;
      
      public const FLID_spawnFrom:uint = 290;
      
      public const FLID_collectedBy:uint = 291;
      
      public function DistributedDooberGameObjectNetworkComponent(Inst:DistributedDooberGameObject, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : DistributedDooberGameObjectNetworkComponent
      {
         var _loc5_:DistributedDooberGameObject = new DistributedDooberGameObject(gs.facade,doid);
         var _loc4_:DistributedDooberGameObjectNetworkComponent = new DistributedDooberGameObjectNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentDistributedDooberGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 287)
         {
            case 0:
               recv_type(packet);
               break;
            case 1:
               recv_position(packet);
               break;
            case 2:
               recv_layer(packet);
               break;
            case 3:
               recv_spawnFrom(packet);
               break;
            case 4:
               recv_collectedBy(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_type(packet);
         recv_position(packet);
         recv_layer(packet);
         recvByIdLoop(packet);
      }
      
      override public function destroy() : void
      {
         the_instance.destroy();
      }
      
      public function recv_type(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.type = _loc2_;
      }
      
      public function recv_position(packet:DcNetworkPacket) : void
      {
         var v_position:Vector3D = (function(param1:DcNetworkPacket):Vector3D
         {
            var _loc2_:Vector3D = new Vector3D();
            _loc2_.x = param1.readFloat();
            _loc2_.y = param1.readFloat();
            return _loc2_;
         })(packet);
         the_instance.position = v_position;
      }
      
      public function recv_layer(packet:DcNetworkPacket) : void
      {
         var _loc2_:int = packet.readByte();
         the_instance.layer = _loc2_;
      }
      
      public function recv_spawnFrom(packet:DcNetworkPacket) : void
      {
         var loc:Vector3D = (function(param1:DcNetworkPacket):Vector3D
         {
            var _loc2_:Vector3D = new Vector3D();
            _loc2_.x = param1.readFloat();
            _loc2_.y = param1.readFloat();
            return _loc2_;
         })(packet);
         the_instance.spawnFrom(loc);
      }
      
      public function recv_collectedBy(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.collectedBy(_loc2_);
      }
   }
}

