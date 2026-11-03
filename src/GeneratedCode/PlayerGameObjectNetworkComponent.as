package GeneratedCode
{
   import DistributedObjects.PlayerGameObject;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class PlayerGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:PlayerGameObject;
      
      public const FLID_screenName:uint = 187;
      
      public const FLID_heroPreloadLook:uint = 188;
      
      public const FLID_basicCurrency:uint = 189;
      
      public const FLID_Chat:uint = 190;
      
      public const FLID_ShowPlayerIsTyping:uint = 191;
      
      public const FLID_requesthero:uint = 192;
      
      public const FLID_requestentry:uint = 193;
      
      public const FLID_requestpartymemberinvite:uint = 194;
      
      public const FLID_requestexit:uint = 195;
      
      public function PlayerGameObjectNetworkComponent(Inst:PlayerGameObject, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : PlayerGameObjectNetworkComponent
      {
         var _loc5_:PlayerGameObject = new PlayerGameObject(gs.facade,doid);
         var _loc4_:PlayerGameObjectNetworkComponent = new PlayerGameObjectNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentPlayerGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 187)
         {
            case 0:
               recv_screenName(packet);
               break;
            case 1:
               recv_heroPreloadLook(packet);
               break;
            case 3:
               recv_Chat(packet);
               break;
            case 4:
               recv_ShowPlayerIsTyping(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_screenName(packet);
         recv_heroPreloadLook(packet);
         recvByIdLoop(packet);
      }
      
      override public function destroy() : void
      {
         the_instance.destroy();
      }
      
      public function recv_screenName(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.screenName = _loc2_;
      }
      
      public function recv_heroPreloadLook(packet:DcNetworkPacket) : void
      {
         var _loc2_:HeroPreloadLook = HeroPreloadLook.readFromPacket(packet);
         the_instance.heroPreloadLook = _loc2_;
      }
      
      public function recv_Chat(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.Chat(_loc2_);
      }
      
      public function recv_ShowPlayerIsTyping(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         the_instance.ShowPlayerIsTyping(_loc2_);
      }
   }
}

