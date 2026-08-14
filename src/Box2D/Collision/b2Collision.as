package Box2D.Collision
{
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   use namespace b2internal;
   
   public class b2Collision
   {
      
      public static const b2_nullFeature:uint = 255;
      
      private static var s_incidentEdge:Vector.<ClipVertex> = MakeClipPointVector();
      
      private static var s_clipPoints1:Vector.<ClipVertex> = MakeClipPointVector();
      
      private static var s_clipPoints2:Vector.<ClipVertex> = MakeClipPointVector();
      
      private static var s_edgeAO:Vector.<int> = new Vector.<int>(1);
      
      private static var s_edgeBO:Vector.<int> = new Vector.<int>(1);
      
      private static var s_localTangent:b2Vec2 = new b2Vec2();
      
      private static var s_localNormal:b2Vec2 = new b2Vec2();
      
      private static var s_planePoint:b2Vec2 = new b2Vec2();
      
      private static var s_normal:b2Vec2 = new b2Vec2();
      
      private static var s_tangent:b2Vec2 = new b2Vec2();
      
      private static var s_tangent2:b2Vec2 = new b2Vec2();
      
      private static var s_v11:b2Vec2 = new b2Vec2();
      
      private static var s_v12:b2Vec2 = new b2Vec2();
      
      private static var b2CollidePolyTempVec:b2Vec2 = new b2Vec2();
      
      public function b2Collision()
      {
         super();
      }
      
      public static function ClipSegmentToLine(vOut:Vector.<ClipVertex>, vIn:Vector.<ClipVertex>, normal:b2Vec2, offset:Number) : int
      {
         var _loc5_:ClipVertex = null;
         var _loc6_:* = 0;
         var _loc7_:b2Vec2 = null;
         var _loc9_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:b2Vec2 = null;
         var _loc13_:ClipVertex = null;
         _loc6_ = 0;
         _loc5_ = vIn[0];
         _loc7_ = _loc5_.v;
         _loc5_ = vIn[1];
         var _loc8_:b2Vec2 = _loc5_.v;
         _loc9_ = normal.x * _loc7_.x + normal.y * _loc7_.y - offset;
         var _loc10_:Number = normal.x * _loc8_.x + normal.y * _loc8_.y - offset;
         if(_loc9_ <= 0)
         {
            vOut[_loc6_++].Set(vIn[0]);
         }
         if(_loc10_ <= 0)
         {
            vOut[_loc6_++].Set(vIn[1]);
         }
         if(_loc9_ * _loc10_ < 0)
         {
            _loc11_ = _loc9_ / (_loc9_ - _loc10_);
            _loc5_ = vOut[_loc6_];
            _loc12_ = _loc5_.v;
            _loc12_.x = _loc7_.x + _loc11_ * (_loc8_.x - _loc7_.x);
            _loc12_.y = _loc7_.y + _loc11_ * (_loc8_.y - _loc7_.y);
            _loc5_ = vOut[_loc6_];
            if(_loc9_ > 0)
            {
               _loc13_ = vIn[0];
               _loc5_.id = _loc13_.id;
            }
            else
            {
               _loc13_ = vIn[1];
               _loc5_.id = _loc13_.id;
            }
            _loc6_++;
         }
         return _loc6_;
      }
      
      public static function EdgeSeparation(poly1:b2PolygonShape, xf1:b2Transform, edge1:int, poly2:b2PolygonShape, xf2:b2Transform) : Number
      {
         var _loc11_:b2Mat22 = null;
         var _loc12_:b2Vec2 = null;
         var _loc25_:Number = NaN;
         var _loc6_:int = poly1.m_vertexCount;
         var _loc7_:Vector.<b2Vec2> = poly1.m_vertices;
         var _loc8_:Vector.<b2Vec2> = poly1.m_normals;
         var _loc9_:int = poly2.m_vertexCount;
         var _loc10_:Vector.<b2Vec2> = poly2.m_vertices;
         _loc11_ = xf1.R;
         _loc12_ = _loc8_[edge1];
         var _loc13_:Number = _loc11_.col1.x * _loc12_.x + _loc11_.col2.x * _loc12_.y;
         var _loc14_:Number = _loc11_.col1.y * _loc12_.x + _loc11_.col2.y * _loc12_.y;
         _loc11_ = xf2.R;
         var _loc15_:Number = _loc11_.col1.x * _loc13_ + _loc11_.col1.y * _loc14_;
         var _loc16_:Number = _loc11_.col2.x * _loc13_ + _loc11_.col2.y * _loc14_;
         var _loc17_:int = 0;
         var _loc18_:Number = Number.MAX_VALUE;
         var _loc19_:* = 0;
         while(_loc19_ < _loc9_)
         {
            _loc12_ = _loc10_[_loc19_];
            _loc25_ = _loc12_.x * _loc15_ + _loc12_.y * _loc16_;
            if(_loc25_ < _loc18_)
            {
               _loc18_ = _loc25_;
               _loc17_ = _loc19_;
            }
            _loc19_++;
         }
         _loc12_ = _loc7_[edge1];
         _loc11_ = xf1.R;
         var _loc20_:Number = xf1.position.x + (_loc11_.col1.x * _loc12_.x + _loc11_.col2.x * _loc12_.y);
         var _loc21_:Number = xf1.position.y + (_loc11_.col1.y * _loc12_.x + _loc11_.col2.y * _loc12_.y);
         _loc12_ = _loc10_[_loc17_];
         _loc11_ = xf2.R;
         var _loc22_:Number = xf2.position.x + (_loc11_.col1.x * _loc12_.x + _loc11_.col2.x * _loc12_.y);
         var _loc23_:Number = xf2.position.y + (_loc11_.col1.y * _loc12_.x + _loc11_.col2.y * _loc12_.y);
         _loc22_ -= _loc20_;
         _loc23_ -= _loc21_;
         return _loc22_ * _loc13_ + _loc23_ * _loc14_;
      }
      
      public static function FindMaxSeparation(edgeIndex:Vector.<int>, poly1:b2PolygonShape, xf1:b2Transform, poly2:b2PolygonShape, xf2:b2Transform) : Number
      {
         var _loc8_:b2Vec2 = null;
         var _loc9_:b2Mat22 = null;
         var _loc22_:int = 0;
         var _loc23_:Number = NaN;
         var _loc24_:int = 0;
         var _loc25_:Number = NaN;
         var _loc6_:int = poly1.m_vertexCount;
         var _loc7_:Vector.<b2Vec2> = poly1.m_normals;
         _loc9_ = xf2.R;
         _loc8_ = poly2.m_centroid;
         var _loc10_:Number = xf2.position.x + (_loc9_.col1.x * _loc8_.x + _loc9_.col2.x * _loc8_.y);
         var _loc11_:Number = xf2.position.y + (_loc9_.col1.y * _loc8_.x + _loc9_.col2.y * _loc8_.y);
         _loc9_ = xf1.R;
         _loc8_ = poly1.m_centroid;
         _loc10_ -= xf1.position.x + (_loc9_.col1.x * _loc8_.x + _loc9_.col2.x * _loc8_.y);
         _loc11_ -= xf1.position.y + (_loc9_.col1.y * _loc8_.x + _loc9_.col2.y * _loc8_.y);
         var _loc12_:Number = _loc10_ * xf1.R.col1.x + _loc11_ * xf1.R.col1.y;
         var _loc13_:Number = _loc10_ * xf1.R.col2.x + _loc11_ * xf1.R.col2.y;
         var _loc14_:int = 0;
         var _loc15_:Number = -Number.MAX_VALUE;
         var _loc16_:* = 0;
         while(_loc16_ < _loc6_)
         {
            _loc8_ = _loc7_[_loc16_];
            _loc25_ = _loc8_.x * _loc12_ + _loc8_.y * _loc13_;
            if(_loc25_ > _loc15_)
            {
               _loc15_ = _loc25_;
               _loc14_ = _loc16_;
            }
            _loc16_++;
         }
         var _loc17_:Number = EdgeSeparation(poly1,xf1,_loc14_,poly2,xf2);
         var _loc18_:int = _loc14_ - 1 >= 0 ? int(_loc14_ - 1) : int(_loc6_ - 1);
         var _loc19_:Number = EdgeSeparation(poly1,xf1,_loc18_,poly2,xf2);
         var _loc20_:int = _loc14_ + 1 < _loc6_ ? int(_loc14_ + 1) : 0;
         var _loc21_:Number = EdgeSeparation(poly1,xf1,_loc20_,poly2,xf2);
         if(_loc19_ > _loc17_ && _loc19_ > _loc21_)
         {
            _loc24_ = -1;
            _loc22_ = _loc18_;
            _loc23_ = _loc19_;
         }
         else
         {
            if(_loc21_ <= _loc17_)
            {
               edgeIndex[0] = _loc14_;
               return _loc17_;
            }
            _loc24_ = 1;
            _loc22_ = _loc20_;
            _loc23_ = _loc21_;
         }
         while(true)
         {
            if(_loc24_ == -1)
            {
               _loc14_ = _loc22_ - 1 >= 0 ? int(_loc22_ - 1) : int(_loc6_ - 1);
            }
            else
            {
               _loc14_ = _loc22_ + 1 < _loc6_ ? int(_loc22_ + 1) : 0;
            }
            _loc17_ = EdgeSeparation(poly1,xf1,_loc14_,poly2,xf2);
            if(_loc17_ <= _loc23_)
            {
               break;
            }
            _loc22_ = _loc14_;
            _loc23_ = _loc17_;
         }
         edgeIndex[0] = _loc22_;
         return _loc23_;
      }
      
      public static function FindIncidentEdge(c:Vector.<ClipVertex>, poly1:b2PolygonShape, xf1:b2Transform, edge1:int, poly2:b2PolygonShape, xf2:b2Transform) : void
      {
         var _loc12_:b2Mat22 = null;
         var _loc13_:b2Vec2 = null;
         var _loc20_:ClipVertex = null;
         var _loc23_:Number = NaN;
         var _loc7_:int = poly1.m_vertexCount;
         var _loc8_:Vector.<b2Vec2> = poly1.m_normals;
         var _loc9_:int = poly2.m_vertexCount;
         var _loc10_:Vector.<b2Vec2> = poly2.m_vertices;
         var _loc11_:Vector.<b2Vec2> = poly2.m_normals;
         _loc12_ = xf1.R;
         _loc13_ = _loc8_[edge1];
         var _loc14_:Number = _loc12_.col1.x * _loc13_.x + _loc12_.col2.x * _loc13_.y;
         var _loc15_:Number = _loc12_.col1.y * _loc13_.x + _loc12_.col2.y * _loc13_.y;
         _loc12_ = xf2.R;
         var _loc16_:Number = _loc12_.col1.x * _loc14_ + _loc12_.col1.y * _loc15_;
         _loc15_ = _loc12_.col2.x * _loc14_ + _loc12_.col2.y * _loc15_;
         _loc14_ = _loc16_;
         var _loc17_:int = 0;
         var _loc18_:Number = Number.MAX_VALUE;
         var _loc19_:* = 0;
         while(_loc19_ < _loc9_)
         {
            _loc13_ = _loc11_[_loc19_];
            _loc23_ = _loc14_ * _loc13_.x + _loc15_ * _loc13_.y;
            if(_loc23_ < _loc18_)
            {
               _loc18_ = _loc23_;
               _loc17_ = _loc19_;
            }
            _loc19_++;
         }
         var _loc21_:int = _loc17_;
         var _loc22_:int = _loc21_ + 1 < _loc9_ ? int(_loc21_ + 1) : 0;
         _loc20_ = c[0];
         _loc13_ = _loc10_[_loc21_];
         _loc12_ = xf2.R;
         _loc20_.v.x = xf2.position.x + (_loc12_.col1.x * _loc13_.x + _loc12_.col2.x * _loc13_.y);
         _loc20_.v.y = xf2.position.y + (_loc12_.col1.y * _loc13_.x + _loc12_.col2.y * _loc13_.y);
         _loc20_.id.features.referenceEdge = edge1;
         _loc20_.id.features.incidentEdge = _loc21_;
         _loc20_.id.features.incidentVertex = 0;
         _loc20_ = c[1];
         _loc13_ = _loc10_[_loc22_];
         _loc12_ = xf2.R;
         _loc20_.v.x = xf2.position.x + (_loc12_.col1.x * _loc13_.x + _loc12_.col2.x * _loc13_.y);
         _loc20_.v.y = xf2.position.y + (_loc12_.col1.y * _loc13_.x + _loc12_.col2.y * _loc13_.y);
         _loc20_.id.features.referenceEdge = edge1;
         _loc20_.id.features.incidentEdge = _loc22_;
         _loc20_.id.features.incidentVertex = 1;
      }
      
      private static function MakeClipPointVector() : Vector.<ClipVertex>
      {
         var _loc1_:Vector.<ClipVertex> = new Vector.<ClipVertex>(2);
         _loc1_[0] = new ClipVertex();
         _loc1_[1] = new ClipVertex();
         return _loc1_;
      }
      
      public static function CollidePolygons(manifold:b2Manifold, polyA:b2PolygonShape, xfA:b2Transform, polyB:b2PolygonShape, xfB:b2Transform) : void
      {
         var _loc6_:ClipVertex = null;
         var _loc12_:b2PolygonShape = null;
         var _loc13_:b2PolygonShape = null;
         var _loc14_:b2Transform = null;
         var _loc15_:b2Transform = null;
         var _loc16_:int = 0;
         var _loc17_:uint = 0;
         var _loc20_:b2Mat22 = null;
         var _loc25_:b2Vec2 = null;
         var _loc39_:int = 0;
         var _loc42_:Number = NaN;
         var _loc43_:b2ManifoldPoint = null;
         var _loc44_:Number = NaN;
         var _loc45_:Number = NaN;
         manifold.m_pointCount = 0;
         var _loc7_:Number = polyA.m_radius + polyB.m_radius;
         var _loc8_:int = 0;
         s_edgeAO[0] = _loc8_;
         var _loc9_:Number = FindMaxSeparation(s_edgeAO,polyA,xfA,polyB,xfB);
         _loc8_ = s_edgeAO[0];
         if(_loc9_ > _loc7_)
         {
            return;
         }
         var _loc10_:int = 0;
         s_edgeBO[0] = _loc10_;
         var _loc11_:Number = FindMaxSeparation(s_edgeBO,polyB,xfB,polyA,xfA);
         _loc10_ = s_edgeBO[0];
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
            manifold.m_type = b2Manifold.e_faceB;
            _loc17_ = 1;
         }
         else
         {
            _loc12_ = polyA;
            _loc13_ = polyB;
            _loc14_ = xfA;
            _loc15_ = xfB;
            _loc16_ = _loc8_;
            manifold.m_type = b2Manifold.e_faceA;
            _loc17_ = 0;
         }
         var _loc21_:Vector.<ClipVertex> = s_incidentEdge;
         FindIncidentEdge(_loc21_,_loc12_,_loc14_,_loc16_,_loc13_,_loc15_);
         var _loc22_:int = _loc12_.m_vertexCount;
         var _loc23_:Vector.<b2Vec2> = _loc12_.m_vertices;
         var _loc24_:b2Vec2 = _loc23_[_loc16_];
         if(_loc16_ + 1 < _loc22_)
         {
            _loc25_ = _loc23_[int(_loc16_ + 1)];
         }
         else
         {
            _loc25_ = _loc23_[0];
         }
         var _loc26_:b2Vec2 = s_localTangent;
         _loc26_.Set(_loc25_.x - _loc24_.x,_loc25_.y - _loc24_.y);
         _loc26_.Normalize();
         var _loc27_:b2Vec2 = s_localNormal;
         _loc27_.x = _loc26_.y;
         _loc27_.y = -_loc26_.x;
         var _loc28_:b2Vec2 = s_planePoint;
         _loc28_.Set(0.5 * (_loc24_.x + _loc25_.x),0.5 * (_loc24_.y + _loc25_.y));
         var _loc29_:b2Vec2 = s_tangent;
         _loc20_ = _loc14_.R;
         _loc29_.x = _loc20_.col1.x * _loc26_.x + _loc20_.col2.x * _loc26_.y;
         _loc29_.y = _loc20_.col1.y * _loc26_.x + _loc20_.col2.y * _loc26_.y;
         var _loc30_:b2Vec2 = s_tangent2;
         _loc30_.x = -_loc29_.x;
         _loc30_.y = -_loc29_.y;
         var _loc31_:b2Vec2 = s_normal;
         _loc31_.x = _loc29_.y;
         _loc31_.y = -_loc29_.x;
         var _loc32_:b2Vec2 = s_v11;
         var _loc33_:b2Vec2 = s_v12;
         _loc32_.x = _loc14_.position.x + (_loc20_.col1.x * _loc24_.x + _loc20_.col2.x * _loc24_.y);
         _loc32_.y = _loc14_.position.y + (_loc20_.col1.y * _loc24_.x + _loc20_.col2.y * _loc24_.y);
         _loc33_.x = _loc14_.position.x + (_loc20_.col1.x * _loc25_.x + _loc20_.col2.x * _loc25_.y);
         _loc33_.y = _loc14_.position.y + (_loc20_.col1.y * _loc25_.x + _loc20_.col2.y * _loc25_.y);
         var _loc34_:Number = _loc31_.x * _loc32_.x + _loc31_.y * _loc32_.y;
         var _loc35_:Number = -_loc29_.x * _loc32_.x - _loc29_.y * _loc32_.y + _loc7_;
         var _loc36_:Number = _loc29_.x * _loc33_.x + _loc29_.y * _loc33_.y + _loc7_;
         var _loc37_:Vector.<ClipVertex> = s_clipPoints1;
         var _loc38_:Vector.<ClipVertex> = s_clipPoints2;
         _loc39_ = ClipSegmentToLine(_loc37_,_loc21_,_loc30_,_loc35_);
         if(_loc39_ < 2)
         {
            return;
         }
         _loc39_ = ClipSegmentToLine(_loc38_,_loc37_,_loc29_,_loc36_);
         if(_loc39_ < 2)
         {
            return;
         }
         manifold.m_localPlaneNormal.SetV(_loc27_);
         manifold.m_localPoint.SetV(_loc28_);
         var _loc40_:* = 0;
         var _loc41_:* = 0;
         while(_loc41_ < b2Settings.b2_maxManifoldPoints)
         {
            _loc6_ = _loc38_[_loc41_];
            _loc42_ = _loc31_.x * _loc6_.v.x + _loc31_.y * _loc6_.v.y - _loc34_;
            if(_loc42_ <= _loc7_)
            {
               _loc43_ = manifold.m_points[_loc40_];
               _loc20_ = _loc15_.R;
               _loc44_ = _loc6_.v.x - _loc15_.position.x;
               _loc45_ = _loc6_.v.y - _loc15_.position.y;
               _loc43_.m_localPoint.x = _loc44_ * _loc20_.col1.x + _loc45_ * _loc20_.col1.y;
               _loc43_.m_localPoint.y = _loc44_ * _loc20_.col2.x + _loc45_ * _loc20_.col2.y;
               _loc43_.m_id.Set(_loc6_.id);
               _loc43_.m_id.features.flip = _loc17_;
               _loc40_++;
            }
            _loc41_++;
         }
         manifold.m_pointCount = _loc40_;
      }
      
      public static function CollideCircles(manifold:b2Manifold, circle1:b2CircleShape, xf1:b2Transform, circle2:b2CircleShape, xf2:b2Transform) : void
      {
         var _loc6_:b2Mat22 = null;
         var _loc7_:b2Vec2 = null;
         manifold.m_pointCount = 0;
         _loc6_ = xf1.R;
         _loc7_ = circle1.m_p;
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
         manifold.m_type = b2Manifold.e_circles;
         manifold.m_localPoint.SetV(circle1.m_p);
         manifold.m_localPlaneNormal.SetZero();
         manifold.m_pointCount = 1;
         manifold.m_points[0].m_localPoint.SetV(circle2.m_p);
         manifold.m_points[0].m_id.key = 0;
      }
      
      public static function CollidePolygonAndCircle(manifold:b2Manifold, polygon:b2PolygonShape, xf1:b2Transform, circle:b2CircleShape, xf2:b2Transform) : void
      {
         var _loc6_:b2ManifoldPoint = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:b2Vec2 = null;
         var _loc12_:b2Mat22 = null;
         var _loc17_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         manifold.m_pointCount = 0;
         _loc12_ = xf2.R;
         _loc11_ = circle.m_p;
         var _loc13_:Number = xf2.position.x + (_loc12_.col1.x * _loc11_.x + _loc12_.col2.x * _loc11_.y);
         var _loc14_:Number = xf2.position.y + (_loc12_.col1.y * _loc11_.x + _loc12_.col2.y * _loc11_.y);
         _loc7_ = _loc13_ - xf1.position.x;
         _loc8_ = _loc14_ - xf1.position.y;
         _loc12_ = xf1.R;
         var _loc15_:Number = _loc7_ * _loc12_.col1.x + _loc8_ * _loc12_.col1.y;
         var _loc16_:Number = _loc7_ * _loc12_.col2.x + _loc8_ * _loc12_.col2.y;
         var _loc18_:int = 0;
         var _loc19_:Number = -Number.MAX_VALUE;
         var _loc20_:Number = polygon.m_radius + circle.m_radius;
         var _loc21_:int = polygon.m_vertexCount;
         var _loc22_:Vector.<b2Vec2> = polygon.m_vertices;
         var _loc23_:Vector.<b2Vec2> = polygon.m_normals;
         var _loc24_:* = 0;
         while(_loc24_ < _loc21_)
         {
            _loc11_ = _loc22_[_loc24_];
            _loc7_ = _loc15_ - _loc11_.x;
            _loc8_ = _loc16_ - _loc11_.y;
            _loc11_ = _loc23_[_loc24_];
            _loc31_ = _loc11_.x * _loc7_ + _loc11_.y * _loc8_;
            if(_loc31_ > _loc20_)
            {
               return;
            }
            if(_loc31_ > _loc19_)
            {
               _loc19_ = _loc31_;
               _loc18_ = _loc24_;
            }
            _loc24_++;
         }
         var _loc25_:int = _loc18_;
         var _loc26_:int = _loc25_ + 1 < _loc21_ ? int(_loc25_ + 1) : 0;
         var _loc27_:b2Vec2 = _loc22_[_loc25_];
         var _loc28_:b2Vec2 = _loc22_[_loc26_];
         if(_loc19_ < Number.MIN_VALUE)
         {
            manifold.m_pointCount = 1;
            manifold.m_type = b2Manifold.e_faceA;
            manifold.m_localPlaneNormal.SetV(_loc23_[_loc18_]);
            manifold.m_localPoint.x = 0.5 * (_loc27_.x + _loc28_.x);
            manifold.m_localPoint.y = 0.5 * (_loc27_.y + _loc28_.y);
            manifold.m_points[0].m_localPoint.SetV(circle.m_p);
            manifold.m_points[0].m_id.key = 0;
            return;
         }
         var _loc29_:Number = (_loc15_ - _loc27_.x) * (_loc28_.x - _loc27_.x) + (_loc16_ - _loc27_.y) * (_loc28_.y - _loc27_.y);
         var _loc30_:Number = (_loc15_ - _loc28_.x) * (_loc27_.x - _loc28_.x) + (_loc16_ - _loc28_.y) * (_loc27_.y - _loc28_.y);
         if(_loc29_ <= 0)
         {
            if((_loc15_ - _loc27_.x) * (_loc15_ - _loc27_.x) + (_loc16_ - _loc27_.y) * (_loc16_ - _loc27_.y) > _loc20_ * _loc20_)
            {
               return;
            }
            manifold.m_pointCount = 1;
            manifold.m_type = b2Manifold.e_faceA;
            manifold.m_localPlaneNormal.x = _loc15_ - _loc27_.x;
            manifold.m_localPlaneNormal.y = _loc16_ - _loc27_.y;
            manifold.m_localPlaneNormal.Normalize();
            manifold.m_localPoint.SetV(_loc27_);
            manifold.m_points[0].m_localPoint.SetV(circle.m_p);
            manifold.m_points[0].m_id.key = 0;
         }
         else if(_loc30_ <= 0)
         {
            if((_loc15_ - _loc28_.x) * (_loc15_ - _loc28_.x) + (_loc16_ - _loc28_.y) * (_loc16_ - _loc28_.y) > _loc20_ * _loc20_)
            {
               return;
            }
            manifold.m_pointCount = 1;
            manifold.m_type = b2Manifold.e_faceA;
            manifold.m_localPlaneNormal.x = _loc15_ - _loc28_.x;
            manifold.m_localPlaneNormal.y = _loc16_ - _loc28_.y;
            manifold.m_localPlaneNormal.Normalize();
            manifold.m_localPoint.SetV(_loc28_);
            manifold.m_points[0].m_localPoint.SetV(circle.m_p);
            manifold.m_points[0].m_id.key = 0;
         }
         else
         {
            _loc32_ = 0.5 * (_loc27_.x + _loc28_.x);
            _loc33_ = 0.5 * (_loc27_.y + _loc28_.y);
            _loc19_ = (_loc15_ - _loc32_) * _loc23_[_loc25_].x + (_loc16_ - _loc33_) * _loc23_[_loc25_].y;
            if(_loc19_ > _loc20_)
            {
               return;
            }
            manifold.m_pointCount = 1;
            manifold.m_type = b2Manifold.e_faceA;
            manifold.m_localPlaneNormal.x = _loc23_[_loc25_].x;
            manifold.m_localPlaneNormal.y = _loc23_[_loc25_].y;
            manifold.m_localPlaneNormal.Normalize();
            manifold.m_localPoint.Set(_loc32_,_loc33_);
            manifold.m_points[0].m_localPoint.SetV(circle.m_p);
            manifold.m_points[0].m_id.key = 0;
         }
      }
      
      public static function TestOverlap(a:b2AABB, b:b2AABB) : Boolean
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
   }
}

