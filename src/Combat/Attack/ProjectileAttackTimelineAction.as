package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Utils.MathUtil;
   import Brain.Utils.MemoryTracker;
   import Combat.Weapon.WeaponGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import Projectile.ChainProjectileGameObject;
   import Projectile.ProjectileGameObject;
   import flash.geom.Vector3D;
   
   public class ProjectileAttackTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "projectile";
      
      protected var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      protected var mEffectObject:Object;
      
      private var mWeaponGameObject:WeaponGameObject;
      
      protected var mCombatResultCallback:Function;
      
      public function ProjectileAttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, weaponGameObject:WeaponGameObject, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, actionObj:Object, combatResultCallback:Function = null)
      {
         super(actorGameObject,actorView,dbFacade);
         mDistributedDungeonFloor = distributedDungeonFloor;
         mEffectObject = actionObj;
         mWeaponGameObject = weaponGameObject;
         mCombatResultCallback = combatResultCallback;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, actionObj:Object, weapon:WeaponGameObject, combatResultCallback:Function = null) : ProjectileAttackTimelineAction
      {
         return new ProjectileAttackTimelineAction(actorGameObject,actorView,weapon,dbFacade,distributedDungeonFloor,actionObj,combatResultCallback);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         var _loc18_:ProjectileGameObject = null;
         var _loc19_:AttackTimeline = null;
         var _loc7_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc8_:int = 0;
         super.execute(timeline);
         var _loc17_:Boolean = Boolean(mEffectObject.dontRotate ?? false);
         var _loc11_:Number = Number(mEffectObject.headingOffset ?? 0);
         var _loc12_:Number = Number(mEffectObject.headingOffsetAngle ?? 0);
         var _loc6_:Number = Number(mEffectObject.headingRandomnessAngle ?? 0);
         _loc12_ += MathUtil.rand(-_loc6_,_loc6_);
         var _loc20_:Number = Number(mEffectObject.startingAngleOffset ?? 0);
         var _loc15_:Number = mWeaponGameObject != null ? mWeaponGameObject.collisionScale() : 1;
         var _loc3_:Number = Number(mEffectObject.xOffset ?? 0);
         _loc3_ *= _loc15_;
         var _loc2_:Number = Number(mEffectObject.yOffset ?? 0);
         _loc2_ *= _loc15_;
         var _loc5_:Number = mActorGameObject.heading;
         var _loc9_:Vector3D = mActorGameObject.getHeadingAsVector(_loc12_);
         var _loc14_:Vector3D = mActorGameObject.worldCenter;
         var _loc10_:Vector3D = mActorGameObject.projectileLaunchOffset;
         var _loc4_:Vector3D = calculateHeadingOffset(_loc11_,_loc5_,_loc12_);
         _loc14_.x += _loc4_.x + _loc3_;
         _loc14_.y += _loc4_.y + _loc2_;
         _loc10_.x += _loc4_.x;
         _loc10_.y += _loc4_.y;
         var _loc13_:Boolean = timeline.autoAim;
         if(timeline is AttackTimeline)
         {
            _loc19_ = timeline as AttackTimeline;
            _loc7_ = 1;
            _loc16_ = _loc12_;
            _loc8_ = 0;
            while(_loc8_ < _loc19_.projectileMultiplier)
            {
               _loc7_ = _loc8_ % 2 == 0 ? 1 : -1;
               _loc12_ = (_loc16_ + _loc19_.projectileScalingAngle * (int((_loc8_ + 1) / 2))) * _loc7_;
               _loc9_ = mActorGameObject.getHeadingAsVector(_loc12_);
               _loc18_ = new ChainProjectileGameObject(this.mDBFacade,mActorGameObject.id,mActorGameObject.team,mAttackType,mWeaponGameObject,mDistributedDungeonFloor,_loc14_,_loc9_,_loc10_,_loc19_.distanceScalingProjectile,0,null,mEffectObject,mCombatResultCallback,_loc13_,_loc17_);
               MemoryTracker.track(_loc18_,"ChainProjectileGameObject - created in ProjectileAttackTimelineAction.execute()");
               _loc18_.distributedDungeonFloor = mDistributedDungeonFloor;
               _loc8_++;
            }
         }
         else
         {
            _loc18_ = new ChainProjectileGameObject(this.mDBFacade,mActorGameObject.id,mActorGameObject.team,mAttackType,mWeaponGameObject,mDistributedDungeonFloor,_loc14_,_loc9_,_loc10_,0,0,null,mEffectObject,mCombatResultCallback,_loc13_,_loc17_);
            MemoryTracker.track(_loc18_,"ChainProjectileGameObject - created in ProjectileAttackTimelineAction.execute()");
            _loc18_.distributedDungeonFloor = mDistributedDungeonFloor;
         }
      }
      
      public function calculateHeadingOffset(offset:Number, heading:Number, angleAddition:Number = 0) : Vector3D
      {
         heading += angleAddition;
         if(heading < 0)
         {
            heading = 360 + heading;
         }
         heading = heading * 3.141592653589793 / 180;
         var _loc4_:Vector3D = new Vector3D(0,0,0);
         _loc4_.x = offset * Math.cos(heading);
         _loc4_.y = offset * Math.sin(heading);
         return _loc4_;
      }
      
      override public function destroy() : void
      {
         mWeaponGameObject = null;
         mDistributedDungeonFloor = null;
         mEffectObject = null;
         super.destroy();
      }
   }
}

