package GeneratedCode
{
   import DistributedObjects.PlayerGameObjectOwner;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   
   public class PlayerGameObjectOwnerNetworkComponent extends PlayerGameObjectNetworkComponent implements DcNetworkInterface
   {
      
      private var the_instance:IPlayerGameObjectOwner;
      
      public function PlayerGameObjectOwnerNetworkComponent(Inst:PlayerGameObjectOwner, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function ownerFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : PlayerGameObjectOwnerNetworkComponent
      {
         var _loc5_:PlayerGameObjectOwner = new PlayerGameObjectOwner(gs.facade,doid);
         var _loc4_:PlayerGameObjectOwnerNetworkComponent = new PlayerGameObjectOwnerNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentPlayerGameObject(_loc4_);
         _loc5_.setOwnerNetworkComponentPlayerGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 181)
         {
            case 0:
               recv_basicCurrency(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_screenName(packet);
         recv_basicCurrency(packet);
         recvByIdLoop(packet);
      }
      
      public function recv_basicCurrency(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.basicCurrency = _loc2_;
      }
      
      public function send_Chat(text:String) : void
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,182);
         _loc2_.writeUTF(text);
         Send_packet(_loc2_);
      }
      
      public function send_ShowPlayerIsTyping(value:uint) : void
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,183);
         _loc2_.writeByte(value);
         Send_packet(_loc2_);
      }
      
      public function send_requesthero() : void
      {
         var _loc1_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc1_,184);
         Send_packet(_loc1_);
      }
      
      public function send_requestentry() : void
      {
         var _loc1_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc1_,185);
         Send_packet(_loc1_);
      }
      
      public function send_requestpartymemberinvite() : void
      {
         var _loc1_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc1_,186);
         Send_packet(_loc1_);
      }
   }
}

