package Facade
{
   import Account.AvatarInfo;
   import Account.Consumable;
   import Account.DBAccountInfo;
   import Account.ItemInfo;
   import Account.PetInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.StarlingAssetMapper;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.LogicalWorkComponent;
   import GameMasterDictionary.GMAttack;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMStackable;
   import GameMasterDictionary.GMWeaponAesthetic;
   import GameMasterDictionary.GMWeaponItem;
   import GameMasterDictionary.GameMaster;
   import GeneratedCode.HeroPreloadLook;
   import GeneratedCode.WeaponDetails;
   import flash.utils.getTimer;
   
   public class LoadingPrewarm
   {
      
      public static const MAX_HOLD_MS:int = 900;
      
      private static const SLICE_MS:int = 30;
      
      private static const HOLD_SLICE_MS:int = 60;
      
      private static const BACKGROUND_SLICE_MS:int = 3;
      
      private static const BACKGROUND_DEADLINE_MS:int = 30000;
      
      public static const MAX_SEGMENT_FRAMES:int = 90;
      
      private static const HERO_EFFECTS:int = 4;
      
      private static const HERO_ANGLE_EFFECTS:int = 2;
      
      private static const HERO_HITS:int = 12;
      
      private static const NPC_EFFECTS:int = 4;
      
      private static const NPC_HITS:int = 4;
      
      private static const NPC_ALLY_HITS:int = 2;
      
      private static const DEATHS:int = 3;
      
      private static const COMMON_HITS:int = 4;
      
      private static const FX_LIBRARY:String = "Resources/Art2D/FX/db_fx_library.swf";
      
      private static var sLoading:LoadingPrewarm;
      
      private static var sFrameKey:uint;
      
      private static var sFrameUsedMs:int;
      
      private static const COMMON_EFFECTS:Array = ["db_fx_hit_bang","db_fx_hit_super","db_fx_hit_sweet","db_fx_hit_weak","db_fx_hit_fail","db_fx_hitRed"];
      
      private static const RARE_EFFECTS:Array = ["db_fx_levelup","db_fx_levelup_background"];
      
      private static const ANGLES:Array = ["90","135","180","225","270"];
      
      private static var sPendingLooks:Array = [];
      
      private static var sBackground:Vector.<LoadingPrewarm> = new Vector.<LoadingPrewarm>();
      
      private static var sWarmedLooks:Object = {};
      
      private var mDBFacade:DBFacade;
      
      private var mBackground:Boolean;
      
      private var mWork:LogicalWorkComponent;
      
      private var mJobs:Vector.<PrewarmJob> = new Vector.<PrewarmJob>();
      
      private var mJobsByKey:Object = {};
      
      private var mNext:int = 0;
      
      private var mFirstSlice:uint;
      
      private var mSliced:Boolean;
      
      private var mHoldStart:uint;
      
      private var mHoldAllowance:int;
      
      private var mHolding:Boolean;
      
      private var mOnRelease:Function;
      
      private var mDone:Boolean;
      
      private var mTrailOverrides:Array = [];
      
      private var mLookKey:String;
      
      public function LoadingPrewarm(dbFacade:DBFacade, background:Boolean)
      {
         super();
         mDBFacade = dbFacade;
         mBackground = background;
      }
      
      public static function startLoading(dbFacade:DBFacade, cacheNpc:Vector.<uint>) : LoadingPrewarm
      {
         var look:HeroPreloadLook;
         var looks:Array = sPendingLooks;
         sPendingLooks = [];
         sWarmedLooks = {};
         sLoading = new LoadingPrewarm(dbFacade,false);
         sLoading.start(function():void
         {
            sLoading.planLoading(cacheNpc);
         });
         for each(look in looks)
         {
            startBackground(dbFacade,look);
         }
         return sLoading;
      }
      
      public static function startLoadingAndRelease(dbFacade:DBFacade, cacheNpc:Vector.<uint>, entryGeneration:int) : LoadingPrewarm
      {
         var _loc4_:LoadingPrewarm = startLoading(dbFacade,cacheNpc);
         dbFacade.assetLoadingComponent.releaseBundlesUnusedSince(entryGeneration);
         return _loc4_;
      }
      
      public static function heroJoined(dbFacade:DBFacade, look:HeroPreloadLook) : void
      {
         if(look == null)
         {
            return;
         }
         if(sLoading == null && dbFacade.mainStateMachine.currentStateName == "LoadingScreenState")
         {
            sPendingLooks.push(look);
            return;
         }
         startBackground(dbFacade,look);
      }
      
      private static function startBackground(dbFacade:DBFacade, look:HeroPreloadLook) : void
      {
         var background:LoadingPrewarm;
         var key:String = look.heroType + "|" + look.skinType + "|" + lookParts(look.weapons) + "|" + look.consumableTypes + "|" + look.petTypes;
         if(sWarmedLooks[key])
         {
            return;
         }
         sWarmedLooks[key] = true;
         background = new LoadingPrewarm(dbFacade,true);
         background.mLookKey = key;
         sBackground.push(background);
         background.start(function():void
         {
            background.planLook(look);
         });
      }
      
      private static function lookParts(weapons:Vector.<WeaponDetails>) : String
      {
         var _loc3_:Array = [];
         for each(var _loc2_:WeaponDetails in weapons)
         {
            _loc3_.push(_loc2_.type + "/" + _loc2_.requiredlevel + "/" + _loc2_.legendarymodifier);
         }
         return _loc3_.join(",");
      }
      
      public static function cancelLoading() : void
      {
         if(sLoading != null)
         {
            sLoading.cancel();
         }
         sLoading = null;
      }
      
      public static function cancelAll() : void
      {
         cancelLoading();
         sPendingLooks = [];
         sWarmedLooks = {};
         for each(var _loc1_:LoadingPrewarm in sBackground.concat())
         {
            _loc1_.cancel();
         }
         sBackground.length = 0;
      }
      
      public static function get busy() : Boolean
      {
         return sLoading != null && sLoading.running || sBackground.length > 0 || sPendingLooks.length > 0;
      }
      
      private function start(plan:Function) : void
      {
         var _loc3_:String = null;
         try
         {
            plan();
         }
         catch(error:Error)
         {
            Logger.error("LoadingPrewarm: planning failed: " + error.message);
         }
         var _loc2_:AssetLoadingComponent = mDBFacade.assetLoadingComponent;
         for each(var _loc4_:PrewarmJob in mJobs)
         {
            _loc3_ = StarlingAssetMapper.getActorAtlasKeyFromPath(_loc4_.swfPath);
            if(_loc2_ != null && _loc3_ != null)
            {
               _loc2_.markStarlingKeyUsed(_loc3_);
            }
         }
         mWork = new LogicalWorkComponent(mDBFacade,"LoadingPrewarm");
         mWork.doEveryFrame(onFrame);
      }
      
      public function get running() : Boolean
      {
         return !mDone;
      }
      
      public function hold(onRelease:Function) : void
      {
         if(mDone)
         {
            onRelease();
            return;
         }
         mOnRelease = onRelease;
         if(mHolding)
         {
            return;
         }
         mHolding = true;
         mHoldStart = getTimer();
         mHoldAllowance = mDBFacade.featureFlags.getFlagValue("loading-prewarm-hold") ? 900 : 0;
         if(pastDeadline)
         {
            finish();
         }
      }
      
      public function cancel() : void
      {
         if(!mDone)
         {
            finish(false);
         }
      }
      
      private function get pastDeadline() : Boolean
      {
         return mBackground ? mSliced && int(getTimer() - mFirstSlice) >= 30000 : mHolding && int(getTimer() - mHoldStart) >= mHoldAllowance;
      }
      
      private function onFrame(clock:GameClock) : void
      {
         var _loc8_:PrewarmJob = null;
         var _loc2_:int = 0;
         if(mDone)
         {
            return;
         }
         if(pastDeadline)
         {
            finish();
            return;
         }
         var _loc3_:uint = uint(mDBFacade.gameClock.realTime);
         if(_loc3_ != sFrameKey)
         {
            sFrameKey = _loc3_;
            sFrameUsedMs = 0;
         }
         if(mBackground && sLoading != null && sLoading.running)
         {
            return;
         }
         var _loc5_:int = !mBackground ? (mHolding ? 60 : 30) : (mDBFacade.mainStateMachine.currentStateName == "LoadingScreenState" ? 30 : 3);
         var _loc6_:int = _loc5_ - sFrameUsedMs;
         if(_loc6_ <= 0)
         {
            return;
         }
         var _loc4_:int = getTimer();
         if(!mSliced)
         {
            mSliced = true;
            mFirstSlice = uint(_loc4_);
         }
         var _loc7_:int = 0;
         while(mNext < mJobs.length && !pastDeadline)
         {
            _loc8_ = mJobs[mNext];
            try
            {
               _loc2_ = _loc8_.step(mDBFacade,mBackground);
            }
            catch(error:Error)
            {
               _loc8_.abort(mDBFacade);
               _loc2_ = PrewarmJob.DONE;
               Logger.error("LoadingPrewarm: building " + _loc8_.name + " failed: " + error.message);
            }
            if(_loc2_ == PrewarmJob.DONE)
            {
               mNext = mNext + 1;
               _loc7_ = 0;
            }
            else if(_loc2_ == 2)
            {
               mJobs.splice(mNext,1);
               mJobs.push(_loc8_);
               if(++_loc7_ >= mJobs.length - mNext)
               {
                  break;
               }
            }
            if(int(getTimer() - _loc4_) >= _loc6_)
            {
               break;
            }
         }
         sFrameUsedMs += int(getTimer() - _loc4_);
         if(mNext >= mJobs.length || pastDeadline)
         {
            finish();
         }
      }
      
      private function finish(callBack:Boolean = true) : void
      {
         var _loc3_:int = 0;
         mDone = true;
         if(mNext < mJobs.length)
         {
            mJobs[mNext].abort(mDBFacade);
         }
         if(mWork != null)
         {
            mWork.destroy();
            mWork = null;
         }
         if(mBackground)
         {
            if(mLookKey != null && mNext < mJobs.length)
            {
               delete sWarmedLooks[mLookKey];
            }
            _loc3_ = sBackground.indexOf(this);
            if(_loc3_ >= 0)
            {
               sBackground.splice(_loc3_,1);
            }
         }
         var _loc2_:Function = mOnRelease;
         mOnRelease = null;
         mJobs = new Vector.<PrewarmJob>();
         mJobsByKey = {};
         if(callBack && _loc2_ != null)
         {
            _loc2_();
         }
      }
      
      private function planLoading(cacheNpc:Vector.<uint>) : void
      {
         var _loc3_:GMNpc = null;
         var _loc14_:Array = null;
         var _loc6_:Array = null;
         var _loc4_:Array = null;
         var _loc7_:GMSkin = null;
         var _loc10_:GameMaster = mDBFacade.gameMaster;
         var _loc2_:DBAccountInfo = mDBFacade.dbAccountInfo;
         var _loc8_:AvatarInfo = _loc2_ != null ? _loc2_.activeAvatarInfo : null;
         var _loc13_:String = DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf");
         if(_loc8_ != null && _loc2_.inventoryInfo != null)
         {
            _loc14_ = [];
            for each(var _loc5_:ItemInfo in _loc2_.inventoryInfo.getEquipedItemsOnAvatar(_loc8_.id))
            {
               if(_loc5_.gmWeaponItem != null)
               {
                  _loc14_.push([_loc5_.gmWeaponItem,_loc5_.gmWeaponAesthetic]);
               }
            }
            _loc6_ = [];
            for each(var _loc11_:Consumable in _loc8_.equippedConsumables)
            {
               if(_loc11_.stackId != 0)
               {
                  _loc6_.push(_loc10_.stackableById.itemFor(_loc11_.stackId));
               }
            }
            _loc4_ = [];
            for each(var _loc15_:PetInfo in _loc2_.inventoryInfo.getEquipedPetsOnAvatar(_loc8_.id))
            {
               _loc4_.push(_loc15_.gmNpc);
            }
            _loc7_ = _loc10_.getSkinByType(_loc8_.skinId);
            addHero(_loc7_ != null ? _loc10_.getHeroByConstant(_loc7_.ForHero) : null,_loc14_,_loc6_,_loc4_);
         }
         for each(var _loc9_:String in COMMON_EFFECTS)
         {
            addEffect(_loc13_,_loc9_,4);
         }
         for each(var _loc16_:uint in cacheNpc)
         {
            addNpc(_loc10_.npcById.itemFor(_loc16_),false);
         }
         for each(_loc16_ in cacheNpc)
         {
            _loc3_ = _loc10_.npcById.itemFor(_loc16_);
            if(_loc3_ != null && _loc3_.ViolentDeathClassName && _loc3_.ViolentDeathFilePath)
            {
               addEffect(DBFacade.buildFullDownloadPath(_loc3_.ViolentDeathFilePath),_loc3_.ViolentDeathClassName,3);
            }
         }
         for each(var _loc12_:String in RARE_EFFECTS)
         {
            addEffect(_loc13_,_loc12_,1);
         }
      }
      
      private function planLook(look:HeroPreloadLook) : void
      {
         var _loc2_:GMWeaponItem = null;
         var _loc6_:Boolean = false;
         var _loc5_:GameMaster = mDBFacade.gameMaster;
         var _loc9_:Array = [];
         for each(var _loc4_:WeaponDetails in look.weapons)
         {
            _loc2_ = _loc4_.type != 0 ? _loc5_.weaponItemById.itemFor(_loc4_.type) : null;
            if(_loc2_ != null)
            {
               _loc6_ = _loc4_.legendarymodifier > 0 && _loc5_.legendaryModifiersById.itemFor(_loc4_.legendarymodifier) != null;
               _loc9_.push([_loc2_,_loc2_.getWeaponAesthetic(_loc4_.requiredlevel,_loc6_)]);
            }
         }
         var _loc7_:Array = [];
         for each(var _loc8_:uint in look.consumableTypes)
         {
            if(_loc8_ != 0)
            {
               _loc7_.push(_loc5_.stackableById.itemFor(_loc8_));
            }
         }
         var _loc3_:Array = [];
         for each(var _loc10_:uint in look.petTypes)
         {
            _loc3_.push(_loc5_.npcById.itemFor(_loc10_));
         }
         addHero(_loc5_.heroById.itemFor(look.heroType),_loc9_,_loc7_,_loc3_);
      }
      
      private function addHero(gmHero:GMHero, weapons:Array, consumables:Array, pets:Array) : void
      {
         var _loc5_:GMWeaponAesthetic = null;
         mTrailOverrides = [null];
         for each(var _loc7_:Array in weapons)
         {
            _loc5_ = _loc7_[1];
            if(_loc5_ != null && _loc5_.SwordTrailOverride && mTrailOverrides.indexOf(_loc5_.SwordTrailOverride) < 0)
            {
               mTrailOverrides.push(_loc5_.SwordTrailOverride);
            }
         }
         for each(_loc7_ in weapons)
         {
            addWeapon(_loc7_[0],true);
         }
         if(gmHero != null)
         {
            addAttack(gmHero.DBuster1,true);
            addAttack(gmHero.TeamAttack,true);
            if(gmHero.Pet)
            {
               addNpc(mDBFacade.gameMaster.npcByConstant.itemFor(gmHero.Pet),true);
            }
         }
         for each(var _loc6_:GMStackable in consumables)
         {
            if(_loc6_ != null)
            {
               addAttack(_loc6_.UsageAttack,true);
            }
         }
         mTrailOverrides = [null];
         for each(var _loc8_:GMNpc in pets)
         {
            addNpc(_loc8_,true);
         }
      }
      
      private function addNpc(npc:GMNpc, heroSide:Boolean) : void
      {
         if(npc == null)
         {
            return;
         }
         for each(var _loc3_:String in [npc.Weapon1,npc.Weapon2,npc.Weapon3,npc.Weapon4,npc.Weapon5])
         {
            if(_loc3_)
            {
               addWeapon(mDBFacade.gameMaster.weaponItemByConstant.itemFor(_loc3_),heroSide);
            }
         }
      }
      
      private function addWeapon(weapon:GMWeaponItem, heroSide:Boolean) : void
      {
         if(weapon == null)
         {
            return;
         }
         for each(var _loc3_:String in weapon.AttackArray)
         {
            if(_loc3_ == null)
            {
               break;
            }
            addAttack(_loc3_,heroSide);
         }
         addAttack(weapon.HoldingAttack,heroSide);
         addAttack(weapon.ChargeAttack,heroSide);
      }
      
      private function addAttack(attackConstant:String, heroSide:Boolean) : void
      {
         var _loc3_:String = null;
         if(!attackConstant)
         {
            return;
         }
         var _loc5_:GMAttack = mDBFacade.gameMaster.attackByConstant.itemFor(attackConstant);
         if(_loc5_ == null)
         {
            return;
         }
         if(_loc5_.HitEffectFilepath)
         {
            _loc3_ = DBFacade.buildFullDownloadPath(_loc5_.HitEffectFilepath);
            if(_loc5_.HitEffect)
            {
               addEffect(_loc3_,_loc5_.HitEffect,heroSide ? 12 : 2);
            }
            if(!heroSide)
            {
               addEffect(_loc3_,"db_fx_hitRed",4);
            }
         }
         var _loc6_:Object = mDBFacade.timelineFactory != null ? mDBFacade.timelineFactory.getTimelineJson(_loc5_.AttackTimeline) : null;
         if(_loc6_ == null || _loc6_.frames == null)
         {
            return;
         }
         for each(var _loc7_:Object in _loc6_.frames)
         {
            for each(var _loc4_:Object in _loc7_.actions)
            {
               if(_loc4_ != null && _loc4_.path && _loc4_.name && !_loc4_.managed && (_loc4_.type == "effect" || _loc4_.type == "attackEffect"))
               {
                  addEffectNames(DBFacade.buildFullDownloadPath(_loc4_.path),String(_loc4_.name),heroSide);
               }
            }
         }
      }
      
      private function addEffectNames(swfPath:String, name:String, heroSide:Boolean) : void
      {
         var _loc5_:String = null;
         if(name.indexOf("_angle") < 0)
         {
            addEffect(swfPath,name,heroSide ? 4 : 4);
            return;
         }
         for each(var _loc4_:String in mTrailOverrides)
         {
            _loc5_ = _loc4_ ? name.replace("db_fx_attack",_loc4_) : name;
            for each(var _loc6_:String in ANGLES)
            {
               if(_loc5_.indexOf("swing_angle") >= 0)
               {
                  addEffect(swfPath,_loc5_ + _loc6_ + "_right",heroSide ? 2 : 1);
                  addEffect(swfPath,_loc5_ + _loc6_ + "_left",heroSide ? 2 : 1);
               }
               else
               {
                  addEffect(swfPath,_loc5_ + _loc6_,heroSide ? 2 : 1);
               }
            }
         }
      }
      
      private function addEffect(swfPath:String, className:String, count:int) : void
      {
         var _loc5_:String = swfPath + "|" + className;
         var _loc4_:PrewarmJob = mJobsByKey[_loc5_];
         if(_loc4_ != null)
         {
            _loc4_.count = Math.max(_loc4_.count,count);
            return;
         }
         _loc4_ = new PrewarmJob(swfPath,className,count);
         mJobsByKey[_loc5_] = _loc4_;
         mJobs.push(_loc4_);
      }
   }
}

import Brain.AssetRepository.AssetLoadingComponent;
import Brain.AssetRepository.StarlingAssetMapper;
import Brain.Logger.Logger;
import Effects.EffectGameObject;
import Effects.EffectView;
import Effects.StarlingEffectRenderer;
import Facade.DBFacade;
import flash.geom.Point;
import starling.extensions.animate.Animation;

class PrewarmJob
{
   
   public static const DONE:int = 0;
   
   public static const MORE:int = 1;
   
   public static const WAIT:int = 2;
   
   private static const READY:int = 0;
   
   private static const LOADING:int = 1;
   
   private static const NEVER:int = 2;
   
   public var swfPath:String;
   
   public var name:String;
   
   public var count:int;
   
   private var mStarted:Boolean;
   
   private var mEntered:Boolean;
   
   private var mLabel:String;
   
   private var mEffects:Array = [];
   
   private var mAnimations:Array = [];
   
   private var mFrame:int;
   
   private var mEnd:int;
   
   private var mRootEnd:int;
   
   public function PrewarmJob(swfPath:String, name:String, count:int)
   {
      super();
      this.swfPath = swfPath;
      this.name = name;
      this.count = count;
   }
   
   public function step(dbFacade:DBFacade, waitForLoads:Boolean) : int
   {
      var _loc4_:int = 0;
      var _loc3_:Boolean = false;
      if(!mStarted)
      {
         _loc4_ = int(residency(dbFacade));
         if(_loc4_ != 0)
         {
            return _loc4_ == 1 && waitForLoads ? 2 : 0;
         }
         mStarted = true;
      }
      if(!mEntered)
      {
         _loc3_ = Boolean(checkoutEffect(dbFacade));
         if(_loc3_ && mAnimations.length < count)
         {
            return 1;
         }
         mEntered = true;
         if(!_loc3_ || !enterSegment())
         {
            handBack(dbFacade);
            return 0;
         }
         return finishedOrMore(dbFacade);
      }
      for each(var _loc5_:Animation in mAnimations)
      {
         _loc5_.currentFrame = Math.min(mFrame,mRootEnd);
         _loc5_.advanceMovieClips();
      }
      mFrame = Number(mFrame) + 1;
      return finishedOrMore(dbFacade);
   }
   
   public function abort(dbFacade:DBFacade) : void
   {
      handBack(dbFacade);
   }
   
   private function finishedOrMore(dbFacade:DBFacade) : int
   {
      if(mFrame <= mEnd)
      {
         return 1;
      }
      handBack(dbFacade);
      return 0;
   }
   
   private function residency(dbFacade:DBFacade) : int
   {
      var _loc2_:AssetLoadingComponent = dbFacade.assetLoadingComponent;
      var _loc3_:String = StarlingAssetMapper.getActorAtlasKeyFromPath(swfPath);
      if(_loc2_ == null || _loc3_ == null || dbFacade.starlingLayerManager == null || StarlingAssetMapper.getActorAtlasFile(swfPath,true) == null)
      {
         return 2;
      }
      if(!_loc2_.isStarlingKeyResident(_loc3_))
      {
         return 1;
      }
      return _loc2_.hasAnimationInAssetManager(name) ? 0 : 2;
   }
   
   private function checkoutEffect(dbFacade:DBFacade) : Boolean
   {
      var _loc3_:EffectGameObject = dbFacade.effectPool.checkout(dbFacade,swfPath,name,null,null) as EffectGameObject;
      if(_loc3_ == null)
      {
         return false;
      }
      mEffects.push(_loc3_);
      var _loc2_:StarlingEffectRenderer = EffectView(_loc3_.view).prewarmRenderer();
      if(_loc2_ == null || _loc2_.animation == null)
      {
         return false;
      }
      mLabel = _loc2_.label;
      mAnimations.push(_loc2_.animation);
      return true;
   }
   
   private function enterSegment() : Boolean
   {
      var _loc3_:Point = null;
      if(mAnimations.length == 0)
      {
         return false;
      }
      var _loc2_:int = 0;
      var _loc4_:int = Animation(mAnimations[0]).numFrames - 1;
      for each(var _loc5_:Animation in mAnimations)
      {
         if(mLabel != null && _loc5_.getFrame(mLabel) >= 0)
         {
            _loc3_ = _loc5_.gotoLabel(mLabel,false);
            if(_loc3_.x < 0)
            {
               return false;
            }
            _loc2_ = _loc3_.x;
            _loc4_ = _loc3_.y;
         }
         else
         {
            _loc5_.currentFrame = 0;
         }
         _loc5_.advanceMovieClips();
      }
      mFrame = _loc2_ + 1;
      mRootEnd = _loc4_;
      var _loc1_:int = int(Animation(mAnimations[0]).deepestFrames);
      mEnd = Math.min(Math.max(_loc4_,_loc2_ + _loc1_ - 1),_loc2_ + 90 - 1);
      return true;
   }
   
   private function handBack(dbFacade:DBFacade) : void
   {
      var _loc2_:Array = mEffects;
      mEffects = [];
      mAnimations = [];
      mFrame = mEnd + 1;
      for each(var _loc3_:EffectGameObject in _loc2_)
      {
         try
         {
            if(!_loc3_.isDestroyed)
            {
               dbFacade.effectPool.checkin(_loc3_);
            }
         }
         catch(error:Error)
         {
            Logger.error("LoadingPrewarm: returning " + name + " to the effect pool failed: " + error.message);
         }
      }
   }
}
