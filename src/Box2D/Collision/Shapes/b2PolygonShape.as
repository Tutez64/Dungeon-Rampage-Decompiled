package Box2D.Collision.Shapes
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   use namespace b2internal;
   
   public class b2PolygonShape extends b2Shape
   {
      
      private static var s_mat:b2Mat22 = new b2Mat22();
      
      b2internal var m_centroid:b2Vec2;
      
      b2internal var m_vertices:Vector.<b2Vec2>;
      
      b2internal var m_normals:Vector.<b2Vec2>;
      
      b2internal var m_vertexCount:int;
      
      public function b2PolygonShape()
      {
         super();
         b2internal::m_type = b2internal::e_polygonShape;
         this.m_centroid = new b2Vec2();
         this.m_vertices = new Vector.<b2Vec2>();
         this.m_normals = new Vector.<b2Vec2>();
      }
      
      public static function AsArray(vertices:Array, vertexCount:Number) : b2PolygonShape
      {
         var _loc3_:b2PolygonShape = new b2PolygonShape();
         _loc3_.SetAsArray(vertices,vertexCount);
         return _loc3_;
      }
      
      public static function AsVector(vertices:Vector.<b2Vec2>, vertexCount:Number) : b2PolygonShape
      {
         var _loc3_:b2PolygonShape = new b2PolygonShape();
         _loc3_.SetAsVector(vertices,vertexCount);
         return _loc3_;
      }
      
      public static function AsBox(hx:Number, hy:Number) : b2PolygonShape
      {
         var _loc3_:b2PolygonShape = new b2PolygonShape();
         _loc3_.SetAsBox(hx,hy);
         return _loc3_;
      }
      
      public static function AsOrientedBox(hx:Number, hy:Number, center:b2Vec2 = null, angle:Number = 0) : b2PolygonShape
      {
         var _loc5_:b2PolygonShape = new b2PolygonShape();
         _loc5_.SetAsOrientedBox(hx,hy,center,angle);
         return _loc5_;
      }
      
      public static function AsEdge(v1:b2Vec2, v2:b2Vec2) : b2PolygonShape
      {
         var _loc3_:b2PolygonShape = new b2PolygonShape();
         _loc3_.SetAsEdge(v1,v2);
         return _loc3_;
      }
      
      public static function ComputeCentroid(vs:Vector.<b2Vec2>, count:uint) : b2Vec2
      {
         var _loc3_:b2Vec2 = null;
         var _loc7_:Number = NaN;
         var _loc9_:b2Vec2 = null;
         var _loc10_:b2Vec2 = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         _loc3_ = new b2Vec2();
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         _loc7_ = 1 / 3;
         var _loc8_:* = 0;
         while(_loc8_ < count)
         {
            _loc9_ = vs[_loc8_];
            _loc10_ = _loc8_ + 1 < count ? vs[int(_loc8_ + 1)] : vs[0];
            _loc11_ = _loc9_.x - _loc5_;
            _loc12_ = _loc9_.y - _loc6_;
            _loc13_ = _loc10_.x - _loc5_;
            _loc14_ = _loc10_.y - _loc6_;
            _loc15_ = _loc11_ * _loc14_ - _loc12_ * _loc13_;
            _loc16_ = 0.5 * _loc15_;
            _loc4_ += _loc16_;
            _loc3_.x += _loc16_ * _loc7_ * (_loc5_ + _loc9_.x + _loc10_.x);
            _loc3_.y += _loc16_ * _loc7_ * (_loc6_ + _loc9_.y + _loc10_.y);
            _loc8_++;
         }
         _loc3_.x *= 1 / _loc4_;
         _loc3_.y *= 1 / _loc4_;
         return _loc3_;
      }
      
      b2internal static function ComputeOBB(obb:b2OBB, vs:Vector.<b2Vec2>, count:int) : void
      {
         var _loc4_:* = 0;
         var _loc7_:b2Vec2 = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:* = 0;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:b2Mat22 = null;
         var _loc5_:Vector.<b2Vec2> = new Vector.<b2Vec2>(count + 1);
         _loc4_ = 0;
         while(_loc4_ < count)
         {
            _loc5_[_loc4_] = vs[_loc4_];
            _loc4_++;
         }
         _loc5_[count] = _loc5_[0];
         var _loc6_:Number = Number.MAX_VALUE;
         _loc4_ = 1;
         while(_loc4_ <= count)
         {
            _loc7_ = _loc5_[int(_loc4_ - 1)];
            _loc8_ = _loc5_[_loc4_].x - _loc7_.x;
            _loc9_ = _loc5_[_loc4_].y - _loc7_.y;
            _loc10_ = Math.sqrt(_loc8_ * _loc8_ + _loc9_ * _loc9_);
            _loc8_ /= _loc10_;
            _loc9_ /= _loc10_;
            _loc11_ = -_loc9_;
            _loc12_ = _loc8_;
            _loc13_ = Number.MAX_VALUE;
            _loc14_ = Number.MAX_VALUE;
            _loc15_ = -Number.MAX_VALUE;
            _loc16_ = -Number.MAX_VALUE;
            _loc17_ = 0;
            while(_loc17_ < count)
            {
               _loc19_ = _loc5_[_loc17_].x - _loc7_.x;
               _loc20_ = _loc5_[_loc17_].y - _loc7_.y;
               _loc21_ = _loc8_ * _loc19_ + _loc9_ * _loc20_;
               _loc22_ = _loc11_ * _loc19_ + _loc12_ * _loc20_;
               if(_loc21_ < _loc13_)
               {
                  _loc13_ = _loc21_;
               }
               if(_loc22_ < _loc14_)
               {
                  _loc14_ = _loc22_;
               }
               if(_loc21_ > _loc15_)
               {
                  _loc15_ = _loc21_;
               }
               if(_loc22_ > _loc16_)
               {
                  _loc16_ = _loc22_;
               }
               _loc17_++;
            }
            _loc18_ = (_loc15_ - _loc13_) * (_loc16_ - _loc14_);
            if(_loc18_ < 0.95 * _loc6_)
            {
               _loc6_ = _loc18_;
               obb.R.col1.x = _loc8_;
               obb.R.col1.y = _loc9_;
               obb.R.col2.x = _loc11_;
               obb.R.col2.y = _loc12_;
               _loc23_ = 0.5 * (_loc13_ + _loc15_);
               _loc24_ = 0.5 * (_loc14_ + _loc16_);
               _loc25_ = obb.R;
               obb.center.x = _loc7_.x + (_loc25_.col1.x * _loc23_ + _loc25_.col2.x * _loc24_);
               obb.center.y = _loc7_.y + (_loc25_.col1.y * _loc23_ + _loc25_.col2.y * _loc24_);
               obb.extents.x = 0.5 * (_loc15_ - _loc13_);
               obb.extents.y = 0.5 * (_loc16_ - _loc14_);
            }
            _loc4_++;
         }
      }
      
      override public function Copy() : b2Shape
      {
         var _loc1_:b2PolygonShape = new b2PolygonShape();
         _loc1_.Set(this);
         return _loc1_;
      }
      
      override public function Set(other:b2Shape) : void
      {
         var _loc2_:b2PolygonShape = null;
         var _loc3_:* = 0;
         super.Set(other);
         if(other is b2PolygonShape)
         {
            _loc2_ = other as b2PolygonShape;
            this.m_centroid.SetV(_loc2_.m_centroid);
            this.m_vertexCount = _loc2_.m_vertexCount;
            this.Reserve(this.m_vertexCount);
            _loc3_ = 0;
            while(_loc3_ < this.m_vertexCount)
            {
               this.m_vertices[_loc3_].SetV(_loc2_.m_vertices[_loc3_]);
               this.m_normals[_loc3_].SetV(_loc2_.m_normals[_loc3_]);
               _loc3_++;
            }
         }
      }
      
      public function SetAsArray(vertices:Array, vertexCount:Number = 0) : void
      {
         var _loc4_:b2Vec2 = null;
         var _loc3_:Vector.<b2Vec2> = new Vector.<b2Vec2>();
         for each(_loc4_ in vertices)
         {
            _loc3_.push(_loc4_);
         }
         this.SetAsVector(_loc3_,vertexCount);
      }
      
      public function SetAsVector(vertices:Vector.<b2Vec2>, vertexCount:Number = 0) : void
      {
         var _loc3_:* = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:b2Vec2 = null;
         if(vertexCount == 0)
         {
            vertexCount = vertices.length;
         }
         b2Settings.b2Assert(2 <= vertexCount);
         this.m_vertexCount = vertexCount;
         this.Reserve(vertexCount);
         _loc3_ = 0;
         while(_loc3_ < this.m_vertexCount)
         {
            this.m_vertices[_loc3_].SetV(vertices[_loc3_]);
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < this.m_vertexCount)
         {
            _loc4_ = _loc3_;
            _loc5_ = _loc3_ + 1 < this.m_vertexCount ? int(_loc3_ + 1) : 0;
            _loc6_ = b2Math.SubtractVV(this.m_vertices[_loc5_],this.m_vertices[_loc4_]);
            b2Settings.b2Assert(_loc6_.LengthSquared() > Number.MIN_VALUE);
            this.m_normals[_loc3_].SetV(b2Math.CrossVF(_loc6_,1));
            this.m_normals[_loc3_].Normalize();
            _loc3_++;
         }
         this.m_centroid = ComputeCentroid(this.m_vertices,this.m_vertexCount);
      }
      
      public function SetAsBox(hx:Number, hy:Number) : void
      {
         this.m_vertexCount = 4;
         this.Reserve(4);
         this.m_vertices[0].Set(-hx,-hy);
         this.m_vertices[1].Set(hx,-hy);
         this.m_vertices[2].Set(hx,hy);
         this.m_vertices[3].Set(-hx,hy);
         this.m_normals[0].Set(0,-1);
         this.m_normals[1].Set(1,0);
         this.m_normals[2].Set(0,1);
         this.m_normals[3].Set(-1,0);
         this.m_centroid.SetZero();
      }
      
      public function SetAsOrientedBox(hx:Number, hy:Number, center:b2Vec2 = null, angle:Number = 0) : void
      {
         this.m_vertexCount = 4;
         this.Reserve(4);
         this.m_vertices[0].Set(-hx,-hy);
         this.m_vertices[1].Set(hx,-hy);
         this.m_vertices[2].Set(hx,hy);
         this.m_vertices[3].Set(-hx,hy);
         this.m_normals[0].Set(0,-1);
         this.m_normals[1].Set(1,0);
         this.m_normals[2].Set(0,1);
         this.m_normals[3].Set(-1,0);
         this.m_centroid = center;
         var _loc5_:b2Transform = new b2Transform();
         _loc5_.position = center;
         _loc5_.R.Set(angle);
         var _loc6_:* = 0;
         while(_loc6_ < this.m_vertexCount)
         {
            this.m_vertices[_loc6_] = b2Math.MulX(_loc5_,this.m_vertices[_loc6_]);
            this.m_normals[_loc6_] = b2Math.MulMV(_loc5_.R,this.m_normals[_loc6_]);
            _loc6_++;
         }
      }
      
      public function SetAsEdge(v1:b2Vec2, v2:b2Vec2) : void
      {
         this.m_vertexCount = 2;
         this.Reserve(2);
         this.m_vertices[0].SetV(v1);
         this.m_vertices[1].SetV(v2);
         this.m_centroid.x = 0.5 * (v1.x + v2.x);
         this.m_centroid.y = 0.5 * (v1.y + v2.y);
         this.m_normals[0] = b2Math.CrossVF(b2Math.SubtractVV(v2,v1),1);
         this.m_normals[0].Normalize();
         this.m_normals[1].x = -this.m_normals[0].x;
         this.m_normals[1].y = -this.m_normals[0].y;
      }
      
      override public function TestPoint(xf:b2Transform, p:b2Vec2) : Boolean
      {
         var _loc3_:b2Vec2 = null;
         var _loc10_:Number = NaN;
         var _loc4_:b2Mat22 = xf.R;
         var _loc5_:Number = p.x - xf.position.x;
         var _loc6_:Number = p.y - xf.position.y;
         var _loc7_:Number = _loc5_ * _loc4_.col1.x + _loc6_ * _loc4_.col1.y;
         var _loc8_:Number = _loc5_ * _loc4_.col2.x + _loc6_ * _loc4_.col2.y;
         var _loc9_:* = 0;
         while(_loc9_ < this.m_vertexCount)
         {
            _loc3_ = this.m_vertices[_loc9_];
            _loc5_ = _loc7_ - _loc3_.x;
            _loc6_ = _loc8_ - _loc3_.y;
            _loc3_ = this.m_normals[_loc9_];
            _loc10_ = _loc3_.x * _loc5_ + _loc3_.y * _loc6_;
            if(_loc10_ > 0)
            {
               return false;
            }
            _loc9_++;
         }
         return true;
      }
      
      override public function RayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform) : Boolean
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:b2Mat22 = null;
         var _loc9_:b2Vec2 = null;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc4_:Number = 0;
         var _loc5_:Number = input.maxFraction;
         _loc6_ = input.p1.x - transform.position.x;
         _loc7_ = input.p1.y - transform.position.y;
         _loc8_ = transform.R;
         var _loc10_:Number = _loc6_ * _loc8_.col1.x + _loc7_ * _loc8_.col1.y;
         var _loc11_:Number = _loc6_ * _loc8_.col2.x + _loc7_ * _loc8_.col2.y;
         _loc6_ = input.p2.x - transform.position.x;
         _loc7_ = input.p2.y - transform.position.y;
         _loc8_ = transform.R;
         var _loc12_:Number = _loc6_ * _loc8_.col1.x + _loc7_ * _loc8_.col1.y;
         var _loc13_:Number = _loc6_ * _loc8_.col2.x + _loc7_ * _loc8_.col2.y;
         var _loc14_:Number = _loc12_ - _loc10_;
         var _loc15_:Number = _loc13_ - _loc11_;
         var _loc16_:int = -1;
         var _loc17_:* = 0;
         while(_loc17_ < this.m_vertexCount)
         {
            _loc9_ = this.m_vertices[_loc17_];
            _loc6_ = _loc9_.x - _loc10_;
            _loc7_ = _loc9_.y - _loc11_;
            _loc9_ = this.m_normals[_loc17_];
            _loc18_ = _loc9_.x * _loc6_ + _loc9_.y * _loc7_;
            _loc19_ = _loc9_.x * _loc14_ + _loc9_.y * _loc15_;
            if(_loc19_ == 0)
            {
               if(_loc18_ < 0)
               {
                  return false;
               }
            }
            else if(_loc19_ < 0 && _loc18_ < _loc4_ * _loc19_)
            {
               _loc4_ = _loc18_ / _loc19_;
               _loc16_ = _loc17_;
            }
            else if(_loc19_ > 0 && _loc18_ < _loc5_ * _loc19_)
            {
               _loc5_ = _loc18_ / _loc19_;
            }
            if(_loc5_ < _loc4_ - Number.MIN_VALUE)
            {
               return false;
            }
            _loc17_++;
         }
         if(_loc16_ >= 0)
         {
            output.fraction = _loc4_;
            _loc8_ = transform.R;
            _loc9_ = this.m_normals[_loc16_];
            output.normal.x = _loc8_.col1.x * _loc9_.x + _loc8_.col2.x * _loc9_.y;
            output.normal.y = _loc8_.col1.y * _loc9_.x + _loc8_.col2.y * _loc9_.y;
            return true;
         }
         return false;
      }
      
      override public function ComputeAABB(aabb:b2AABB, xf:b2Transform) : void
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc3_:b2Mat22 = xf.R;
         var _loc4_:b2Vec2 = this.m_vertices[0];
         var _loc5_:Number = xf.position.x + (_loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y);
         var _loc6_:Number = xf.position.y + (_loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y);
         var _loc7_:Number = _loc5_;
         var _loc8_:Number = _loc6_;
         var _loc9_:* = 1;
         while(_loc9_ < this.m_vertexCount)
         {
            _loc4_ = this.m_vertices[_loc9_];
            _loc10_ = xf.position.x + (_loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y);
            _loc11_ = xf.position.y + (_loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y);
            _loc5_ = _loc5_ < _loc10_ ? _loc5_ : _loc10_;
            _loc6_ = _loc6_ < _loc11_ ? _loc6_ : _loc11_;
            _loc7_ = _loc7_ > _loc10_ ? _loc7_ : _loc10_;
            _loc8_ = _loc8_ > _loc11_ ? _loc8_ : _loc11_;
            _loc9_++;
         }
         aabb.lowerBound.x = _loc5_ - m_radius;
         aabb.lowerBound.y = _loc6_ - m_radius;
         aabb.upperBound.x = _loc7_ + m_radius;
         aabb.upperBound.y = _loc8_ + m_radius;
      }
      
      override public function ComputeMass(massData:b2MassData, density:Number) : void
      {
         var _loc11_:b2Vec2 = null;
         var _loc12_:b2Vec2 = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
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
         if(this.m_vertexCount == 2)
         {
            massData.center.x = 0.5 * (this.m_vertices[0].x + this.m_vertices[1].x);
            massData.center.y = 0.5 * (this.m_vertices[0].y + this.m_vertices[1].y);
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
         var _loc9_:Number = 1 / 3;
         var _loc10_:* = 0;
         while(_loc10_ < this.m_vertexCount)
         {
            _loc11_ = this.m_vertices[_loc10_];
            _loc12_ = _loc10_ + 1 < this.m_vertexCount ? this.m_vertices[int(_loc10_ + 1)] : this.m_vertices[0];
            _loc13_ = _loc11_.x - _loc7_;
            _loc14_ = _loc11_.y - _loc8_;
            _loc15_ = _loc12_.x - _loc7_;
            _loc16_ = _loc12_.y - _loc8_;
            _loc17_ = _loc13_ * _loc16_ - _loc14_ * _loc15_;
            _loc18_ = 0.5 * _loc17_;
            _loc5_ += _loc18_;
            _loc3_ += _loc18_ * _loc9_ * (_loc7_ + _loc11_.x + _loc12_.x);
            _loc4_ += _loc18_ * _loc9_ * (_loc8_ + _loc11_.y + _loc12_.y);
            _loc19_ = _loc7_;
            _loc20_ = _loc8_;
            _loc21_ = _loc13_;
            _loc22_ = _loc14_;
            _loc23_ = _loc15_;
            _loc24_ = _loc16_;
            _loc25_ = _loc9_ * (0.25 * (_loc21_ * _loc21_ + _loc23_ * _loc21_ + _loc23_ * _loc23_) + (_loc19_ * _loc21_ + _loc19_ * _loc23_)) + 0.5 * _loc19_ * _loc19_;
            _loc26_ = _loc9_ * (0.25 * (_loc22_ * _loc22_ + _loc24_ * _loc22_ + _loc24_ * _loc24_) + (_loc20_ * _loc22_ + _loc20_ * _loc24_)) + 0.5 * _loc20_ * _loc20_;
            _loc6_ += _loc17_ * (_loc25_ + _loc26_);
            _loc10_++;
         }
         massData.mass = density * _loc5_;
         _loc3_ *= 1 / _loc5_;
         _loc4_ *= 1 / _loc5_;
         massData.center.Set(_loc3_,_loc4_);
         massData.I = density * _loc6_;
      }
      
      override public function ComputeSubmergedArea(normal:b2Vec2, offset:Number, xf:b2Transform, c:b2Vec2) : Number
      {
         var _loc12_:* = 0;
         var _loc22_:b2Vec2 = null;
         var _loc23_:Boolean = false;
         var _loc24_:b2MassData = null;
         var _loc25_:Number = NaN;
         var _loc5_:b2Vec2 = b2Math.MulTMV(xf.R,normal);
         var _loc6_:Number = offset - b2Math.Dot(normal,xf.position);
         var _loc7_:Vector.<Number> = new Vector.<Number>();
         var _loc8_:* = 0;
         var _loc9_:int = -1;
         var _loc10_:int = -1;
         var _loc11_:Boolean = false;
         _loc12_ = 0;
         while(_loc12_ < this.m_vertexCount)
         {
            _loc7_[_loc12_] = b2Math.Dot(_loc5_,this.m_vertices[_loc12_]) - _loc6_;
            _loc23_ = _loc7_[_loc12_] < -Number.MIN_VALUE;
            if(_loc12_ > 0)
            {
               if(_loc23_)
               {
                  if(!_loc11_)
                  {
                     _loc9_ = _loc12_ - 1;
                     _loc8_++;
                  }
               }
               else if(_loc11_)
               {
                  _loc10_ = _loc12_ - 1;
                  _loc8_++;
               }
            }
            _loc11_ = _loc23_;
            _loc12_++;
         }
         switch(_loc8_)
         {
            case 0:
               if(_loc11_)
               {
                  _loc24_ = new b2MassData();
                  this.ComputeMass(_loc24_,1);
                  c.SetV(b2Math.MulX(xf,_loc24_.center));
                  return _loc24_.mass;
               }
               return 0;
               break;
            case 1:
               if(_loc9_ == -1)
               {
                  _loc9_ = this.m_vertexCount - 1;
               }
               else
               {
                  _loc10_ = this.m_vertexCount - 1;
               }
         }
         var _loc13_:int = (_loc9_ + 1) % this.m_vertexCount;
         var _loc14_:int = (_loc10_ + 1) % this.m_vertexCount;
         var _loc15_:Number = (0 - _loc7_[_loc9_]) / (_loc7_[_loc13_] - _loc7_[_loc9_]);
         var _loc16_:Number = (0 - _loc7_[_loc10_]) / (_loc7_[_loc14_] - _loc7_[_loc10_]);
         var _loc17_:b2Vec2 = new b2Vec2(this.m_vertices[_loc9_].x * (1 - _loc15_) + this.m_vertices[_loc13_].x * _loc15_,this.m_vertices[_loc9_].y * (1 - _loc15_) + this.m_vertices[_loc13_].y * _loc15_);
         var _loc18_:b2Vec2 = new b2Vec2(this.m_vertices[_loc10_].x * (1 - _loc16_) + this.m_vertices[_loc14_].x * _loc16_,this.m_vertices[_loc10_].y * (1 - _loc16_) + this.m_vertices[_loc14_].y * _loc16_);
         var _loc19_:Number = 0;
         var _loc20_:b2Vec2 = new b2Vec2();
         var _loc21_:b2Vec2 = this.m_vertices[_loc13_];
         _loc12_ = _loc13_;
         while(_loc12_ != _loc14_)
         {
            _loc12_ = int((_loc12_ + 1) % this.m_vertexCount);
            if(_loc12_ == _loc14_)
            {
               _loc22_ = _loc18_;
            }
            else
            {
               _loc22_ = this.m_vertices[_loc12_];
            }
            _loc25_ = 0.5 * ((_loc21_.x - _loc17_.x) * (_loc22_.y - _loc17_.y) - (_loc21_.y - _loc17_.y) * (_loc22_.x - _loc17_.x));
            _loc19_ += _loc25_;
            _loc20_.x += _loc25_ * (_loc17_.x + _loc21_.x + _loc22_.x) / 3;
            _loc20_.y += _loc25_ * (_loc17_.y + _loc21_.y + _loc22_.y) / 3;
            _loc21_ = _loc22_;
         }
         _loc20_.Multiply(1 / _loc19_);
         c.SetV(b2Math.MulX(xf,_loc20_));
         return _loc19_;
      }
      
      public function GetVertexCount() : int
      {
         return this.m_vertexCount;
      }
      
      public function GetVertices() : Vector.<b2Vec2>
      {
         return this.m_vertices;
      }
      
      public function GetNormals() : Vector.<b2Vec2>
      {
         return this.m_normals;
      }
      
      public function GetSupport(d:b2Vec2) : int
      {
         var _loc5_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:Number = this.m_vertices[0].x * d.x + this.m_vertices[0].y * d.y;
         var _loc4_:* = 1;
         while(_loc4_ < this.m_vertexCount)
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
         while(_loc4_ < this.m_vertexCount)
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
      
      private function Validate() : Boolean
      {
         return false;
      }
      
      private function Reserve(count:int) : void
      {
         var _loc2_:* = int(this.m_vertices.length);
         while(_loc2_ < count)
         {
            this.m_vertices[_loc2_] = new b2Vec2();
            this.m_normals[_loc2_] = new b2Vec2();
            _loc2_++;
         }
      }
   }
}

