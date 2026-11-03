package Input.KeyBindings
{
   public class InputAction
   {
      
      public static const MOVE_UP:String = "moveUp";
      
      public static const MOVE_DOWN:String = "moveDown";
      
      public static const MOVE_LEFT:String = "moveLeft";
      
      public static const MOVE_RIGHT:String = "moveRight";
      
      public static const ATTACK_WEAPON_1:String = "attackWeapon1";
      
      public static const ATTACK_WEAPON_2:String = "attackWeapon2";
      
      public static const ATTACK_WEAPON_3:String = "attackWeapon3";
      
      public static const USE_DUNGEON_BUSTER:String = "useDungeonBuster";
      
      public static const USE_CONSUMABLE_1:String = "useConsumable1";
      
      public static const USE_CONSUMABLE_2:String = "useConsumable2";
      
      public static const HOLD_IN_PLACE:String = "holdInPlace";
      
      public static const REVIVE_ALLY:String = "reviveAlly";
      
      public static const TOGGLE_CHAT_LOG:String = "toggleChatLog";
      
      public static const OPEN_OPTIONS_MENU:String = "openOptionsMenu";
      
      public static const ORDERED:Vector.<String> = new <String>["moveUp","moveDown","moveLeft","moveRight","attackWeapon1","attackWeapon2","attackWeapon3","useDungeonBuster","useConsumable1","useConsumable2","holdInPlace","reviveAlly","toggleChatLog","openOptionsMenu"];
      
      public static const ATTACK_SLOTS:Vector.<String> = new <String>["attackWeapon1","attackWeapon2","attackWeapon3","useDungeonBuster"];
      
      public static const CONSUMABLE_SLOTS:Vector.<String> = new <String>["useConsumable1","useConsumable2"];
      
      private static const DEFAULTS:Object = buildDefaults();
      
      private static const LEGACY_ALIASES:Object = buildLegacyAliases();
      
      public function InputAction()
      {
         super();
      }
      
      public static function isKnown(action:String) : Boolean
      {
         return action != null && DEFAULTS.hasOwnProperty(action);
      }
      
      public static function defaultPrimary(action:String) : int
      {
         return isKnown(action) ? DEFAULTS[action][0] : 0;
      }
      
      public static function defaultAlternate(action:String) : int
      {
         return isKnown(action) ? DEFAULTS[action][1] : 0;
      }
      
      public static function legacyAlias(action:String) : int
      {
         return action != null && LEGACY_ALIASES.hasOwnProperty(action) ? LEGACY_ALIASES[action] : 0;
      }
      
      public static function isMovement(action:String) : Boolean
      {
         return action == "moveUp" || action == "moveDown" || action == "moveLeft" || action == "moveRight";
      }
      
      public static function isWeaponAttack(action:String) : Boolean
      {
         return action == "attackWeapon1" || action == "attackWeapon2" || action == "attackWeapon3";
      }
      
      private static function buildDefaults() : Object
      {
         var _loc1_:Object = {};
         _loc1_["moveUp"] = [87,38];
         _loc1_["moveDown"] = [83,40];
         _loc1_["moveLeft"] = [65,37];
         _loc1_["moveRight"] = [68,39];
         _loc1_["attackWeapon1"] = [74,90];
         _loc1_["attackWeapon2"] = [75,88];
         _loc1_["attackWeapon3"] = [76,67];
         _loc1_["useDungeonBuster"] = [66,0];
         _loc1_["useConsumable1"] = [49,0];
         _loc1_["useConsumable2"] = [50,0];
         _loc1_["holdInPlace"] = [16,0];
         _loc1_["reviveAlly"] = [32,0];
         _loc1_["toggleChatLog"] = [220,0];
         _loc1_["openOptionsMenu"] = [79,0];
         return _loc1_;
      }
      
      private static function buildLegacyAliases() : Object
      {
         var _loc1_:Object = {};
         _loc1_["attackWeapon1"] = 89;
         return _loc1_;
      }
   }
}

