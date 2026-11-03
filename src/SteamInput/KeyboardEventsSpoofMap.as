package SteamInput
{
   import Input.KeyBindings.KeyBindings;
   
   public class KeyboardEventsSpoofMap
   {
      
      private var mKeyBindings:KeyBindings;
      
      private var mActionNames:Vector.<String> = new Vector.<String>();
      
      public function KeyboardEventsSpoofMap(keyBindings:KeyBindings)
      {
         super();
         mKeyBindings = keyBindings;
         mActionNames.push("revive_ally");
         mActionNames.push("toggle_menu");
      }
      
      public function get actionNames() : Vector.<String>
      {
         return mActionNames;
      }
      
      public function getKeyCode(action:String) : int
      {
         var _loc2_:int = 0;
         switch(action)
         {
            case "revive_ally":
               _loc2_ = mKeyBindings.getPrimary("reviveAlly");
               return _loc2_ != 0 ? _loc2_ : mKeyBindings.getAlternate("reviveAlly");
            case "toggle_menu":
               return 27;
            default:
               return 0;
         }
      }
   }
}

