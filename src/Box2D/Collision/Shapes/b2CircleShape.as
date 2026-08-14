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
   import Box2D.Common.b2internal;
   
   use namespace b2internal;
   
   public class b2CircleShape extends b2Shape
   {
      
      b2internal var m_p:b2Vec2 = new b2Vec2();
      
      public function b2CircleShape(radius:Number = 0)
      {
         super();
         b2internal::m_type = b2internal::e_circleShape;
         b2internal::m_radius = radius;
      }
      
      override public function Copy() : b2Shape
      {
         var _loc1_:b2Shape = new b2CircleShape();
         _loc1_.Set(this);
         return _loc1_;
      }
      
      override public function Set(other:b2Shape) : void
      {
         var _loc2_:b2CircleShape = null;
         super.Set(other);
         if(other is b2CircleShape)
         {
            _loc2_ = other as b2CircleShape;
            this.m_p.SetV(_loc2_.m_p);
         }
      }
      
      override public function TestPoint(transform:b2Transform, p:b2Vec2) : Boolean
      {
         var _loc3_:b2Mat22 = transform.R;
         var _loc4_:Number = transform.position.x + (_loc3_.col1.x * this.m_p.x + _loc3_.col2.x * this.m_p.y);
         var _loc5_:Number = transform.position.y + (_loc3_.col1.y * this.m_p.x + _loc3_.col2.y * this.m_p.y);
         _loc4_ = p.x - _loc4_;
         _loc5_ = p.y - _loc5_;
         return _loc4_ * _loc4_ + _loc5_ * _loc5_ <= m_radius * m_radius;
      }
      
      override public function RayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform) : Boolean
      {
         var _loc8_:Number = NaN;
         var _loc4_:b2Mat22 = transform.R;
         var _loc5_:Number = transform.position.x + (_loc4_.col1.x * this.m_p.x + _loc4_.col2.x * this.m_p.y);
         var _loc6_:Number = transform.position.y + (_loc4_.col1.y * this.m_p.x + _loc4_.col2.y * this.m_p.y);
         var _loc7_:Number = input.p1.x - _loc5_;
         _loc8_ = input.p1.y - _loc6_;
         var _loc9_:Number = _loc7_ * _loc7_ + _loc8_ * _loc8_ - m_radius * m_radius;
         var _loc10_:Number = input.p2.x - input.p1.x;
         var _loc11_:Number = input.p2.y - input.p1.y;
         var _loc12_:Number = _loc7_ * _loc10_ + _loc8_ * _loc11_;
         var _loc13_:Number = _loc10_ * _loc10_ + _loc11_ * _loc11_;
         var _loc14_:Number = _loc12_ * _loc12_ - _loc13_ * _loc9_;
         if(_loc14_ < 0 || _loc13_ < Number.MIN_VALUE)
         {
            return false;
         }
         var _loc15_:Number = -(_loc12_ + Math.sqrt(_loc14_));
         if(0 <= _loc15_ && _loc15_ <= input.maxFraction * _loc13_)
         {
            _loc15_ /= _loc13_;
            output.fraction = _loc15_;
            output.normal.x = _loc7_ + _loc15_ * _loc10_;
            output.normal.y = _loc8_ + _loc15_ * _loc11_;
            output.normal.Normalize();
            return true;
         }
         return false;
      }
      
      override public function ComputeAABB(aabb:b2AABB, transform:b2Transform) : void
      {
         var _loc3_:b2Mat22 = transform.R;
         var _loc4_:Number = transform.position.x + (_loc3_.col1.x * this.m_p.x + _loc3_.col2.x * this.m_p.y);
         var _loc5_:Number = transform.position.y + (_loc3_.col1.y * this.m_p.x + _loc3_.col2.y * this.m_p.y);
         aabb.lowerBound.Set(_loc4_ - m_radius,_loc5_ - m_radius);
         aabb.upperBound.Set(_loc4_ + m_radius,_loc5_ + m_radius);
      }
      
      override public function ComputeMass(massData:b2MassData, density:Number) : void
      {
         massData.mass = density * b2Settings.b2_pi * m_radius * m_radius;
         massData.center.SetV(this.m_p);
         massData.I = massData.mass * (0.5 * m_radius * m_radius + (this.m_p.x * this.m_p.x + this.m_p.y * this.m_p.y));
      }
      
      override public function ComputeSubmergedArea(normal:b2Vec2, offset:Number, xf:b2Transform, c:b2Vec2) : Number
      {
         var _loc9_:Number = NaN;
         var _loc5_:b2Vec2 = b2Math.MulX(xf,this.m_p);
         var _loc6_:Number = -(b2Math.Dot(normal,_loc5_) - offset);
         if(_loc6_ < -m_radius + Number.MIN_VALUE)
         {
            return 0;
         }
         if(_loc6_ > m_radius)
         {
            c.SetV(_loc5_);
            return Math.PI * m_radius * m_radius;
         }
         var _loc7_:Number = m_radius * m_radius;
         var _loc8_:Number = _loc6_ * _loc6_;
         _loc9_ = _loc7_ * (Math.asin(_loc6_ / m_radius) + Math.PI / 2) + _loc6_ * Math.sqrt(_loc7_ - _loc8_);
         var _loc10_:Number = -2 / 3 * Math.pow(_loc7_ - _loc8_,1.5) / _loc9_;
         c.x = _loc5_.x + normal.x * _loc10_;
         c.y = _loc5_.y + normal.y * _loc10_;
         return _loc9_;
      }
      
      public function GetLocalPosition() : b2Vec2
      {
         return this.m_p;
      }
      
      public function SetLocalPosition(position:b2Vec2) : void
      {
         this.m_p.SetV(position);
      }
      
      public function GetRadius() : Number
      {
         return m_radius;
      }
      
      public function SetRadius(radius:Number) : void
      {
         m_radius = radius;
      }
   }
}

