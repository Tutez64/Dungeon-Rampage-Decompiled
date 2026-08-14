package GeneratedCode
{
   import DistributedObjects.DistributedTownArea;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class DistributedTownAreaNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:DistributedTownArea;
      
      public const FLID_tileLibrary:uint = 286;
      
      public function DistributedTownAreaNetworkComponent(Inst:DistributedTownArea, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : DistributedTownAreaNetworkComponent
      {
         var _loc5_:DistributedTownArea = new DistributedTownArea(gs.facade,doid);
         var _loc4_:DistributedTownAreaNetworkComponent = new DistributedTownAreaNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentDistributedTownArea(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 286)
         {
            case 0:
               recv_tileLibrary(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_tileLibrary(packet);
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
   }
}

