package Combat.Weapon
{
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class ShieldWeaponController extends WeaponController
   {
      
      public function ShieldWeaponController(dbFacade:DBFacade, controlledWeapon:WeaponGameObject, hero:HeroGameObjectOwner)
      {
         super(dbFacade,controlledWeapon,hero);
      }
      
      override public function onWeaponDown(autoAim:Boolean = true) : void
      {
         var _loc2_:* = 0;
         if(!mWeaponDownActive)
         {
            _loc2_ = this.getNextAttackId();
            mWeaponDownActive = true;
            attack(_loc2_,false);
         }
      }
      
      override public function onWeaponUp(autoAim:Boolean = true) : void
      {
         mWeaponDownActive = false;
         stopCurrentTimeline();
      }
      
      override public function canCombo() : Boolean
      {
         return true;
      }
   }
}

