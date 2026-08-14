package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class GameServerPartyMember
   {
      
      public var id:uint;
      
      public var status:int;
      
      public function GameServerPartyMember()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : GameServerPartyMember
      {
         var _loc2_:GameServerPartyMember = new GameServerPartyMember();
         _loc2_.id = packet.readUnsignedInt();
         _loc2_.status = packet.readByte();
         return _loc2_;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         outpacket.writeUnsignedInt(id);
         outpacket.writeByte(status);
      }
   }
}

