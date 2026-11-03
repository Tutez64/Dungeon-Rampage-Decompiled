package Box2D.Collision
{
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import flash.Boot;
   
   public class b2DistanceProxy
   {
      
      public var m_vertices:Array;
      
      public var m_radius:Number;
      
      public var m_count:int;
      
      public function b2DistanceProxy()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_radius = 0;
         m_count = 0;
         m_vertices = [];
      }
      
      public function set(shape:b2Shape) : void
      {
         Set(shape);
      }
      
      public function getVertexCount() : int
      {
         return GetVertexCount();
      }
      
      public function getVertex(index:int) : b2Vec2
      {
         return GetVertex(index);
      }
      
      public function getSupportVertex(d:b2Vec2) : b2Vec2
      {
         return GetSupportVertex(d);
      }
      
      public function getSupport(d:b2Vec2) : Number
      {
         return GetSupport(d);
      }
      
      public function Set(shape:b2Shape) : void
      {
         var _loc2_:* = null as b2CircleShape;
         var _loc3_:* = null as b2PolygonShape;
         switch(shape.getType())
         {
            case 1:
               _loc2_ = b2CircleShape(shape);
               m_vertices = [];
               m_vertices[0] = _loc2_.m_p;
               m_count = 1;
               m_radius = _loc2_.m_radius;
               break;
            case 2:
               _loc3_ = b2PolygonShape(shape);
               m_vertices = _loc3_.m_vertices;
               m_count = _loc3_.m_vertexCount;
               m_radius = _loc3_.m_radius;
               break;
            default:
               b2Settings.b2Assert(false);
         }
      }
      
      public function GetVertexCount() : int
      {
         return m_count;
      }
      
      public function GetVertex(index:int) : b2Vec2
      {
         b2Settings.b2Assert(0 <= index && index < m_count);
         return m_vertices[index];
      }
      
      public function GetSupportVertex(d:b2Vec2) : b2Vec2
      {
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:Number = m_vertices[0].x * d.x + m_vertices[0].y * d.y;
         var _loc4_:int = 1;
         var _loc5_:int = m_count;
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc7_ = m_vertices[_loc6_].x * d.x + m_vertices[_loc6_].y * d.y;
            if(_loc7_ > _loc3_)
            {
               _loc2_ = _loc6_;
               _loc3_ = _loc7_;
            }
         }
         return m_vertices[_loc2_];
      }
      
      public function GetSupport(d:b2Vec2) : Number
      {
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:Number = m_vertices[0].x * d.x + m_vertices[0].y * d.y;
         var _loc4_:int = 1;
         var _loc5_:int = m_count;
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc7_ = m_vertices[_loc6_].x * d.x + m_vertices[_loc6_].y * d.y;
            if(_loc7_ > _loc3_)
            {
               _loc2_ = _loc6_;
               _loc3_ = _loc7_;
            }
         }
         return _loc2_;
      }
   }
}

