package Actor.Buffs
{
   import Actor.ActorGameObject;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.DoLater;
   import Collections.IMapIterator;
   import Collections.Map;
   import DBGlobals.DBGlobal;
   import DistributedObjects.HeroGameObjectOwner;
   import Events.ActorInvulnerableEvent;
   import Events.GameObjectEvent;
   import Events.XPBonusEvent;
   import Facade.DBFacade;
   import GameMasterDictionary.StatVector;
   
   public class BuffHandler
   {
      
      public static var ACTOR_INVULNERABLE:String = "ACTOR_INVULNERABLE";
      
      public static var BERSERK_MODE_START:String = "BERSERK_MODE_START";
      
      public static var BERSERK_MODE_DONE:String = "BERSERK_MODE_DONE";
      
      private var mActorGameObject:ActorGameObject;
      
      private var mBuffs:Map;
      
      protected var mMultiplier:StatVector;
      
      protected var mExpMultiplier:Number;
      
      protected var mEventExpMultiplier:Number;
      
      protected var mAttackCooldownMultiplier:Number;
      
      private var mFacade:DBFacade;
      
      public var Ability:uint;
      
      private var mEventComponent:EventComponent;
      
      private var mSwappableBuffs:Vector.<BuffGameObject>;
      
      private var mCurrentSwappableBuff:int = 0;
      
      private var mSwappableBuffDisplayTask:DoLater;
      
      public function BuffHandler(facade:DBFacade, actorGameObject:ActorGameObject)
      {
         super();
         mFacade = facade;
         mActorGameObject = actorGameObject;
         mMultiplier = new StatVector();
         resetMultiplier();
         mExpMultiplier = 1;
         mEventExpMultiplier = 1;
         mAttackCooldownMultiplier = 1;
         mBuffs = new Map();
         mEventComponent = new EventComponent(mFacade);
         mSwappableBuffs = new Vector.<BuffGameObject>();
      }
      
      private static function isAdditiveSlot(slot:uint) : Boolean
      {
         return slot == DBGlobal.MELEE_DEF || slot == DBGlobal.SHOOT_DEF || slot == DBGlobal.MAGIC_DEF;
      }
      
      public function destroy() : void
      {
         if(mEventComponent)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         if(mSwappableBuffDisplayTask)
         {
            mSwappableBuffDisplayTask.destroy();
            mSwappableBuffDisplayTask = null;
         }
         var _loc1_:IMapIterator = mBuffs.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc1_.next();
            _loc1_.current.destroy();
         }
         mBuffs.clear();
         mMultiplier.destroy();
         mMultiplier = null;
         mExpMultiplier = 0;
         mEventExpMultiplier = 1;
         mAttackCooldownMultiplier = 1;
         mBuffs = null;
         mSwappableBuffs.splice(0,mSwappableBuffs.length);
         mSwappableBuffs = null;
      }
      
      public function addBuff(dBuff:DistributedBuffGameObject) : void
      {
         var _loc9_:BuffGameObject = null;
         var _loc3_:BuffGameObject = null;
         var _loc7_:HeroGameObjectOwner = null;
         if(mBuffs == null)
         {
            return;
         }
         var _loc6_:Boolean = IsInvulnerable();
         var _loc5_:Boolean = IsBerserk();
         var _loc4_:Number = mExpMultiplier;
         var _loc8_:Number = mEventExpMultiplier;
         var _loc2_:BuffGameObject = mBuffs.itemFor(dBuff.type);
         if(_loc2_ == null)
         {
            _loc9_ = new BuffGameObject(mFacade,mActorGameObject,mActorGameObject.actorView,dBuff.type,0,dBuff.attackerActor);
            MemoryTracker.track(_loc9_,"BuffGameObject - created in BuffHandler.activateBuff()");
            mBuffs.add(dBuff.type,_loc9_);
            recalcBuffMultiplier();
            recalcBuffAbility();
            _loc3_ = mBuffs.itemFor(dBuff.type);
            if(_loc3_.CanSwapDisplay)
            {
               mSwappableBuffs.push(_loc3_);
               if(mSwappableBuffDisplayTask == null && mSwappableBuffs.length > 1)
               {
                  processSwappableBuffDisplays();
                  mSwappableBuffDisplayTask = mFacade.logicalWorkManager.doEverySeconds(1,processSwappableBuffDisplays,true,"BuffHandler");
               }
            }
         }
         else
         {
            _loc2_.instanceCount += 1;
            _loc2_.updateInstanceCountOnHud();
            recalcBuffMultiplier();
         }
         dBuff.buffHandler = this;
         if(mActorGameObject.isOwner && IsDisabledControls())
         {
            _loc7_ = mActorGameObject as HeroGameObjectOwner;
            if(_loc7_)
            {
               _loc7_.inputController.disableCombat();
            }
         }
         if(!_loc6_ && IsInvulnerable())
         {
            mEventComponent.dispatchEvent(new ActorInvulnerableEvent(ACTOR_INVULNERABLE,mActorGameObject.id,true));
         }
         if(!_loc5_ && IsBerserk())
         {
            mEventComponent.dispatchEvent(new GameObjectEvent(BERSERK_MODE_START,mActorGameObject.id));
         }
         if(mActorGameObject && mActorGameObject.isOwner && mExpMultiplier != _loc4_)
         {
         }
         if(mActorGameObject && mActorGameObject.isOwner && mEventExpMultiplier != _loc8_)
         {
            mEventComponent.dispatchEvent(new XPBonusEvent("XP_BONUS_EVENT",true,mEventExpMultiplier));
         }
      }
      
      public function removeBuff(dBuff:DistributedBuffGameObject) : void
      {
         var _loc6_:HeroGameObjectOwner = null;
         var _loc5_:int = 0;
         if(mBuffs == null)
         {
            return;
         }
         var _loc7_:Boolean = IsInvulnerable();
         var _loc4_:Boolean = IsBerserk();
         var _loc3_:Number = mExpMultiplier;
         if(mActorGameObject.isOwner && IsDisabledControls())
         {
            _loc6_ = mActorGameObject as HeroGameObjectOwner;
            if(_loc6_)
            {
               _loc6_.inputController.enableCombat();
            }
         }
         var _loc2_:BuffGameObject = mBuffs.itemFor(dBuff.type);
         if(_loc2_ != null)
         {
            _loc2_.instanceCount -= 1;
            _loc2_.updateInstanceCountOnHud();
            if(_loc2_.instanceCount <= 0)
            {
               _loc5_ = 0;
               while(_loc5_ < mSwappableBuffs.length)
               {
                  if(mSwappableBuffs[_loc5_] == _loc2_)
                  {
                     mSwappableBuffs.splice(_loc5_,1);
                  }
                  _loc5_++;
               }
               if(mCurrentSwappableBuff > mSwappableBuffs.length)
               {
                  mCurrentSwappableBuff = mSwappableBuffs.length;
               }
               if(mSwappableBuffDisplayTask && mSwappableBuffs.length < 2)
               {
                  mSwappableBuffDisplayTask.destroy();
                  mSwappableBuffDisplayTask = null;
                  mCurrentSwappableBuff = 0;
                  if(mSwappableBuffs.length == 1)
                  {
                     mSwappableBuffs[0].buffView.show(0.5);
                  }
               }
               mBuffs.remove(_loc2_);
               _loc2_.destroy();
               _loc2_ = null;
               recalcBuffAbility();
            }
            recalcBuffMultiplier();
         }
         if(_loc7_ && !IsInvulnerable())
         {
            mEventComponent.dispatchEvent(new ActorInvulnerableEvent(ACTOR_INVULNERABLE,mActorGameObject.id,false));
         }
         if(_loc4_ && !IsBerserk())
         {
            mEventComponent.dispatchEvent(new GameObjectEvent(BERSERK_MODE_DONE,mActorGameObject.id));
         }
      }
      
      private function processSwappableBuffDisplays(gameClock:GameClock = null) : void
      {
         if(mSwappableBuffs.length == 0)
         {
            mCurrentSwappableBuff = 0;
            return;
         }
         if(mCurrentSwappableBuff >= mSwappableBuffs.length)
         {
            mCurrentSwappableBuff = 0;
            mSwappableBuffs[mSwappableBuffs.length - 1].buffView.show(0.5);
         }
         else if(mCurrentSwappableBuff > 0)
         {
            mSwappableBuffs[mCurrentSwappableBuff - 1].buffView.show(0.5);
         }
         mSwappableBuffs[mCurrentSwappableBuff].buffView.hide(0.5);
         mCurrentSwappableBuff = mCurrentSwappableBuff + 1;
      }
      
      private function resetMultiplier() : void
      {
         mMultiplier.setConstant(1);
         mMultiplier.values[DBGlobal.MELEE_DEF] = 0;
         mMultiplier.values[DBGlobal.SHOOT_DEF] = 0;
         mMultiplier.values[DBGlobal.MAGIC_DEF] = 0;
      }
      
      public function recalcBuffMultiplier() : void
      {
         var _loc3_:BuffGameObject = null;
         var _loc1_:uint = 0;
         var _loc2_:uint = 0;
         resetMultiplier();
         mExpMultiplier = 1;
         mEventExpMultiplier = 1;
         mAttackCooldownMultiplier = 1;
         var _loc4_:IMapIterator = mBuffs.iterator() as IMapIterator;
         while(_loc4_.hasNext())
         {
            _loc3_ = _loc4_.next();
            _loc1_ = 0;
            while(_loc1_ < _loc3_.instanceCount)
            {
               _loc2_ = 0;
               while(_loc2_ < StatVector.slotCount)
               {
                  if(isAdditiveSlot(_loc2_))
                  {
                     var _loc5_:* = _loc2_;
                     var _loc6_:* = mMultiplier.values[_loc5_] + _loc3_.deltaValues.values[_loc2_];
                     mMultiplier.values[_loc5_] = _loc6_;
                  }
                  else
                  {
                     _loc6_ = _loc2_;
                     _loc5_ = mMultiplier.values[_loc6_] * _loc3_.deltaValues.values[_loc2_];
                     mMultiplier.values[_loc6_] = _loc5_;
                  }
                  _loc2_++;
               }
               mExpMultiplier *= _loc3_.ExpMult;
               mEventExpMultiplier *= _loc3_.EventExpMult;
               mAttackCooldownMultiplier *= _loc3_.attackCooldownMultiplier;
               _loc1_++;
            }
         }
      }
      
      public function get attackCooldownMultiplier() : Number
      {
         return mAttackCooldownMultiplier;
      }
      
      public function recalcBuffAbility() : void
      {
         var _loc2_:BuffGameObject = null;
         var _loc1_:uint = 0;
         Ability = 0;
         var _loc3_:IMapIterator = mBuffs.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc2_ = _loc3_.next();
            _loc1_ = 0;
            while(_loc1_ < _loc2_.instanceCount)
            {
               Ability |= _loc2_.Ability;
               _loc1_++;
            }
         }
      }
      
      public function HasAbility(ability:uint) : Boolean
      {
         return (Ability & ability) != 0;
      }
      
      public function IsInvulnerable() : Boolean
      {
         return (Ability & DBGlobal.ABILITY_INVULNERABLE_ALL) != 0;
      }
      
      public function IsDisabledControls() : Boolean
      {
         return (Ability & DBGlobal.ABILITY_DISABLE_CONTROLS) != 0;
      }
      
      public function IsInvulnerableMelee() : Boolean
      {
         return (Ability & DBGlobal.ABILITY_INVULNERABLE_MELEE) != 0;
      }
      
      public function IsInvulnerableMagic() : Boolean
      {
         return (Ability & DBGlobal.ABILITY_INVULNERABLE_MAGIC) != 0;
      }
      
      public function IsInvulnerableShoot() : Boolean
      {
         return (Ability & DBGlobal.ABILITY_INVULNERABLE_SHOOT) != 0;
      }
      
      public function CanStun() : Boolean
      {
         return (Ability & DBGlobal.ABILITY_SUFFER_IMMUNITY) == 0;
      }
      
      public function IsBerserk() : Boolean
      {
         return (Ability & DBGlobal.ABILITY_BERSERK_MODE) != 0;
      }
      
      public function get multiplier() : StatVector
      {
         return mMultiplier;
      }
   }
}

