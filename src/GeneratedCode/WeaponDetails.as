package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class WeaponDetails
   {
      
      public var type:uint;
      
      public var power:uint;
      
      public var requiredlevel:uint;
      
      public var rarity:uint;
      
      public var modifier1:uint;
      
      public var modifier2:uint;
      
      public var legendarymodifier:uint;
      
      public function WeaponDetails()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : WeaponDetails
      {
         var _loc2_:WeaponDetails = new WeaponDetails();
         _loc2_.type = packet.readUnsignedInt();
         _loc2_.power = packet.readUnsignedShort();
         _loc2_.requiredlevel = packet.readUnsignedByte();
         _loc2_.rarity = packet.readUnsignedByte();
         _loc2_.modifier1 = packet.readUnsignedInt();
         _loc2_.modifier2 = packet.readUnsignedInt();
         _loc2_.legendarymodifier = packet.readUnsignedInt();
         return _loc2_;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         outpacket.writeUnsignedInt(type);
         outpacket.writeShort(power);
         outpacket.writeByte(requiredlevel);
         outpacket.writeByte(rarity);
         outpacket.writeUnsignedInt(modifier1);
         outpacket.writeUnsignedInt(modifier2);
         outpacket.writeUnsignedInt(legendarymodifier);
      }
   }
}

