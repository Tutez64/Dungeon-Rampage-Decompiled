package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class DungeonTileUsage
   {
      
      public var x:int;
      
      public var y:int;
      
      public var tileId:String;
      
      public function DungeonTileUsage()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : DungeonTileUsage
      {
         var _loc2_:DungeonTileUsage = new DungeonTileUsage();
         _loc2_.x = packet.readInt();
         _loc2_.y = packet.readInt();
         _loc2_.tileId = packet.readUTF();
         return _loc2_;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         outpacket.writeInt(x);
         outpacket.writeInt(y);
         outpacket.writeUTF(tileId);
      }
   }
}

