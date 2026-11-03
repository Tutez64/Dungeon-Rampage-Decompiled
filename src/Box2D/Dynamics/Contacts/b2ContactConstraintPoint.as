package Box2D.Dynamics.Contacts
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2ContactConstraintPoint
   {
      
      public var velocityBias:Number;
      
      public var tangentMass:Number;
      
      public var tangentImpulse:Number;
      
      public var rB:b2Vec2;
      
      public var rA:b2Vec2;
      
      public var normalMass:Number;
      
      public var normalImpulse:Number;
      
      public var localPoint:b2Vec2;
      
      public var equalizedMass:Number;
      
      public function b2ContactConstraintPoint()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         localPoint = new b2Vec2();
         rA = new b2Vec2();
         rB = new b2Vec2();
      }
   }
}

