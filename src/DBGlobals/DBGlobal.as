package DBGlobals
{
   import Brain.Logger.Logger;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   
   public class DBGlobal
   {
      
      public static var TUTORIAL_MAP_NODE_ID:uint = 50002;
      
      public static var MUSIC_VOLUME:Number = 0.7;
      
      public static var SFX_VOLUME:Number = 0.7;
      
      public static const RESSURECTION_POTION_STACK_ID:uint = 60001;
      
      public static const RESSURECTION_POTION_OFFER_ID:uint = 51304;
      
      public static const PARTYBOMB_POTION_STACK_ID:uint = 60018;
      
      public static const PARTYBOMB_POTION_OFFER_ID:uint = 51369;
      
      public static const SFX_PATH:String = "Resources/Audio/soundEffects.swf";
      
      public static const DEFAULT_ICON_NATIVE_SIZE:Number = 100;
      
      public static const WEAPON_ICON_NATIVE_SIZE:Number = 100;
      
      public static const CHEST_ICON_NATIVE_SIZE:Number = 120;
      
      public static const CHARGE_ICON_NATIVE_SIZE:Number = 60;
      
      public static const HERO_ICON_NATIVE_SIZE:Number = 72;
      
      public static const PET_ICON_NATIVE_SIZE:Number = 68;
      
      public static const BERSERKER_TYPE_ID:uint = 101;
      
      public static const RANGER_TYPE_ID:uint = 102;
      
      public static const SORCERER_TYPE_ID:uint = 103;
      
      public static const BATTLE_CHEF_TYPE_ID:uint = 104;
      
      public static const VAMPIRE_HUNTER_TYPE_ID:uint = 105;
      
      public static const GHOST_SAMURAI_TYPE_ID:uint = 106;
      
      public static const MELEE_ITEM_CATEGORY:String = "MELEE";
      
      public static const SHOOTING_ITEM_CATEGORY:String = "SHOOTING";
      
      public static const MAGIC_ITEM_CATEGORY:String = "MAGIC";
      
      public static const HP_BOOST:Number = 0;
      
      public static const MP_BOOST:Number = 1;
      
      public static const MELEE_ATK:Number = 2;
      
      public static const SHOOT_ATK:Number = 3;
      
      public static const MAGIC_ATK:Number = 4;
      
      public static const MELEE_DEF:Number = 5;
      
      public static const SHOOT_DEF:Number = 6;
      
      public static const MAGIC_DEF:Number = 7;
      
      public static const MELEE_SPD:Number = 8;
      
      public static const SHOOT_SPD:Number = 9;
      
      public static const MAGIC_SPD:Number = 10;
      
      public static const HP_REGEN:Number = 11;
      
      public static const MP_REGEN:Number = 12;
      
      public static const MOVEMENT:Number = 13;
      
      public static const LUCK:Number = 14;
      
      public static const LV_HP_BOOST:Number = 0;
      
      public static const LV_MP_BOOST:Number = 1;
      
      public static const LV_MELEE_ATK:Number = 2;
      
      public static const LV_SHOOT_ATK:Number = 3;
      
      public static const LV_MAGIC_ATK:Number = 4;
      
      public static const LV_MELEE_DEF:Number = 5;
      
      public static const LV_SHOOT_DEF:Number = 6;
      
      public static const LV_MAGIC_DEF:Number = 7;
      
      public static const LV_MELEE_SPD:Number = 8;
      
      public static const LV_SHOOT_SPD:Number = 9;
      
      public static const LV_MAGIC_SPD:Number = 10;
      
      public static const LV_HP_REGEN:Number = 11;
      
      public static const LV_MP_REGEN:Number = 12;
      
      public static const LV_MOVEMENT:Number = 13;
      
      public static const LV_LUCK:Number = 14;
      
      public static const ATTTACK_TYPE_MELEE:Number = 0;
      
      public static const ATTTACK_TYPE_RANGE:Number = 1;
      
      public static const ATTTACK_TYPE_MAGIC:Number = 2;
      
      public static const B2D_ENVIRONMENT_MASK:uint = 1;
      
      public static const B2D_COMBAT_MASK:uint = 2;
      
      public static const TEAM_ENVIRONMENT:uint = 1;
      
      public static const TEAM_1:uint = 5;
      
      public static const TEAM_2:uint = 6;
      
      public static const TEAM_3:uint = 7;
      
      public static const ABILITY_SUFFER_IMMUNITY:uint = 1;
      
      public static const ABILITY_INVULNERABLE_MELEE:uint = 2;
      
      public static const ABILITY_INVULNERABLE_MAGIC:uint = 4;
      
      public static const ABILITY_INVULNERABLE_SHOOT:uint = 8;
      
      public static const ABILITY_INVULNERABLE_ALL:uint = 14;
      
      public static const ABILITY_BERSERK_MODE:uint = 16;
      
      public static const ABILITY_PARALYZED:uint = 32;
      
      public static const ABILITY_BREAK_FREE:uint = 64;
      
      public static const ABILITY_PANIC:uint = 128;
      
      public static const ABILITY_PARALYZE_IMMUNITY:uint = 256;
      
      public static const ABILITY_DISABLE_CONTROLS:uint = 512;
      
      public static const ABILITY_PIERCE_IMMUNE:uint = 16777216;
      
      public static const BERSERKER_RAMPAGE:String = "RAMPAGE";
      
      public static const UI_16_TO_9_PORT_OBJECT_SCALE:Number = 1.8;
      
      public static const FILTER_QUALITY_LOW:uint = 0;
      
      public static const FILTER_QUALITY_MEDIUM:uint = 1;
      
      public static const FILTER_QUALITY_HIGH:uint = 2;
      
      public static var StatNames:Vector.<String> = Vector.<String>(["HP_BOOST","MP_BOOST","MELEE_ATK","SHOOT_ATK","MAGIC_ATK","SHOOT_DEF","MELEE_DEF","MAGIC_DEF","MELEE_SPD","SHOOT_SPD","MAGIC_SPD","HP_REGEN","MP_REGEN","MOVEMENT","LUCK"]);
      
      public static const UI_ROLLOVER_FILTER:GlowFilter = new GlowFilter(16633879,1,8,8,5);
      
      public static const UI_SELECTED_FILTER:GlowFilter = new GlowFilter(16777215,1,6,6,12);
      
      public static const UI_DISABLED_FILTER:GlowFilter = new GlowFilter(16711680,0.1,5,5,2.6);
      
      public function DBGlobal()
      {
         super();
      }
      
      public static function NameToSlotOffset(name:String) : int
      {
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < StatNames.length)
         {
            if(StatNames[_loc2_] == name)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public static function b2dMaskForAllTeamsBut(team:uint) : uint
      {
         if(team == 5)
         {
            return 193;
         }
         if(team == 6)
         {
            return 161;
         }
         if(team == 7)
         {
            return 97;
         }
         if(team == 1)
         {
            return 96;
         }
         Logger.error("Unable to determine box2D team mask for team: " + team + " in function: b2dMaskForAllTeamsBut");
         return 0;
      }
      
      public static function b2dMaskForTeam(team:uint) : uint
      {
         if(team == 5)
         {
            return 1 << 5;
         }
         if(team == 6)
         {
            return 1 << 6;
         }
         if(team == 7)
         {
            return 1 << 7;
         }
         if(team == 1)
         {
            return 1;
         }
         Logger.error("Unable to determine box2D team mask for team: " + team + " in function: b2dMaskForTeam");
         return 0;
      }
      
      public static function mapAbilityMask(ability:String) : uint
      {
         if(ability == "SUFFER_IMMUNE")
         {
            return 1;
         }
         if(ability == "INVULNERABLE_MELEE")
         {
            return 2;
         }
         if(ability == "INVULNERABLE_MAGIC")
         {
            return 4;
         }
         if(ability == "INVULNERABLE_SHOOT")
         {
            return 8;
         }
         if(ability == "INVULNERABLE_ALL")
         {
            return 14;
         }
         if(ability == "BERSERK_MODE")
         {
            return 16;
         }
         if(ability == "PARALYZED")
         {
            return 32;
         }
         if(ability == "DISABLE_CONTROLS")
         {
            return 512;
         }
         if(ability == "BREAK_FREE")
         {
            return 64;
         }
         if(ability == "PANIC")
         {
            return 128;
         }
         if(ability == "PARALYZE_IMMUNITY")
         {
            return 256;
         }
         if(ability == "PIERCE_IMMUNE")
         {
            return 16777216;
         }
         return 0;
      }
      
      public static function traceClipChildren(clipToTrace:MovieClip) : void
      {
         var _loc2_:* = 0;
         trace("+ number of DisplayObject: " + clipToTrace.numChildren + "  --------------------------------");
         _loc2_ = 0;
         while(_loc2_ < clipToTrace.numChildren)
         {
            trace("\t|\t " + _loc2_ + ".\t name:" + clipToTrace.getChildAt(_loc2_).name + "\t type:" + typeof clipToTrace.getChildAt(_loc2_) + "\t" + clipToTrace.getChildAt(_loc2_));
            _loc2_++;
         }
         trace("\t+ --------------------------------------------------------------------------------------");
      }
      
      public static function highlightButton(button:*, quality:uint = 1) : void
      {
         var _loc3_:GlowFilter = UI_ROLLOVER_FILTER;
         if(quality == 0)
         {
            _loc3_.quality = 1;
         }
         else if(quality == 1)
         {
            _loc3_.quality = 2;
         }
         else if(quality == 2)
         {
            _loc3_.quality = 3;
         }
         else
         {
            Logger.warn("No such quality exists..");
         }
         if(button is MovieClip)
         {
            button.filters = [_loc3_];
         }
         else
         {
            button.root.filters = [_loc3_];
         }
      }
      
      public static function unHighlightButton(button:*) : void
      {
         if(button == null)
         {
            Logger.warn("Cannot unhilight null button/movieclip");
         }
         if(button is MovieClip)
         {
            button.filters = [];
         }
         else
         {
            button.root.filters = null;
         }
      }
      
      public static function endsWith(input:String, suffix:String) : Boolean
      {
         return suffix == input.substring(input.length - suffix.length);
      }
   }
}

