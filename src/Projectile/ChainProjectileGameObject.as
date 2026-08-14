package Projectile
{
   import Actor.ActorGameObject;
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Fixture;
   import Brain.Utils.MemoryTracker;
   import Combat.CombatGameObject;
   import Combat.Weapon.WeaponGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import DistributedObjects.NPCGameObject;
   import Dungeon.NavCollider;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Set;
   
   public class ChainProjectileGameObject extends ProjectileGameObject
   {
      
      private static const DEFAULT_CHAIN_CHECK_DISTANCE:Number = 300;
      
      private static const DEFAULT_NUM_BRANCHES:uint = 1;
      
      private var mMaxBranches:uint = 3;
      
      private var mNumBranches:uint = 0;
      
      private var mMaxChain:uint = 2;
      
      private var mNumChains:uint = 0;
      
      private var mEnvironmentTargets:Vector.<NPCGameObject>;
      
      private var mEnemyTargets:Vector.<NPCGameObject>;
      
      private var mIgnoreList:Set;
      
      private var mChainCheckDistance:Number = 0;
      
      private var mActorJustHit:ActorGameObject;
      
      public function ChainProjectileGameObject(dbFacade:DBFacade, actorId:uint, actorTeam:uint, attackType:uint, weapon:WeaponGameObject, distDungeonfloor:DistributedDungeonFloor, position:Vector3D, directionVector:Vector3D, visualOffset:Vector3D, range:Number = 0, currentChain:uint = 0, ignoreList:Set = null, effectObject:Object = null, combatResultCallback:Function = null, autoAim:Boolean = true, dontRotate:Boolean = false)
      {
         super(dbFacade,actorId,actorTeam,attackType,weapon,distDungeonfloor,position,directionVector,visualOffset,range,effectObject,combatResultCallback,autoAim,dontRotate,currentChain);
         mNumChains = currentChain;
         if(ignoreList == null)
         {
            mIgnoreList = new Set();
         }
         else
         {
            mIgnoreList = ignoreList;
         }
         var _loc17_:uint = weapon != null ? weapon.chains() : 0;
         mMaxChain = mGMProjectile.NumChains + _loc17_;
         mMaxBranches = mGMProjectile.NumBranches > 0 ? mGMProjectile.NumBranches : 1;
         mChainCheckDistance = mGMProjectile.ChainDist > 0 ? mGMProjectile.ChainDist : 300;
      }
      
      override protected function hitActor(actor:ActorGameObject) : Boolean
      {
         var _loc2_:b2Transform = null;
         mActorJustHit = actor;
         if(mIgnoreList.has(actor.id))
         {
            return false;
         }
         if(super.hitActor(actor))
         {
            if(mNumChains < mMaxChain)
            {
               mIgnoreList.add(actor.id);
               _loc2_ = new b2Transform();
               _loc2_.position = NavCollider.convertToB2Vec2(this.position);
               mEnvironmentTargets = new Vector.<NPCGameObject>();
               mEnemyTargets = new Vector.<NPCGameObject>();
               this.mDistributedDungeonFloor.box2DWorld.QueryShape(collisionCallback,new b2CircleShape(mChainCheckDistance / 50),_loc2_);
               processTargets();
            }
         }
         if(mCollisionComponent.markedForDeletion())
         {
            this.destroy();
         }
         return true;
      }
      
      private function collisionCallback(fixture:b2Fixture) : Boolean
      {
         var _loc3_:ActorGameObject = mDistributedDungeonFloor.getActor(mParentActorId);
         if(_loc3_ == null)
         {
            return false;
         }
         var _loc2_:uint = fixture.GetBody().GetUserData() as uint;
         var _loc4_:NPCGameObject = mDBFacade.gameObjectManager.getReferenceFromId(_loc2_) as NPCGameObject;
         if(_loc4_ && mActorJustHit.id != _loc4_.id && _loc4_.isAttackable && (!mIgnoreList.has(_loc4_.id) || mGMProjectile.CyclicChains))
         {
            if(mFlightComponent.isTargetableTeam(_loc4_.team))
            {
               if(!CombatGameObject.didAttackGoThroughWall(mDBFacade,mB2Body.GetPosition(),_loc4_,NavCollider.convertToB2Vec2(_loc4_.worldCenter),mDistributedDungeonFloor))
               {
                  if(_loc4_.team == 1)
                  {
                     mEnvironmentTargets.push(_loc4_);
                  }
                  else
                  {
                     mEnemyTargets.push(_loc4_);
                  }
               }
            }
         }
         if(mNumBranches >= mMaxBranches)
         {
            return false;
         }
         return true;
      }
      
      private function processTargets() : void
      {
         mEnemyTargets.sort(sortByDistance);
         processNewChains(mEnemyTargets);
         mEnvironmentTargets.sort(sortByDistance);
         processNewChains(mEnvironmentTargets);
      }
      
      private function sortByDistance(targetA:NPCGameObject, targetB:NPCGameObject) : Number
      {
         var _loc3_:b2Vec2 = new b2Vec2();
         _loc3_.x = mActorJustHit.worldCenterAsb2Vec2.x;
         _loc3_.y = mActorJustHit.worldCenterAsb2Vec2.y;
         _loc3_.Subtract(targetA.worldCenterAsb2Vec2);
         var _loc4_:b2Vec2 = new b2Vec2();
         _loc4_.x = mActorJustHit.worldCenterAsb2Vec2.x;
         _loc4_.y = mActorJustHit.worldCenterAsb2Vec2.y;
         _loc4_.Subtract(targetB.worldCenterAsb2Vec2);
         return _loc3_.LengthSquared() - _loc4_.LengthSquared();
      }
      
      private function processNewChains(targets:Vector.<NPCGameObject>) : void
      {
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < targets.length)
         {
            if(mNumBranches >= mMaxBranches)
            {
               return;
            }
            shootNewChain(targets[_loc2_]);
            _loc2_++;
         }
      }
      
      private function shootNewChain(targetActor:NPCGameObject) : void
      {
         mNumBranches = mNumBranches + 1;
         var _loc3_:Vector3D = targetActor.view.position.subtract(this.position);
         _loc3_.normalize();
         var _loc2_:ChainProjectileGameObject = new ChainProjectileGameObject(mDBFacade,mParentActorId,mParentActorTeam,mAttackType,mWeaponGameObject,this.mDistributedDungeonFloor,mActorJustHit.position,_loc3_,new Vector3D(0,0),mRange,mNumChains + 1,mIgnoreList,mEffectObject,mCombatResultCallback,false);
         MemoryTracker.track(_loc2_,"ChainProjectileGameObject - created in ChainProjectileGameObject.shootNewChain()");
      }
   }
}

