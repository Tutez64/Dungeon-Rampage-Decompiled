package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class Attack
   {
      
      public var weaponSlot:int;
      
      public var isConsumableWeapon:uint;
      
      public var attackType:uint;
      
      public var targetActorDoid:uint;
      
      public function Attack()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : Attack
      {
         var _loc2_:Attack = new Attack();
         _loc2_.weaponSlot = packet.readByte();
         _loc2_.isConsumableWeapon = packet.readUnsignedByte();
         _loc2_.attackType = packet.readUnsignedInt();
         _loc2_.targetActorDoid = packet.readUnsignedInt();
         return _loc2_;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         outpacket.writeByte(weaponSlot);
         outpacket.writeByte(isConsumableWeapon);
         outpacket.writeUnsignedInt(attackType);
         outpacket.writeUnsignedInt(targetActorDoid);
      }
   }
}

