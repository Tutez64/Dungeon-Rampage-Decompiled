package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2ManifoldPoint
   {
      
      public var m_tangentImpulse:Number;
      
      public var m_normalImpulse:Number;
      
      public var m_localPoint:b2Vec2;
      
      public var m_id:b2ContactID;
      
      public function b2ManifoldPoint()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_localPoint = new b2Vec2();
         m_id = new b2ContactID();
         reset();
      }
      
      public function set(m:b2ManifoldPoint) : void
      {
         Set(m);
      }
      
      public function reset() : void
      {
         Reset();
      }
      
      public function Set(m:b2ManifoldPoint) : void
      {
         m_localPoint.setV(m.m_localPoint);
         m_normalImpulse = m.m_normalImpulse;
         m_tangentImpulse = m.m_tangentImpulse;
         m_id.set(m.m_id);
      }
      
      public function Reset() : void
      {
         m_localPoint.setZero();
         m_normalImpulse = 0;
         m_tangentImpulse = 0;
         m_id.set_key(0);
      }
   }
}

