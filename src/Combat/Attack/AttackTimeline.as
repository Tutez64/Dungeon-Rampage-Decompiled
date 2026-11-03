package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Clock.GameClock;
   import Collections.LinkedList;
   import Collections.Map;
   import Combat.Weapon.WeaponGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import GeneratedCode.AttackChoreography;
   import GeneratedCode.CombatResult;
   
   public class AttackTimeline extends ScriptTimeline
   {
      
      protected var mCombatResultActions:Map;
      
      protected var mAttackName:String;
      
      protected var mWeapon:WeaponGameObject;
      
      protected var mChoreographed:Boolean;
      
      protected var mPowerMultiplier:Number = 1;
      
      protected var mProjectileMultiplier:uint = 1;
      
      protected var mProjectileScalingAngle:Number = 20;
      
      protected var mDistanceScalingTime:Number = 0;
      
      protected var mDistanceScalingForHero:Number = 0;
      
      protected var mDistanceScalingForProjectiles:Number = 0;
      
      public function AttackTimeline(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, attackJson:Object, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor)
      {
         mWeapon = weapon;
         super(actorGameObject,actorView,attackJson,dbFacade,distributedDungeonFloor);
         mCombatResultActions = new Map();
         mAttackName = attackJson.attackName;
         mChoreographed = attackJson.choreographed;
      }
      
      override public function destroy() : void
      {
         mCombatResultActions.clear();
         mCombatResultActions = null;
         mWeapon = null;
         super.destroy();
      }
      
      public function get weapon() : WeaponGameObject
      {
         return mWeapon;
      }
      
      override public function get attackName() : String
      {
         return mAttackName;
      }
      
      public function get totalFrames() : uint
      {
         return mTotalFrames;
      }
      
      public function isAttackWithinComboWindow() : Boolean
      {
         var _loc1_:uint = currentGMAttack.ComboWindow * mTotalFrames;
         var _loc2_:uint = uint(mLastExecutedFrame);
         return _loc2_ >= _loc1_;
      }
      
      override protected function parseAction(actionObj:Object) : AttackTimelineAction
      {
         var _loc2_:String = actionObj.type as String;
         var _loc3_:AttackTimelineAction = null;
         switch(_loc2_)
         {
            case "attackEffect":
               _loc3_ = PlayEffectAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,mDistributedDungeonFloor,actionObj,mWeapon);
               break;
            case "projectile":
               _loc3_ = ProjectileAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,mDistributedDungeonFloor,actionObj,mWeapon);
               break;
            case "automove":
               _loc3_ = AutoMoveTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade);
               break;
            case "attackautomove":
               _loc3_ = AttackAutoMoveTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade);
               break;
            case "block":
               _loc3_ = BlockAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            default:
               return super.parseAction(actionObj);
         }
         return _loc3_;
      }
      
      override protected function processTimelineActions(frame:int, gameClock:GameClock) : void
      {
         super.processTimelineActions(frame,gameClock);
         processTimelineFrame(mCombatResultActions,frame,gameClock);
      }
      
      override public function stop() : void
      {
         super.stop();
      }
      
      public function appendChoreography(attackChoreography:AttackChoreography) : void
      {
         var _loc2_:CombatResultAttackTimelineAction = null;
         var _loc4_:LinkedList = null;
         var _loc5_:uint = 0;
         for each(var _loc3_:CombatResult in attackChoreography.combatResults)
         {
            _loc5_ = _loc3_.when;
            _loc2_ = new CombatResultAttackTimelineAction(mActorGameObject,mActorView,mDBFacade,_loc3_,mDistributedDungeonFloor);
            if(mCombatResultActions.hasKey(_loc5_))
            {
               _loc4_ = mCombatResultActions.itemFor(_loc5_);
               _loc4_.add(_loc2_);
            }
            else
            {
               _loc4_ = new LinkedList();
               _loc4_.add(_loc2_);
               mCombatResultActions.add(_loc5_,_loc4_);
            }
         }
      }
      
      public function set powerMultiplier(val:Number) : void
      {
         mPowerMultiplier = val;
      }
      
      public function get powerMultiplier() : Number
      {
         return mPowerMultiplier;
      }
      
      public function set projectileMultiplier(val:uint) : void
      {
         mProjectileMultiplier = val;
      }
      
      public function get projectileMultiplier() : uint
      {
         return mProjectileMultiplier;
      }
      
      public function set projectileScalingAngle(val:uint) : void
      {
         mProjectileScalingAngle = val;
      }
      
      public function get projectileScalingAngle() : uint
      {
         return mProjectileScalingAngle;
      }
      
      public function set distanceScalingTime(val:Number) : void
      {
         mDistanceScalingTime = val;
      }
      
      public function get distanceScalingTime() : Number
      {
         return mDistanceScalingTime;
      }
      
      public function set distanceScalingHero(val:Number) : void
      {
         mDistanceScalingForHero = val;
      }
      
      public function get distanceScalingHero() : Number
      {
         return mDistanceScalingForHero;
      }
      
      public function set distanceScalingProjectile(val:Number) : void
      {
         mDistanceScalingForProjectiles = val;
      }
      
      public function get distanceScalingProjectile() : Number
      {
         return mDistanceScalingForProjectiles;
      }
   }
}

