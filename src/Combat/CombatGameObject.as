package Combat
{
   import Actor.ActorGameObject;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Fixture;
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Brain.Utils.GeometryUtil;
   import Combat.Attack.CombatCollider;
   import Combat.Weapon.WeaponGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import DistributedObjects.HeroGameObjectOwner;
   import DistributedObjects.NPCGameObject;
   import Dungeon.Prop;
   import Dungeon.Tile;
   import Dungeon.TileGridIterator;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import GameMasterDictionary.GMAttack;
   import GeneratedCode.Attack;
   import GeneratedCode.CombatResult;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class CombatGameObject extends FloorObject
   {
      
      protected var mCombatCollider:CombatCollider;
      
      protected var mActorOwner:ActorGameObject;
      
      protected var mCombatResults:Vector.<CombatResult>;
      
      protected var mAttackType:uint;
      
      protected var mWeapon:WeaponGameObject;
      
      protected var mTimelineFrame:uint;
      
      protected var mShowColliders:Boolean;
      
      protected var mCombatResultCallback:Function;
      
      public var mCurrentHitMap:Map;
      
      public var mLifeTime:uint;
      
      public var mHitDelayPerObject:uint;
      
      public function CombatGameObject(facade:DBFacade, actor:ActorGameObject, attackName:uint, weapon:WeaponGameObject, distributedDungeonFloor:DistributedDungeonFloor, combatCollider:CombatCollider, lifetime:uint = 1, hitDelayPerObj:uint = 0, callBack:Function = null, remoteId:uint = 0)
      {
         super(facade,remoteId);
         mActorOwner = actor;
         mCombatResults = new Vector.<CombatResult>();
         mDistributedDungeonFloor = distributedDungeonFloor;
         mAttackType = attackName;
         mWeapon = weapon;
         mCombatCollider = combatCollider;
         mShowColliders = mDBFacade.showCollisions || mDBFacade.dbConfigManager.getConfigBoolean("show_colliders",false);
         this.layer = 20;
         mCurrentHitMap = new Map();
         mLifeTime = lifetime;
         mHitDelayPerObject = hitDelayPerObj;
         mCombatResultCallback = callBack;
      }
      
      public static function blockCheck(blockHeading:Vector3D, maxBlockDotProduct:Number, blockingActorPosition:Vector3D, attackingActorPosition:Vector3D) : Boolean
      {
         return false;
      }
      
      public static function didAttackGoThroughWall(dbFacade:DBFacade, attackerPos:b2Vec2, targetActor:ActorGameObject, attackeePos:b2Vec2, dungeonFloor:DistributedDungeonFloor, showColliders:Boolean = false) : Boolean
      {
         var attackThroughWall:Boolean = false;
         var distanceOfRayIntersection:Number = 999;
         var wallCheck:Function = function(param1:b2Fixture, param2:b2Vec2, param3:b2Vec2, param4:Number):Number
         {
            var _loc6_:uint = param1.GetBody().GetUserData() as uint;
            var _loc5_:GameObject = dbFacade.gameObjectManager.getReferenceFromId(_loc6_);
            if(_loc5_ == null || _loc5_ is Prop)
            {
               if(param4 < distanceOfRayIntersection)
               {
                  attackThroughWall = true;
                  distanceOfRayIntersection = param4;
               }
            }
            else if(_loc5_.id == targetActor.id)
            {
               if(param4 < distanceOfRayIntersection)
               {
                  attackThroughWall = false;
                  distanceOfRayIntersection = param4;
               }
            }
            return 1;
         };
         if(showColliders)
         {
            dungeonFloor.debugVisualizer.reportRayCast(attackerPos,attackeePos);
         }
         dungeonFloor.box2DWorld.RayCast(wallCheck,attackerPos,attackeePos);
         return attackThroughWall;
      }
      
      public static function determineIfHitBasedOnTeam(attackerTeam:uint, hitActorTeam:uint, attackTeamType:String) : Boolean
      {
         switch(attackTeamType)
         {
            case "FRIENDLY":
               return attackerTeam == hitActorTeam;
            case "HOSTILE":
               return attackerTeam != hitActorTeam;
            default:
               Logger.warn("No case for attackTeamType: " + attackTeamType);
               return false;
         }
      }
      
      public function get combatResult() : Vector.<CombatResult>
      {
         return mCombatResults;
      }
      
      override public function set position(pos:Vector3D) : void
      {
         super.position = pos;
         mFloorView.position = pos;
         mCombatCollider.position = pos;
      }
      
      public function doCollisions(timelineFrame:uint = 0) : void
      {
         checkCollisions(collisionCallback,timelineFrame);
      }
      
      protected function checkCollisions(callbackForCollisions:Function, timelineFrame:uint = 0) : void
      {
         mTimelineFrame = timelineFrame;
         mDistributedDungeonFloor.box2DWorld.QueryShape(callbackForCollisions,mCombatCollider.shape,mCombatCollider.transform);
      }
      
      protected function collisionCallback(fixture:b2Fixture) : Boolean
      {
         var _loc5_:HeroGameObjectOwner = null;
         var _loc2_:uint = fixture.GetBody().GetUserData() as uint;
         var _loc3_:ActorGameObject = mDBFacade.gameObjectManager.getReferenceFromId(_loc2_) as ActorGameObject;
         if(!_loc3_)
         {
            return true;
         }
         if(!_loc3_.isAttackable)
         {
            return true;
         }
         var _loc4_:GMAttack = mDBFacade.gameMaster.attackById.itemFor(mAttackType);
         if(_loc4_ == null)
         {
            Logger.error("No GMAttack found for attack type: " + mAttackType);
            return true;
         }
         if(!determineIfHitBasedOnTeam(mActorOwner.team,_loc3_.team,_loc4_.Team))
         {
            return true;
         }
         if(_loc4_.LineOfSightReq && didAttackGoThroughWall(mDBFacade,mActorOwner.worldCenterAsb2Vec2,_loc3_,fixture.GetBody().GetPosition(),mDistributedDungeonFloor,mShowColliders))
         {
            return true;
         }
         if(_loc4_.AffectsOthers && mActorOwner.id != _loc3_.id || _loc4_.AffectsSelf && mActorOwner.id == _loc3_.id)
         {
            if(!_loc4_.AffectsProps && _loc3_.isProp)
            {
               return true;
            }
            if(passesRecurringHitCheck(_loc2_))
            {
               hitActor(_loc3_);
               registerHitActor(_loc2_);
               if(_loc4_.AttackOnHit != null)
               {
                  if(mActorOwner.isOwner)
                  {
                     _loc5_ = mActorOwner as HeroGameObjectOwner;
                     _loc5_.doAttackOnHit(_loc4_.AttackOnHit,this.mWeapon);
                  }
               }
            }
            return true;
         }
         return true;
      }
      
      private function registerHitActor(actorId:uint) : void
      {
         if(!mCurrentHitMap.hasKey(actorId))
         {
            mCurrentHitMap.add(actorId,mHitDelayPerObject);
         }
         else
         {
            mCurrentHitMap.replaceFor(actorId,mHitDelayPerObject);
         }
      }
      
      private function passesRecurringHitCheck(actorId:uint) : Boolean
      {
         if(mCurrentHitMap.hasKey(actorId) && mCurrentHitMap.itemFor(actorId) > 0)
         {
            return false;
         }
         return true;
      }
      
      private function hitActor(actorGameObject:ActorGameObject) : void
      {
         var _loc6_:GMAttack = mDBFacade.gameMaster.attackById.itemFor(mAttackType);
         if(_loc6_ == null)
         {
            Logger.error("No GMAttack found for attack type: " + mAttackType);
            return;
         }
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc2_:int = 0;
         if(mWeapon != null)
         {
            _loc4_ = mWeapon.power;
            _loc5_ = mWeapon.weaponType;
            _loc2_ = mWeapon.slot;
         }
         var _loc7_:CombatResult = new CombatResult();
         _loc7_.attacker = mActorOwner.id;
         _loc7_.attackee = actorGameObject.id;
         _loc7_.when = mTimelineFrame;
         _loc7_.generation = 0;
         var _loc3_:Attack = new Attack();
         _loc3_.attackType = mAttackType;
         _loc3_.weaponSlot = _loc2_;
         _loc3_.isConsumableWeapon = mWeapon && mWeapon.isConsumable() ? 1 : 0;
         if(actorGameObject.isBlocking && !_loc6_.Unblockable)
         {
            if(blockCheck(actorGameObject.getHeadingAsVector(),actorGameObject.maximumDotForBlocking,actorGameObject.worldCenter,mActorOwner.worldCenter))
            {
               _loc7_.blocked = 1;
            }
         }
         else
         {
            _loc7_.blocked = 0;
         }
         if(_loc7_.blocked == 0)
         {
            if(actorGameObject.hasAbility(1))
            {
               _loc7_.suffer = 0;
            }
            else
            {
               _loc7_.suffer = Math.random() <= _loc6_.StunChance ? 1 : 0;
            }
            if(_loc7_.suffer == 1)
            {
               if(_loc6_.Knockback != 0)
               {
                  _loc7_.knockback = 1;
               }
            }
         }
         _loc7_.attack = _loc3_;
         if(mCombatResultCallback != null)
         {
            mCombatResultCallback(_loc7_);
         }
      }
      
      private function getNPCs() : Vector.<NPCGameObject>
      {
         var _loc4_:Tile = null;
         var _loc5_:IIterator = null;
         var _loc1_:NPCGameObject = null;
         var _loc3_:Vector.<NPCGameObject> = new Vector.<NPCGameObject>();
         var _loc2_:TileGridIterator = mDistributedDungeonFloor.tileGrid.iterator(true);
         while(_loc2_.hasNext())
         {
            _loc4_ = _loc2_.next();
            _loc5_ = _loc4_.NPCGameObjects.iterator();
            while(_loc5_.hasNext())
            {
               _loc1_ = _loc5_.next();
               _loc3_.push(_loc1_);
            }
         }
         return _loc3_;
      }
      
      override public function destroy() : void
      {
         mActorOwner = null;
         if(mCombatCollider)
         {
            mCombatCollider.destroy();
            mCombatCollider = null;
         }
         mCombatResults = null;
         super.destroy();
      }
      
      private function updateRecurringHits() : void
      {
         var _loc1_:IMapIterator = mCurrentHitMap.iterator() as IMapIterator;
         while(_loc1_.next())
         {
            mCurrentHitMap.replaceFor(_loc1_.key,mCurrentHitMap.itemFor(_loc1_.key) - 1);
         }
      }
      
      public function perFrameUpCall(timelineFrame:uint) : void
      {
         updateRecurringHits();
         doCollisions(timelineFrame);
         mLifeTime = mLifeTime - 1;
      }
      
      public function isAlive() : Boolean
      {
         return mLifeTime > 0;
      }
   }
}

