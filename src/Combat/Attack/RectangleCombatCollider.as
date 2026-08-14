package Combat.Attack
{
   import Actor.ActorGameObject;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2World;
   import Facade.DBFacade;
   
   public class RectangleCombatCollider extends CombatCollider
   {
      
      private var mHalfWidth:Number;
      
      private var mHalfHeight:Number;
      
      private var mRotationOffset:Number;
      
      private var mHeadingAngle:Number;
      
      public function RectangleCombatCollider(dbFacade:DBFacade, parentObject:ActorGameObject, box2DWorld:b2World, halfWidth:Number, halfHeight:Number, heading:Number, rotationOffset:Number)
      {
         mHalfWidth = halfWidth / 50;
         mHalfHeight = halfHeight / 50;
         mRotationOffset = rotationOffset;
         mHeadingAngle = heading % 360;
         super(dbFacade,parentObject,box2DWorld);
      }
      
      override protected function buildShape() : void
      {
         var _loc2_:b2PolygonShape = new b2PolygonShape();
         var _loc1_:Number = mHeadingAngle;
         if(_loc1_ < 0)
         {
            _loc1_ += 360;
         }
         if(_loc1_ > 90 && _loc1_ < 270)
         {
            _loc1_ -= mRotationOffset;
         }
         else
         {
            _loc1_ += mRotationOffset;
         }
         var _loc3_:Number = _loc1_ / 180 * 3.141592653589793;
         mB2Shape = _loc2_;
         _loc2_.SetAsOrientedBox(mHalfWidth,mHalfHeight,new b2Vec2(0,0),_loc3_);
         mB2Transform = new b2Transform();
         if(mParentGameObject.distributedDungeonFloor.debugVisualizer != null)
         {
            mParentGameObject.distributedDungeonFloor.debugVisualizer.reportPolyAttack(mB2Transform,_loc2_);
         }
      }
   }
}

