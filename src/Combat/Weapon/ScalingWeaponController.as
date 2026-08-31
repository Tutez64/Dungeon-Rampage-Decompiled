package Combat.Weapon
{
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Combat.Attack.AttackTimeline;
   import DistributedObjects.HeroGameObjectOwner;
   import Events.FirstScalingEvent;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   import GameMasterDictionary.GMModifier;
   
   public class ScalingWeaponController extends WeaponController
   {
      
      public static const SCALING_EFFECT_SWF:String = "Resources/Art2D/FX/db_fx_library.swf";
      
      private var mPowerMultiplier:Number = 1;
      
      private var mProjectileMinMultiplier:uint = 1;
      
      private var mProjectileMaxMultiplier:uint = 1;
      
      private var mProjectileStartScalingAngle:Number = 0;
      
      private var mProjectileEndScalingAngle:Number = 20;
      
      private var mProjectileScaleTapAttack:Boolean;
      
      protected var mDistanceScalingTime:Number = 0;
      
      protected var mDistanceScalingForHeroMin:Number = 0;
      
      protected var mDistanceScalingForHeroMax:Number = 0;
      
      protected var mDistanceScalingForProjectilesMin:Number = 0;
      
      protected var mDistanceScalingForProjectilesMax:Number = 0;
      
      protected var mTotalTime:Number = 0;
      
      protected var mFramesFinished:uint = 0;
      
      protected var mPlayerExittedState:Boolean = false;
      
      protected var mChargeReleaseGMAttack:GMAttack;
      
      protected var NOT_ENOUGH_MANA_ON_CHARGE_DELAY:Number = 0.2;
      
      protected var mNotEnoughManaTask:Task;
      
      protected var mScalingLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mHoldingAttack:GMAttack;
      
      protected var mHoldingAttackTimeline:AttackTimeline;
      
      protected var mTutorialMessageSent:Boolean = false;
      
      protected var mWeaponModifierManaReduction:Number = 1;
      
      public function ScalingWeaponController(dbFacade:DBFacade, controlledWeapon:WeaponGameObject, hero:HeroGameObjectOwner)
      {
         super(dbFacade,controlledWeapon,hero);
         buildControllerAttacks();
      }
      
      public function buildControllerAttacks() : void
      {
         mScalingLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"ScalingWeaponController");
         mHoldingAttack = mDBFacade.gameMaster.attackByConstant.itemFor(mWeapon.weaponData.HoldingAttack);
         if(mHoldingAttack)
         {
            mHoldingAttackTimeline = mWeapon.getAttackTimeline(mHoldingAttack.Id);
         }
         setAttributes();
      }
      
      public function setAttributes() : void
      {
         mPowerMultiplier = mWeapon.weaponData.ScalingMaxPowerMultiplier;
         mProjectileScaleTapAttack = mWeapon.weaponData.ScaleTapAttack;
         mProjectileMinMultiplier = mWeapon.weaponData.ScalingMinProjectiles;
         mProjectileMaxMultiplier = mWeapon.weaponData.ScalingMaxProjectiles;
         mProjectileStartScalingAngle = mWeapon.weaponData.ScalingProjectileStartAngle;
         mProjectileEndScalingAngle = mWeapon.weaponData.ScalingProjectileEndAngle;
         mDistanceScalingTime = mWeapon.weaponData.ScalingDistanceTime;
         mDistanceScalingForHeroMin = mWeapon.weaponData.ScalingHeroMinDistance;
         mDistanceScalingForHeroMax = mWeapon.weaponData.ScalingHeroMaxDistance;
         mDistanceScalingForProjectilesMin = mWeapon.weaponData.ScalingProjectileMinDistance;
         mDistanceScalingForProjectilesMax = mWeapon.weaponData.ScalingProjectileMaxDistance;
         var _loc2_:String = mWeapon.weaponData.ChargeAttack;
         mChargeReleaseGMAttack = mDBFacade.gameMaster.attackByConstant.itemFor(_loc2_);
         for each(var _loc1_:GMModifier in mWeapon.modifierList)
         {
            if(_loc1_.MODIFIER_TYPE == "MANA_COST")
            {
               mWeaponModifierManaReduction = _loc1_.MP_COST;
            }
         }
         setTotalTime();
      }
      
      public function setTotalTime() : void
      {
         mTotalTime = mWeapon.weaponData.ControllerTimeTillEnd;
         if(mTotalTime == 0)
         {
            Logger.error("Weapon has no ControllerTimeTillEnd data set !");
         }
      }
      
      public function setStartEffectTotalTime() : Number
      {
         return 1.2;
      }
      
      public function startHoldingAttack() : void
      {
         var _loc1_:Number = 1 / mTotalTime * setStartEffectTotalTime();
         attack(mHoldingAttack.Id,mAutoAim,_loc1_);
      }
      
      override public function onWeaponDown(autoAim:Boolean = true) : void
      {
         if(!mWeaponDownActive)
         {
            super.onWeaponDown(autoAim);
            mFramesFinished = 0;
            mWeaponDownActive = true;
            mScalingLogicalWorkComponent.clear();
            if(mTotalTime > 0)
            {
               if(mChargeReleaseGMAttack && mChargeReleaseGMAttack.ManaCost * mWeaponModifierManaReduction > mHero.manaPoints)
               {
                  if(mNotEnoughManaTask == null)
                  {
                     mNotEnoughManaTask = mScalingLogicalWorkComponent.doLater(NOT_ENOUGH_MANA_ON_CHARGE_DELAY,function(param1:GameClock):void
                     {
                        notEnoughMana();
                     });
                  }
               }
               else
               {
                  mScalingLogicalWorkComponent.doLater(0.2,function(param1:GameClock):void
                  {
                     mScalingLogicalWorkComponent.doEveryFrame(update);
                     startHoldingAttack();
                  });
               }
            }
            mPlayerExittedState = false;
         }
      }
      
      override public function onWeaponUp(autoAim:Boolean = true) : void
      {
         var _loc6_:Number = NaN;
         var _loc3_:* = 0;
         var _loc10_:AttackTimeline = null;
         var _loc11_:Number = NaN;
         var _loc7_:* = 0;
         var _loc4_:Number = NaN;
         var _loc2_:* = 0;
         var _loc9_:Boolean = false;
         var _loc5_:* = 0;
         var _loc8_:AttackTimeline = null;
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasScalingTutorialParam() && !mTutorialMessageSent)
         {
            mDBFacade.eventManager.dispatchEvent(new FirstScalingEvent());
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
               _loc6_ = mFramesFinished / 24 * 1 / mTotalTime;
               if(_loc6_ > 1)
               {
                  _loc6_ = 1;
               }
               _loc3_ = 0;
               if(mChargeReleaseGMAttack && _loc6_ > 0)
               {
                  _loc3_ = mChargeReleaseGMAttack.Id;
               }
               else
               {
                  _loc3_ = getNextAttackId();
               }
               _loc10_ = mWeapon.getAttackTimeline(_loc3_);
               if(!_loc10_)
               {
                  Logger.error("AttackTimeline for attack: <" + _loc3_ + "> was null. Ignoring onWeaponDown");
                  return;
               }
               _loc11_ = mPowerMultiplier > 1 ? 1 + _loc6_ * mPowerMultiplier : 1;
               _loc7_ = 1;
               if(_loc6_ > 0 && (mProjectileMinMultiplier > 1 || mProjectileMaxMultiplier > 1))
               {
                  _loc7_ = uint(Math.ceil(mProjectileMinMultiplier + _loc6_ * (mProjectileMaxMultiplier - mProjectileMinMultiplier)));
               }
               _loc4_ = 0;
               if(_loc7_ > 1)
               {
                  if(mProjectileStartScalingAngle < mProjectileEndScalingAngle)
                  {
                     _loc4_ = mProjectileStartScalingAngle + (mProjectileEndScalingAngle - mProjectileStartScalingAngle) * _loc6_;
                  }
                  else
                  {
                     _loc4_ = mProjectileStartScalingAngle - (mProjectileStartScalingAngle - mProjectileEndScalingAngle) * _loc6_;
                  }
               }
               _loc2_ = 0;
               _loc9_ = false;
               for each(var _loc12_:GMModifier in mWeapon.modifierList)
               {
                  if(_loc12_.MAX_PROJECTILES > 0)
                  {
                     _loc7_ += _loc6_ * _loc12_.MAX_PROJECTILES;
                     _loc9_ = true;
                  }
                  if(_loc12_.INCREASED_PROJECTILE_ANGLE_PERCENT >= 0)
                  {
                     _loc2_ += _loc12_.INCREASED_PROJECTILE_ANGLE_PERCENT * _loc4_ * _loc12_.MAX_PROJECTILES;
                  }
               }
               if(_loc6_ == 0)
               {
                  if(mProjectileScaleTapAttack)
                  {
                     _loc4_ = mProjectileStartScalingAngle;
                     _loc7_ = mProjectileMinMultiplier;
                  }
                  else
                  {
                     _loc4_ = 0;
                     _loc7_ = 1;
                  }
               }
               if(_loc10_.projectileMultiplier > 1)
               {
                  mAutoAim = false;
               }
               _loc10_.powerMultiplier = _loc11_;
               if(_loc7_ < 1)
               {
                  _loc7_ = 1;
               }
               _loc10_.projectileMultiplier = _loc7_;
               _loc10_.projectileScalingAngle = (_loc4_ + _loc2_) / _loc7_;
               _loc10_.distanceScalingTime = mDistanceScalingTime;
               _loc10_.distanceScalingHero = mDistanceScalingForHeroMin + _loc6_ * (mDistanceScalingForHeroMax - mDistanceScalingForHeroMin);
               _loc10_.distanceScalingProjectile = mDistanceScalingForProjectilesMin + _loc6_ * (mDistanceScalingForProjectilesMax - mDistanceScalingForProjectilesMin);
            }
            else
            {
               _loc5_ = _loc3_;
               _loc3_ = getNextAttackId();
               _loc8_ = mWeapon.getAttackTimeline(_loc3_);
               _loc8_.projectileMultiplier = 1;
               _loc8_.projectileScalingAngle = 0;
            }
            attack(_loc3_,mAutoAim);
         }
         clear();
      }
      
      public function update(gameClock:GameClock) : void
      {
         mFramesFinished = mFramesFinished + 1;
      }
      
      override public function clear() : void
      {
         mFramesFinished = 0;
         mScalingLogicalWorkComponent.clear();
         mWeaponDownActive = false;
         if(mNotEnoughManaTask != null)
         {
            mNotEnoughManaTask.destroy();
            mNotEnoughManaTask = null;
         }
      }
      
      override public function canCombo() : Boolean
      {
         if(mCurrentAttackTimeline)
         {
            if(mCurrentAttackTimeline == mHoldingAttackTimeline)
            {
               return true;
            }
            if(mCurrentAttackTimeline.isAttackWithinComboWindow())
            {
               return true;
            }
            return false;
         }
         return true;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         mScalingLogicalWorkComponent.destroy();
         mScalingLogicalWorkComponent = null;
         if(mIsInCooldown)
         {
            mDBFacade.hud.stopCooldown(weapon.slot);
         }
      }
   }
}

