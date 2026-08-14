package Combat.Weapon
{
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class ConsumableWeaponController extends WeaponController
   {
      
      private var consumableWeapon:ConsumableWeaponGameObject;
      
      public function ConsumableWeaponController(dbFacade:DBFacade, controlledWeapon:ConsumableWeaponGameObject, hero:HeroGameObjectOwner)
      {
         super(dbFacade,controlledWeapon,hero);
         consumableWeapon = controlledWeapon;
      }
      
      public function consume() : void
      {
         if(consumableWeapon.canExecute() && consumableWeapon.getConsumableAttack() && consumableWeapon.getConsumableCount() > 0)
         {
            attack(consumableWeapon.getConsumableAttack().Id,false,1,consumableWeapon.getConsumableCount() > 1);
            consumableWeapon.consume();
         }
      }
      
      override protected function updateHudCooldown(showStartCooldown:Boolean) : void
      {
         if(showStartCooldown)
         {
            mDBFacade.hud.startConsumableCooldown(weapon.slot,mCoolDownTime / 1000);
         }
         else
         {
            mDBFacade.hud.stopConsumableCooldown(weapon.slot);
         }
      }
      
      override public function destroy() : void
      {
         mDBFacade.hud.stopConsumableCooldown(weapon.slot);
         super.destroy();
      }
   }
}

