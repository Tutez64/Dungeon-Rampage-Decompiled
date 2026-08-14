package Dungeon
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2FilterData;
   import Box2D.Dynamics.b2Fixture;
   import Box2D.Dynamics.b2World;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import flash.geom.Vector3D;
   
   public class NavCollider
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mParentObject:FloorObject;
      
      protected var mWorldSpaceOffset:Vector3D;
      
      protected var mB2Body:b2Body;
      
      protected var mB2World:b2World;
      
      public function NavCollider(dbFacade:DBFacade, parentObject:FloorObject, offset:Vector3D, box2DWorld:b2World)
      {
         super();
         mDBFacade = dbFacade;
         mParentObject = parentObject;
         mWorldSpaceOffset = offset;
         mB2World = box2DWorld;
         mB2Body = buildBody();
         if(parentObject == null)
         {
            mB2Body.SetUserData(null);
         }
         else
         {
            mB2Body.SetUserData(parentObject.id);
         }
      }
      
      public static function buildNavColliderFromJson(dbFacade:DBFacade, collisionJson:Object, parentObject:FloorObject, offset:Vector3D, angle:Number, scale:Vector3D, box2DWorld:b2World, filter:b2FilterData = null) : NavCollider
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:String = collisionJson.type;
         if(_loc11_ == "circle")
         {
            return new CircleNavCollider(dbFacade,parentObject,offset,collisionJson.radius * scale.x,box2DWorld,filter);
         }
         if(_loc11_ == "rectangle")
         {
            _loc9_ = collisionJson.halfWidth * scale.x;
            _loc10_ = collisionJson.halfHeight * scale.y;
            return new RectangleNavCollider(dbFacade,parentObject,offset,angle,box2DWorld,_loc9_,_loc10_,filter);
         }
         Logger.error("Could not figure out collision type of json to build a b2Shape:" + collisionJson.toString());
         return null;
      }
      
      public static function convertToB2Vec2(vector3d:Vector3D) : b2Vec2
      {
         return new b2Vec2(vector3d.x / 50,vector3d.y / 50);
      }
      
      public static function convertToVector3D(b2dVec2:b2Vec2) : Vector3D
      {
         return new Vector3D(b2dVec2.x * 50,b2dVec2.y * 50);
      }
      
      public function destroy() : void
      {
         mB2World.DestroyBody(mB2Body);
         mB2Body = null;
         mB2World = null;
         mParentObject = null;
         mDBFacade = null;
      }
      
      public function set active(value:Boolean) : void
      {
         mB2Body.SetActive(value);
      }
      
      public function get active() : Boolean
      {
         return mB2Body.IsActive();
      }
      
      protected function buildBody() : b2Body
      {
         Logger.error("Override build definition in sub classes.");
         return null;
      }
      
      public function get worldCenter() : Vector3D
      {
         return convertToVector3D(mB2Body.GetWorldCenter());
      }
      
      public function set position(val:Vector3D) : void
      {
         var _loc2_:Vector3D = new Vector3D(val.x + mWorldSpaceOffset.x,val.y + mWorldSpaceOffset.y);
         mB2Body.SetPosition(convertToB2Vec2(_loc2_));
      }
      
      public function get position() : Vector3D
      {
         var _loc1_:Vector3D = convertToVector3D(mB2Body.GetPosition());
         return _loc1_.subtract(mWorldSpaceOffset);
      }
      
      public function set velocity(vel:Vector3D) : void
      {
         mB2Body.SetAwake(true);
         mB2Body.SetLinearVelocity(convertToB2Vec2(vel));
      }
      
      public function get offset() : Vector3D
      {
         return mWorldSpaceOffset;
      }
      
      public function set type(colliderType:uint) : void
      {
         mB2Body.SetType(b2Body.b2_dynamicBody);
      }
      
      public function get collisionRadius() : Number
      {
         if(this as CircleNavCollider)
         {
            return (this as CircleNavCollider).radius;
         }
         return -1;
      }
      
      public function getBody() : b2Body
      {
         return mB2Body;
      }
      
      public function getShape() : b2Shape
      {
         var _loc1_:b2Fixture = mB2Body.GetFixtureList();
         return _loc1_.GetShape();
      }
   }
}

