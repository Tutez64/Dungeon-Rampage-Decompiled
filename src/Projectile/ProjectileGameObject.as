package Projectile
{
   import Actor.ActorGameObject;
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2FilterData;
   import Box2D.Dynamics.b2Fixture;
   import Box2D.Dynamics.b2FixtureDef;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Collision.IContactResolver;
   import Combat.CombatGameObject;
   import Combat.Weapon.WeaponGameObject;
   import DBGlobals.DBGlobal;
   import DistributedObjects.DistributedDungeonFloor;
   import DistributedObjects.HeroGameObjectOwner;
   import Dungeon.NavCollider;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import Floor.FloorView;
   import GameMasterDictionary.GMAttack;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMProjectile;
   import flash.geom.Vector3D;
   
   public class ProjectileGameObject extends FloorObject implements IContactResolver
   {
      
      protected var mProjectileView:ProjectileView;
      
      protected var mNumCollisions:uint = 0;
      
      private var mStartPosition:Vector3D;
      
      private var mVelocity:Vector3D = new Vector3D();
      
      private var mAngularVelocity:Number;
      
      private var mDontRotate:Boolean = false;
      
      protected var mFlightComponent:FlightComponent;
      
      protected var mCollisionComponent:CollisionComponent;
      
      protected var mUseRange:Boolean;
      
      protected var mGMAttack:GMAttack;
      
      protected var mGMProjectile:GMProjectile;
      
      protected var mParentActorId:uint;
      
      protected var mParentActorTeam:uint;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mFinishedCallback:Function;
      
      protected var mEffectName:String;
      
      protected var mEffectPath:String;
      
      protected var mEffectTimeOffset:Number;
      
      protected var mB2Body:b2Body;
      
      protected var mB2Fixture:b2Fixture;
      
      protected var mAttackType:uint;
      
      protected var mVisualOffset:Vector3D;
      
      protected var mCollisionScale:Number;
      
      private var mIsAlive:Boolean = true;
      
      protected var mWeaponGameObject:WeaponGameObject;
      
      protected var mCombatResultCallback:Function;
      
      protected var mEffectObject:Object;
      
      protected var mUpdateTask:Task;
      
      private var mLastHitActor:Boolean = false;
      
      private var mLastHitWall:Boolean = false;
      
      protected var mRange:Number = 0;
      
      public function ProjectileGameObject(dbFacade:DBFacade, actorId:uint, actorTeam:uint, attackType:uint, weapon:WeaponGameObject, distDungeonfloor:DistributedDungeonFloor, collisionPosition:Vector3D, directionVector:Vector3D, visualOffset:Vector3D, range:Number = 0, effectObject:Object = null, combatResultCallback:Function = null, autoAim:Boolean = true, dontRotate:Boolean = false, generation:uint = 0)
      {
         mCombatResultCallback = combatResultCallback;
         mAttackType = attackType;
         mGMAttack = dbFacade.gameMaster.attackById.itemFor(attackType);
         if(mGMAttack == null)
         {
            Logger.error("Unable to find GMAttack record for attack type: " + attackType);
         }
         mGMProjectile = dbFacade.gameMaster.projectileByConstant.itemFor(mGMAttack.Projectile);
         if(mGMProjectile == null)
         {
            Logger.error("No projectile defined for attack type: " + attackType);
         }
         mEffectObject = effectObject;
         if(mEffectObject != null)
         {
            mEffectName = mEffectObject.attackEffectName;
            mEffectPath = mEffectObject.attackEffectPath;
            mEffectTimeOffset = mEffectObject.attackEffectTimeOffset;
            if(!mEffectTimeOffset)
            {
               mEffectTimeOffset = 0;
            }
         }
         mDontRotate = dontRotate;
         mCollisionScale = weapon != null ? weapon.collisionScale() : 1;
         mRange = range == 0 ? mGMProjectile.Range : range;
         super(dbFacade);
         this.layer = mGMProjectile.NoFade == true ? 46 : 20;
         if(mEffectObject.layer == "foreground")
         {
            this.layer = 30;
         }
         else if(mEffectObject.layer == "background")
         {
            this.layer = 10;
         }
         else if(mEffectObject.layer == "sorted")
         {
            this.layer = 20;
         }
         distributedDungeonFloor = distDungeonfloor;
         mWeaponGameObject = weapon;
         var _loc22_:uint = 0;
         var _loc23_:uint = 0;
         if(weapon != null)
         {
            _loc22_ = weapon.power;
            _loc23_ = weapon.weaponType;
         }
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"ProjectileGameObject");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mParentActorId = actorId;
         mParentActorTeam = actorTeam;
         mVisualOffset = visualOffset;
         var _loc16_:Vector3D = new Vector3D();
         mUpdateTask = mLogicalWorkComponent.doEveryFrame(update);
         var _loc19_:b2FixtureDef = new b2FixtureDef();
         _loc19_.isSensor = true;
         var _loc17_:b2CircleShape = new b2CircleShape(mGMProjectile.CollisionSize * mCollisionScale / 50);
         _loc19_.shape = _loc17_;
         var _loc20_:b2FilterData = new b2FilterData();
         _loc20_.categoryBits = 2;
         _loc20_.maskBits = 0;
         _loc20_.groupIndex = -1;
         if(mGMProjectile.CollisionSize > 0)
         {
            switch(mGMAttack.Team)
            {
               case "FRIENDLY":
                  _loc20_.maskBits |= DBGlobal.b2dMaskForTeam(mParentActorTeam);
                  break;
               case "HOSTILE":
                  _loc20_.maskBits |= DBGlobal.b2dMaskForAllTeamsBut(mParentActorTeam);
            }
         }
         _loc20_.maskBits |= 1;
         _loc19_.filter = _loc20_;
         _loc19_.isSensor = true;
         _loc19_.userData = this.id;
         var _loc18_:b2BodyDef = new b2BodyDef();
         _loc18_.userData = this.id;
         _loc18_.type = b2Body.b2_dynamicBody;
         mB2Body = mDistributedDungeonFloor.box2DWorld.CreateBody(_loc18_);
         mB2Fixture = mB2Body.CreateFixture(_loc19_);
         this.position = collisionPosition.add(visualOffset);
         var _loc21_:ActorGameObject = mDistributedDungeonFloor.getActor(mParentActorId);
         mUseRange = true;
         mVelocity = directionVector;
         switch(mGMProjectile.FlightPattern)
         {
            case "HOMING":
               mFlightComponent = new HomingFlightComponent(collisionPosition,directionVector,this,mParentActorId,dbFacade,mDistributedDungeonFloor,mGMAttack.Team == "FRIENDLY",applySteeringVector);
               if(weapon == null)
               {
                  mCollisionComponent = new CollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,0,0,true,generation);
               }
               else
               {
                  mCollisionComponent = new CollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,weapon.slot,weapon.pierces(),true,generation);
               }
               break;
            case "BOOMERANG":
               mUseRange = false;
               mFlightComponent = new BoomerangFlightComponent(collisionPosition,directionVector,this,mParentActorId,dbFacade,mDistributedDungeonFloor,mGMAttack.Team == "FRIENDLY",applySteeringVector);
               if(weapon == null)
               {
                  mCollisionComponent = new BounceBackCollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,0,0);
               }
               else
               {
                  mCollisionComponent = new BounceBackCollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,weapon.slot,weapon.pierces());
               }
               break;
            case "ORBITER":
               mUseRange = false;
               mFlightComponent = new OrbiterFlightComponent(collisionPosition,directionVector,this,mParentActorId,dbFacade,mDistributedDungeonFloor,mGMAttack.Team == "FRIENDLY",applySteeringVector);
               if(weapon == null)
               {
                  mCollisionComponent = new BounceBackCollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,0,0);
               }
               else
               {
                  mCollisionComponent = new BounceBackCollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,weapon.slot,weapon.pierces());
               }
               break;
            default:
               if(weapon == null)
               {
                  mCollisionComponent = new CollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,0,0,true);
               }
               else
               {
                  mCollisionComponent = new CollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,weapon.slot,weapon.pierces(),true,generation);
               }
               if(_loc21_ is HeroGameObjectOwner && autoAim && mGMAttack.UseAutoAim)
               {
                  mFlightComponent = new AutoAimFlightComponent(collisionPosition,directionVector,this,mParentActorId,dbFacade,mDistributedDungeonFloor,mGMAttack.Team == "FRIENDLY",applySteeringVector);
               }
               else
               {
                  mFlightComponent = new FlightComponent(collisionPosition,directionVector,this,mParentActorId,dbFacade,mDistributedDungeonFloor,mGMAttack.Team == "FRIENDLY",applySteeringVector);
                  mVelocity = directionVector;
               }
         }
         mVelocity.scaleBy(mGMProjectile.ProjSpeedF);
         mStartPosition = mPosition.clone();
         mAngularVelocity = mGMProjectile.RotationSpeedF;
         mB2Body.SetPosition(NavCollider.convertToB2Vec2(collisionPosition.clone()));
         mB2Body.SetLinearVelocity(NavCollider.convertToB2Vec2(mVelocity));
         this.init();
      }
      
      public function get weapon() : WeaponGameObject
      {
         return mWeaponGameObject;
      }
      
      public function get team() : uint
      {
         return mParentActorTeam;
      }
      
      public function get effectName() : String
      {
         return mEffectName;
      }
      
      public function get effectPath() : String
      {
         return mEffectPath;
      }
      
      public function get effectTimeOffset() : Number
      {
         return mEffectTimeOffset;
      }
      
      public function get velocity() : Vector3D
      {
         return mVelocity;
      }
      
      public function set velocity(newVelocity:Vector3D) : void
      {
         mVelocity = newVelocity;
      }
      
      public function get rotationSpeed() : Number
      {
         return mAngularVelocity;
      }
      
      public function set rotationSpeed(newSpeed:Number) : void
      {
         mAngularVelocity = newSpeed;
      }
      
      public function get gmProjectile() : GMProjectile
      {
         return mGMProjectile;
      }
      
      public function get gmAttack() : GMAttack
      {
         return mGMAttack;
      }
      
      public function get shouldRotate() : Boolean
      {
         return !mDontRotate;
      }
      
      private function update(gameClock:GameClock) : void
      {
         if(!distributedDungeonFloor.isAlive())
         {
            destroy();
            return;
         }
         var _loc2_:Vector3D = NavCollider.convertToVector3D(mB2Body.GetPosition());
         _loc2_ = _loc2_.add(mVisualOffset);
         this.position = _loc2_;
         mProjectileView.position = _loc2_;
         if(!checkIfDone())
         {
            applyFlightPattern(_loc2_);
         }
      }
      
      private function applyFlightPattern(pos:Vector3D) : void
      {
         if(mGMProjectile != null && mFlightComponent != null)
         {
            mFlightComponent.update();
         }
         else if(!mGMProjectile)
         {
            Logger.error("!mGMProjectile");
         }
         else if(!mFlightComponent)
         {
            Logger.error("!mFlightComponent");
         }
      }
      
      private function applySteeringVector(steer_vector:Vector3D) : void
      {
         mVelocity = mVelocity.add(steer_vector);
         var _loc2_:Number = mVelocity.length;
         var _loc3_:Number = Math.min(_loc2_,mGMProjectile.ProjSpeedF);
         mVelocity.scaleBy(_loc3_ / _loc2_);
         mB2Body.SetLinearVelocity(NavCollider.convertToB2Vec2(mVelocity));
      }
      
      protected function checkIfDone() : Boolean
      {
         if(mCollisionComponent.markedForDeletion() || mUseRange && Vector3D.distance(this.position,mStartPosition) >= mRange)
         {
            this.destroy();
            return true;
         }
         return false;
      }
      
      override protected function buildView() : void
      {
         mProjectileView = new ProjectileView(mDBFacade,this);
         MemoryTracker.track(mProjectileView,"ProjectileView - created in ProjectileGameObject.buildView()");
         this.view = mProjectileView as FloorView;
      }
      
      public function set rotation(newRotation:Number) : void
      {
         mProjectileView.setRotation(newRotation);
      }
      
      public function enterContact(actorId:uint) : void
      {
         if(!mIsAlive)
         {
            return;
         }
         var _loc2_:ActorGameObject = mDBFacade.gameObjectManager.getReferenceFromId(actorId) as ActorGameObject;
         if(_loc2_ == null)
         {
            if(!gmProjectile.IgnoreWalls)
            {
               mCollisionComponent.hitWall();
            }
         }
         else if(_loc2_.id != mParentActorId)
         {
            if(!_loc2_.isAttackable)
            {
               if(!gmProjectile.IgnoreWalls)
               {
                  mCollisionComponent.hitWall();
               }
            }
            else if(CombatGameObject.determineIfHitBasedOnTeam(mParentActorTeam,_loc2_.team,mGMAttack.Team))
            {
               hitActor(_loc2_);
            }
         }
         if(mIsAlive && mCollisionComponent.updatedVelocity)
         {
            mB2Body.SetLinearVelocity(NavCollider.convertToB2Vec2(mVelocity));
         }
      }
      
      protected function hitActor(actor:ActorGameObject) : Boolean
      {
         return mCollisionComponent.hitActor(actor);
      }
      
      public function exitContact(actorId:uint) : void
      {
         if(mCollisionComponent)
         {
            mCollisionComponent.exitContact(actorId);
         }
      }
      
      public function onHitWall() : void
      {
         mLastHitActor = false;
         mLastHitWall = true;
      }
      
      public function onHitActor(actor:ActorGameObject) : void
      {
         var _loc2_:HeroGameObjectOwner = null;
         mLastHitActor = false;
         if(mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) is HeroGameObjectOwner)
         {
            _loc2_ = mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) as HeroGameObjectOwner;
            if(actor.team != _loc2_.team)
            {
               mLastHitActor = true;
            }
         }
         mFlightComponent.informOfHit(actor);
         mLastHitWall = false;
      }
      
      private function setTeleDest() : void
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) is HeroGameObjectOwner)
         {
            if(mLastHitActor && mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) is HeroGameObjectOwner)
            {
               _loc1_ = mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) as HeroGameObjectOwner;
               _loc1_.setTeleDest(position);
            }
         }
      }
      
      private function doAttackOnHit() : void
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(mLastHitActor && mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) is HeroGameObjectOwner)
         {
            _loc1_ = mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) as HeroGameObjectOwner;
            _loc1_.doAttackOnHit(mGMAttack.AttackOnHit,mWeaponGameObject);
         }
      }
      
      override public function destroy() : void
      {
         var _loc2_:GMNpc = null;
         var _loc3_:HeroGameObjectOwner = null;
         if(mGMAttack.SetTeleport)
         {
            setTeleDest();
         }
         if(mGMAttack.AttackOnHit)
         {
            doAttackOnHit();
         }
         var _loc1_:ActorGameObject = mDistributedDungeonFloor.getActor(mParentActorId);
         if(_loc1_ && _loc1_.isOwner && mGMProjectile && mGMProjectile.OnDeathNPC)
         {
            _loc2_ = mDBFacade.gameMaster.npcByConstant.itemFor(mGMProjectile.OnDeathNPC);
            _loc3_ = _loc1_ as HeroGameObjectOwner;
            _loc3_.ProposeCreateNPC(_loc2_.Id,this.weapon.slot,position.x,position.y);
         }
         mIsAlive = false;
         mWeaponGameObject = null;
         mFinishedCallback = null;
         mCombatResultCallback = null;
         mEffectObject = null;
         mStartPosition = null;
         mProjectileView = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         if(mFlightComponent)
         {
            mFlightComponent.destroy();
            mFlightComponent = null;
         }
         mDistributedDungeonFloor.box2DWorld.DestroyBody(mB2Body);
         mB2Body.SetUserData(null);
         mB2Body.GetDefinition().userData = null;
         mB2Fixture.SetUserData(null);
         mB2Body.DestroyFixture(mB2Fixture);
         mB2Fixture = null;
         mB2Body = null;
         if(mUpdateTask)
         {
            mUpdateTask.destroy();
            mUpdateTask = null;
         }
         if(mCollisionComponent)
         {
            mCollisionComponent.destroy();
            mCollisionComponent = null;
         }
         super.destroy();
      }
      
      public function get parentActorSkinId() : uint
      {
         var _loc1_:ActorGameObject = mDistributedDungeonFloor.getActor(mParentActorId);
         if(_loc1_ && _loc1_.gmSkin)
         {
            return _loc1_.gmSkin.Id;
         }
         return 0;
      }
   }
}

