package GeneratedCode
{
   import DistributedObjects.PlayerGameObject;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class PlayerGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:PlayerGameObject;
      
      public const FLID_screenName:uint = 180;
      
      public const FLID_basicCurrency:uint = 181;
      
      public const FLID_Chat:uint = 182;
      
      public const FLID_ShowPlayerIsTyping:uint = 183;
      
      public const FLID_requesthero:uint = 184;
      
      public const FLID_requestentry:uint = 185;
      
      public const FLID_requestpartymemberinvite:uint = 186;
      
      public const FLID_requestexit:uint = 187;
      
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
         switch(int(fieldid) - 180)
         {
            case 0:
               recv_screenName(packet);
               break;
            case 2:
               recv_Chat(packet);
               break;
            case 3:
               recv_ShowPlayerIsTyping(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_screenName(packet);
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

