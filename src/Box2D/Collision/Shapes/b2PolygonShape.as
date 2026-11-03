package Box2D.Collision.Shapes
{
   import Box2D.Collision.b2AABB;
   import Box2D.Collision.b2OBB;
   import Box2D.Collision.b2RayCastInput;
   import Box2D.Collision.b2RayCastOutput;
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import box2dcompat.As3Array;
   import flash.Boot;
   
   public class b2PolygonShape extends b2Shape
   {
      
      public static var s_mat:b2Mat22 = new b2Mat22();
      
      public var m_vertices:Array;
      
      public var m_vertexCount:int;
      
      public var m_normals:Array;
      
      public var m_centroid:b2Vec2;
      
      public function b2PolygonShape()
      {
         if(!Boot.skip_constructor)
         {
            m_vertexCount = 0;
            super();
            m_type = 2;
            m_centroid = new b2Vec2();
            m_vertices = [];
            m_normals = [];
         }
      }
      
      public static function asArray(vertices:Array, vertexCount:Number) : b2PolygonShape
      {
         var _loc3_:b2PolygonShape = new b2PolygonShape();
         _loc3_.setAsArray(vertices,vertexCount);
         return _loc3_;
      }
      
      public static function asVector(vertices:Array, vertexCount:Number) : b2PolygonShape
      {
         var _loc3_:b2PolygonShape = new b2PolygonShape();
         _loc3_.setAsVector(vertices,vertexCount);
         return _loc3_;
      }
      
      public static function asBox(hx:Number, hy:Number) : b2PolygonShape
      {
         var _loc3_:b2PolygonShape = new b2PolygonShape();
         _loc3_.setAsBox(hx,hy);
         return _loc3_;
      }
      
      public static function asOrientedBox(hx:Number, hy:Number, center:b2Vec2 = undefined, angle:Number = 0) : b2PolygonShape
      {
         var _loc5_:b2PolygonShape = new b2PolygonShape();
         _loc5_.setAsOrientedBox(hx,hy,center,angle);
         return _loc5_;
      }
      
      public static function asEdge(v1:b2Vec2, v2:b2Vec2) : b2PolygonShape
      {
         var _loc3_:b2PolygonShape = new b2PolygonShape();
         _loc3_.setAsEdge(v1,v2);
         return _loc3_;
      }
      
      public static function computeCentroid(vs:Array, count:int) : b2Vec2
      {
         var _loc10_:int = 0;
         var _loc11_:* = null as b2Vec2;
         var _loc12_:* = null as b2Vec2;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc3_:b2Vec2 = new b2Vec2();
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc7_:Number = 0.3333333333333333;
         var _loc8_:int = 0;
         var _loc9_:int = count;
         while(_loc8_ < _loc9_)
         {
            _loc10_ = _loc8_++;
            _loc11_ = vs[_loc10_];
            _loc12_ = _loc10_ + 1 < count ? vs[_loc10_ + 1] : vs[0];
            _loc13_ = _loc11_.x - _loc5_;
            _loc14_ = _loc11_.y - _loc6_;
            _loc15_ = _loc12_.x - _loc5_;
            _loc16_ = _loc12_.y - _loc6_;
            _loc17_ = _loc13_ * _loc16_ - _loc14_ * _loc15_;
            _loc18_ = 0.5 * _loc17_;
            _loc4_ += _loc18_;
            _loc3_.x += _loc18_ * _loc7_ * (_loc5_ + _loc11_.x + _loc12_.x);
            _loc3_.y += _loc18_ * _loc7_ * (_loc6_ + _loc11_.y + _loc12_.y);
         }
         _loc3_.x *= 1 / _loc4_;
         _loc3_.y *= 1 / _loc4_;
         return _loc3_;
      }
      
      public static function computeOBB(obb:b2OBB, vs:Array, count:int) : void
      {
         var _loc8_:int = 0;
         var _loc10_:* = null as b2Vec2;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:* = null as b2Mat22;
         var _loc5_:Array = [];
         var _loc6_:int = 0;
         var _loc7_:* = count;
         while(_loc6_ < _loc7_)
         {
            _loc8_ = _loc6_++;
            _loc5_[_loc8_] = vs[_loc8_];
         }
         _loc5_[count] = _loc5_[0];
         var _loc9_:Number = Number(Number.MAX_VALUE);
         _loc6_ = 1;
         _loc7_ = count + 1;
         while(_loc6_ < _loc7_)
         {
            _loc8_ = _loc6_++;
            _loc10_ = _loc5_[_loc8_ - 1];
            _loc11_ = _loc5_[_loc8_].x - _loc10_.x;
            _loc12_ = _loc5_[_loc8_].y - _loc10_.y;
            _loc13_ = Math.sqrt(_loc11_ * _loc11_ + _loc12_ * _loc12_);
            _loc11_ /= _loc13_;
            _loc12_ /= _loc13_;
            _loc14_ = -_loc12_;
            _loc15_ = _loc11_;
            _loc16_ = Number(Number.MAX_VALUE);
            _loc17_ = Number(Number.MAX_VALUE);
            _loc18_ = -Number(Number.MAX_VALUE);
            _loc19_ = -Number(Number.MAX_VALUE);
            _loc20_ = 0;
            _loc21_ = count;
            while(_loc20_ < _loc21_)
            {
               _loc22_ = _loc20_++;
               _loc23_ = _loc5_[_loc22_].x - _loc10_.x;
               _loc24_ = _loc5_[_loc22_].y - _loc10_.y;
               _loc25_ = _loc11_ * _loc23_ + _loc12_ * _loc24_;
               _loc26_ = _loc14_ * _loc23_ + _loc15_ * _loc24_;
               if(_loc25_ < _loc16_)
               {
                  _loc16_ = _loc25_;
               }
               if(_loc26_ < _loc17_)
               {
                  _loc17_ = _loc26_;
               }
               if(_loc25_ > _loc18_)
               {
                  _loc18_ = _loc25_;
               }
               if(_loc26_ > _loc19_)
               {
                  _loc19_ = _loc26_;
               }
            }
            _loc23_ = (_loc18_ - _loc16_) * (_loc19_ - _loc17_);
            if(_loc23_ < 0.95 * _loc9_)
            {
               _loc9_ = _loc23_;
               obb.R.col1.x = _loc11_;
               obb.R.col1.y = _loc12_;
               obb.R.col2.x = _loc14_;
               obb.R.col2.y = _loc15_;
               _loc24_ = 0.5 * (_loc16_ + _loc18_);
               _loc25_ = 0.5 * (_loc17_ + _loc19_);
               _loc27_ = obb.R;
               obb.center.x = _loc10_.x + (_loc27_.col1.x * _loc24_ + _loc27_.col2.x * _loc25_);
               obb.center.y = _loc10_.y + (_loc27_.col1.y * _loc24_ + _loc27_.col2.y * _loc25_);
               obb.extents.x = 0.5 * (_loc18_ - _loc16_);
               obb.extents.y = 0.5 * (_loc19_ - _loc17_);
            }
         }
      }
      
      public static function AsArray(vertices:*, vertexCount:Number) : b2PolygonShape
      {
         return b2PolygonShape.asArray(As3Array.of(vertices),vertexCount);
      }
      
      public static function AsVector(vertices:*, vertexCount:Number) : b2PolygonShape
      {
         return b2PolygonShape.asVector(As3Array.of(vertices),vertexCount);
      }
      
      public static function AsBox(hx:Number, hy:Number) : b2PolygonShape
      {
         return b2PolygonShape.asBox(hx,hy);
      }
      
      public static function AsOrientedBox(hx:Number, hy:Number, center:b2Vec2 = undefined, angle:Number = 0) : b2PolygonShape
      {
         return b2PolygonShape.asOrientedBox(hx,hy,center,angle);
      }
      
      public static function AsEdge(v1:b2Vec2, v2:b2Vec2) : b2PolygonShape
      {
         return b2PolygonShape.asEdge(v1,v2);
      }
      
      public static function ComputeCentroid(vs:*, count:int) : b2Vec2
      {
         return b2PolygonShape.computeCentroid(As3Array.of(vs),count);
      }
      
      public static function ComputeOBB(obb:b2OBB, vs:*, count:int) : void
      {
         b2PolygonShape.computeOBB(obb,As3Array.of(vs),count);
      }
      
      public function validate() : Boolean
      {
         return false;
      }
      
      override public function testPoint(xf:b2Transform, p:b2Vec2) : Boolean
      {
         return TestPoint(xf,p);
      }
      
      public function setAsVector(vertices:Array, vertexCount:Number = 0) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:* = null as b2Vec2;
         if(vertexCount == 0)
         {
            vertexCount = int(vertices.length);
         }
         b2Settings.b2Assert(2 <= vertexCount);
         m_vertexCount = int(vertexCount);
         reserve(int(vertexCount));
         var _loc4_:int = 0;
         var _loc5_:int = m_vertexCount;
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            m_vertices[_loc6_].setV(vertices[_loc6_]);
         }
         _loc4_ = 0;
         _loc5_ = m_vertexCount;
         while(_loc4_ < _loc5_)
         {
            _loc7_ = _loc6_ = _loc4_++;
            _loc8_ = _loc6_ + 1 < m_vertexCount ? _loc6_ + 1 : 0;
            _loc9_ = b2Math.subtractVV(m_vertices[_loc8_],m_vertices[_loc7_]);
            b2Settings.b2Assert(_loc9_.lengthSquared() > Number(Number.MIN_VALUE));
            m_normals[_loc6_].setV(b2Math.crossVF(_loc9_,1));
            m_normals[_loc6_].normalize();
         }
         m_centroid = b2PolygonShape.computeCentroid(m_vertices,m_vertexCount);
      }
      
      public function setAsOrientedBox(hx:Number, hy:Number, center:b2Vec2 = undefined, angle:Number = 0) : void
      {
         SetAsOrientedBox(hx,hy,center,angle);
      }
      
      public function setAsEdge(v1:b2Vec2, v2:b2Vec2) : void
      {
         SetAsEdge(v1,v2);
      }
      
      public function setAsBox(hx:Number, hy:Number) : void
      {
         SetAsBox(hx,hy);
      }
      
      public function setAsArray(vertices:Array, vertexCount:Number = 0) : void
      {
         var _loc5_:* = null;
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < int(vertices.length))
         {
            _loc5_ = vertices[_loc4_];
            _loc4_++;
            _loc3_.push(_loc5_);
         }
         setAsVector(_loc3_,vertexCount);
      }
      
      override public function set(other:b2Shape) : void
      {
         Set(other);
      }
      
      public function reserve(count:int) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = int(m_vertices.length);
         var _loc3_:int = count;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc2_++;
            m_vertices[_loc4_] = new b2Vec2();
            m_normals[_loc4_] = new b2Vec2();
         }
      }
      
      override public function rayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform) : Boolean
      {
         return RayCast(output,input,transform);
      }
      
      public function getVertices() : Array
      {
         return GetVertices();
      }
      
      public function getVertexCount() : int
      {
         return GetVertexCount();
      }
      
      public function getSupportVertex(d:b2Vec2) : b2Vec2
      {
         return GetSupportVertex(d);
      }
      
      public function getSupport(d:b2Vec2) : int
      {
         return GetSupport(d);
      }
      
      public function getNormals() : Array
      {
         return GetNormals();
      }
      
      override public function copy() : b2Shape
      {
         return Copy();
      }
      
      override public function computeSubmergedArea(normal:b2Vec2, offset:Number, xf:b2Transform, c:b2Vec2) : Number
      {
         return ComputeSubmergedArea(normal,offset,xf,c);
      }
      
      override public function computeMass(massData:b2MassData, density:Number) : void
      {
         ComputeMass(massData,density);
      }
      
      override public function computeAABB(aabb:b2AABB, xf:b2Transform) : void
      {
         ComputeAABB(aabb,xf);
      }
      
      override public function TestPoint(xf:b2Transform, p:b2Vec2) : Boolean
      {
         var _loc3_:* = null as b2Vec2;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc4_:b2Mat22 = xf.R;
         var _loc5_:Number = p.x - xf.position.x;
         var _loc6_:Number = p.y - xf.position.y;
         var _loc7_:Number = _loc5_ * _loc4_.col1.x + _loc6_ * _loc4_.col1.y;
         var _loc8_:Number = _loc5_ * _loc4_.col2.x + _loc6_ * _loc4_.col2.y;
         var _loc9_:int = 0;
         var _loc10_:int = m_vertexCount;
         while(_loc9_ < _loc10_)
         {
            _loc11_ = _loc9_++;
            _loc3_ = m_vertices[_loc11_];
            _loc5_ = _loc7_ - _loc3_.x;
            _loc6_ = _loc8_ - _loc3_.y;
            _loc3_ = m_normals[_loc11_];
            _loc12_ = _loc3_.x * _loc5_ + _loc3_.y * _loc6_;
            if(_loc12_ > 0)
            {
               return false;
            }
         }
         return true;
      }
      
      public function SetAsVector(vertices:*, vertexCount:Number = 0) : void
      {
         setAsVector(As3Array.of(vertices),vertexCount);
      }
      
      public function SetAsOrientedBox(hx:Number, hy:Number, center:b2Vec2 = undefined, angle:Number = 0) : void
      {
         var _loc8_:int = 0;
         m_vertexCount = 4;
         reserve(4);
         m_vertices[0].set(-hx,-hy);
         m_vertices[1].set(hx,-hy);
         m_vertices[2].set(hx,hy);
         m_vertices[3].set(-hx,hy);
         m_normals[0].set(0,-1);
         m_normals[1].set(1,0);
         m_normals[2].set(0,1);
         m_normals[3].set(-1,0);
         m_centroid = center;
         var _loc5_:b2Transform = new b2Transform();
         _loc5_.position = center;
         _loc5_.R.set(angle);
         var _loc6_:int = 0;
         var _loc7_:int = m_vertexCount;
         while(_loc6_ < _loc7_)
         {
            _loc8_ = _loc6_++;
            m_vertices[_loc8_] = b2Math.mulX(_loc5_,m_vertices[_loc8_]);
            m_normals[_loc8_] = b2Math.mulMV(_loc5_.R,m_normals[_loc8_]);
         }
      }
      
      public function SetAsEdge(v1:b2Vec2, v2:b2Vec2) : void
      {
         m_vertexCount = 2;
         reserve(2);
         m_vertices[0].setV(v1);
         m_vertices[1].setV(v2);
         m_centroid.x = 0.5 * (v1.x + v2.x);
         m_centroid.y = 0.5 * (v1.y + v2.y);
         m_normals[0] = b2Math.crossVF(b2Math.subtractVV(v2,v1),1);
         m_normals[0].normalize();
         m_normals[1].x = -m_normals[0].x;
         m_normals[1].y = -m_normals[0].y;
      }
      
      public function SetAsBox(hx:Number, hy:Number) : void
      {
         m_vertexCount = 4;
         reserve(4);
         m_vertices[0].set(-hx,-hy);
         m_vertices[1].set(hx,-hy);
         m_vertices[2].set(hx,hy);
         m_vertices[3].set(-hx,hy);
         m_normals[0].set(0,-1);
         m_normals[1].set(1,0);
         m_normals[2].set(0,1);
         m_normals[3].set(-1,0);
         m_centroid.setZero();
      }
      
      public function SetAsArray(vertices:*, vertexCount:Number = 0) : void
      {
         setAsArray(As3Array.of(vertices),vertexCount);
      }
      
      override public function Set(other:b2Shape) : void
      {
         var _loc2_:* = null as b2PolygonShape;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         super.Set(other);
         if(other is b2PolygonShape)
         {
            _loc2_ = b2PolygonShape(other);
            m_centroid.setV(_loc2_.m_centroid);
            m_vertexCount = _loc2_.m_vertexCount;
            reserve(m_vertexCount);
            _loc3_ = 0;
            _loc4_ = m_vertexCount;
            while(_loc3_ < _loc4_)
            {
               _loc5_ = _loc3_++;
               m_vertices[_loc5_].setV(_loc2_.m_vertices[_loc5_]);
               m_normals[_loc5_].setV(_loc2_.m_normals[_loc5_]);
            }
         }
      }
      
      override public function RayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform) : Boolean
      {
         var _loc6_:* = null as b2Vec2;
         var _loc19_:int = 0;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc4_:Number = 0;
         var _loc5_:Number = input.maxFraction;
         var _loc7_:Number = input.p1.x - transform.position.x;
         var _loc8_:Number = input.p1.y - transform.position.y;
         var _loc9_:b2Mat22 = transform.R;
         var _loc10_:Number = _loc7_ * _loc9_.col1.x + _loc8_ * _loc9_.col1.y;
         var _loc11_:Number = _loc7_ * _loc9_.col2.x + _loc8_ * _loc9_.col2.y;
         _loc7_ = input.p2.x - transform.position.x;
         _loc8_ = input.p2.y - transform.position.y;
         _loc9_ = transform.R;
         var _loc12_:Number = _loc7_ * _loc9_.col1.x + _loc8_ * _loc9_.col1.y;
         var _loc13_:Number = _loc7_ * _loc9_.col2.x + _loc8_ * _loc9_.col2.y;
         var _loc14_:Number = _loc12_ - _loc10_;
         var _loc15_:Number = _loc13_ - _loc11_;
         var _loc16_:int = -1;
         var _loc17_:int = 0;
         var _loc18_:int = m_vertexCount;
         while(_loc17_ < _loc18_)
         {
            _loc19_ = _loc17_++;
            _loc6_ = m_vertices[_loc19_];
            _loc7_ = _loc6_.x - _loc10_;
            _loc8_ = _loc6_.y - _loc11_;
            _loc6_ = m_normals[_loc19_];
            _loc20_ = _loc6_.x * _loc7_ + _loc6_.y * _loc8_;
            _loc21_ = _loc6_.x * _loc14_ + _loc6_.y * _loc15_;
            if(_loc21_ == 0)
            {
               if(_loc20_ < 0)
               {
                  return false;
               }
            }
            else if(_loc21_ < 0 && _loc20_ < _loc4_ * _loc21_)
            {
               _loc4_ = _loc20_ / _loc21_;
               _loc16_ = _loc19_;
            }
            else if(_loc21_ > 0 && _loc20_ < _loc5_ * _loc21_)
            {
               _loc5_ = _loc20_ / _loc21_;
            }
            if(_loc5_ < _loc4_ - Number(Number.MIN_VALUE))
            {
               return false;
            }
         }
         if(_loc16_ >= 0)
         {
            output.fraction = _loc4_;
            _loc9_ = transform.R;
            _loc6_ = m_normals[_loc16_];
            output.normal.x = _loc9_.col1.x * _loc6_.x + _loc9_.col2.x * _loc6_.y;
            output.normal.y = _loc9_.col1.y * _loc6_.x + _loc9_.col2.y * _loc6_.y;
            return true;
         }
         return false;
      }
      
      public function GetVertices() : Array
      {
         return m_vertices;
      }
      
      public function GetVertexCount() : int
      {
         return m_vertexCount;
      }
      
      public function GetSupportVertex(d:b2Vec2) : b2Vec2
      {
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:Number = m_vertices[0].x * d.x + m_vertices[0].y * d.y;
         var _loc4_:int = 1;
         var _loc5_:int = m_vertexCount;
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
      
      public function GetSupport(d:b2Vec2) : int
      {
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:Number = m_vertices[0].x * d.x + m_vertices[0].y * d.y;
         var _loc4_:int = 1;
         var _loc5_:int = m_vertexCount;
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
      
      public function GetNormals() : Array
      {
         return m_normals;
      }
      
      override public function Copy() : b2Shape
      {
         var _loc1_:b2PolygonShape = new b2PolygonShape();
         _loc1_.set(this);
         return _loc1_;
      }
      
      override public function ComputeSubmergedArea(normal:b2Vec2, offset:Number, xf:b2Transform, c:b2Vec2) : Number
      {
         var _loc14_:int = 0;
         var _loc15_:Boolean = false;
         var _loc16_:* = null as b2MassData;
         var _loc24_:* = null as b2Vec2;
         var _loc25_:Number = NaN;
         var _loc5_:b2Vec2 = b2Math.mulTMV(xf.R,normal);
         var _loc6_:Number = offset - b2Math.dot(normal,xf.position);
         var _loc7_:Array = [];
         var _loc8_:int = 0;
         var _loc9_:* = -1;
         var _loc10_:* = -1;
         var _loc11_:Boolean = false;
         var _loc12_:int = 0;
         var _loc13_:int = m_vertexCount;
         while(_loc12_ < _loc13_)
         {
            _loc14_ = _loc12_++;
            _loc7_[_loc14_] = b2Math.dot(_loc5_,m_vertices[_loc14_]) - _loc6_;
            _loc15_ = Number(_loc7_[_loc14_]) < -Number(Number.MIN_VALUE);
            if(_loc14_ > 0)
            {
               if(_loc15_)
               {
                  if(!_loc11_)
                  {
                     _loc9_ = _loc14_ - 1;
                     _loc8_++;
                  }
               }
               else if(_loc11_)
               {
                  _loc10_ = _loc14_ - 1;
                  _loc8_++;
               }
            }
            _loc11_ = _loc15_;
         }
         switch(_loc8_)
         {
            case 0:
               if(_loc11_)
               {
                  _loc16_ = new b2MassData();
                  computeMass(_loc16_,1);
                  c.setV(b2Math.mulX(xf,_loc16_.center));
                  return _loc16_.mass;
               }
               return 0;
               break;
            case 1:
               if(_loc9_ == -1)
               {
                  _loc9_ = m_vertexCount - 1;
                  break;
               }
               _loc10_ = m_vertexCount - 1;
         }
         _loc12_ = (_loc9_ + 1) % m_vertexCount;
         _loc13_ = (_loc10_ + 1) % m_vertexCount;
         var _loc17_:Number = (0 - Number(_loc7_[_loc9_])) / (Number(_loc7_[_loc12_]) - Number(_loc7_[_loc9_]));
         var _loc18_:Number = (0 - Number(_loc7_[_loc10_])) / (Number(_loc7_[_loc13_]) - Number(_loc7_[_loc10_]));
         var _loc19_:b2Vec2 = new b2Vec2(m_vertices[_loc9_].x * (1 - _loc17_) + m_vertices[_loc12_].x * _loc17_,m_vertices[_loc9_].y * (1 - _loc17_) + m_vertices[_loc12_].y * _loc17_);
         var _loc20_:b2Vec2 = new b2Vec2(m_vertices[_loc10_].x * (1 - _loc18_) + m_vertices[_loc13_].x * _loc18_,m_vertices[_loc10_].y * (1 - _loc18_) + m_vertices[_loc13_].y * _loc18_);
         var _loc21_:Number = 0;
         var _loc22_:b2Vec2 = new b2Vec2();
         var _loc23_:b2Vec2 = m_vertices[_loc12_];
         _loc14_ = _loc12_;
         while(_loc14_ != _loc13_)
         {
            _loc14_ = (_loc14_ + 1) % m_vertexCount;
            if(_loc14_ == _loc13_)
            {
               _loc24_ = _loc20_;
            }
            else
            {
               _loc24_ = m_vertices[_loc14_];
            }
            _loc25_ = 0.5 * ((_loc23_.x - _loc19_.x) * (_loc24_.y - _loc19_.y) - (_loc23_.y - _loc19_.y) * (_loc24_.x - _loc19_.x));
            _loc21_ += _loc25_;
            _loc22_.x += _loc25_ * (_loc19_.x + _loc23_.x + _loc24_.x) / 3;
            _loc22_.y += _loc25_ * (_loc19_.y + _loc23_.y + _loc24_.y) / 3;
            _loc23_ = _loc24_;
         }
         _loc22_.multiply(1 / _loc21_);
         c.setV(b2Math.mulX(xf,_loc22_));
         return _loc21_;
      }
      
      override public function ComputeMass(massData:b2MassData, density:Number) : void
      {
         var _loc12_:int = 0;
         var _loc13_:* = null as b2Vec2;
         var _loc14_:* = null as b2Vec2;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         if(m_vertexCount == 2)
         {
            massData.center.x = 0.5 * (m_vertices[0].x + m_vertices[1].x);
            massData.center.y = 0.5 * (m_vertices[0].y + m_vertices[1].y);
            massData.mass = 0;
            massData.I = 0;
            return;
         }
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc7_:Number = 0;
         var _loc8_:Number = 0;
         var _loc9_:Number = 0.3333333333333333;
         var _loc10_:int = 0;
         var _loc11_:int = m_vertexCount;
         while(_loc10_ < _loc11_)
         {
            _loc12_ = _loc10_++;
            _loc13_ = m_vertices[_loc12_];
            _loc14_ = _loc12_ + 1 < m_vertexCount ? m_vertices[_loc12_ + 1] : m_vertices[0];
            _loc15_ = _loc13_.x - _loc7_;
            _loc16_ = _loc13_.y - _loc8_;
            _loc17_ = _loc14_.x - _loc7_;
            _loc18_ = _loc14_.y - _loc8_;
            _loc19_ = _loc15_ * _loc18_ - _loc16_ * _loc17_;
            _loc20_ = 0.5 * _loc19_;
            _loc5_ += _loc20_;
            _loc3_ += _loc20_ * _loc9_ * (_loc7_ + _loc13_.x + _loc14_.x);
            _loc4_ += _loc20_ * _loc9_ * (_loc8_ + _loc13_.y + _loc14_.y);
            _loc21_ = _loc7_;
            _loc22_ = _loc8_;
            _loc23_ = _loc15_;
            _loc24_ = _loc16_;
            _loc25_ = _loc17_;
            _loc26_ = _loc18_;
            _loc27_ = _loc9_ * (0.25 * (_loc23_ * _loc23_ + _loc25_ * _loc23_ + _loc25_ * _loc25_) + (_loc21_ * _loc23_ + _loc21_ * _loc25_)) + 0.5 * _loc21_ * _loc21_;
            _loc28_ = _loc9_ * (0.25 * (_loc24_ * _loc24_ + _loc26_ * _loc24_ + _loc26_ * _loc26_) + (_loc22_ * _loc24_ + _loc22_ * _loc26_)) + 0.5 * _loc22_ * _loc22_;
            _loc6_ += _loc19_ * (_loc27_ + _loc28_);
         }
         massData.mass = density * _loc5_;
         _loc3_ *= 1 / _loc5_;
         _loc4_ *= 1 / _loc5_;
         massData.center.set(_loc3_,_loc4_);
         massData.I = density * _loc6_;
      }
      
      override public function ComputeAABB(aabb:b2AABB, xf:b2Transform) : void
      {
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc3_:b2Mat22 = xf.R;
         var _loc4_:b2Vec2 = m_vertices[0];
         var _loc5_:Number = xf.position.x + (_loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y);
         var _loc6_:Number = xf.position.y + (_loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y);
         var _loc7_:Number = _loc5_;
         var _loc8_:Number = _loc6_;
         var _loc9_:int = 1;
         var _loc10_:int = m_vertexCount;
         while(_loc9_ < _loc10_)
         {
            _loc11_ = _loc9_++;
            _loc4_ = m_vertices[_loc11_];
            _loc12_ = xf.position.x + (_loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y);
            _loc13_ = xf.position.y + (_loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y);
            if(_loc5_ >= _loc12_)
            {
               _loc5_ = _loc12_;
            }
            if(_loc6_ >= _loc13_)
            {
               _loc6_ = _loc13_;
            }
            if(_loc7_ <= _loc12_)
            {
               _loc7_ = _loc12_;
            }
            if(_loc8_ <= _loc13_)
            {
               _loc8_ = _loc13_;
            }
         }
         aabb.lowerBound.x = _loc5_ - m_radius;
         aabb.lowerBound.y = _loc6_ - m_radius;
         aabb.upperBound.x = _loc7_ + m_radius;
         aabb.upperBound.y = _loc8_ + m_radius;
      }
   }
}

