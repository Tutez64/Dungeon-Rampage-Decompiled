package Projectile
{
   import Actor.ActorGameObject;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Combat.CombatGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   import GeneratedCode.Attack;
   import GeneratedCode.CombatResult;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class CollisionComponent
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mProjectile:ProjectileGameObject;
      
      protected var mParentActorId:uint;
      
      protected var mDungeonFloor:DistributedDungeonFloor;
      
      protected var mUpdatedVelocity:Boolean;
      
      protected var mNumCollisions:uint;
      
      protected var mCombatResultCallback:Function;
      
      protected var mWeaponType:uint;
      
      private var mWeaponPower:uint;
      
      private var mWeaponSlot:int;
      
      private var mActorCollisions:Map;
      
      private var mHitsPerActor:uint;
      
      private var mHitRecurDelay:Number;
      
      private var mMaxCollisions:uint;
      
      private var mRecurringHitDelayTasks:Map;
      
      private var mGMAttack:GMAttack;
      
      private var mGeneration:uint;
      
      private var mDontTrackGenerations:Boolean;
      
      private var mIsPierceProjectile:Boolean;
      
      private var mMarkedForDeletion:Boolean = false;
      
      public function CollisionComponent(dbFacade:DBFacade, projectile:ProjectileGameObject, parentActorId:uint, dungeonFloor:DistributedDungeonFloor, weaponType:uint, weaponPower:uint, gmAttck:GMAttack, combatResultCallback:Function, weaponSlot:int, additiveHits:Number, isPierceProjectile:Boolean, generation:uint = 0)
      {
         super();
         mDBFacade = dbFacade;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"CollisionComponent");
         mDungeonFloor = dungeonFloor;
         mNumCollisions = 0;
         mDontTrackGenerations = projectile.gmProjectile.NoGenerations;
         mGeneration = mDontTrackGenerations ? 0 : generation;
         mProjectile = projectile;
         mParentActorId = parentActorId;
         mCombatResultCallback = combatResultCallback;
         mUpdatedVelocity = false;
         mWeaponType = weaponType;
         mWeaponPower = weaponPower;
         mWeaponSlot = weaponSlot;
         mActorCollisions = new Map();
         mHitRecurDelay = mProjectile.gmProjectile.HitRecurDelay;
         mHitsPerActor = mProjectile.gmProjectile.HitsPerActor;
         mMaxCollisions = mProjectile.gmProjectile.MaxCollisions + additiveHits;
         mRecurringHitDelayTasks = new Map();
         mGMAttack = gmAttck;
         mIsPierceProjectile = isPierceProjectile;
      }
      
      public function get numCollisions() : uint
      {
         return mNumCollisions;
      }
      
      public function get updatedVelocity() : Boolean
      {
         return mUpdatedVelocity;
      }
      
      public function destroy() : void
      {
         var _loc3_:Task = null;
         var _loc2_:* = 0;
         mDungeonFloor = null;
         mCombatResultCallback = null;
         var _loc1_:IMapIterator = mRecurringHitDelayTasks.iterator() as IMapIterator;
         while(_loc1_.next())
         {
            _loc2_ = _loc1_.key as uint;
            _loc3_ = mRecurringHitDelayTasks.itemFor(_loc2_) as Task;
            if(_loc3_)
            {
               _loc3_.destroy();
            }
         }
         mRecurringHitDelayTasks.clear();
         mRecurringHitDelayTasks = null;
         mActorCollisions.clear();
         mActorCollisions = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
            mLogicalWorkComponent = null;
         }
      }
      
      public function hitWall() : void
      {
         mProjectile.onHitWall();
         mProjectile.destroy();
      }
      
      public function hitActor(actor:ActorGameObject) : Boolean
      {
         var _loc2_:* = 0;
         var _loc6_:Number = NaN;
         var _loc3_:Number = NaN;
         mProjectile.onHitActor(actor);
         var _loc5_:CollisionHelper = mActorCollisions.itemFor(actor.id) as CollisionHelper;
         if(_loc5_)
         {
            _loc5_ = mActorCollisions.itemFor(actor.id) as CollisionHelper;
            _loc2_ = _loc5_.hits;
            if(_loc2_ >= mHitsPerActor)
            {
               return false;
            }
         }
         if(_loc5_)
         {
            _loc6_ = _loc5_.lastHitTime + mHitRecurDelay * 1000;
            if(mDBFacade.gameClock.gameTime < _loc6_)
            {
               _loc3_ = _loc6_ - mDBFacade.gameClock.gameTime;
               addRecurringHitDelayTask(actor,_loc3_ / 1000);
               return false;
            }
         }
         else
         {
            _loc5_ = new CollisionHelper(actor.id);
         }
         if(!mActorCollisions.hasKey(actor.id))
         {
            mActorCollisions.add(actor.id,_loc5_);
         }
         _loc5_.hits++;
         _loc5_.lastHitTime = mDBFacade.gameClock.gameTime;
         mNumCollisions = mNumCollisions + 1;
         var _loc7_:CombatResult = new CombatResult();
         var _loc4_:Attack = new Attack();
         _loc4_.attackType = mProjectile.gmAttack.Id;
         _loc4_.weaponSlot = this.mWeaponSlot;
         _loc7_.attacker = mParentActorId;
         _loc7_.attack = _loc4_;
         _loc7_.attackee = actor.id;
         _loc7_.damage = 0;
         _loc7_.generation = mDontTrackGenerations ? 0 : mNumCollisions + mGeneration - 1;
         if(actor.isBlocking && !mGMAttack.Unblockable)
         {
            if(CombatGameObject.blockCheck(actor.getHeadingAsVector(),actor.maximumDotForBlocking,actor.worldCenter,mProjectile.worldCenter))
            {
               _loc7_.blocked = 1;
            }
            else
            {
               _loc7_.blocked = 0;
            }
         }
         if(_loc7_.blocked == 1)
         {
            _loc7_.knockback = 0;
            _loc7_.suffer = 0;
         }
         else
         {
            _loc7_.knockback = mProjectile.gmAttack.Knockback;
            if(_loc7_.knockback != 0)
            {
               _loc7_.suffer = 1;
            }
            else
            {
               _loc7_.suffer = Math.random() <= mProjectile.gmAttack.StunChance ? 1 : 0;
            }
         }
         if(mCombatResultCallback != null)
         {
            mCombatResultCallback(_loc7_);
         }
         if(mHitsPerActor > _loc2_ && mNumCollisions < mMaxCollisions)
         {
            addRecurringHitDelayTask(actor,mHitRecurDelay);
         }
         if(mNumCollisions >= mMaxCollisions || actor.hasAbility(16777216) && mIsPierceProjectile)
         {
            mMarkedForDeletion = true;
         }
         return true;
      }
      
      private function handleRecurringHitDelay(actor:ActorGameObject, actorId:uint) : void
      {
         if(mRecurringHitDelayTasks == null)
         {
            Logger.error("Error in handleRecurringHitDelay.  mRecurringHitDelayTasks is not being cleaned up correctly.");
            return;
         }
         mRecurringHitDelayTasks.removeKey(actorId);
         if(actor != null && !actor.isDestroyed)
         {
            hitActor(actor);
         }
      }
      
      public function exitContact(actorId:uint) : void
      {
         var _loc2_:Task = mRecurringHitDelayTasks.itemFor(actorId);
         if(_loc2_ != null)
         {
            _loc2_.destroy();
            mRecurringHitDelayTasks.removeKey(actorId);
         }
      }
      
      private function addRecurringHitDelayTask(actor:ActorGameObject, delayForNextHitInSeconds:Number) : void
      {
         var recurringHitTask:Task = mRecurringHitDelayTasks.removeKey(actor.id);
         if(recurringHitTask != null)
         {
            recurringHitTask.destroy();
         }
         if(delayForNextHitInSeconds > 0)
         {
            recurringHitTask = mLogicalWorkComponent.doLater(delayForNextHitInSeconds,function(param1:GameClock):void
            {
               if(actor && !actor.isDestroyed)
               {
                  handleRecurringHitDelay(actor,actor.id);
               }
            });
            mRecurringHitDelayTasks.add(actor.id,recurringHitTask);
         }
         else
         {
            hitActor(actor);
         }
      }
      
      public function markedForDeletion() : Boolean
      {
         return mMarkedForDeletion;
      }
   }
}

class CollisionHelper
{
   
   public var hits:uint;
   
   public var actorId:uint;
   
   public var lastHitTime:int;
   
   public function CollisionHelper(theActorId:uint)
   {
      super();
      hits = 0;
      lastHitTime = 0;
      actorId = theActorId;
   }
}
