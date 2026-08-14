package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class CombatResult
   {
      
      public var attacker:uint;
      
      public var attackee:uint;
      
      public var damage:int;
      
      public var attack:Attack;
      
      public var when:uint;
      
      public var suffer:uint;
      
      public var knockback:uint;
      
      public var blocked:uint;
      
      public var criticalHit:uint;
      
      public var effectiveness:int;
      
      public var selfDamage:int;
      
      public var scalingMaxPowerMultiplier:Number;
      
      public var generation:uint;
      
      public function CombatResult()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : CombatResult
      {
         var _loc2_:CombatResult = new CombatResult();
         _loc2_.attacker = packet.readUnsignedInt();
         _loc2_.attackee = packet.readUnsignedInt();
         _loc2_.damage = packet.readInt();
         _loc2_.attack = Attack.readFromPacket(packet);
         _loc2_.when = packet.readUnsignedByte();
         _loc2_.suffer = packet.readUnsignedByte();
         _loc2_.knockback = packet.readUnsignedByte();
         _loc2_.blocked = packet.readUnsignedByte();
         _loc2_.criticalHit = packet.readUnsignedByte();
         _loc2_.effectiveness = packet.readByte();
         _loc2_.selfDamage = packet.readInt();
         _loc2_.scalingMaxPowerMultiplier = packet.readFloat();
         _loc2_.generation = packet.readUnsignedByte();
         return _loc2_;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         outpacket.writeUnsignedInt(attacker);
         outpacket.writeUnsignedInt(attackee);
         outpacket.writeInt(damage);
         attack.writeToPacket(outpacket);
         outpacket.writeByte(when);
         outpacket.writeByte(suffer);
         outpacket.writeByte(knockback);
         outpacket.writeByte(blocked);
         outpacket.writeByte(criticalHit);
         outpacket.writeByte(effectiveness);
         outpacket.writeInt(selfDamage);
         outpacket.writeFloat(scalingMaxPowerMultiplier);
         outpacket.writeByte(generation);
      }
   }
}

