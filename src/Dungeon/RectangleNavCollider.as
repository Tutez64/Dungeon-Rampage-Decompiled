package Dungeon
{
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2FilterData;
   import Box2D.Dynamics.b2FixtureDef;
   import Box2D.Dynamics.b2World;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import flash.geom.Vector3D;
   
   public class RectangleNavCollider extends NavCollider
   {
      
      protected var mHalfWidth:Number;
      
      protected var mHalfHeight:Number;
      
      protected var mFilter:b2FilterData;
      
      public function RectangleNavCollider(dbFacade:DBFacade, parentObject:FloorObject, offset:Vector3D, angle:Number, box2DWorld:b2World, halfWidth:Number, halfHeight:Number, filter:b2FilterData = null)
      {
         mHalfWidth = halfWidth / 50;
         mHalfHeight = halfHeight / 50;
         mFilter = filter;
         super(dbFacade,parentObject,offset,box2DWorld);
         this.angle = angle;
      }
      
      public function set angle(value:Number) : void
      {
         mB2Body.SetAngle(value);
      }
      
      public function get angle() : Number
      {
         return mB2Body.GetAngle();
      }
      
      override protected function buildBody() : b2Body
      {
         var _loc1_:b2BodyDef = new b2BodyDef();
         var _loc3_:b2FixtureDef = new b2FixtureDef();
         var _loc2_:b2PolygonShape = new b2PolygonShape();
         _loc2_.SetAsBox(mHalfWidth,mHalfHeight);
         _loc3_.shape = _loc2_;
         if(mFilter != null)
         {
            _loc3_.filter = mFilter;
         }
         var _loc4_:b2Body = mB2World.CreateBody(_loc1_);
         _loc4_.CreateFixture(_loc3_);
         return _loc4_;
      }
   }
}

