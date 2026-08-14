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
   
   public class RectangleColliderTimelineAction extends ColliderTimelineAction
   {
      
      public static const TYPE:String = "rectangleCollider";
      
      private var mHalfWidth:Number;
      
      private var mHalfHeight:Number;
      
      private var mRotation:Number;
      
      public function RectangleColliderTimelineAction(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, combatResultCallback:Function, headingOffset:Vector3D, globalOffset:Vector3D, halfWidth:Number, halfHeight:Number, rotation:Number, lifeTime:uint, hitDelayPerObject:uint)
      {
         mHalfWidth = halfWidth;
         mHalfHeight = halfHeight;
         mRotation = rotation;
         super(weapon,actorGameObject,actorView,dbFacade,distributedDungeonFloor,combatResultCallback,headingOffset,globalOffset,lifeTime,hitDelayPerObject);
      }
      
      public static function buildFromJson(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, actionObj:Object, combatResultCallback:Function) : RectangleColliderTimelineAction
      {
         var _loc17_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc14_:Vector3D = null;
         var _loc13_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc15_:Vector3D = null;
         var _loc18_:* = 0;
         var _loc19_:* = 0;
         if(actorGameObject.isOwner)
         {
            _loc17_ = weapon != null ? weapon.collisionScale() : 1;
            _loc10_ = actionObj.halfHeight * _loc17_;
            _loc16_ = actionObj.halfWidth * _loc17_;
            _loc11_ = Number(actionObj.rotation);
            _loc9_ = 0;
            if(actionObj.xOffset != null)
            {
               _loc9_ = actionObj.xOffset * _loc17_;
            }
            _loc8_ = 0;
            if(actionObj.yOffset != null)
            {
               _loc8_ = actionObj.yOffset * _loc17_;
            }
            _loc14_ = new Vector3D(_loc9_,_loc8_);
            _loc13_ = 0;
            if(actionObj.xGlobalOffset != null)
            {
               _loc13_ = actionObj.xGlobalOffset * _loc17_;
            }
            _loc12_ = 0;
            if(actionObj.yGlobalOffset != null)
            {
               _loc12_ = actionObj.yGlobalOffset * _loc17_;
            }
            _loc15_ = new Vector3D(_loc13_,_loc12_);
            _loc18_ = 1;
            if(actionObj.lifeTime != null)
            {
               _loc18_ = uint(actionObj.timeToLive);
            }
            _loc19_ = 0;
            if(actionObj.hitDelayPerObject != null)
            {
               _loc19_ = uint(actionObj.hitDelayPerObject);
            }
            return new RectangleColliderTimelineAction(weapon,actorGameObject,actorView,dbFacade,distributedDungeonFloor,combatResultCallback,_loc14_,_loc15_,_loc16_,_loc10_,_loc11_,_loc18_,_loc19_);
         }
         return null;
      }
      
      override protected function buildCombatGameObject(lifetime:uint, hitDelayPerObj:uint) : CombatGameObject
      {
         var _loc4_:RectangleCombatCollider = new RectangleCombatCollider(mDBFacade,mActorGameObject,mDistributedDungeonFloor.box2DWorld,mHalfWidth,mHalfHeight,mActorGameObject.heading,mRotation);
         var _loc3_:CombatGameObject = new CombatGameObject(mDBFacade,mActorGameObject,mAttackType,mWeapon,mDistributedDungeonFloor,_loc4_,lifetime,hitDelayPerObj,mCombatResultCallback);
         MemoryTracker.track(_loc3_,"CombatGameObject - created in RectangleColliderTimelineAction.buildCombatGameObject()");
         return _loc3_;
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

