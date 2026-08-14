package Actor.Player.Input
{
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import SteamInput.SteamInputManager;
   import flash.geom.Vector3D;
   
   public class GamepadController
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mHeroOwner:HeroGameObjectOwner;
      
      private var mSteamInputManager:SteamInputManager;
      
      private var mCombatDisabled:Boolean = false;
      
      private var mMovementInput:Vector3D = new Vector3D();
      
      private var mMovementVelocity:Vector3D = new Vector3D();
      
      private var mInputHeading:Vector3D = new Vector3D();
      
      private var mPressedCombatButtonsThisFrame:Vector.<int> = new Vector.<int>();
      
      private var mReleasedCombatButtonsThisFrame:Vector.<int> = new Vector.<int>();
      
      private var mReleasedConsumableButtonsThisFrame:Vector.<int> = new Vector.<int>();
      
      public function GamepadController(dbFacade:DBFacade, heroOwner:HeroGameObjectOwner, steamInputManager:SteamInputManager)
      {
         super();
         mDBFacade = dbFacade;
         mHeroOwner = heroOwner;
         mSteamInputManager = steamInputManager;
         mCombatDisabled = false;
      }
      
      public function get inputVelocity() : Vector3D
      {
         return mMovementVelocity;
      }
      
      public function get inputHeading() : Vector3D
      {
         return mInputHeading;
      }
      
      public function get pressedCombatButtonsThisFrame() : Vector.<int>
      {
         return mPressedCombatButtonsThisFrame;
      }
      
      public function get releasedCombatButtonsThisFrame() : Vector.<int>
      {
         return mReleasedCombatButtonsThisFrame;
      }
      
      public function get releasedConsumableButtonsThisFrame() : Vector.<int>
      {
         return mReleasedConsumableButtonsThisFrame;
      }
      
      public function init() : void
      {
         mPressedCombatButtonsThisFrame.length = 0;
         mReleasedCombatButtonsThisFrame.length = 0;
         mReleasedConsumableButtonsThisFrame.length = 0;
      }
      
      public function destroy() : void
      {
         mMovementVelocity = null;
         mInputHeading = null;
         mPressedCombatButtonsThisFrame.length = 0;
         mPressedCombatButtonsThisFrame = null;
         mReleasedCombatButtonsThisFrame.length = 0;
         mReleasedCombatButtonsThisFrame = null;
         mReleasedConsumableButtonsThisFrame.length = 0;
         mReleasedConsumableButtonsThisFrame = null;
      }
      
      public function set combatDisabled(disableCombat:Boolean) : void
      {
         mCombatDisabled = disableCombat;
      }
      
      public function perFrameUpCall() : void
      {
         updateMovement();
         updateCombatButtons();
      }
      
      private function updateMovement() : void
      {
         mMovementInput = calcMovementInput();
         calcMovementVelocity(mMovementInput);
         updateInputHeading(mMovementInput);
      }
      
      private function updateCombatButtons() : void
      {
         mPressedCombatButtonsThisFrame.length = 0;
         mReleasedCombatButtonsThisFrame.length = 0;
         if(mCombatDisabled)
         {
            return;
         }
         handleAttackInputs();
         handleConsumableInputs();
      }
      
      private function calcMovementInput() : Vector3D
      {
         var _loc1_:Vector3D = mSteamInputManager.getAnalogAction("game_movement");
         _loc1_.y = -_loc1_.y;
         return _loc1_;
      }
      
      private function calcMovementVelocity(movementInput:Vector3D) : void
      {
         var _loc3_:Boolean = mSteamInputManager.heldAction("hold_in_place");
         if(_loc3_)
         {
            mMovementVelocity.setTo(0,0,0);
            return;
         }
         mMovementVelocity.copyFrom(mMovementInput);
         var _loc2_:Number = mHeroOwner.movementSpeed;
         mMovementVelocity.scaleBy(_loc2_);
      }
      
      private function updateInputHeading(movementInput:Vector3D) : void
      {
         mInputHeading.setTo(movementInput.x,movementInput.y,0);
      }
      
      private function handleAttackInputs() : void
      {
         checkWeaponButton(0,"attack_weapon_1");
         checkWeaponButton(1,"attack_weapon_2");
         checkWeaponButton(2,"attack_weapon_3");
         checkWeaponButton(3,"use_dungeon_buster");
      }
      
      private function checkWeaponButton(index:int, actionName:String) : void
      {
         var _loc3_:Boolean = mSteamInputManager.pressedAction(actionName);
         var _loc4_:Boolean = mSteamInputManager.releasedAction(actionName);
         if(_loc3_)
         {
            mPressedCombatButtonsThisFrame.push(index);
         }
         if(_loc4_)
         {
            mReleasedCombatButtonsThisFrame.push(index);
         }
      }
      
      private function handleConsumableInputs() : void
      {
         mReleasedConsumableButtonsThisFrame.length = 0;
         var _loc1_:Boolean = mSteamInputManager.releasedAction("use_consumable_one");
         if(_loc1_)
         {
            mReleasedConsumableButtonsThisFrame.push(0);
         }
         var _loc2_:Boolean = mSteamInputManager.releasedAction("use_consumable_two");
         if(_loc2_)
         {
            mReleasedConsumableButtonsThisFrame.push(1);
         }
      }
   }
}

