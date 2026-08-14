package Actor.Player.Input
{
   import Brain.Logger.Logger;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class KeyboardController
   {
      
      private static const KEYS_TO_ATTACK_INDEX:Array = [0,1,2,3,0,1,2,0];
      
      private static const KEYS_TO_CONSUMABLE_INDEX:Array = [0,1];
      
      protected var mDBFacade:DBFacade;
      
      protected var mHeroOwner:HeroGameObjectOwner;
      
      private var mInputVector:Vector3D;
      
      private var mMovementVelocity:Vector3D;
      
      private var mInputHeading:Vector3D;
      
      private var mCombatKeys:Vector.<int>;
      
      private var mPressedCombatKeysThisFrame:Vector.<int>;
      
      private var mReleasedCombatKeysThisFrame:Vector.<int>;
      
      private var mConsumableKeys:Vector.<int>;
      
      private var mReleasedConsumableKeysThisFrame:Vector.<int>;
      
      private var mCombatDisabled:Boolean;
      
      public function KeyboardController(dbFacade:DBFacade, heroOwner:HeroGameObjectOwner)
      {
         super();
         mDBFacade = dbFacade;
         mHeroOwner = heroOwner;
         mMovementVelocity = new Vector3D();
         mInputHeading = new Vector3D();
         mCombatKeys = new Vector.<int>();
         mPressedCombatKeysThisFrame = new Vector.<int>();
         mConsumableKeys = new Vector.<int>();
         mReleasedConsumableKeysThisFrame = new Vector.<int>();
         mCombatKeys.push(90,88,67,66,74,75,76,89);
         mCombatDisabled = false;
         mConsumableKeys.push(49,50);
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
         if(mDBFacade.inputManager.check(38) || mDBFacade.inputManager.check(87))
         {
            mInputVector.y -= 1;
         }
         if(mDBFacade.inputManager.check(40) || mDBFacade.inputManager.check(83))
         {
            mInputVector.y += 1;
         }
         if(mDBFacade.inputManager.check(39) || mDBFacade.inputManager.check(68))
         {
            mInputVector.x += 1;
         }
         if(mDBFacade.inputManager.check(37) || mDBFacade.inputManager.check(65))
         {
            mInputVector.x -= 1;
         }
         mInputVector.normalize();
      }
      
      public function set combatDisabled(disableCombat:Boolean) : void
      {
         mCombatDisabled = disableCombat;
      }
      
      public function KeyIndexToAttack(keyIndex:int) : int
      {
         return KEYS_TO_ATTACK_INDEX[keyIndex];
      }
      
      public function KeyIndexToConsumable(keyIndex:int) : int
      {
         return KEYS_TO_CONSUMABLE_INDEX[keyIndex];
      }
      
      protected function checkCombatButtons() : void
      {
         if(!mCombatDisabled)
         {
            mReleasedCombatKeysThisFrame = new Vector.<int>();
            mPressedCombatKeysThisFrame = new Vector.<int>();
            mCombatKeys.map(checkCombatButton,this);
         }
         mReleasedConsumableKeysThisFrame = new Vector.<int>();
         mConsumableKeys.map(checkConsumableButton,this);
      }
      
      private function checkCombatButton(key:int, weaponIndex:uint, combatKeys:Vector.<int>) : void
      {
         mPressedCombatKeysThisFrame.push(mDBFacade.inputManager.check(key));
         mReleasedCombatKeysThisFrame.push(mDBFacade.inputManager.released(key));
      }
      
      private function checkConsumableButton(key:int, consumableIndex:uint, combatKeys:Vector.<int>) : void
      {
         mReleasedConsumableKeysThisFrame.push(mDBFacade.inputManager.released(key));
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
      
      public function destroy() : void
      {
      }
   }
}

