package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class HeroPreloadLook
   {
      
      public var heroType:uint;
      
      public var skinType:uint;
      
      public var weapons:Vector.<WeaponDetails>;
      
      public var consumableTypes:Vector.<uint>;
      
      public var petTypes:Vector.<uint>;
      
      public function HeroPreloadLook()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : HeroPreloadLook
      {
         var work:HeroPreloadLook = new HeroPreloadLook();
         work.heroType = packet.readUnsignedInt();
         work.skinType = packet.readUnsignedInt();
         work.weapons = (function(param1:DcNetworkPacket):Vector.<WeaponDetails>
         {
            var _loc3_:uint = 0;
            var _loc5_:WeaponDetails = null;
            var _loc4_:Vector.<WeaponDetails> = new Vector.<WeaponDetails>();
            var _loc2_:uint = 3;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc5_ = WeaponDetails.readFromPacket(param1);
               _loc4_.push(_loc5_);
               _loc3_++;
            }
            return _loc4_;
         })(packet);
         work.consumableTypes = (function(param1:DcNetworkPacket):Vector.<uint>
         {
            var _loc3_:uint = 0;
            var _loc5_:uint = 0;
            var _loc4_:Vector.<uint> = new Vector.<uint>();
            var _loc2_:uint = 2;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc5_ = param1.readUnsignedInt();
               _loc4_.push(_loc5_);
               _loc3_++;
            }
            return _loc4_;
         })(packet);
         work.petTypes = (function(param1:DcNetworkPacket):Vector.<uint>
         {
            var _loc5_:uint = 0;
            var _loc3_:Vector.<uint> = new Vector.<uint>();
            var _loc2_:uint = param1.readUnsignedShort();
            var _loc4_:uint = _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = param1.readUnsignedInt();
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         return work;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         var weapons_count:uint;
         var weapons_loop:uint;
         var consumableTypes_count:uint;
         var consumableTypes_loop:uint;
         var petTypesfunc:Function;
         outpacket.writeUnsignedInt(heroType);
         outpacket.writeUnsignedInt(skinType);
         weapons_count = 3;
         weapons_loop = 0;
         while(weapons_loop < weapons_count)
         {
            weapons[weapons_loop].writeToPacket(outpacket);
            weapons_loop = weapons_loop + 1;
         }
         consumableTypes_count = 2;
         consumableTypes_loop = 0;
         while(consumableTypes_loop < consumableTypes_count)
         {
            outpacket.writeUnsignedInt(consumableTypes[consumableTypes_loop]);
            consumableTypes_loop = consumableTypes_loop + 1;
         }
         petTypesfunc = function():void
         {
            var _loc1_:uint = 0;
            var _loc3_:uint = petTypes.length;
            var _loc2_:DcNetworkPacket = outpacket;
            outpacket = new DcNetworkPacket();
            _loc1_ = 0;
            while(_loc1_ < _loc3_)
            {
               outpacket.writeUnsignedInt(petTypes[_loc1_]);
               _loc1_++;
            }
            _loc2_.writeShort(outpacket.length);
            _loc2_.writeBytes(outpacket);
            outpacket = _loc2_;
         };
         petTypesfunc();
      }
   }
}

