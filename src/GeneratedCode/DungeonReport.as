package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class DungeonReport
   {
      
      public var name:String;
      
      public var trophyCount:uint;
      
      public var id:uint;
      
      public var type:uint;
      
      public var skin_type:uint;
      
      public var kills:uint;
      
      public var xp:uint;
      
      public var xp_earned:uint;
      
      public var xp_bonus:uint;
      
      public var team_xp_bonus:uint;
      
      public var gold_earned:uint;
      
      public var gems_earned:uint;
      
      public var boost_xp:Number;
      
      public var boost_gold:Number;
      
      public var receivedTrophy:uint;
      
      public var dungeonModifier1:uint;
      
      public var dungeonModifier2:uint;
      
      public var dungeonModifier3:uint;
      
      public var dungeonModifier4:uint;
      
      public var loot_type_1:uint;
      
      public var loot_type_2:uint;
      
      public var loot_type_3:uint;
      
      public var loot_type_4:uint;
      
      public var weapon_level_1:uint;
      
      public var weapon_level_2:uint;
      
      public var weapon_level_3:uint;
      
      public var weapon_type_1:uint;
      
      public var weapon_type_2:uint;
      
      public var weapon_type_3:uint;
      
      public var modifier_type_1a:uint;
      
      public var modifier_type_1b:uint;
      
      public var legendary_modifier_type_1:uint;
      
      public var modifier_type_2a:uint;
      
      public var modifier_type_2b:uint;
      
      public var legendary_modifier_type_2:uint;
      
      public var modifier_type_3a:uint;
      
      public var modifier_type_3b:uint;
      
      public var legendary_modifier_type_3:uint;
      
      public var weapon_power_1:uint;
      
      public var weapon_power_2:uint;
      
      public var weapon_power_3:uint;
      
      public var weapon_rarity_1:uint;
      
      public var weapon_rarity_2:uint;
      
      public var weapon_rarity_3:uint;
      
      public var chest_type_1:uint;
      
      public var chest_type_2:uint;
      
      public var chest_type_3:uint;
      
      public var chest_type_4:uint;
      
      public var valid:uint;
      
      public var account_flags:uint;
      
      public var totalAvatarsOwned:uint;
      
      public var consumable1_id:uint;
      
      public var consumable1_count:uint;
      
      public var consumable2_id:uint;
      
      public var consumable2_count:uint;
      
      public function DungeonReport()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : DungeonReport
      {
         var _loc2_:DungeonReport = new DungeonReport();
         _loc2_.name = packet.readUTF();
         _loc2_.trophyCount = packet.readUnsignedInt();
         _loc2_.id = packet.readUnsignedInt();
         _loc2_.type = packet.readUnsignedInt();
         _loc2_.skin_type = packet.readUnsignedInt();
         _loc2_.kills = packet.readUnsignedInt();
         _loc2_.xp = packet.readUnsignedInt();
         _loc2_.xp_earned = packet.readUnsignedInt();
         _loc2_.xp_bonus = packet.readUnsignedInt();
         _loc2_.team_xp_bonus = packet.readUnsignedInt();
         _loc2_.gold_earned = packet.readUnsignedInt();
         _loc2_.gems_earned = packet.readUnsignedInt();
         _loc2_.boost_xp = packet.readFloat();
         _loc2_.boost_gold = packet.readFloat();
         _loc2_.receivedTrophy = packet.readUnsignedByte();
         _loc2_.dungeonModifier1 = packet.readUnsignedInt();
         _loc2_.dungeonModifier2 = packet.readUnsignedInt();
         _loc2_.dungeonModifier3 = packet.readUnsignedInt();
         _loc2_.dungeonModifier4 = packet.readUnsignedInt();
         _loc2_.loot_type_1 = packet.readUnsignedInt();
         _loc2_.loot_type_2 = packet.readUnsignedInt();
         _loc2_.loot_type_3 = packet.readUnsignedInt();
         _loc2_.loot_type_4 = packet.readUnsignedInt();
         _loc2_.weapon_level_1 = packet.readUnsignedInt();
         _loc2_.weapon_level_2 = packet.readUnsignedInt();
         _loc2_.weapon_level_3 = packet.readUnsignedInt();
         _loc2_.weapon_type_1 = packet.readUnsignedInt();
         _loc2_.weapon_type_2 = packet.readUnsignedInt();
         _loc2_.weapon_type_3 = packet.readUnsignedInt();
         _loc2_.modifier_type_1a = packet.readUnsignedInt();
         _loc2_.modifier_type_1b = packet.readUnsignedInt();
         _loc2_.legendary_modifier_type_1 = packet.readUnsignedInt();
         _loc2_.modifier_type_2a = packet.readUnsignedInt();
         _loc2_.modifier_type_2b = packet.readUnsignedInt();
         _loc2_.legendary_modifier_type_2 = packet.readUnsignedInt();
         _loc2_.modifier_type_3a = packet.readUnsignedInt();
         _loc2_.modifier_type_3b = packet.readUnsignedInt();
         _loc2_.legendary_modifier_type_3 = packet.readUnsignedInt();
         _loc2_.weapon_power_1 = packet.readUnsignedInt();
         _loc2_.weapon_power_2 = packet.readUnsignedInt();
         _loc2_.weapon_power_3 = packet.readUnsignedInt();
         _loc2_.weapon_rarity_1 = packet.readUnsignedInt();
         _loc2_.weapon_rarity_2 = packet.readUnsignedInt();
         _loc2_.weapon_rarity_3 = packet.readUnsignedInt();
         _loc2_.chest_type_1 = packet.readUnsignedInt();
         _loc2_.chest_type_2 = packet.readUnsignedInt();
         _loc2_.chest_type_3 = packet.readUnsignedInt();
         _loc2_.chest_type_4 = packet.readUnsignedInt();
         _loc2_.valid = packet.readUnsignedByte();
         _loc2_.account_flags = packet.readUnsignedInt();
         _loc2_.totalAvatarsOwned = packet.readUnsignedInt();
         _loc2_.consumable1_id = packet.readUnsignedInt();
         _loc2_.consumable1_count = packet.readUnsignedInt();
         _loc2_.consumable2_id = packet.readUnsignedInt();
         _loc2_.consumable2_count = packet.readUnsignedInt();
         return _loc2_;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         outpacket.writeUTF(name);
         outpacket.writeUnsignedInt(trophyCount);
         outpacket.writeUnsignedInt(id);
         outpacket.writeUnsignedInt(type);
         outpacket.writeUnsignedInt(skin_type);
         outpacket.writeUnsignedInt(kills);
         outpacket.writeUnsignedInt(xp);
         outpacket.writeUnsignedInt(xp_earned);
         outpacket.writeUnsignedInt(xp_bonus);
         outpacket.writeUnsignedInt(team_xp_bonus);
         outpacket.writeUnsignedInt(gold_earned);
         outpacket.writeUnsignedInt(gems_earned);
         outpacket.writeFloat(boost_xp);
         outpacket.writeFloat(boost_gold);
         outpacket.writeByte(receivedTrophy);
         outpacket.writeUnsignedInt(dungeonModifier1);
         outpacket.writeUnsignedInt(dungeonModifier2);
         outpacket.writeUnsignedInt(dungeonModifier3);
         outpacket.writeUnsignedInt(dungeonModifier4);
         outpacket.writeUnsignedInt(loot_type_1);
         outpacket.writeUnsignedInt(loot_type_2);
         outpacket.writeUnsignedInt(loot_type_3);
         outpacket.writeUnsignedInt(loot_type_4);
         outpacket.writeUnsignedInt(weapon_level_1);
         outpacket.writeUnsignedInt(weapon_level_2);
         outpacket.writeUnsignedInt(weapon_level_3);
         outpacket.writeUnsignedInt(weapon_type_1);
         outpacket.writeUnsignedInt(weapon_type_2);
         outpacket.writeUnsignedInt(weapon_type_3);
         outpacket.writeUnsignedInt(modifier_type_1a);
         outpacket.writeUnsignedInt(modifier_type_1b);
         outpacket.writeUnsignedInt(legendary_modifier_type_1);
         outpacket.writeUnsignedInt(modifier_type_2a);
         outpacket.writeUnsignedInt(modifier_type_2b);
         outpacket.writeUnsignedInt(legendary_modifier_type_2);
         outpacket.writeUnsignedInt(modifier_type_3a);
         outpacket.writeUnsignedInt(modifier_type_3b);
         outpacket.writeUnsignedInt(legendary_modifier_type_3);
         outpacket.writeUnsignedInt(weapon_power_1);
         outpacket.writeUnsignedInt(weapon_power_2);
         outpacket.writeUnsignedInt(weapon_power_3);
         outpacket.writeUnsignedInt(weapon_rarity_1);
         outpacket.writeUnsignedInt(weapon_rarity_2);
         outpacket.writeUnsignedInt(weapon_rarity_3);
         outpacket.writeUnsignedInt(chest_type_1);
         outpacket.writeUnsignedInt(chest_type_2);
         outpacket.writeUnsignedInt(chest_type_3);
         outpacket.writeUnsignedInt(chest_type_4);
         outpacket.writeByte(valid);
         outpacket.writeUnsignedInt(account_flags);
         outpacket.writeUnsignedInt(totalAvatarsOwned);
         outpacket.writeUnsignedInt(consumable1_id);
         outpacket.writeUnsignedInt(consumable1_count);
         outpacket.writeUnsignedInt(consumable2_id);
         outpacket.writeUnsignedInt(consumable2_count);
      }
   }
}

