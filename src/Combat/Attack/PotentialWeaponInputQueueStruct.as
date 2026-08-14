package Combat.Attack
{
   import Combat.Weapon.WeaponController;
   
   public class PotentialWeaponInputQueueStruct
   {
      
      private var mWeaponController:WeaponController;
      
      private var mDown:Boolean;
      
      private var mWeaponIndex:uint;
      
      private var mAutoAim:Boolean;
      
      public function PotentialWeaponInputQueueStruct(weaponController:WeaponController, weaponIndex:uint, down:Boolean, autoAim:Boolean = true)
      {
         super();
         mWeaponController = weaponController;
         mWeaponIndex = weaponIndex;
         mDown = down;
         mAutoAim = autoAim;
      }
      
      public function get down() : Boolean
      {
         return mDown;
      }
      
      public function get weaponController() : WeaponController
      {
         return mWeaponController;
      }
      
      public function get weaponIndex() : uint
      {
         return mWeaponIndex;
      }
      
      public function get autoAim() : Boolean
      {
         return mAutoAim;
      }
   }
}

