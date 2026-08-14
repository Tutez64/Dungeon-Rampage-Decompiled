package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class AttackChoreography
   {
      
      public var attack:Attack;
      
      public var loop:uint;
      
      public var playSpeed:Number;
      
      public var scalingMaxProjectiles:Number;
      
      public var combatResults:Vector.<CombatResult>;
      
      public function AttackChoreography()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : AttackChoreography
      {
         var work:AttackChoreography = new AttackChoreography();
         work.attack = Attack.readFromPacket(packet);
         work.loop = packet.readUnsignedByte();
         work.playSpeed = packet.readFloat();
         work.scalingMaxProjectiles = packet.readFloat();
         work.combatResults = (function(param1:DcNetworkPacket):Vector.<CombatResult>
         {
            var _loc5_:CombatResult = null;
            var _loc3_:Vector.<CombatResult> = new Vector.<CombatResult>();
            var _loc2_:uint = param1.readUnsignedShort();
            var _loc4_:uint = _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = CombatResult.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         return work;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         var combatResultsfunc:Function;
         attack.writeToPacket(outpacket);
         outpacket.writeByte(loop);
         outpacket.writeFloat(playSpeed);
         outpacket.writeFloat(scalingMaxProjectiles);
         combatResultsfunc = function():void
         {
            var _loc2_:* = 0;
            var _loc1_:uint = combatResults.length;
            var _loc3_:DcNetworkPacket = outpacket;
            outpacket = new DcNetworkPacket();
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               combatResults[_loc2_].writeToPacket(outpacket);
               _loc2_++;
            }
            _loc3_.writeShort(outpacket.length);
            _loc3_.writeBytes(outpacket);
            outpacket = _loc3_;
         };
         combatResultsfunc();
      }
   }
}

