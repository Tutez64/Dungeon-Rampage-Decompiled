package Projectile
{
   import Actor.ActorGameObject;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Fixture;
   import Brain.Utils.GeometryUtil;
   import Combat.CombatGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Dungeon.NavCollider;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class AutoAimFlightComponent extends FlightComponent
   {
      
      private var mAutoAimConeStartHalfWidth:Number;
      
      private var mAutoAimConeEndHalfWidth:Number;
      
      private var mAutoAimConeLength:Number;
      
      private var mCurrentTarget:ActorGameObject;
      
      private var mBestDotProduct:Number;
      
      public function AutoAimFlightComponent(position:Vector3D, directionVector:Vector3D, projectile:ProjectileGameObject, parentActorId:uint, dbFacade:DBFacade, dungeonFloor:DistributedDungeonFloor, friendly:Boolean, applySteeringVector:Function = null)
      {
         var perpendicularToDirection:Vector3D;
         var lowConePos1:Vector3D;
         var lowConePos2:Vector3D;
         var lowConePos3:Vector3D;
         var lowConePos4:Vector3D;
         var boundingBoxPoints:Vector.<b2Vec2>;
         var boundingBoxForAutoAimShape:b2PolygonShape;
         var transform:b2Transform;
         var autoAimCallback:Function;
         var targetActor:ActorGameObject;
         var parentActor:ActorGameObject;
         super(position,directionVector,projectile,parentActorId,dbFacade,dungeonFloor,friendly,applySteeringVector);
         mAutoAimConeStartHalfWidth = mDBFacade.dbConfigManager.getConfigNumber("auto_aim_cone_start_width",80) * 0.5;
         mAutoAimConeEndHalfWidth = mDBFacade.dbConfigManager.getConfigNumber("auto_aim_cone_end_width",450) * 0.5;
         mAutoAimConeLength = mDBFacade.dbConfigManager.getConfigNumber("auto_aim_cone_length",485);
         mBestDotProduct = -1;
         perpendicularToDirection = new Vector3D(-directionVector.y,directionVector.x);
         lowConePos1 = new Vector3D(directionVector.x + perpendicularToDirection.x * mAutoAimConeStartHalfWidth,directionVector.y + perpendicularToDirection.y * mAutoAimConeStartHalfWidth);
         lowConePos2 = new Vector3D(directionVector.x + perpendicularToDirection.x * -mAutoAimConeStartHalfWidth,directionVector.y + perpendicularToDirection.y * -mAutoAimConeStartHalfWidth);
         lowConePos3 = new Vector3D(directionVector.x * mAutoAimConeLength + perpendicularToDirection.x * mAutoAimConeEndHalfWidth,directionVector.y * mAutoAimConeLength + perpendicularToDirection.y * mAutoAimConeEndHalfWidth);
         lowConePos4 = new Vector3D(directionVector.x * mAutoAimConeLength + perpendicularToDirection.x * -mAutoAimConeEndHalfWidth,directionVector.y * mAutoAimConeLength + perpendicularToDirection.y * -mAutoAimConeEndHalfWidth);
         boundingBoxPoints = new Vector.<b2Vec2>();
         boundingBoxPoints.push(NavCollider.convertToB2Vec2(lowConePos4));
         boundingBoxPoints.push(NavCollider.convertToB2Vec2(lowConePos3));
         boundingBoxPoints.push(NavCollider.convertToB2Vec2(lowConePos1));
         boundingBoxPoints.push(NavCollider.convertToB2Vec2(lowConePos2));
         boundingBoxForAutoAimShape = new b2PolygonShape();
         boundingBoxForAutoAimShape.SetAsVector(boundingBoxPoints,boundingBoxPoints.length);
         transform = new b2Transform();
         transform.position = NavCollider.convertToB2Vec2(position);
         autoAimCallback = function(param1:b2Fixture):Boolean
         {
            return targetSelectCallback(param1);
         };
         mProjectile.distributedDungeonFloor.box2DWorld.QueryShape(autoAimCallback,boundingBoxForAutoAimShape,transform);
         targetActor = mCurrentTarget;
         parentActor = mDungeonFloor.getActor(mParentActorId);
         if(targetActor != null && parentActor != null)
         {
            mProjectile.velocity = targetActor.worldCenter.subtract(parentActor.worldCenter);
         }
         else
         {
            mProjectile.velocity = directionVector;
         }
         mProjectile.velocity.normalize();
         if(mDBFacade.showCollisions || mDBFacade.dbConfigManager.getConfigBoolean("show_colliders",false))
         {
            if(mProjectile.distributedDungeonFloor.debugVisualizer != null)
            {
               mProjectile.distributedDungeonFloor.debugVisualizer.reportShape(boundingBoxForAutoAimShape,transform,48);
            }
         }
      }
      
      private function targetSelectCallback(fixture:b2Fixture) : Boolean
      {
         var _loc2_:ActorGameObject = mDungeonFloor.getActor(mParentActorId);
         if(_loc2_ == null)
         {
            return false;
         }
         var _loc4_:uint = fixture.GetBody().GetUserData() as uint;
         var _loc3_:ActorGameObject = mDBFacade.gameObjectManager.getReferenceFromId(_loc4_) as ActorGameObject;
         if(_loc3_ && _loc3_.isAttackable && !CombatGameObject.didAttackGoThroughWall(mDBFacade,_loc2_.worldCenterAsb2Vec2,_loc3_,_loc3_.worldCenterAsb2Vec2,mDungeonFloor,mDBFacade.dbConfigManager.getConfigBoolean("show_colliders",false)))
         {
            if(isTargetableTeam(_loc3_.team) && isBetterTargetThanCurrent(_loc3_))
            {
               mCurrentTarget = _loc3_;
               mBestDotProduct = calculateTargetScore(_loc3_);
            }
         }
         return true;
      }
      
      private function isBetterTargetThanCurrent(newTarget:ActorGameObject) : Boolean
      {
         var _loc2_:Number = NaN;
         if(mCurrentTarget == null)
         {
            return true;
         }
         if(mCurrentTarget.team == 1 && newTarget.team != 1)
         {
            return true;
         }
         if(mCurrentTarget.team != 1 && newTarget.team != 1 || mCurrentTarget.team == 1 && newTarget.team == 1)
         {
            _loc2_ = calculateTargetScore(newTarget);
            if(_loc2_ > mBestDotProduct)
            {
               return true;
            }
            return false;
         }
         return false;
      }
      
      private function calculateTargetScore(target:ActorGameObject) : Number
      {
         var _loc2_:ActorGameObject = mDungeonFloor.getActor(mParentActorId);
         if(_loc2_ == null)
         {
            return -1;
         }
         var _loc3_:Vector3D = target.worldCenter.clone();
         _loc3_ = _loc3_.subtract(_loc2_.worldCenter);
         _loc3_.normalize();
         return GeometryUtil.dotProduct2D(_loc3_,mHeadingVector);
      }
   }
}

