package Settings.Model
{
   public class SettingIds
   {
      
      public static const GRAPHICS_PRESET:String = "graphicsPreset";
      
      public static const ZOOM:String = "zoom";
      
      public static const DAMAGE_FLOATERS:String = "damageFloaters";
      
      public static const RARITY_BACKGROUNDS:String = "rarityBackgrounds";
      
      public static const BUSTER_BACKGROUND_FADE:String = "busterBackgroundFade";
      
      public static const MUSIC_VOLUME:String = "musicVolume";
      
      public static const SFX_VOLUME:String = "sfxVolume";
      
      public static const STEAM_INPUT:String = "steamInput";
      
      public static const CONTROLLER_RUMBLE:String = "controllerRumble";
      
      public static const KEY_MOVE_UP:String = "keyMoveUp";
      
      public static const KEY_MOVE_DOWN:String = "keyMoveDown";
      
      public static const KEY_MOVE_LEFT:String = "keyMoveLeft";
      
      public static const KEY_MOVE_RIGHT:String = "keyMoveRight";
      
      public static const KEY_ATTACK_WEAPON_1:String = "keyAttackWeapon1";
      
      public static const KEY_ATTACK_WEAPON_2:String = "keyAttackWeapon2";
      
      public static const KEY_ATTACK_WEAPON_3:String = "keyAttackWeapon3";
      
      public static const KEY_USE_DUNGEON_BUSTER:String = "keyUseDungeonBuster";
      
      public static const KEY_USE_CONSUMABLE_1:String = "keyUseConsumable1";
      
      public static const KEY_USE_CONSUMABLE_2:String = "keyUseConsumable2";
      
      public static const KEY_HOLD_IN_PLACE:String = "keyHoldInPlace";
      
      public static const KEY_REVIVE_ALLY:String = "keyReviveAlly";
      
      public static const KEY_TOGGLE_CHAT_LOG:String = "keyToggleChatLog";
      
      public static const KEY_OPEN_OPTIONS_MENU:String = "keyOpenOptionsMenu";
      
      public static const HUD_STYLE:String = "hudStyle";
      
      public static const NUMBERS_ON_BARS:String = "numbersOnBars";
      
      public static const TOWN_ANIMATIONS:String = "townAnimations";
      
      public static const PICKUP_UI_POP:String = "pickupUiPop";
      
      public static const FPS:String = "fps";
      
      public static const VSYNC:String = "vsync";
      
      public static const START_WINDOWED:String = "startWindowed";
      
      public static const STARLING_RENDERER:String = "starlingRenderer";
      
      public static const RESUMABLE_CONNECTION:String = "resumableConnection";
      
      public static const STARLING_HUD:String = "starlingHud";
      
      public function SettingIds()
      {
         super();
      }
      
      public static function keyBindingIdFor(action:String) : String
      {
         switch(action)
         {
            case "moveUp":
               return "keyMoveUp";
            case "moveDown":
               return "keyMoveDown";
            case "moveLeft":
               return "keyMoveLeft";
            case "moveRight":
               return "keyMoveRight";
            case "attackWeapon1":
               return "keyAttackWeapon1";
            case "attackWeapon2":
               return "keyAttackWeapon2";
            case "attackWeapon3":
               return "keyAttackWeapon3";
            case "useDungeonBuster":
               return "keyUseDungeonBuster";
            case "useConsumable1":
               return "keyUseConsumable1";
            case "useConsumable2":
               return "keyUseConsumable2";
            case "holdInPlace":
               return "keyHoldInPlace";
            case "reviveAlly":
               return "keyReviveAlly";
            case "toggleChatLog":
               return "keyToggleChatLog";
            case "openOptionsMenu":
               return "keyOpenOptionsMenu";
            default:
               throw new Error("No setting id for input action: " + action);
         }
      }
   }
}

