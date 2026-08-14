package GeneratedCode
{
   import Actor.Buffs.DistributedBuffGameObject;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class DistributedBuffGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:DistributedBuffGameObject;
      
      public const FLID_type:uint = 292;
      
      public const FLID_effectedActor:uint = 293;
      
      public const FLID_attackerActor:uint = 294;
      
      public function DistributedBuffGameObjectNetworkComponent(Inst:DistributedBuffGameObject, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : DistributedBuffGameObjectNetworkComponent
      {
         var _loc5_:DistributedBuffGameObject = new DistributedBuffGameObject(gs.facade,doid);
         var _loc4_:DistributedBuffGameObjectNetworkComponent = new DistributedBuffGameObjectNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentDistributedBuffGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 292)
         {
            case 0:
               recv_type(packet);
               break;
            case 1:
               recv_effectedActor(packet);
               break;
            case 2:
               recv_attackerActor(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_type(packet);
         recv_effectedActor(packet);
         recv_attackerActor(packet);
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
      
      public function recv_effectedActor(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.effectedActor = _loc2_;
      }
      
      public function recv_attackerActor(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.attackerActor = _loc2_;
      }
   }
}

