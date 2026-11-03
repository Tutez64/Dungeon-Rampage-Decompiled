package Input.KeyBindings
{
   import Brain.Input.InputManager;
   import Brain.Logger.Logger;
   
   public class KeyBindings
   {
      
      public static const NONE:int = 0;
      
      private var mInputManager:InputManager;
      
      private var mPrimary:Object;
      
      private var mAlternate:Object;
      
      private var mChangeListeners:Vector.<Function>;
      
      public function KeyBindings(inputManager:InputManager)
      {
         super();
         mInputManager = inputManager;
         mPrimary = {};
         mAlternate = {};
         mChangeListeners = new Vector.<Function>();
         for each(var _loc2_:String in InputAction.ORDERED)
         {
            resetToDefault(_loc2_);
         }
      }
      
      public static function isBindable(keyCode:int) : Boolean
      {
         if(keyCode <= 0 || keyCode >= 256)
         {
            return false;
         }
         return keyCode != 27 && keyCode != 13 && keyCode != 119 && keyCode != 122;
      }
      
      private static function checkKey(keyCode:int, query:Function) : Boolean
      {
         return keyCode != 0 && query(keyCode);
      }
      
      public function destroy() : void
      {
         mInputManager = null;
         mPrimary = null;
         mAlternate = null;
         mChangeListeners = null;
      }
      
      public function addChangeListener(listener:Function) : void
      {
         if(mChangeListeners.indexOf(listener) == -1)
         {
            mChangeListeners.push(listener);
         }
      }
      
      public function removeChangeListener(listener:Function) : void
      {
         if(mChangeListeners == null)
         {
            return;
         }
         var _loc2_:int = mChangeListeners.indexOf(listener);
         if(_loc2_ != -1)
         {
            mChangeListeners.splice(_loc2_,1);
         }
      }
      
      public function getPrimary(action:String) : int
      {
         return mPrimary.hasOwnProperty(action) ? mPrimary[action] : 0;
      }
      
      public function getAlternate(action:String) : int
      {
         return mAlternate.hasOwnProperty(action) ? mAlternate[action] : 0;
      }
      
      public function setBinding(action:String, primary:int, alternate:int) : void
      {
         if(!InputAction.isKnown(action))
         {
            Logger.warn("Tried to bind unknown input action: " + action);
            return;
         }
         var _loc5_:int = isBindable(primary) ? primary : 0;
         var _loc4_:int = isBindable(alternate) ? alternate : 0;
         if(getPrimary(action) == _loc5_ && getAlternate(action) == _loc4_)
         {
            return;
         }
         mPrimary[action] = _loc5_;
         mAlternate[action] = _loc4_;
         notifyChanged(action);
      }
      
      public function resetToDefault(action:String) : void
      {
         setBinding(action,InputAction.defaultPrimary(action),InputAction.defaultAlternate(action));
      }
      
      public function isDown(action:String) : Boolean
      {
         return checkKey(getPrimary(action),mInputManager.check) || checkKey(getAlternate(action),mInputManager.check) || checkKey(activeLegacyAlias(action),mInputManager.check);
      }
      
      public function wasPressed(action:String) : Boolean
      {
         return checkKey(getPrimary(action),mInputManager.pressed) || checkKey(getAlternate(action),mInputManager.pressed) || checkKey(activeLegacyAlias(action),mInputManager.pressed);
      }
      
      public function wasReleased(action:String) : Boolean
      {
         return checkKey(getPrimary(action),mInputManager.released) || checkKey(getAlternate(action),mInputManager.released) || checkKey(activeLegacyAlias(action),mInputManager.released);
      }
      
      public function matches(action:String, keyCode:int) : Boolean
      {
         if(keyCode == 0)
         {
            return false;
         }
         return getPrimary(action) == keyCode || getAlternate(action) == keyCode || activeLegacyAlias(action) == keyCode;
      }
      
      public function actionForKey(keyCode:int) : String
      {
         if(keyCode == 0)
         {
            return null;
         }
         for each(var _loc2_:String in InputAction.ORDERED)
         {
            if(matches(_loc2_,keyCode))
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function displayNameFor(action:String) : String
      {
         var _loc2_:int = getPrimary(action);
         if(_loc2_ == 0)
         {
            _loc2_ = getAlternate(action);
         }
         return KeyNames.displayName(_loc2_);
      }
      
      private function activeLegacyAlias(action:String) : int
      {
         var _loc3_:int = InputAction.legacyAlias(action);
         if(_loc3_ == 0)
         {
            return 0;
         }
         if(getPrimary(action) != InputAction.defaultPrimary(action) || getAlternate(action) != InputAction.defaultAlternate(action))
         {
            return 0;
         }
         for each(var _loc2_:String in InputAction.ORDERED)
         {
            if(getPrimary(_loc2_) == _loc3_ || getAlternate(_loc2_) == _loc3_)
            {
               return 0;
            }
         }
         return _loc3_;
      }
      
      private function notifyChanged(action:String) : void
      {
         if(mChangeListeners == null)
         {
            return;
         }
         var _loc2_:Vector.<Function> = mChangeListeners.concat();
         for each(var _loc3_:Function in _loc2_)
         {
            _loc3_(action);
         }
      }
   }
}

