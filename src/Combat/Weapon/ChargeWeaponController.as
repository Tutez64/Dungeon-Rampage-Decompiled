package Combat.Weapon
{
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import flash.events.Event;
   
   public class ChargeWeaponController extends ScalingWeaponController
   {
      
      public static const CHARGE_ATTACK_EVENT:String = "CHARGE_ATTACK_EVENT";
      
      public function ChargeWeaponController(dbFacade:DBFacade, controlledWeapon:WeaponGameObject, hero:HeroGameObjectOwner)
      {
         super(dbFacade,controlledWeapon,hero);
      }
      
      override public function buildControllerAttacks() : void
      {
         super.buildControllerAttacks();
      }
      
      override public function setStartEffectTotalTime() : Number
      {
         return 1.2;
      }
      
      override public function setTotalTime() : void
      {
         if(mWeapon.weaponData.ControllerTimeTillEnd && mWeapon.weaponData.ControllerTimeTillEnd > 0)
         {
            mTotalTime = mWeapon.weaponData.ControllerTimeTillEnd;
         }
         else
         {
            mTotalTime = mChargeReleaseGMAttack != null ? mChargeReleaseGMAttack.ChargeTime : 0;
         }
         mTotalTime *= mWeapon.chargeReduction();
      }
      
      override public function onWeaponUp(autoAim:Boolean = true) : void
      {
         var _loc2_:Number = NaN;
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasChargeTutorialParam() && !mTutorialMessageSent)
         {
            mDBFacade.eventManager.dispatchEvent(new Event("CHARGE_ATTACK_EVENT"));
            mTutorialMessageSent = true;
         }
         if(mHoldingAttackTimeline && mHoldingAttackTimeline.isPlaying)
         {
            mHoldingAttackTimeline.stopAndFinish();
         }
         if(!mPlayerExittedState)
         {
            if(mTotalTime > 0 && mNotEnoughManaTask == null)
            {
               _loc2_ = mFramesFinished / 24 * 1 / mTotalTime;
               if(_loc2_ > 1)
               {
                  _loc2_ = 1;
               }
               if(_loc2_ == 1 && mChargeReleaseGMAttack)
               {
                  attack(mChargeReleaseGMAttack.Id,mAutoAim);
               }
               else
               {
                  attack(getNextAttackId(),mAutoAim);
               }
            }
            else
            {
               attack(getNextAttackId(),mAutoAim);
            }
         }
         clear();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(mNotEnoughManaTask != null)
         {
            mNotEnoughManaTask.destroy();
            mNotEnoughManaTask = null;
         }
      }
   }
}

