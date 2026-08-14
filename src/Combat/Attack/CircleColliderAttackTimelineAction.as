package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Utils.MemoryTracker;
   import Combat.CombatGameObject;
   import Combat.Weapon.WeaponGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class CircleColliderAttackTimelineAction extends ColliderTimelineAction
   {
      
      public static const TYPE:String = "circleCollider";
      
      protected var mRadius:Number;
      
      public function CircleColliderAttackTimelineAction(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, combatResultCallback:Function, radius:Number, headingOffset:Vector3D, globalOffset:Vector3D, lifeTime:uint, hitDelayPerObject:uint)
      {
         mRadius = radius;
         super(weapon,actorGameObject,actorView,dbFacade,distributedDungeonFloor,combatResultCallback,headingOffset,globalOffset,lifeTime,hitDelayPerObject);
      }
      
      public static function buildFromJson(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, actionObj:Object, combatResultCallback:Function) : CircleColliderAttackTimelineAction
      {
         var _loc14_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc10_:Vector3D = null;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc13_:Vector3D = null;
         var _loc15_:* = 0;
         var _loc17_:* = 0;
         if(actorGameObject.isOwner)
         {
            _loc14_ = weapon != null ? weapon.collisionScale() : 1;
            _loc16_ = actionObj.radius * _loc14_;
            _loc12_ = 0;
            if(actionObj.xOffset != null)
            {
               _loc12_ = actionObj.xOffset * _loc14_;
            }
            _loc11_ = 0;
            if(actionObj.yOffset != null)
            {
               _loc11_ = actionObj.yOffset * _loc14_;
            }
            _loc10_ = new Vector3D(_loc12_,_loc11_);
            _loc9_ = 0;
            if(actionObj.xGlobalOffset != null)
            {
               _loc9_ = actionObj.xGlobalOffset * _loc14_;
            }
            _loc8_ = 0;
            if(actionObj.yGlobalOffset != null)
            {
               _loc8_ = actionObj.yGlobalOffset * _loc14_;
            }
            _loc13_ = new Vector3D(_loc9_,_loc8_);
            _loc15_ = 1;
            if(actionObj.lifeTime != null)
            {
               _loc15_ = uint(actionObj.lifeTime);
            }
            _loc17_ = 0;
            if(actionObj.hitDelayPerObject != null)
            {
               _loc17_ = uint(actionObj.hitDelayPerObject);
            }
            return new CircleColliderAttackTimelineAction(weapon,actorGameObject,actorView,dbFacade,distributedDungeonFloor,combatResultCallback,_loc16_,_loc10_,_loc13_,_loc15_,_loc17_);
         }
         return null;
      }
      
      override protected function buildCombatGameObject(lifetime:uint, hitDelayPerObj:uint) : CombatGameObject
      {
         var _loc3_:CircleCombatCollider = new CircleCombatCollider(mDBFacade,mActorGameObject,mDistributedDungeonFloor.box2DWorld,mRadius);
         var _loc4_:CombatGameObject = new CombatGameObject(mDBFacade,mActorGameObject,mAttackType,mWeapon,mDistributedDungeonFloor,_loc3_,lifetime,hitDelayPerObj,mCombatResultCallback);
         MemoryTracker.track(_loc4_,"CombatGameObject - created in CircleColliderAttackTimelineAction.buildCombatGameObject()");
         return _loc4_;
      }
      
      override public function destroy() : void
      {
         mWeapon = null;
         mDistributedDungeonFloor = null;
         mCombatGameObject.destroy();
         super.destroy();
      }
   }
}

