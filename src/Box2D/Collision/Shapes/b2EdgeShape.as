package Box2D.Collision.Shapes
{
   import Box2D.Collision.b2AABB;
   import Box2D.Collision.b2RayCastInput;
   import Box2D.Collision.b2RayCastOutput;
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import flash.Boot;
   
   public class b2EdgeShape extends b2Shape
   {
      
      public var s_supportVec:b2Vec2;
      
      public var m_v2:b2Vec2;
      
      public var m_v1:b2Vec2;
      
      public var m_prevEdge:b2EdgeShape;
      
      public var m_normal:b2Vec2;
      
      public var m_nextEdge:b2EdgeShape;
      
      public var m_length:Number;
      
      public var m_direction:b2Vec2;
      
      public var m_cornerDir2:b2Vec2;
      
      public var m_cornerDir1:b2Vec2;
      
      public var m_cornerConvex2:Boolean;
      
      public var m_cornerConvex1:Boolean;
      
      public var m_coreV2:b2Vec2;
      
      public var m_coreV1:b2Vec2;
      
      public function b2EdgeShape(v1:b2Vec2 = undefined, v2:b2Vec2 = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super();
            s_supportVec = new b2Vec2();
            m_v1 = new b2Vec2();
            m_v2 = new b2Vec2();
            m_coreV1 = new b2Vec2();
            m_coreV2 = new b2Vec2();
            m_normal = new b2Vec2();
            m_direction = new b2Vec2();
            m_cornerDir1 = new b2Vec2();
            m_cornerDir2 = new b2Vec2();
            m_type = 3;
            m_prevEdge = null;
            m_nextEdge = null;
            m_v1 = v1;
            m_v2 = v2;
            m_direction.set(m_v2.x - m_v1.x,m_v2.y - m_v1.y);
            m_length = m_direction.normalize();
            m_normal.set(m_direction.y,-m_direction.x);
            m_coreV1.set(-b2Settings.b2_toiSlop * (m_normal.x - m_direction.x) + m_v1.x,-b2Settings.b2_toiSlop * (m_normal.y - m_direction.y) + m_v1.y);
            m_coreV2.set(-b2Settings.b2_toiSlop * (m_normal.x + m_direction.x) + m_v2.x,-b2Settings.b2_toiSlop * (m_normal.y + m_direction.y) + m_v2.y);
            m_cornerDir1 = m_normal;
            m_cornerDir2.set(-m_normal.x,-m_normal.y);
         }
      }
      
      override public function testPoint(transform:b2Transform, p:b2Vec2) : Boolean
      {
         return TestPoint(transform,p);
      }
      
      public function support(xf:b2Transform, dX:Number, dY:Number) : b2Vec2
      {
         return Support(xf,dX,dY);
      }
      
      public function setPrevEdge(edge:b2EdgeShape, core:b2Vec2, cornerDir:b2Vec2, convex:Boolean) : void
      {
         SetPrevEdge(edge,core,cornerDir,convex);
      }
      
      public function setNextEdge(edge:b2EdgeShape, core:b2Vec2, cornerDir:b2Vec2, convex:Boolean) : void
      {
         SetNextEdge(edge,core,cornerDir,convex);
      }
      
      override public function rayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform) : Boolean
      {
         return RayCast(output,input,transform);
      }
      
      public function getVertex2() : b2Vec2
      {
         return GetVertex2();
      }
      
      public function getVertex1() : b2Vec2
      {
         return GetVertex1();
      }
      
      public function getPrevEdge() : b2EdgeShape
      {
         return GetPrevEdge();
      }
      
      public function getNormalVector() : b2Vec2
      {
         return GetNormalVector();
      }
      
      public function getNextEdge() : b2EdgeShape
      {
         return GetNextEdge();
      }
      
      public function getLength() : Number
      {
         return GetLength();
      }
      
      public function getFirstVertex(xf:b2Transform) : b2Vec2
      {
         return GetFirstVertex(xf);
      }
      
      public function getDirectionVector() : b2Vec2
      {
         return GetDirectionVector();
      }
      
      public function getCorner2Vector() : b2Vec2
      {
         return GetCorner2Vector();
      }
      
      public function getCorner1Vector() : b2Vec2
      {
         return GetCorner1Vector();
      }
      
      public function getCoreVertex2() : b2Vec2
      {
         return GetCoreVertex2();
      }
      
      public function getCoreVertex1() : b2Vec2
      {
         return GetCoreVertex1();
      }
      
      public function corner2IsConvex() : Boolean
      {
         return Corner2IsConvex();
      }
      
      public function corner1IsConvex() : Boolean
      {
         return Corner1IsConvex();
      }
      
      override public function computeSubmergedArea(normal:b2Vec2, offset:Number, xf:b2Transform, c:b2Vec2) : Number
      {
         return ComputeSubmergedArea(normal,offset,xf,c);
      }
      
      override public function computeMass(massData:b2MassData, density:Number) : void
      {
         ComputeMass(massData,density);
      }
      
      override public function computeAABB(aabb:b2AABB, transform:b2Transform) : void
      {
         ComputeAABB(aabb,transform);
      }
      
      override public function TestPoint(transform:b2Transform, p:b2Vec2) : Boolean
      {
         return false;
      }
      
      public function Support(xf:b2Transform, dX:Number, dY:Number) : b2Vec2
      {
         var _loc4_:b2Mat22 = xf.R;
         var _loc5_:Number = xf.position.x + (_loc4_.col1.x * m_coreV1.x + _loc4_.col2.x * m_coreV1.y);
         var _loc6_:Number = xf.position.y + (_loc4_.col1.y * m_coreV1.x + _loc4_.col2.y * m_coreV1.y);
         var _loc7_:Number = xf.position.x + (_loc4_.col1.x * m_coreV2.x + _loc4_.col2.x * m_coreV2.y);
         var _loc8_:Number = xf.position.y + (_loc4_.col1.y * m_coreV2.x + _loc4_.col2.y * m_coreV2.y);
         if(_loc5_ * dX + _loc6_ * dY > _loc7_ * dX + _loc8_ * dY)
         {
            s_supportVec.x = _loc5_;
            s_supportVec.y = _loc6_;
         }
         else
         {
            s_supportVec.x = _loc7_;
            s_supportVec.y = _loc8_;
         }
         return s_supportVec;
      }
      
      public function SetPrevEdge(edge:b2EdgeShape, core:b2Vec2, cornerDir:b2Vec2, convex:Boolean) : void
      {
         m_prevEdge = edge;
         m_coreV1 = core;
         m_cornerDir1 = cornerDir;
         m_cornerConvex1 = convex;
      }
      
      public function SetNextEdge(edge:b2EdgeShape, core:b2Vec2, cornerDir:b2Vec2, convex:Boolean) : void
      {
         m_nextEdge = edge;
         m_coreV2 = core;
         m_cornerDir2 = cornerDir;
         m_cornerConvex2 = convex;
      }
      
      override public function RayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform) : Boolean
      {
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc4_:Number = input.p2.x - input.p1.x;
         var _loc5_:Number = input.p2.y - input.p1.y;
         var _loc6_:b2Mat22 = transform.R;
         var _loc7_:Number = transform.position.x + (_loc6_.col1.x * m_v1.x + _loc6_.col2.x * m_v1.y);
         var _loc8_:Number = transform.position.y + (_loc6_.col1.y * m_v1.x + _loc6_.col2.y * m_v1.y);
         var _loc9_:Number = transform.position.y + (_loc6_.col1.y * m_v2.x + _loc6_.col2.y * m_v2.y) - _loc8_;
         var _loc10_:Number = -(transform.position.x + (_loc6_.col1.x * m_v2.x + _loc6_.col2.x * m_v2.y) - _loc7_);
         var _loc11_:Number = 100 * Number(Number.MIN_VALUE);
         var _loc12_:Number = -(_loc4_ * _loc9_ + _loc5_ * _loc10_);
         if(_loc12_ > _loc11_)
         {
            _loc13_ = input.p1.x - _loc7_;
            _loc14_ = input.p1.y - _loc8_;
            _loc15_ = _loc13_ * _loc9_ + _loc14_ * _loc10_;
            if(0 <= _loc15_ && _loc15_ <= input.maxFraction * _loc12_)
            {
               _loc16_ = -_loc4_ * _loc14_ + _loc5_ * _loc13_;
               if(-_loc11_ * _loc12_ <= _loc16_ && _loc16_ <= _loc12_ * (1 + _loc11_))
               {
                  _loc15_ /= _loc12_;
                  output.fraction = _loc15_;
                  _loc17_ = Math.sqrt(_loc9_ * _loc9_ + _loc10_ * _loc10_);
                  output.normal.x = _loc9_ / _loc17_;
                  output.normal.y = _loc10_ / _loc17_;
                  return true;
               }
            }
         }
         return false;
      }
      
      public function GetVertex2() : b2Vec2
      {
         return m_v2;
      }
      
      public function GetVertex1() : b2Vec2
      {
         return m_v1;
      }
      
      public function GetPrevEdge() : b2EdgeShape
      {
         return m_prevEdge;
      }
      
      public function GetNormalVector() : b2Vec2
      {
         return m_normal;
      }
      
      public function GetNextEdge() : b2EdgeShape
      {
         return m_nextEdge;
      }
      
      public function GetLength() : Number
      {
         return m_length;
      }
      
      public function GetFirstVertex(xf:b2Transform) : b2Vec2
      {
         var _loc2_:b2Mat22 = xf.R;
         return new b2Vec2(xf.position.x + (_loc2_.col1.x * m_coreV1.x + _loc2_.col2.x * m_coreV1.y),xf.position.y + (_loc2_.col1.y * m_coreV1.x + _loc2_.col2.y * m_coreV1.y));
      }
      
      public function GetDirectionVector() : b2Vec2
      {
         return m_direction;
      }
      
      public function GetCorner2Vector() : b2Vec2
      {
         return m_cornerDir2;
      }
      
      public function GetCorner1Vector() : b2Vec2
      {
         return m_cornerDir1;
      }
      
      public function GetCoreVertex2() : b2Vec2
      {
         return m_coreV2;
      }
      
      public function GetCoreVertex1() : b2Vec2
      {
         return m_coreV1;
      }
      
      public function Corner2IsConvex() : Boolean
      {
         return m_cornerConvex2;
      }
      
      public function Corner1IsConvex() : Boolean
      {
         return m_cornerConvex1;
      }
      
      override public function ComputeSubmergedArea(normal:b2Vec2, offset:Number, xf:b2Transform, c:b2Vec2) : Number
      {
         var _loc5_:b2Vec2 = new b2Vec2(normal.x * offset,normal.y * offset);
         var _loc6_:b2Vec2 = b2Math.mulX(xf,m_v1);
         var _loc7_:b2Vec2 = b2Math.mulX(xf,m_v2);
         var _loc8_:Number = b2Math.dot(normal,_loc6_) - offset;
         var _loc9_:Number = b2Math.dot(normal,_loc7_) - offset;
         if(_loc8_ > 0)
         {
            if(_loc9_ > 0)
            {
               return 0;
            }
            _loc6_.x = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.x + _loc8_ / (_loc8_ - _loc9_) * _loc7_.x;
            _loc6_.y = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.y + _loc8_ / (_loc8_ - _loc9_) * _loc7_.y;
         }
         else if(_loc9_ > 0)
         {
            _loc7_.x = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.x + _loc8_ / (_loc8_ - _loc9_) * _loc7_.x;
            _loc7_.y = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.y + _loc8_ / (_loc8_ - _loc9_) * _loc7_.y;
         }
         c.x = (_loc5_.x + _loc6_.x + _loc7_.x) / 3;
         c.y = (_loc5_.y + _loc6_.y + _loc7_.y) / 3;
         return 0.5 * ((_loc6_.x - _loc5_.x) * (_loc7_.y - _loc5_.y) - (_loc6_.y - _loc5_.y) * (_loc7_.x - _loc5_.x));
      }
      
      override public function ComputeMass(massData:b2MassData, density:Number) : void
      {
         massData.mass = 0;
         massData.center.setV(m_v1);
         massData.I = 0;
      }
      
      override public function ComputeAABB(aabb:b2AABB, transform:b2Transform) : void
      {
         var _loc3_:b2Mat22 = transform.R;
         var _loc4_:Number = transform.position.x + (_loc3_.col1.x * m_v1.x + _loc3_.col2.x * m_v1.y);
         var _loc5_:Number = transform.position.y + (_loc3_.col1.y * m_v1.x + _loc3_.col2.y * m_v1.y);
         var _loc6_:Number = transform.position.x + (_loc3_.col1.x * m_v2.x + _loc3_.col2.x * m_v2.y);
         var _loc7_:Number = transform.position.y + (_loc3_.col1.y * m_v2.x + _loc3_.col2.y * m_v2.y);
         if(_loc4_ < _loc6_)
         {
            aabb.lowerBound.x = _loc4_;
            aabb.upperBound.x = _loc6_;
         }
         else
         {
            aabb.lowerBound.x = _loc6_;
            aabb.upperBound.x = _loc4_;
         }
         if(_loc5_ < _loc7_)
         {
            aabb.lowerBound.y = _loc5_;
            aabb.upperBound.y = _loc7_;
         }
         else
         {
            aabb.lowerBound.y = _loc7_;
            aabb.upperBound.y = _loc5_;
         }
      }
   }
}

