package Combat.Attack
{
   import Actor.Player.HeroView;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class TavernPlayerOwnerAttackController extends PlayerOwnerAttackController
   {
      
      public function TavernPlayerOwnerAttackController(distributedPlayerOwner:HeroGameObjectOwner, heroView:HeroView, dbFacade:DBFacade)
      {
         super(distributedPlayerOwner,heroView,dbFacade);
      }
      
      override protected function canQueueWeaponDown(weaponQueue:PotentialWeaponInputQueueStruct) : Boolean
      {
         return true;
      }
      
      override protected function canQueueWeaponUp(weaponQueue:PotentialWeaponInputQueueStruct) : Boolean
      {
         return true;
      }
      
      override protected function tryAttack() : void
      {
         if(mNextWeaponCommand == null)
         {
            return;
         }
         mDistributedPlayerOwner.currentWeaponIndex = mNextWeaponCommand.weaponIndex;
         mNextWeaponCommand = null;
      }
   }
}

