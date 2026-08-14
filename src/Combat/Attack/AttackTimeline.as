package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Combat.Weapon.WeaponGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Effects.ChargeEffectGameObject;
   import Effects.EffectGameObject;
   import Facade.DBFacade;
   import GeneratedCode.AttackChoreography;
   import GeneratedCode.CombatResult;
   import org.as3commons.collections.LinkedList;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class AttackTimeline extends ScriptTimeline
   {
      
      protected var mCombatResultActions:Map;
      
      protected var mAttackName:String;
      
      protected var mWeapon:WeaponGameObject;
      
      protected var mChoreographed:Boolean;
      
      private var mRegisteredEffects:Map;
      
      private var mChargeEffect:ChargeEffectGameObject;
      
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
         mRegisteredEffects = new Map();
         mAttackName = attackJson.attackName;
         mChoreographed = attackJson.choreographed;
      }
      
      override public function destroy() : void
      {
         this.cleanUpRegisteredEffects();
         mRegisteredEffects.clear();
         mRegisteredEffects = null;
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
         if(_loc2_ >= _loc1_)
         {
            return true;
         }
         return false;
      }
      
      override protected function parseAction(actionObj:Object) : AttackTimelineAction
      {
         var _loc3_:String = actionObj.type as String;
         var _loc2_:AttackTimelineAction = null;
         switch(_loc3_)
         {
            case "attackEffect":
               _loc2_ = PlayEffectAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,mDistributedDungeonFloor,actionObj,mWeapon,registerEffect);
               break;
            case "projectile":
               _loc2_ = ProjectileAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,mDistributedDungeonFloor,actionObj,mWeapon);
               break;
            case "automove":
               _loc2_ = AutoMoveTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade);
               break;
            case "attackautomove":
               _loc2_ = AttackAutoMoveTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade);
               break;
            case "block":
               _loc2_ = BlockAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            default:
               return super.parseAction(actionObj);
         }
         return _loc2_;
      }
      
      override protected function processTimelineActions(frame:int, gameClock:GameClock) : void
      {
         super.processTimelineActions(frame,gameClock);
         processTimelineFrame(mCombatResultActions,frame,gameClock);
      }
      
      override public function stop() : void
      {
         super.stop();
         cleanUpRegisteredEffects();
      }
      
      private function cleanUpRegisteredEffects() : void
      {
         var _loc2_:EffectGameObject = null;
         var _loc1_:IMapIterator = mRegisteredEffects.iterator() as IMapIterator;
         while(_loc1_.next())
         {
            _loc2_ = _loc1_.current as EffectGameObject;
            _loc2_.destroy();
         }
         mRegisteredEffects.clear();
         if(mChargeEffect)
         {
            mChargeEffect.destroy();
            mChargeEffect = null;
         }
      }
      
      public function appendChoreography(attackChoreography:AttackChoreography) : void
      {
         var _loc2_:CombatResultAttackTimelineAction = null;
         var _loc4_:LinkedList = null;
         var _loc5_:* = 0;
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
      
      public function registerEffect(effectGameObject:EffectGameObject) : void
      {
         if(effectGameObject is ChargeEffectGameObject)
         {
            if(mChargeEffect != null)
            {
               Logger.error("Trying to register more than one charge effect on timeline.");
               mRegisteredEffects.removeKey(mChargeEffect.id);
               mChargeEffect.destroy();
               mChargeEffect = null;
               return;
            }
            mChargeEffect = effectGameObject as ChargeEffectGameObject;
         }
         mRegisteredEffects.add(effectGameObject.id,effectGameObject);
      }
      
      public function get chargeEffect() : ChargeEffectGameObject
      {
         return mChargeEffect;
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

