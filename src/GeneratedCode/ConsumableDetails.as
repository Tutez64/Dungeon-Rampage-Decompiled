package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class ConsumableDetails
   {
      
      public var type:uint;
      
      public var count:uint;
      
      public function ConsumableDetails()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : ConsumableDetails
      {
         var _loc2_:ConsumableDetails = new ConsumableDetails();
         _loc2_.type = packet.readUnsignedInt();
         _loc2_.count = packet.readUnsignedShort();
         return _loc2_;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         outpacket.writeUnsignedInt(type);
         outpacket.writeShort(count);
      }
   }
}

