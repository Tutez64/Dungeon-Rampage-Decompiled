package SteamInput
{
   import flash.utils.Dictionary;
   
   public class KeyboardEventsSpoofMap
   {
      
      private var mActionNamesToKeyCodes:Dictionary = new Dictionary();
      
      private var mActionNames:Vector.<String> = new Vector.<String>();
      
      public function KeyboardEventsSpoofMap()
      {
         super();
         mActionNamesToKeyCodes["revive_ally"] = 32;
         mActionNamesToKeyCodes["toggle_menu"] = 27;
         for(var _loc1_:String in mActionNamesToKeyCodes)
         {
            mActionNames.push(_loc1_);
         }
      }
      
      public function get actionNames() : Vector.<String>
      {
         return mActionNames;
      }
      
      public function getKeyCode(action:String) : int
      {
         return mActionNamesToKeyCodes[action];
      }
   }
}

