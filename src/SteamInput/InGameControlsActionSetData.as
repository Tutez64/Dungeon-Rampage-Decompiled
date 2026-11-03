package SteamInput
{
   public class InGameControlsActionSetData
   {
      
      public static const actionSetName:String = "InGameControls";
      
      public static const movementAction:String = "game_movement";
      
      public static const holdInPlaceAction:String = "hold_in_place";
      
      public static const attackWeapon1Action:String = "attack_weapon_1";
      
      public static const attackWeapon2Action:String = "attack_weapon_2";
      
      public static const attackWeapon3Action:String = "attack_weapon_3";
      
      public static const useConsumable1Action:String = "use_consumable_one";
      
      public static const useConsumable2Action:String = "use_consumable_two";
      
      public static const useDungeonBusterAction:String = "use_dungeon_buster";
      
      public static const reviveAllyAction:String = "revive_ally";
      
      public static const toggleMenuAction:String = "toggle_menu";
      
      public static const openChatKeyboardAction:String = "open_chat_keyboard";
      
      public static const toggleChatLogAction:String = "toggle_chat_log";
      
      public static const openOptionsMenuAction:String = "open_options_menu";
      
      public function InGameControlsActionSetData()
      {
         super();
      }
      
      public static function gatherAnalogActionNames() : Vector.<String>
      {
         var _loc1_:Vector.<String> = new Vector.<String>();
         _loc1_.push("game_movement");
         return _loc1_;
      }
      
      public static function gatherDigitalActionNames() : Vector.<String>
      {
         var _loc1_:Vector.<String> = new Vector.<String>();
         _loc1_.push("hold_in_place");
         _loc1_.push("attack_weapon_1");
         _loc1_.push("attack_weapon_2");
         _loc1_.push("attack_weapon_3");
         _loc1_.push("use_dungeon_buster");
         _loc1_.push("use_consumable_one");
         _loc1_.push("use_consumable_two");
         _loc1_.push("revive_ally");
         _loc1_.push("toggle_menu");
         _loc1_.push("open_chat_keyboard");
         _loc1_.push("toggle_chat_log");
         _loc1_.push("open_options_menu");
         return _loc1_;
      }
   }
}

