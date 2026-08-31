package Combat.Weapon
{
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Combat.Attack.AttackTimeline;
   import DistributedObjects.HeroGameObjectOwner;
   import Events.FirstRepeaterEvent;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   
   public class RepeaterWeaponController extends ScalingWeaponController
   {
      
      private var mCount:uint = 0;
      
      private var mTotalFramesForAttackTimeline:uint = 0;
      
      private var mAttackSpeed:Number = 0;
      
      private var mMaxSpeedReached:Boolean = false;
      
      private var mChargeAttack:GMAttack;
      
      private var mRepeatChargeAttackOnly:Boolean = false;
      
      private var mInRepeaterMode:Boolean;
      
      private var mLastComboReached:Boolean;
      
      public function RepeaterWeaponController(dbFacade:DBFacade, controlledWeapon:WeaponGameObject, hero:HeroGameObjectOwner)
      {
         super(dbFacade,controlledWeapon,hero);
      }
      
      override public function setTotalTime() : void
      {
         mTotalTime = 0;
      }
      
      override public function isRepeater() : Boolean
      {
         return true;
      }
      
      override public function onWeaponDown(autoAim:Boolean = true) : void
      {
         var attackType:uint;
         var attackTimeLine:AttackTimeline;
         super.onWeaponDown(autoAim);
         mInRepeaterMode = false;
         attackType = getNextAttackId();
         attackTimeLine = mWeapon.getAttackTimeline(attackType);
         mTotalFramesForAttackTimeline = attackTimeLine.totalFrames;
         mRepeatChargeAttackOnly = mWeapon.weaponData.RepeaterOnlyChargeRepeated;
         resetData();
         mScalingLogicalWorkComponent.doLater(0.1,function(param1:GameClock):void
         {
            if(mChargeReleaseGMAttack)
            {
               mChargeAttack = mDBFacade.gameMaster.attackById.itemFor(mChargeReleaseGMAttack.Id);
               if(!mChargeAttack)
               {
                  Logger.error("Invalid Charge for Repeater : " + mChargeReleaseGMAttack.Constant);
               }
            }
            mInRepeaterMode = true;
            mNextAttackComboIndex = 0;
            mLastComboReached = false;
            mScalingLogicalWorkComponent.doEveryFrame(update);
         });
      }
      
      private function resetData() : void
      {
         mCount = 0;
         mAttackSpeed = 1;
         mMaxSpeedReached = false;
      }
      
      override public function update(gameClock:GameClock) : void
      {
         var attackId:uint;
         var gmAttack:GMAttack;
         if(canCombo() && (mChargeAttack == null || mChargeAttack.ManaCost * mWeaponModifierManaReduction <= mHero.manaPoints))
         {
            if(mChargeReleaseGMAttack && (mLastComboReached || mRepeatChargeAttackOnly))
            {
               attackId = mChargeReleaseGMAttack.Id;
               mNextAttackComboIndex = 0;
               mLastComboReached = false;
            }
            else
            {
               if(mNextAttackComboIndex == mAttackArray.length - 1)
               {
                  mLastComboReached = true;
               }
               attackId = getNextAttackId();
            }
            gmAttack = mDBFacade.gameMaster.attackById.itemFor(attackId);
            if(!mMaxSpeedReached)
            {
               mAttackSpeed = 1 + ++mCount * mWeapon.weaponData.RepeaterIncrementSpeedPercent;
               if(mAttackSpeed >= mWeapon.weaponData.RepeaterMaxSpeedPercent)
               {
                  mAttackSpeed = mWeapon.weaponData.RepeaterMaxSpeedPercent;
                  mMaxSpeedReached = true;
               }
            }
            if(gmAttack.ManaCost * mWeaponModifierManaReduction > mHero.manaPoints)
            {
               if(mNotEnoughManaTask == null)
               {
                  mNotEnoughManaTask = mScalingLogicalWorkComponent.doLater(NOT_ENOUGH_MANA_ON_CHARGE_DELAY,function(param1:GameClock):void
                  {
                     notEnoughMana();
                  });
               }
               resetData();
            }
            else
            {
               attack(attackId,mAutoAim,mAttackSpeed);
            }
         }
      }
      
      override public function onWeaponUp(autoAim:Boolean = true) : void
      {
         var _loc2_:* = 0;
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasRepeaterTutorialParam() && !mTutorialMessageSent)
         {
            mDBFacade.eventManager.dispatchEvent(new FirstRepeaterEvent());
            mTutorialMessageSent = true;
         }
         if(!mInRepeaterMode)
         {
            _loc2_ = getNextAttackId();
            attack(_loc2_,mAutoAim);
         }
         clear();
      }
   }
}

