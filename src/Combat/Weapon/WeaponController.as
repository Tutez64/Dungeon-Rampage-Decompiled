package Combat.Weapon
{
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Combat.Attack.AttackTimeline;
   import Combat.Attack.PotentialWeaponInputQueueStruct;
   import Combat.Attack.ScriptTimeline;
   import DistributedObjects.HeroGameObjectOwner;
   import Events.FirstCooldownEvent;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   
   public class WeaponController
   {
      
      private static const RAMPAGE_ATTACK_CONSTANT:String = "RAMPAGE";
      
      protected var mDBFacade:DBFacade;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mWeapon:WeaponGameObject;
      
      protected var mHero:HeroGameObjectOwner;
      
      protected var mCurrentAttackTimeline:AttackTimeline;
      
      protected var mNextAttackComboIndex:int = 0;
      
      protected var mAttackArray:Array;
      
      protected var mAutoAim:Boolean;
      
      protected var mWeaponDownActive:Boolean;
      
      protected var mCoolDownTime:Number;
      
      protected var mIsInCooldown:Boolean = false;
      
      private var mTimeStartedAttack:Number;
      
      private var mQueueAttack:GMAttack;
      
      public function WeaponController(dbFacade:DBFacade, controlledWeapon:WeaponGameObject, hero:HeroGameObjectOwner)
      {
         super();
         mDBFacade = dbFacade;
         mWeapon = controlledWeapon;
         mHero = hero;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"WeaponController");
         mQueueAttack = null;
         buildAttackArray();
      }
      
      public function reset() : void
      {
         resetCombos();
         stopCurrentTimeline();
         clear();
      }
      
      public function clear() : void
      {
      }
      
      protected function buildAttacks() : void
      {
         buildAttackArray();
      }
      
      protected function stopCurrentTimeline() : void
      {
         if(mCurrentAttackTimeline != null && mCurrentAttackTimeline.isPlaying)
         {
            mCurrentAttackTimeline.stopAndFinish();
         }
         mCurrentAttackTimeline = null;
      }
      
      public function get IsInCooldown() : Boolean
      {
         if(mIsInCooldown)
         {
            mDBFacade.hud.isInCooldown();
         }
         return mIsInCooldown;
      }
      
      protected function attack(attackType:uint, autoAim:Boolean, attackSpeedModifier:Number = 1, autoStartCooldown:Boolean = true) : void
      {
         var speedIndex:uint;
         var actorAttackSpeed:Number;
         var buffMult:Number;
         var baseAttackSpeed:Number;
         var stopCallback:Function;
         var gmAttack:GMAttack = mDBFacade.gameMaster.attackById.itemFor(attackType);
         var attackSpeedMultiplier:Number = 1;
         var trueManaCosts:Number = gmAttack.ManaCost;
         if(gmAttack.StatOffsets)
         {
            trueManaCosts = gmAttack.ManaCost * mWeapon.manaCostModifier;
         }
         if(mHero.manaPoints < trueManaCosts)
         {
            notEnoughMana();
            return;
         }
         if(gmAttack.StatOffsets)
         {
            speedIndex = gmAttack.StatOffsets.speed;
            actorAttackSpeed = mHero.stats.values[speedIndex];
            buffMult = mHero.buffHandler.multiplier.values[speedIndex];
            baseAttackSpeed = gmAttack.AttackSpdF;
            attackSpeedMultiplier = baseAttackSpeed * actorAttackSpeed * buffMult * mWeapon.finalWeaponSpeedWithModifiers(gmAttack.StatOffsets.type);
            attackSpeedMultiplier *= attackSpeedModifier;
         }
         stopCurrentTimeline();
         mCurrentAttackTimeline = mWeapon.getAttackTimeline(attackType);
         if(!mCurrentAttackTimeline)
         {
            Logger.error("AttackTimeline for attack: <" + attackType + "> was null. Ignoring onWeaponDown");
            return;
         }
         stopCallback = function():void
         {
            mCurrentAttackTimeline = null;
         };
         mHero.attack(attackType,null,attackSpeedMultiplier,mCurrentAttackTimeline,function():void
         {
            finishedAttack(autoAim,attackSpeedModifier);
         },stopCallback,false,autoAim);
         if(autoStartCooldown && gmAttack.CooldownLength > 0)
         {
            startCooldown();
         }
      }
      
      private function finishedAttack(autoAim:Boolean, attackSpeedModifier:uint) : void
      {
         if(mQueueAttack)
         {
            attack(mQueueAttack.Id,autoAim,attackSpeedModifier);
            mQueueAttack = null;
         }
      }
      
      public function doQueue() : void
      {
         if(mQueueAttack)
         {
            attack(mQueueAttack.Id,false,1);
            mQueueAttack = null;
         }
      }
      
      public function startCooldown() : void
      {
         mIsInCooldown = true;
         var _loc1_:Number = currentTimeline.currentGMAttack.CooldownLength ? currentTimeline.currentGMAttack.CooldownLength : currentTimeline.currentGMAttack.AIRechargeT;
         mCoolDownTime = _loc1_ * 1000 * weapon.cooldownReduction() - _loc1_ * 1000 * mHero.attackCooldownMultiplier;
         mTimeStartedAttack = mLogicalWorkComponent.gameClock.gameTime;
         updateHudCooldown(true);
         mLogicalWorkComponent.doEveryFrame(updateCooldown);
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasCooldownTutorialParam())
         {
            mDBFacade.eventManager.dispatchEvent(new FirstCooldownEvent());
         }
      }
      
      public function updateCooldown(gameClock:GameClock) : void
      {
         if(gameClock.gameTime - mTimeStartedAttack >= mCoolDownTime)
         {
            mIsInCooldown = false;
            mLogicalWorkComponent.clear();
            updateHudCooldown(false);
         }
      }
      
      protected function updateHudCooldown(showStartCooldown:Boolean) : void
      {
         if(showStartCooldown)
         {
            mDBFacade.hud.startCooldown(weapon.slot,mCoolDownTime / 1000);
         }
         else
         {
            mDBFacade.hud.stopCooldown(weapon.slot);
         }
      }
      
      protected function getNextAttackId() : uint
      {
         var _loc2_:* = 0;
         var _loc1_:GMAttack = getAttackFromComboArray();
         if(_loc1_ == null)
         {
            _loc2_ = 0;
         }
         else
         {
            _loc2_ = _loc1_.Id;
         }
         return _loc2_;
      }
      
      private function buildAttackArray() : void
      {
         var _loc3_:GMAttack = null;
         mAttackArray = [];
         var _loc1_:Array = mDBFacade.gameMaster.weaponItemByConstant.itemFor(mWeapon.weaponData.Constant).AttackArray;
         for each(var _loc2_:String in _loc1_)
         {
            if(_loc2_ == null)
            {
               break;
            }
            _loc3_ = mDBFacade.gameMaster.attackByConstant.itemFor(_loc2_) as GMAttack;
            if(_loc3_ == null)
            {
               Logger.error("Could not find gmAttack for string name: " + _loc2_ + ".  For weaponId: " + mWeapon.weaponData.Id);
            }
            else
            {
               mAttackArray.push(_loc3_);
            }
         }
         if(mAttackArray.length == 0)
         {
            Logger.warn("Did not find any attacks for weaponId: " + mWeapon.weaponData.Id);
         }
      }
      
      public function resetCombos() : void
      {
         mNextAttackComboIndex = 0;
      }
      
      protected function getAttackFromComboArray() : GMAttack
      {
         var _loc1_:uint = uint(!mWeapon.weaponData.ChooseRandomAttack ? mNextAttackComboIndex : mAttackArray.length * Math.random() - 1);
         var _loc2_:GMAttack = mAttackArray[_loc1_];
         if(_loc2_ == null)
         {
            Logger.error("Attack in attack array is null for attack index: " + mNextAttackComboIndex + " on weapon id: " + mWeapon.weaponData.Id + " Array Size: " + mAttackArray.length);
         }
         incrementCombo();
         return _loc2_;
      }
      
      protected function incrementCombo() : void
      {
         mNextAttackComboIndex = mNextAttackComboIndex + 1;
         if(mNextAttackComboIndex >= mAttackArray.length)
         {
            mNextAttackComboIndex = 0;
         }
      }
      
      public function canQueue(weaponQueue:PotentialWeaponInputQueueStruct, nextQueueAttackWindow:Number) : Boolean
      {
         if(mIsInCooldown)
         {
            return false;
         }
         if(this.currentTimeline == null)
         {
            return true;
         }
         if(mWeaponDownActive)
         {
            if(weaponQueue.weaponController == this && !weaponQueue.down)
            {
               return true;
            }
         }
         else if(this.currentTimeline.getPercentageOfTimelinePlayed() >= nextQueueAttackWindow)
         {
            return true;
         }
         return false;
      }
      
      public function canCombo() : Boolean
      {
         if(mCurrentAttackTimeline)
         {
            if(mCurrentAttackTimeline.isAttackWithinComboWindow())
            {
               return true;
            }
            return false;
         }
         return true;
      }
      
      public function berserkModeStart() : void
      {
         if(mWeapon.weaponData.ClassType == "MELEE")
         {
            overrideAttacksWithRampage();
         }
      }
      
      public function berserkModeEnd() : void
      {
         buildAttacks();
      }
      
      private function overrideAttacksWithRampage() : void
      {
         var _loc1_:GMAttack = mDBFacade.gameMaster.attackByConstant.itemFor("RAMPAGE");
         if(_loc1_ == null)
         {
            Logger.error("Could not find rampage attack by constant for constant: RAMPAGE. Will not override attacks.");
            return;
         }
         mAttackArray = [];
         mAttackArray.push(_loc1_);
         mNextAttackComboIndex = 0;
      }
      
      protected function notEnoughMana() : void
      {
         mHero.distributedDungeonFloor.effectManager.playNotEnoughManaEffects();
      }
      
      public function onWeaponDown(autoAim:Boolean = true) : void
      {
         mAutoAim = autoAim;
      }
      
      public function get weaponDownActive() : Boolean
      {
         return mWeaponDownActive;
      }
      
      public function onWeaponUp(autoAim:Boolean = true) : void
      {
         mAutoAim = autoAim;
      }
      
      public function get weapon() : WeaponGameObject
      {
         return mWeapon;
      }
      
      public function get currentTimeline() : ScriptTimeline
      {
         return mCurrentAttackTimeline;
      }
      
      public function get weaponRange() : uint
      {
         return 0;
      }
      
      public function queueAttack(attackName:String) : void
      {
         mQueueAttack = mDBFacade.gameMaster.attackByConstant.itemFor(attackName);
         if(mQueueAttack == null)
         {
            Logger.error("Queue Attack doesn\'t exist!");
         }
      }
      
      public function isRepeater() : Boolean
      {
         return false;
      }
      
      public function destroy() : void
      {
         mIsInCooldown = false;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
            mLogicalWorkComponent = null;
         }
      }
   }
}

