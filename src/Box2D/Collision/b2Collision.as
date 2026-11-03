package Box2D.Collision
{
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import box2D.collision.B2ManifoldType;
   import box2dcompat.As3Array;
   
   public class b2Collision
   {
      
      public static var b2_nullFeature:int = 255;
      
      public static var s_incidentEdge:Array = b2Collision.makeClipPointVector();
      
      public static var s_clipPoints1:Array = b2Collision.makeClipPointVector();
      
      public static var s_clipPoints2:Array = b2Collision.makeClipPointVector();
      
      public static var s_edgeAO:Array = [];
      
      public static var s_edgeBO:Array = [];
      
      public static var s_localTangent:b2Vec2 = new b2Vec2();
      
      public static var s_localNormal:b2Vec2 = new b2Vec2();
      
      public static var s_planePoint:b2Vec2 = new b2Vec2();
      
      public static var s_normal:b2Vec2 = new b2Vec2();
      
      public static var s_tangent:b2Vec2 = new b2Vec2();
      
      public static var s_tangent2:b2Vec2 = new b2Vec2();
      
      public static var s_v11:b2Vec2 = new b2Vec2();
      
      public static var s_v12:b2Vec2 = new b2Vec2();
      
      public static var b2CollidePolyTempVec:b2Vec2 = new b2Vec2();
      
      public function b2Collision()
      {
      }
      
      public static function clipSegmentToLine(vOut:Array, vIn:Array, normal:b2Vec2, offset:Number) : int
      {
         var _loc11_:Number = NaN;
         var _loc12_:* = null as b2Vec2;
         var _loc13_:* = null as ClipVertex;
         var _loc5_:int = 0;
         var _loc6_:ClipVertex = vIn[0];
         var _loc7_:b2Vec2 = _loc6_.v;
         _loc6_ = vIn[1];
         var _loc8_:b2Vec2 = _loc6_.v;
         var _loc9_:Number = normal.x * _loc7_.x + normal.y * _loc7_.y - offset;
         var _loc10_:Number = normal.x * _loc8_.x + normal.y * _loc8_.y - offset;
         if(_loc9_ <= 0)
         {
            vOut[_loc5_++].set(vIn[0]);
         }
         if(_loc10_ <= 0)
         {
            vOut[_loc5_++].set(vIn[1]);
         }
         if(_loc9_ * _loc10_ < 0)
         {
            _loc11_ = _loc9_ / (_loc9_ - _loc10_);
            _loc6_ = vOut[_loc5_];
            _loc12_ = _loc6_.v;
            _loc12_.x = _loc7_.x + _loc11_ * (_loc8_.x - _loc7_.x);
            _loc12_.y = _loc7_.y + _loc11_ * (_loc8_.y - _loc7_.y);
            _loc6_ = vOut[_loc5_];
            if(_loc9_ > 0)
            {
               _loc13_ = vIn[0];
               _loc6_.id = _loc13_.id;
            }
            else
            {
               _loc13_ = vIn[1];
               _loc6_.id = _loc13_.id;
            }
            _loc5_++;
         }
         return _loc5_;
      }
      
      public static function edgeSeparation(poly1:b2PolygonShape, xf1:b2Transform, edge1:int, poly2:b2PolygonShape, xf2:b2Transform) : Number
      {
         var _loc21_:int = 0;
         var _loc22_:Number = NaN;
         var _loc6_:int = poly1.m_vertexCount;
         var _loc7_:Array = poly1.m_vertices;
         var _loc8_:Array = poly1.m_normals;
         var _loc9_:int = poly2.m_vertexCount;
         var _loc10_:Array = poly2.m_vertices;
         var _loc11_:b2Mat22 = xf1.R;
         var _loc12_:b2Vec2 = _loc8_[edge1];
         var _loc13_:Number = _loc11_.col1.x * _loc12_.x + _loc11_.col2.x * _loc12_.y;
         var _loc14_:Number = _loc11_.col1.y * _loc12_.x + _loc11_.col2.y * _loc12_.y;
         _loc11_ = xf2.R;
         var _loc15_:Number = _loc11_.col1.x * _loc13_ + _loc11_.col1.y * _loc14_;
         var _loc16_:Number = _loc11_.col2.x * _loc13_ + _loc11_.col2.y * _loc14_;
         var _loc17_:int = 0;
         var _loc18_:Number = Number(Number.MAX_VALUE);
         var _loc19_:int = 0;
         var _loc20_:int = _loc9_;
         while(_loc19_ < _loc20_)
         {
            _loc21_ = _loc19_++;
            _loc12_ = _loc10_[_loc21_];
            _loc22_ = _loc12_.x * _loc15_ + _loc12_.y * _loc16_;
            if(_loc22_ < _loc18_)
            {
               _loc18_ = _loc22_;
               _loc17_ = _loc21_;
            }
         }
         _loc12_ = _loc7_[edge1];
         _loc11_ = xf1.R;
         _loc22_ = xf1.position.x + (_loc11_.col1.x * _loc12_.x + _loc11_.col2.x * _loc12_.y);
         var _loc23_:Number = xf1.position.y + (_loc11_.col1.y * _loc12_.x + _loc11_.col2.y * _loc12_.y);
         _loc12_ = _loc10_[_loc17_];
         _loc11_ = xf2.R;
         var _loc24_:Number = xf2.position.x + (_loc11_.col1.x * _loc12_.x + _loc11_.col2.x * _loc12_.y);
         var _loc25_:Number = xf2.position.y + (_loc11_.col1.y * _loc12_.x + _loc11_.col2.y * _loc12_.y);
         _loc24_ -= _loc22_;
         _loc25_ -= _loc23_;
         return _loc24_ * _loc13_ + _loc25_ * _loc14_;
      }
      
      public static function findMaxSeparation(edgeIndex:Array, poly1:b2PolygonShape, xf1:b2Transform, poly2:b2PolygonShape, xf2:b2Transform) : Number
      {
         var _loc18_:int = 0;
         var _loc19_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:int = 0;
         var _loc6_:int = poly1.m_vertexCount;
         var _loc7_:Array = poly1.m_normals;
         var _loc8_:b2Mat22 = xf2.R;
         var _loc9_:b2Vec2 = poly2.m_centroid;
         var _loc10_:Number = xf2.position.x + (_loc8_.col1.x * _loc9_.x + _loc8_.col2.x * _loc9_.y);
         var _loc11_:Number = xf2.position.y + (_loc8_.col1.y * _loc9_.x + _loc8_.col2.y * _loc9_.y);
         _loc8_ = xf1.R;
         _loc9_ = poly1.m_centroid;
         _loc10_ -= xf1.position.x + (_loc8_.col1.x * _loc9_.x + _loc8_.col2.x * _loc9_.y);
         _loc11_ -= xf1.position.y + (_loc8_.col1.y * _loc9_.x + _loc8_.col2.y * _loc9_.y);
         var _loc12_:Number = _loc10_ * xf1.R.col1.x + _loc11_ * xf1.R.col1.y;
         var _loc13_:Number = _loc10_ * xf1.R.col2.x + _loc11_ * xf1.R.col2.y;
         var _loc14_:int = 0;
         var _loc15_:Number = -Number(Number.MAX_VALUE);
         var _loc16_:int = 0;
         var _loc17_:int = _loc6_;
         while(_loc16_ < _loc17_)
         {
            _loc18_ = _loc16_++;
            _loc9_ = _loc7_[_loc18_];
            _loc19_ = _loc9_.x * _loc12_ + _loc9_.y * _loc13_;
            if(_loc19_ > _loc15_)
            {
               _loc15_ = _loc19_;
               _loc14_ = _loc18_;
            }
         }
         _loc19_ = b2Collision.edgeSeparation(poly1,xf1,_loc14_,poly2,xf2);
         _loc16_ = _loc14_ - 1 >= 0 ? _loc14_ - 1 : _loc6_ - 1;
         var _loc20_:Number = b2Collision.edgeSeparation(poly1,xf1,_loc16_,poly2,xf2);
         _loc17_ = _loc14_ + 1 < _loc6_ ? _loc14_ + 1 : 0;
         var _loc21_:Number = b2Collision.edgeSeparation(poly1,xf1,_loc17_,poly2,xf2);
         if(_loc20_ > _loc19_ && _loc20_ > _loc21_)
         {
            _loc23_ = -1;
            _loc18_ = _loc16_;
            _loc22_ = _loc20_;
         }
         else
         {
            if(_loc21_ <= _loc19_)
            {
               edgeIndex[0] = _loc14_;
               return _loc19_;
            }
            _loc23_ = 1;
            _loc18_ = _loc17_;
            _loc22_ = _loc21_;
         }
         while(true)
         {
            if(_loc23_ == -1)
            {
               _loc14_ = _loc18_ - 1 >= 0 ? _loc18_ - 1 : _loc6_ - 1;
            }
            else
            {
               _loc14_ = _loc18_ + 1 < _loc6_ ? _loc18_ + 1 : 0;
            }
            _loc19_ = b2Collision.edgeSeparation(poly1,xf1,_loc14_,poly2,xf2);
            if(_loc19_ <= _loc22_)
            {
               break;
            }
            _loc18_ = _loc14_;
            _loc22_ = _loc19_;
         }
         edgeIndex[0] = _loc18_;
         return _loc22_;
      }
      
      public static function findIncidentEdge(c:Array, poly1:b2PolygonShape, xf1:b2Transform, edge1:int, poly2:b2PolygonShape, xf2:b2Transform) : void
      {
         var _loc21_:int = 0;
         var _loc22_:Number = NaN;
         var _loc7_:int = poly1.m_vertexCount;
         var _loc8_:Array = poly1.m_normals;
         var _loc9_:int = poly2.m_vertexCount;
         var _loc10_:Array = poly2.m_vertices;
         var _loc11_:Array = poly2.m_normals;
         var _loc12_:b2Mat22 = xf1.R;
         var _loc13_:b2Vec2 = _loc8_[edge1];
         var _loc14_:Number = _loc12_.col1.x * _loc13_.x + _loc12_.col2.x * _loc13_.y;
         var _loc15_:Number = _loc12_.col1.y * _loc13_.x + _loc12_.col2.y * _loc13_.y;
         _loc12_ = xf2.R;
         var _loc16_:Number = _loc12_.col1.x * _loc14_ + _loc12_.col1.y * _loc15_;
         _loc15_ = _loc12_.col2.x * _loc14_ + _loc12_.col2.y * _loc15_;
         _loc14_ = _loc16_;
         var _loc17_:int = 0;
         var _loc18_:Number = Number(Number.MAX_VALUE);
         var _loc19_:int = 0;
         var _loc20_:int = _loc9_;
         while(_loc19_ < _loc20_)
         {
            _loc21_ = _loc19_++;
            _loc13_ = _loc11_[_loc21_];
            _loc22_ = _loc14_ * _loc13_.x + _loc15_ * _loc13_.y;
            if(_loc22_ < _loc18_)
            {
               _loc18_ = _loc22_;
               _loc17_ = _loc21_;
            }
         }
         _loc19_ = _loc17_;
         _loc20_ = _loc19_ + 1 < _loc9_ ? _loc19_ + 1 : 0;
         var _loc23_:ClipVertex = c[0];
         _loc13_ = _loc10_[_loc19_];
         _loc12_ = xf2.R;
         _loc23_.v.x = xf2.position.x + (_loc12_.col1.x * _loc13_.x + _loc12_.col2.x * _loc13_.y);
         _loc23_.v.y = xf2.position.y + (_loc12_.col1.y * _loc13_.x + _loc12_.col2.y * _loc13_.y);
         _loc23_.id.features.set_referenceEdge(edge1);
         _loc23_.id.features.set_incidentEdge(_loc19_);
         _loc23_.id.features.set_incidentVertex(0);
         _loc23_ = c[1];
         _loc13_ = _loc10_[_loc20_];
         _loc12_ = xf2.R;
         _loc23_.v.x = xf2.position.x + (_loc12_.col1.x * _loc13_.x + _loc12_.col2.x * _loc13_.y);
         _loc23_.v.y = xf2.position.y + (_loc12_.col1.y * _loc13_.x + _loc12_.col2.y * _loc13_.y);
         _loc23_.id.features.set_referenceEdge(edge1);
         _loc23_.id.features.set_incidentEdge(_loc20_);
         _loc23_.id.features.set_incidentVertex(1);
      }
      
      public static function makeClipPointVector() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new ClipVertex();
         _loc1_[1] = new ClipVertex();
         return _loc1_;
      }
      
      public static function collidePolygons(manifold:b2Manifold, polyA:b2PolygonShape, xfA:b2Transform, polyB:b2PolygonShape, xfB:b2Transform) : void
      {
         var _loc6_:* = null as ClipVertex;
         var _loc12_:* = null as b2PolygonShape;
         var _loc13_:* = null as b2PolygonShape;
         var _loc14_:* = null as b2Transform;
         var _loc15_:* = null as b2Transform;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc24_:* = null as b2Vec2;
         var _loc43_:int = 0;
         var _loc44_:Number = NaN;
         var _loc45_:* = null as b2ManifoldPoint;
         var _loc46_:Number = NaN;
         var _loc47_:Number = NaN;
         manifold.m_pointCount = 0;
         var _loc7_:Number = polyA.m_radius + polyB.m_radius;
         var _loc8_:int = 0;
         b2Collision.s_edgeAO[0] = _loc8_;
         var _loc9_:Number = b2Collision.findMaxSeparation(b2Collision.s_edgeAO,polyA,xfA,polyB,xfB);
         _loc8_ = int(b2Collision.s_edgeAO[0]);
         if(_loc9_ > _loc7_)
         {
            return;
         }
         var _loc10_:int = 0;
         b2Collision.s_edgeBO[0] = _loc10_;
         var _loc11_:Number = b2Collision.findMaxSeparation(b2Collision.s_edgeBO,polyB,xfB,polyA,xfA);
         _loc10_ = int(b2Collision.s_edgeBO[0]);
         if(_loc11_ > _loc7_)
         {
            return;
         }
         var _loc18_:Number = 0.98;
         var _loc19_:Number = 0.001;
         if(_loc11_ > _loc18_ * _loc9_ + _loc19_)
         {
            _loc12_ = polyB;
            _loc13_ = polyA;
            _loc14_ = xfB;
            _loc15_ = xfA;
            _loc16_ = _loc10_;
            manifold.m_type = B2ManifoldType.FACE_B;
            _loc17_ = 1;
         }
         else
         {
            _loc12_ = polyA;
            _loc13_ = polyB;
            _loc14_ = xfA;
            _loc15_ = xfB;
            _loc16_ = _loc8_;
            manifold.m_type = B2ManifoldType.FACE_A;
            _loc17_ = 0;
         }
         var _loc20_:Array = b2Collision.s_incidentEdge;
         b2Collision.findIncidentEdge(_loc20_,_loc12_,_loc14_,_loc16_,_loc13_,_loc15_);
         var _loc21_:int = _loc12_.m_vertexCount;
         var _loc22_:Array = _loc12_.m_vertices;
         var _loc23_:b2Vec2 = _loc22_[_loc16_];
         if(_loc16_ + 1 < _loc21_)
         {
            _loc24_ = _loc22_[_loc16_ + 1];
         }
         else
         {
            _loc24_ = _loc22_[0];
         }
         var _loc25_:b2Vec2 = b2Collision.s_localTangent;
         _loc25_.set(_loc24_.x - _loc23_.x,_loc24_.y - _loc23_.y);
         _loc25_.normalize();
         var _loc26_:b2Vec2 = b2Collision.s_localNormal;
         _loc26_.x = _loc25_.y;
         _loc26_.y = -_loc25_.x;
         var _loc27_:b2Vec2 = b2Collision.s_planePoint;
         _loc27_.set(0.5 * (_loc23_.x + _loc24_.x),0.5 * (_loc23_.y + _loc24_.y));
         var _loc28_:b2Vec2 = b2Collision.s_tangent;
         var _loc29_:b2Mat22 = _loc14_.R;
         _loc28_.x = _loc29_.col1.x * _loc25_.x + _loc29_.col2.x * _loc25_.y;
         _loc28_.y = _loc29_.col1.y * _loc25_.x + _loc29_.col2.y * _loc25_.y;
         var _loc30_:b2Vec2 = b2Collision.s_tangent2;
         _loc30_.x = -_loc28_.x;
         _loc30_.y = -_loc28_.y;
         var _loc31_:b2Vec2 = b2Collision.s_normal;
         _loc31_.x = _loc28_.y;
         _loc31_.y = -_loc28_.x;
         var _loc32_:b2Vec2 = b2Collision.s_v11;
         var _loc33_:b2Vec2 = b2Collision.s_v12;
         _loc32_.x = _loc14_.position.x + (_loc29_.col1.x * _loc23_.x + _loc29_.col2.x * _loc23_.y);
         _loc32_.y = _loc14_.position.y + (_loc29_.col1.y * _loc23_.x + _loc29_.col2.y * _loc23_.y);
         _loc33_.x = _loc14_.position.x + (_loc29_.col1.x * _loc24_.x + _loc29_.col2.x * _loc24_.y);
         _loc33_.y = _loc14_.position.y + (_loc29_.col1.y * _loc24_.x + _loc29_.col2.y * _loc24_.y);
         var _loc34_:Number = _loc31_.x * _loc32_.x + _loc31_.y * _loc32_.y;
         var _loc35_:Number = -_loc28_.x * _loc32_.x - _loc28_.y * _loc32_.y + _loc7_;
         var _loc36_:Number = _loc28_.x * _loc33_.x + _loc28_.y * _loc33_.y + _loc7_;
         var _loc37_:Array = b2Collision.s_clipPoints1;
         var _loc38_:Array = b2Collision.s_clipPoints2;
         var _loc39_:int = b2Collision.clipSegmentToLine(_loc37_,_loc20_,_loc30_,_loc35_);
         if(_loc39_ < 2)
         {
            return;
         }
         _loc39_ = b2Collision.clipSegmentToLine(_loc38_,_loc37_,_loc28_,_loc36_);
         if(_loc39_ < 2)
         {
            return;
         }
         manifold.m_localPlaneNormal.setV(_loc26_);
         manifold.m_localPoint.setV(_loc27_);
         var _loc40_:int = 0;
         var _loc41_:int = 0;
         var _loc42_:int = b2Settings.b2_maxManifoldPoints;
         while(_loc41_ < _loc42_)
         {
            _loc43_ = _loc41_++;
            _loc6_ = _loc38_[_loc43_];
            _loc44_ = _loc31_.x * _loc6_.v.x + _loc31_.y * _loc6_.v.y - _loc34_;
            if(_loc44_ <= _loc7_)
            {
               _loc45_ = manifold.m_points[_loc40_];
               _loc29_ = _loc15_.R;
               _loc46_ = _loc6_.v.x - _loc15_.position.x;
               _loc47_ = _loc6_.v.y - _loc15_.position.y;
               _loc45_.m_localPoint.x = _loc46_ * _loc29_.col1.x + _loc47_ * _loc29_.col1.y;
               _loc45_.m_localPoint.y = _loc46_ * _loc29_.col2.x + _loc47_ * _loc29_.col2.y;
               _loc45_.m_id.set(_loc6_.id);
               _loc45_.m_id.features.set_flip(_loc17_);
               _loc40_++;
            }
         }
         manifold.m_pointCount = _loc40_;
      }
      
      public static function collideCircles(manifold:b2Manifold, circle1:b2CircleShape, xf1:b2Transform, circle2:b2CircleShape, xf2:b2Transform) : void
      {
         manifold.m_pointCount = 0;
         var _loc6_:b2Mat22 = xf1.R;
         var _loc7_:b2Vec2 = circle1.m_p;
         var _loc8_:Number = xf1.position.x + (_loc6_.col1.x * _loc7_.x + _loc6_.col2.x * _loc7_.y);
         var _loc9_:Number = xf1.position.y + (_loc6_.col1.y * _loc7_.x + _loc6_.col2.y * _loc7_.y);
         _loc6_ = xf2.R;
         _loc7_ = circle2.m_p;
         var _loc10_:Number = xf2.position.x + (_loc6_.col1.x * _loc7_.x + _loc6_.col2.x * _loc7_.y);
         var _loc11_:Number = xf2.position.y + (_loc6_.col1.y * _loc7_.x + _loc6_.col2.y * _loc7_.y);
         var _loc12_:Number = _loc10_ - _loc8_;
         var _loc13_:Number = _loc11_ - _loc9_;
         var _loc14_:Number = _loc12_ * _loc12_ + _loc13_ * _loc13_;
         var _loc15_:Number = circle1.m_radius + circle2.m_radius;
         if(_loc14_ > _loc15_ * _loc15_)
         {
            return;
         }
         manifold.m_type = B2ManifoldType.CIRCLES;
         manifold.m_localPoint.setV(circle1.m_p);
         manifold.m_localPlaneNormal.setZero();
         manifold.m_pointCount = 1;
         manifold.m_points[0].m_localPoint.setV(circle2.m_p);
         manifold.m_points[0].m_id.set_key(0);
      }
      
      public static function collidePolygonAndCircle(manifold:b2Manifold, polygon:b2PolygonShape, xf1:b2Transform, circle:b2CircleShape, xf2:b2Transform) : void
      {
         var _loc26_:int = 0;
         var _loc27_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         manifold.m_pointCount = 0;
         var _loc9_:b2Mat22 = xf2.R;
         var _loc10_:b2Vec2 = circle.m_p;
         var _loc11_:Number = xf2.position.x + (_loc9_.col1.x * _loc10_.x + _loc9_.col2.x * _loc10_.y);
         var _loc12_:Number = xf2.position.y + (_loc9_.col1.y * _loc10_.x + _loc9_.col2.y * _loc10_.y);
         var _loc13_:Number = _loc11_ - xf1.position.x;
         var _loc14_:Number = _loc12_ - xf1.position.y;
         _loc9_ = xf1.R;
         var _loc15_:Number = _loc13_ * _loc9_.col1.x + _loc14_ * _loc9_.col1.y;
         var _loc16_:Number = _loc13_ * _loc9_.col2.x + _loc14_ * _loc9_.col2.y;
         var _loc18_:int = 0;
         var _loc19_:Number = -Number(Number.MAX_VALUE);
         var _loc20_:Number = polygon.m_radius + circle.m_radius;
         var _loc21_:int = polygon.m_vertexCount;
         var _loc22_:Array = polygon.m_vertices;
         var _loc23_:Array = polygon.m_normals;
         var _loc24_:int = 0;
         var _loc25_:int = _loc21_;
         while(_loc24_ < _loc25_)
         {
            _loc26_ = _loc24_++;
            _loc10_ = _loc22_[_loc26_];
            _loc13_ = _loc15_ - _loc10_.x;
            _loc14_ = _loc16_ - _loc10_.y;
            _loc10_ = _loc23_[_loc26_];
            _loc27_ = _loc10_.x * _loc13_ + _loc10_.y * _loc14_;
            if(_loc27_ > _loc20_)
            {
               return;
            }
            if(_loc27_ > _loc19_)
            {
               _loc19_ = _loc27_;
               _loc18_ = _loc26_;
            }
         }
         _loc24_ = _loc18_;
         _loc25_ = _loc24_ + 1 < _loc21_ ? _loc24_ + 1 : 0;
         var _loc28_:b2Vec2 = _loc22_[_loc24_];
         var _loc29_:b2Vec2 = _loc22_[_loc25_];
         if(_loc19_ < Number(Number.MIN_VALUE))
         {
            manifold.m_pointCount = 1;
            manifold.m_type = B2ManifoldType.FACE_A;
            manifold.m_localPlaneNormal.setV(_loc23_[_loc18_]);
            manifold.m_localPoint.x = 0.5 * (_loc28_.x + _loc29_.x);
            manifold.m_localPoint.y = 0.5 * (_loc28_.y + _loc29_.y);
            manifold.m_points[0].m_localPoint.setV(circle.m_p);
            manifold.m_points[0].m_id.set_key(0);
            return;
         }
         _loc27_ = (_loc15_ - _loc28_.x) * (_loc29_.x - _loc28_.x) + (_loc16_ - _loc28_.y) * (_loc29_.y - _loc28_.y);
         var _loc30_:Number = (_loc15_ - _loc29_.x) * (_loc28_.x - _loc29_.x) + (_loc16_ - _loc29_.y) * (_loc28_.y - _loc29_.y);
         if(_loc27_ <= 0)
         {
            if((_loc15_ - _loc28_.x) * (_loc15_ - _loc28_.x) + (_loc16_ - _loc28_.y) * (_loc16_ - _loc28_.y) > _loc20_ * _loc20_)
            {
               return;
            }
            manifold.m_pointCount = 1;
            manifold.m_type = B2ManifoldType.FACE_A;
            manifold.m_localPlaneNormal.x = _loc15_ - _loc28_.x;
            manifold.m_localPlaneNormal.y = _loc16_ - _loc28_.y;
            manifold.m_localPlaneNormal.normalize();
            manifold.m_localPoint.setV(_loc28_);
            manifold.m_points[0].m_localPoint.setV(circle.m_p);
            manifold.m_points[0].m_id.set_key(0);
         }
         else if(_loc30_ <= 0)
         {
            if((_loc15_ - _loc29_.x) * (_loc15_ - _loc29_.x) + (_loc16_ - _loc29_.y) * (_loc16_ - _loc29_.y) > _loc20_ * _loc20_)
            {
               return;
            }
            manifold.m_pointCount = 1;
            manifold.m_type = B2ManifoldType.FACE_A;
            manifold.m_localPlaneNormal.x = _loc15_ - _loc29_.x;
            manifold.m_localPlaneNormal.y = _loc16_ - _loc29_.y;
            manifold.m_localPlaneNormal.normalize();
            manifold.m_localPoint.setV(_loc29_);
            manifold.m_points[0].m_localPoint.setV(circle.m_p);
            manifold.m_points[0].m_id.set_key(0);
         }
         else
         {
            _loc31_ = 0.5 * (_loc28_.x + _loc29_.x);
            _loc32_ = 0.5 * (_loc28_.y + _loc29_.y);
            _loc19_ = (_loc15_ - _loc31_) * _loc23_[_loc24_].x + (_loc16_ - _loc32_) * _loc23_[_loc24_].y;
            if(_loc19_ > _loc20_)
            {
               return;
            }
            manifold.m_pointCount = 1;
            manifold.m_type = B2ManifoldType.FACE_A;
            manifold.m_localPlaneNormal.x = _loc23_[_loc24_].x;
            manifold.m_localPlaneNormal.y = _loc23_[_loc24_].y;
            manifold.m_localPlaneNormal.normalize();
            manifold.m_localPoint.set(_loc31_,_loc32_);
            manifold.m_points[0].m_localPoint.setV(circle.m_p);
            manifold.m_points[0].m_id.set_key(0);
         }
      }
      
      public static function testOverlap(a:b2AABB, b:b2AABB) : Boolean
      {
         var _loc3_:b2Vec2 = b.lowerBound;
         var _loc4_:b2Vec2 = a.upperBound;
         var _loc5_:Number = _loc3_.x - _loc4_.x;
         var _loc6_:Number = _loc3_.y - _loc4_.y;
         _loc3_ = a.lowerBound;
         _loc4_ = b.upperBound;
         var _loc7_:Number = _loc3_.x - _loc4_.x;
         var _loc8_:Number = _loc3_.y - _loc4_.y;
         if(_loc5_ > 0 || _loc6_ > 0)
         {
            return false;
         }
         if(_loc7_ > 0 || _loc8_ > 0)
         {
            return false;
         }
         return true;
      }
      
      public static function ClipSegmentToLine(vOut:*, vIn:*, normal:b2Vec2, offset:Number) : int
      {
         return b2Collision.clipSegmentToLine(As3Array.of(vOut),As3Array.of(vIn),normal,offset);
      }
      
      public static function EdgeSeparation(poly1:b2PolygonShape, xf1:b2Transform, edge1:int, poly2:b2PolygonShape, xf2:b2Transform) : Number
      {
         return b2Collision.edgeSeparation(poly1,xf1,edge1,poly2,xf2);
      }
      
      public static function FindMaxSeparation(edgeIndex:*, poly1:b2PolygonShape, xf1:b2Transform, poly2:b2PolygonShape, xf2:b2Transform) : Number
      {
         return b2Collision.findMaxSeparation(As3Array.of(edgeIndex),poly1,xf1,poly2,xf2);
      }
      
      public static function FindIncidentEdge(c:*, poly1:b2PolygonShape, xf1:b2Transform, edge1:int, poly2:b2PolygonShape, xf2:b2Transform) : void
      {
         b2Collision.findIncidentEdge(As3Array.of(c),poly1,xf1,edge1,poly2,xf2);
      }
      
      public static function CollidePolygons(manifold:b2Manifold, polyA:b2PolygonShape, xfA:b2Transform, polyB:b2PolygonShape, xfB:b2Transform) : void
      {
         b2Collision.collidePolygons(manifold,polyA,xfA,polyB,xfB);
      }
      
      public static function CollideCircles(manifold:b2Manifold, circle1:b2CircleShape, xf1:b2Transform, circle2:b2CircleShape, xf2:b2Transform) : void
      {
         b2Collision.collideCircles(manifold,circle1,xf1,circle2,xf2);
      }
      
      public static function CollidePolygonAndCircle(manifold:b2Manifold, polygon:b2PolygonShape, xf1:b2Transform, circle:b2CircleShape, xf2:b2Transform) : void
      {
         b2Collision.collidePolygonAndCircle(manifold,polygon,xf1,circle,xf2);
      }
      
      public static function TestOverlap(a:b2AABB, b:b2AABB) : Boolean
      {
         return b2Collision.testOverlap(a,b);
      }
   }
}

