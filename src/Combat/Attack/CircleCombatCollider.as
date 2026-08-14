package Combat.Attack
{
   import Actor.ActorGameObject;
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Dynamics.b2World;
   import Facade.DBFacade;
   
   public class CircleCombatCollider extends CombatCollider
   {
      
      private var mRadius:Number;
      
      public function CircleCombatCollider(dbFacade:DBFacade, parentObject:ActorGameObject, box2DWorld:b2World, radius:Number)
      {
         mRadius = radius / 50;
         super(dbFacade,parentObject,box2DWorld);
      }
      
      override protected function buildShape() : void
      {
         var _loc1_:b2CircleShape = new b2CircleShape(mRadius);
         mB2Shape = _loc1_;
         mB2Transform = new b2Transform();
         if(mParentGameObject.distributedDungeonFloor.debugVisualizer != null)
         {
            mParentGameObject.distributedDungeonFloor.debugVisualizer.reportCircleAttack(mB2Transform,_loc1_);
         }
      }
   }
}

