package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class InfiniteRewardData
   {
      
      public var dooberId:uint;
      
      public var floorNumber:uint;
      
      public var status:int;
      
      public function InfiniteRewardData()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : InfiniteRewardData
      {
         var _loc2_:InfiniteRewardData = new InfiniteRewardData();
         _loc2_.dooberId = packet.readUnsignedInt();
         _loc2_.floorNumber = packet.readUnsignedShort();
         _loc2_.status = packet.readByte();
         return _loc2_;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         outpacket.writeUnsignedInt(dooberId);
         outpacket.writeShort(floorNumber);
         outpacket.writeByte(status);
      }
   }
}

