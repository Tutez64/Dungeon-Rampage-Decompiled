package Box2D.Collision
{
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   use namespace b2internal;
   
   public class b2DistanceProxy
   {
      
      public var m_vertices:Vector.<b2Vec2>;
      
      public var m_count:int;
      
      public var m_radius:Number;
      
      public function b2DistanceProxy()
      {
         super();
      }
      
      public function Set(shape:b2Shape) : void
      {
         var _loc2_:b2CircleShape = null;
         var _loc3_:b2PolygonShape = null;
         switch(shape.GetType())
         {
            case b2Shape.e_circleShape:
               _loc2_ = shape as b2CircleShape;
               this.m_vertices = new Vector.<b2Vec2>(1,true);
               this.m_vertices[0] = _loc2_.m_p;
               this.m_count = 1;
               this.m_radius = _loc2_.m_radius;
               break;
            case b2Shape.e_polygonShape:
               _loc3_ = shape as b2PolygonShape;
               this.m_vertices = _loc3_.m_vertices;
               this.m_count = _loc3_.m_vertexCount;
               this.m_radius = _loc3_.m_radius;
               break;
            default:
               b2Settings.b2Assert(false);
         }
      }
      
      public function GetSupport(d:b2Vec2) : Number
      {
         var _loc5_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:Number = this.m_vertices[0].x * d.x + this.m_vertices[0].y * d.y;
         var _loc4_:* = 1;
         while(_loc4_ < this.m_count)
         {
            _loc5_ = this.m_vertices[_loc4_].x * d.x + this.m_vertices[_loc4_].y * d.y;
            if(_loc5_ > _loc3_)
            {
               _loc2_ = _loc4_;
               _loc3_ = _loc5_;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function GetSupportVertex(d:b2Vec2) : b2Vec2
      {
         var _loc5_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:Number = this.m_vertices[0].x * d.x + this.m_vertices[0].y * d.y;
         var _loc4_:* = 1;
         while(_loc4_ < this.m_count)
         {
            _loc5_ = this.m_vertices[_loc4_].x * d.x + this.m_vertices[_loc4_].y * d.y;
            if(_loc5_ > _loc3_)
            {
               _loc2_ = _loc4_;
               _loc3_ = _loc5_;
            }
            _loc4_++;
         }
         return this.m_vertices[_loc2_];
      }
      
      public function GetVertexCount() : int
      {
         return this.m_count;
      }
      
      public function GetVertex(index:int) : b2Vec2
      {
         b2Settings.b2Assert(0 <= index && index < this.m_count);
         return this.m_vertices[index];
      }
   }
}

