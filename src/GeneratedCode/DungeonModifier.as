package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class DungeonModifier
   {
      
      public var id:uint;
      
      public var new_this_floor:uint;
      
      public function DungeonModifier()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : DungeonModifier
      {
         var _loc2_:DungeonModifier = new DungeonModifier();
         _loc2_.id = packet.readUnsignedInt();
         _loc2_.new_this_floor = packet.readUnsignedByte();
         return _loc2_;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         outpacket.writeUnsignedInt(id);
         outpacket.writeByte(new_this_floor);
      }
   }
}

