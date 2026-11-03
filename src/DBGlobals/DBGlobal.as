package DBGlobals
{
   import Brain.Logger.Logger;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   import haxe.Log;
   
   public class DBGlobal
   {
      
      public static var TUTORIAL_MAP_NODE_ID:uint = 50002;
      
      public static var MUSIC_VOLUME:Number = 0.5;
      
      public static var SFX_VOLUME:Number = 0.5;
      
      public static var RESSURECTION_POTION_STACK_ID:uint = 60001;
      
      public static var RESSURECTION_POTION_OFFER_ID:uint = 51304;
      
      public static var PARTYBOMB_POTION_STACK_ID:uint = 60018;
      
      public static var PARTYBOMB_POTION_OFFER_ID:uint = 51369;
      
      public static var CONSUMABLE_WEAPON_ID:uint = 40000;
      
      public static var SFX_PATH:String = "Resources/Audio/soundEffects.swf";
      
      public static var DEFAULT_ICON_NATIVE_SIZE:Number = 100;
      
      public static var WEAPON_ICON_NATIVE_SIZE:Number = 100;
      
      public static var CHEST_ICON_NATIVE_SIZE:Number = 120;
      
      public static var CHARGE_ICON_NATIVE_SIZE:Number = 60;
      
      public static var HERO_ICON_NATIVE_SIZE:Number = 72;
      
      public static var PET_ICON_NATIVE_SIZE:Number = 68;
      
      public static var BERSERKER_TYPE_ID:uint = 101;
      
      public static var RANGER_TYPE_ID:uint = 102;
      
      public static var SORCERER_TYPE_ID:uint = 103;
      
      public static var BATTLE_CHEF_TYPE_ID:uint = 104;
      
      public static var VAMPIRE_HUNTER_TYPE_ID:uint = 105;
      
      public static var GHOST_SAMURAI_TYPE_ID:uint = 106;
      
      public static var MELEE_ITEM_CATEGORY:String = "MELEE";
      
      public static var SHOOTING_ITEM_CATEGORY:String = "SHOOTING";
      
      public static var MAGIC_ITEM_CATEGORY:String = "MAGIC";
      
      public static var HP_BOOST:int = 0;
      
      public static var MP_BOOST:int = 1;
      
      public static var MELEE_ATK:int = 2;
      
      public static var SHOOT_ATK:int = 3;
      
      public static var MAGIC_ATK:int = 4;
      
      public static var MELEE_DEF:int = 5;
      
      public static var SHOOT_DEF:int = 6;
      
      public static var MAGIC_DEF:int = 7;
      
      public static var MELEE_SPD:int = 8;
      
      public static var SHOOT_SPD:int = 9;
      
      public static var MAGIC_SPD:int = 10;
      
      public static var HP_REGEN:int = 11;
      
      public static var MP_REGEN:int = 12;
      
      public static var MOVEMENT:int = 13;
      
      public static var LV_HP_BOOST:int = 0;
      
      public static var LV_MP_BOOST:int = 1;
      
      public static var LV_MELEE_ATK:int = 2;
      
      public static var LV_SHOOT_ATK:int = 3;
      
      public static var LV_MAGIC_ATK:int = 4;
      
      public static var LV_MELEE_DEF:int = 5;
      
      public static var LV_SHOOT_DEF:int = 6;
      
      public static var LV_MAGIC_DEF:int = 7;
      
      public static var LV_MELEE_SPD:int = 8;
      
      public static var LV_SHOOT_SPD:int = 9;
      
      public static var LV_MAGIC_SPD:int = 10;
      
      public static var LV_HP_REGEN:int = 11;
      
      public static var LV_MP_REGEN:int = 12;
      
      public static var LV_MOVEMENT:int = 13;
      
      public static var ATTTACK_TYPE_MELEE:int = 0;
      
      public static var ATTTACK_TYPE_RANGE:int = 1;
      
      public static var ATTTACK_TYPE_MAGIC:int = 2;
      
      public static var B2D_ENVIRONMENT_MASK:uint = 1;
      
      public static var B2D_COMBAT_MASK:uint = 2;
      
      public static var TEAM_ENVIRONMENT:uint = 1;
      
      public static var TEAM_1:uint = 5;
      
      public static var TEAM_2:uint = 6;
      
      public static var TEAM_3:uint = 7;
      
      public static var ABILITY_SUFFER_IMMUNITY:uint = 1;
      
      public static var ABILITY_INVULNERABLE_MELEE:uint = 2;
      
      public static var ABILITY_INVULNERABLE_MAGIC:uint = 4;
      
      public static var ABILITY_INVULNERABLE_SHOOT:uint = 8;
      
      public static var ABILITY_BERSERK_MODE:uint = 16;
      
      public static var ABILITY_PARALYZED:uint = 32;
      
      public static var ABILITY_BREAK_FREE:uint = 64;
      
      public static var ABILITY_PANIC:uint = 128;
      
      public static var ABILITY_PARALYZE_IMMUNITY:uint = 256;
      
      public static var ABILITY_DISABLE_CONTROLS:uint = 512;
      
      public static var ABILITY_PIERCE_IMMUNE:uint = 16777216;
      
      public static var BERSERKER_RAMPAGE:String = "RAMPAGE";
      
      public static var UI_16_TO_9_PORT_OBJECT_SCALE:Number = 1.8;
      
      public static var FILTER_QUALITY_LOW:uint = 0;
      
      public static var FILTER_QUALITY_MEDIUM:uint = 1;
      
      public static var FILTER_QUALITY_HIGH:uint = 2;
      
      public static var StatNames:Vector.<String> = Vector.<String>(["HP_BOOST","MP_BOOST","MELEE_ATK","SHOOT_ATK","MAGIC_ATK","MELEE_DEF","SHOOT_DEF","MAGIC_DEF","MELEE_SPD","SHOOT_SPD","MAGIC_SPD","HP_REGEN","MP_REGEN","MOVEMENT"]);
      
      public static var ABILITY_INVULNERABLE_ALL:uint = DBGlobal.ABILITY_INVULNERABLE_MELEE | DBGlobal.ABILITY_INVULNERABLE_MAGIC | DBGlobal.ABILITY_INVULNERABLE_SHOOT;
      
      public static var UI_ROLLOVER_FILTER:GlowFilter = new GlowFilter(16633879,1,8,8,5);
      
      public static var UI_SELECTED_FILTER:GlowFilter = new GlowFilter(16777215,1,6,6,12);
      
      public static var UI_DISABLED_FILTER:GlowFilter = new GlowFilter(16711680,0.1,5,5,2.6);
      
      public function DBGlobal()
      {
      }
      
      public static function NameToSlotOffset(name:String) : int
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = int(DBGlobal.StatNames.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc2_++;
            if(DBGlobal.StatNames[_loc4_] == name)
            {
               return _loc4_;
            }
         }
         return -1;
      }
      
      public static function b2dMaskForAllTeamsBut(team:uint) : uint
      {
         if(team == DBGlobal.TEAM_1)
         {
            return DBGlobal.B2D_ENVIRONMENT_MASK | 1 << DBGlobal.TEAM_2 | 1 << DBGlobal.TEAM_3;
         }
         if(team == DBGlobal.TEAM_2)
         {
            return DBGlobal.B2D_ENVIRONMENT_MASK | 1 << DBGlobal.TEAM_1 | 1 << DBGlobal.TEAM_3;
         }
         if(team == DBGlobal.TEAM_3)
         {
            return DBGlobal.B2D_ENVIRONMENT_MASK | 1 << DBGlobal.TEAM_1 | 1 << DBGlobal.TEAM_2;
         }
         if(team == DBGlobal.TEAM_ENVIRONMENT)
         {
            return 1 << DBGlobal.TEAM_1 | 1 << DBGlobal.TEAM_2;
         }
         Logger.error("Unable to determine box2D team mask for team: " + ("" + team) + " in function: b2dMaskForAllTeamsBut");
         return 0;
      }
      
      public static function b2dMaskForTeam(team:uint) : uint
      {
         if(team == DBGlobal.TEAM_1)
         {
            return 1 << DBGlobal.TEAM_1;
         }
         if(team == DBGlobal.TEAM_2)
         {
            return 1 << DBGlobal.TEAM_2;
         }
         if(team == DBGlobal.TEAM_3)
         {
            return 1 << DBGlobal.TEAM_3;
         }
         if(team == DBGlobal.TEAM_ENVIRONMENT)
         {
            return DBGlobal.B2D_ENVIRONMENT_MASK;
         }
         Logger.error("Unable to determine box2D team mask for team: " + ("" + team) + " in function: b2dMaskForTeam");
         return 0;
      }
      
      public static function mapAbilityMask(ability:String) : uint
      {
         if(ability == "SUFFER_IMMUNE")
         {
            return DBGlobal.ABILITY_SUFFER_IMMUNITY;
         }
         if(ability == "INVULNERABLE_MELEE")
         {
            return DBGlobal.ABILITY_INVULNERABLE_MELEE;
         }
         if(ability == "INVULNERABLE_MAGIC")
         {
            return DBGlobal.ABILITY_INVULNERABLE_MAGIC;
         }
         if(ability == "INVULNERABLE_SHOOT")
         {
            return DBGlobal.ABILITY_INVULNERABLE_SHOOT;
         }
         if(ability == "INVULNERABLE_ALL")
         {
            return DBGlobal.ABILITY_INVULNERABLE_ALL;
         }
         if(ability == "BERSERK_MODE")
         {
            return DBGlobal.ABILITY_BERSERK_MODE;
         }
         if(ability == "PARALYZED")
         {
            return DBGlobal.ABILITY_PARALYZED;
         }
         if(ability == "DISABLE_CONTROLS")
         {
            return DBGlobal.ABILITY_DISABLE_CONTROLS;
         }
         if(ability == "BREAK_FREE")
         {
            return DBGlobal.ABILITY_BREAK_FREE;
         }
         if(ability == "PANIC")
         {
            return DBGlobal.ABILITY_PANIC;
         }
         if(ability == "PARALYZE_IMMUNITY")
         {
            return DBGlobal.ABILITY_PARALYZE_IMMUNITY;
         }
         if(ability == "PIERCE_IMMUNE")
         {
            return DBGlobal.ABILITY_PIERCE_IMMUNE;
         }
         return 0;
      }
      
      public static function traceClipChildren(clipToTrace:MovieClip) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = null as DisplayObject;
         Log.trace("+ number of DisplayObject: " + clipToTrace.numChildren + "  --------------------------------",{
            "fileName":"../DungeonBusters/Client/GameMasterProjectHaxe/src/dbglobals/DBGlobal.hx",
            "lineNumber":202,
            "className":"dbglobals.DBGlobal",
            "methodName":"traceClipChildren"
         });
         var _loc2_:int = 0;
         var _loc3_:int = clipToTrace.numChildren;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc2_++;
            _loc5_ = clipToTrace.getChildAt(_loc4_);
            Log.trace("\t|\t " + _loc4_ + ".\t name:" + _loc5_.name + "\t type:" + Type.getClassName(Type.getClass(_loc5_)) + "\t" + Std.string(_loc5_),{
               "fileName":"../DungeonBusters/Client/GameMasterProjectHaxe/src/dbglobals/DBGlobal.hx",
               "lineNumber":205,
               "className":"dbglobals.DBGlobal",
               "methodName":"traceClipChildren"
            });
         }
         Log.trace("\t+ --------------------------------------------------------------------------------------",{
            "fileName":"../DungeonBusters/Client/GameMasterProjectHaxe/src/dbglobals/DBGlobal.hx",
            "lineNumber":207,
            "className":"dbglobals.DBGlobal",
            "methodName":"traceClipChildren"
         });
      }
      
      public static function highlightButton(button:*, quality:uint = 1) : void
      {
         var _loc3_:GlowFilter = DBGlobal.UI_ROLLOVER_FILTER;
         if(quality == DBGlobal.FILTER_QUALITY_LOW)
         {
            _loc3_.quality = 1;
         }
         else if(quality == DBGlobal.FILTER_QUALITY_MEDIUM)
         {
            _loc3_.quality = 2;
         }
         else if(quality == DBGlobal.FILTER_QUALITY_HIGH)
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

