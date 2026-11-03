package Actor.Player.Input
{
   import Brain.Logger.Logger;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import Input.KeyBindings.InputAction;
   import Input.KeyBindings.KeyBindings;
   import flash.geom.Vector3D;
   
   public class KeyboardController
   {
      
      private static const MENU_INDEX_EXIT:int = 0;
      
      private static const MENU_INDEX_OPEN_OPTIONS_MENU:int = 1;
      
      private static const MENU_INDEX_TOGGLE_CHAT_LOG:int = 2;
      
      private static const MENU_INDEX_CHAT_INPUT:int = 3;
      
      private static const MENU_INDEX_COUNT:int = 4;
      
      protected var mDBFacade:DBFacade;
      
      protected var mHeroOwner:HeroGameObjectOwner;
      
      private var mKeyBindings:KeyBindings;
      
      private var mInputVector:Vector3D;
      
      private var mMovementVelocity:Vector3D;
      
      private var mInputHeading:Vector3D;
      
      private var mPressedCombatKeysThisFrame:Vector.<int>;
      
      private var mReleasedCombatKeysThisFrame:Vector.<int>;
      
      private var mReleasedConsumableKeysThisFrame:Vector.<int>;
      
      private var mReleasedMenuKeysThisFrame:Vector.<int>;
      
      private var mCombatDisabled:Boolean;
      
      public function KeyboardController(dbFacade:DBFacade, heroOwner:HeroGameObjectOwner)
      {
         super();
         mDBFacade = dbFacade;
         mHeroOwner = heroOwner;
         mKeyBindings = dbFacade.keyBindings;
         mMovementVelocity = new Vector3D();
         mInputHeading = new Vector3D();
         mPressedCombatKeysThisFrame = new Vector.<int>();
         mReleasedCombatKeysThisFrame = new Vector.<int>();
         mReleasedConsumableKeysThisFrame = new Vector.<int>();
         mReleasedMenuKeysThisFrame = new Vector.<int>();
         mCombatDisabled = false;
      }
      
      public function perFrameUpCall() : void
      {
         getInputDirectionVector();
         checkCombatButtons();
         determineMotion();
         checkForDebugIdentifyTile();
      }
      
      private function checkForDebugIdentifyTile() : void
      {
         if(mDBFacade.inputManager.pressed(73))
         {
            Logger.warn("[ DEBUG ] Tile ID is : " + mHeroOwner.distributedDungeonFloor.GetTileIdWhichAvatarIsOn());
         }
      }
      
      private function getInputDirectionVector() : void
      {
         mInputVector = new Vector3D();
         if(mKeyBindings.isDown("moveUp"))
         {
            mInputVector.y -= 1;
         }
         if(mKeyBindings.isDown("moveDown"))
         {
            mInputVector.y += 1;
         }
         if(mKeyBindings.isDown("moveRight"))
         {
            mInputVector.x += 1;
         }
         if(mKeyBindings.isDown("moveLeft"))
         {
            mInputVector.x -= 1;
         }
         mInputVector.normalize();
      }
      
      public function set combatDisabled(disableCombat:Boolean) : void
      {
         mCombatDisabled = disableCombat;
      }
      
      protected function checkCombatButtons() : void
      {
         if(!mCombatDisabled)
         {
            mReleasedCombatKeysThisFrame = new Vector.<int>();
            mPressedCombatKeysThisFrame = new Vector.<int>();
            for each(var _loc1_:String in InputAction.ATTACK_SLOTS)
            {
               mPressedCombatKeysThisFrame.push(mKeyBindings.isDown(_loc1_));
               mReleasedCombatKeysThisFrame.push(mKeyBindings.wasReleased(_loc1_));
            }
         }
         mReleasedConsumableKeysThisFrame = new Vector.<int>();
         for each(var _loc2_:String in InputAction.CONSUMABLE_SLOTS)
         {
            mReleasedConsumableKeysThisFrame.push(mKeyBindings.wasReleased(_loc2_));
         }
         mReleasedMenuKeysThisFrame = new Vector.<int>(4);
         mReleasedMenuKeysThisFrame[0] = int(mDBFacade.inputManager.released(27));
         mReleasedMenuKeysThisFrame[1] = int(mKeyBindings.wasReleased("openOptionsMenu"));
         mReleasedMenuKeysThisFrame[2] = int(mKeyBindings.wasReleased("toggleChatLog"));
         mReleasedMenuKeysThisFrame[3] = int(mDBFacade.inputManager.released(13));
      }
      
      public function determineMotion() : void
      {
         mMovementVelocity.copyFrom(mInputVector);
         var _loc1_:Number = mHeroOwner.movementSpeed;
         mMovementVelocity.scaleBy(_loc1_);
         mInputHeading.copyFrom(mInputVector);
      }
      
      public function get inputVelocity() : Vector3D
      {
         return mMovementVelocity;
      }
      
      public function get inputHeading() : Vector3D
      {
         return mInputHeading;
      }
      
      public function get pressedCombatKeysThisFrame() : Vector.<int>
      {
         return mPressedCombatKeysThisFrame;
      }
      
      public function get releasedCombatKeysThisFrame() : Vector.<int>
      {
         return mReleasedCombatKeysThisFrame;
      }
      
      public function get releasedConsumableKeysThisFrame() : Vector.<int>
      {
         return mReleasedConsumableKeysThisFrame;
      }
      
      public function get releasedMenuKeysThisFrame() : Vector.<int>
      {
         return mReleasedMenuKeysThisFrame;
      }
      
      public function destroy() : void
      {
         mKeyBindings = null;
      }
   }
}

