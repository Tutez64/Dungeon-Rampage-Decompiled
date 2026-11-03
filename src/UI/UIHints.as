package UI
{
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMHints;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UIHints
   {
      
      private static const KEYBOARD_MOUSE_HINT_TYPE:String = "CONTROLS";
      
      private static const KEYBOARD_MOUSE_HINT_CONSTANTS:Array = ["HINT_GAMEPLAY_1"];
      
      private var mDBFacade:DBFacade;
      
      private var mHintBox:MovieClip;
      
      private var mHintText:TextField;
      
      public function UIHints(dbFacade:DBFacade, hintBox:MovieClip)
      {
         super();
         mDBFacade = dbFacade;
         mHintBox = hintBox;
         mHintText = hintBox.hint_text;
         var _loc3_:TextField = hintBox.hint_title;
         Locale.setText(_loc3_,"HINT_TITLE");
         getNewHint();
      }
      
      private static function isKeyboardMouseHint(hint:GMHints) : Boolean
      {
         return hint.Type == "CONTROLS" || KEYBOARD_MOUSE_HINT_CONSTANTS.indexOf(hint.Constant) != -1;
      }
      
      private function getNewHint() : void
      {
         var _loc2_:Vector.<GMHints> = new Vector.<GMHints>();
         var _loc3_:uint = mDBFacade.dbAccountInfo.activeAvatarInfo.ogLevel;
         var _loc6_:Boolean = mDBFacade.steamInputManager.wantsControllerPrompts;
         for each(var _loc5_:GMHints in mDBFacade.gameMaster.Hints)
         {
            if(!(_loc6_ && isKeyboardMouseHint(_loc5_)))
            {
               if(_loc5_.MinLevel <= _loc3_ && _loc5_.MaxLevel >= _loc3_)
               {
                  _loc2_.push(_loc5_);
               }
            }
         }
         if(_loc2_.length == 0)
         {
            return;
         }
         var _loc1_:uint = Math.floor(Math.random() * _loc2_.length);
         var _loc4_:GMHints = _loc2_[_loc1_];
         if(!_loc4_)
         {
            return;
         }
         TextUtil.setText(mHintText,GameMasterLocale.getGameMasterSubString("HINTS",_loc4_.Constant),1.55);
         TextUtil.fitToField(mHintText);
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         mHintBox = null;
         mHintText = null;
      }
   }
}

