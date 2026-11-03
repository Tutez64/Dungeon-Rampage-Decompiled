package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import box2D.collision.B2ManifoldType;
   import flash.Boot;
   
   public class b2Manifold
   {
      
      public var m_type:B2ManifoldType;
      
      public var m_points:Array;
      
      public var m_pointCount:int;
      
      public var m_localPoint:b2Vec2;
      
      public var m_localPlaneNormal:b2Vec2;
      
      public function b2Manifold()
      {
         var _loc3_:int = 0;
         if(Boot.skip_constructor)
         {
            return;
         }
         m_pointCount = 0;
         m_points = [];
         var _loc1_:int = 0;
         var _loc2_:int = b2Settings.b2_maxManifoldPoints;
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            m_points[_loc3_] = new b2ManifoldPoint();
         }
         m_localPlaneNormal = new b2Vec2();
         m_localPoint = new b2Vec2();
      }
      
      public function set(m:b2Manifold) : void
      {
         Set(m);
      }
      
      public function reset() : void
      {
         Reset();
      }
      
      public function copy() : b2Manifold
      {
         return Copy();
      }
      
      public function Set(m:b2Manifold) : void
      {
         var _loc4_:int = 0;
         m_pointCount = m.m_pointCount;
         var _loc2_:int = 0;
         var _loc3_:int = b2Settings.b2_maxManifoldPoints;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc2_++;
            m_points[_loc4_].set(m.m_points[_loc4_]);
         }
         m_localPlaneNormal.setV(m.m_localPlaneNormal);
         m_localPoint.setV(m.m_localPoint);
         m_type = m.m_type;
      }
      
      public function Reset() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = b2Settings.b2_maxManifoldPoints;
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            m_points[_loc3_].reset();
         }
         m_localPlaneNormal.setZero();
         m_localPoint.setZero();
         m_type = B2ManifoldType.CIRCLES;
         m_pointCount = 0;
      }
      
      public function Copy() : b2Manifold
      {
         var _loc1_:b2Manifold = new b2Manifold();
         _loc1_.set(this);
         return _loc1_;
      }
   }
}

