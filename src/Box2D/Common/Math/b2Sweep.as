package Box2D.Common.Math
{
   public class b2Sweep
   {
      
      public var localCenter:b2Vec2 = new b2Vec2();
      
      public var c0:b2Vec2 = new b2Vec2();
      
      public var c:b2Vec2 = new b2Vec2();
      
      public var a0:Number;
      
      public var a:Number;
      
      public var t0:Number;
      
      public function b2Sweep()
      {
         super();
      }
      
      public function Set(other:b2Sweep) : void
      {
         this.localCenter.SetV(other.localCenter);
         this.c0.SetV(other.c0);
         this.c.SetV(other.c);
         this.a0 = other.a0;
         this.a = other.a;
         this.t0 = other.t0;
      }
      
      public function Copy() : b2Sweep
      {
         var _loc1_:b2Sweep = new b2Sweep();
         _loc1_.localCenter.SetV(this.localCenter);
         _loc1_.c0.SetV(this.c0);
         _loc1_.c.SetV(this.c);
         _loc1_.a0 = this.a0;
         _loc1_.a = this.a;
         _loc1_.t0 = this.t0;
         return _loc1_;
      }
      
      public function GetTransform(xf:b2Transform, alpha:Number) : void
      {
         xf.position.x = (1 - alpha) * this.c0.x + alpha * this.c.x;
         xf.position.y = (1 - alpha) * this.c0.y + alpha * this.c.y;
         var _loc3_:Number = (1 - alpha) * this.a0 + alpha * this.a;
         xf.R.Set(_loc3_);
         var _loc4_:b2Mat22 = xf.R;
         xf.position.x -= _loc4_.col1.x * this.localCenter.x + _loc4_.col2.x * this.localCenter.y;
         xf.position.y -= _loc4_.col1.y * this.localCenter.x + _loc4_.col2.y * this.localCenter.y;
      }
      
      public function Advance(t:Number) : void
      {
         var _loc2_:Number = NaN;
         if(this.t0 < t && 1 - this.t0 > Number.MIN_VALUE)
         {
            _loc2_ = (t - this.t0) / (1 - this.t0);
            this.c0.x = (1 - _loc2_) * this.c0.x + _loc2_ * this.c.x;
            this.c0.y = (1 - _loc2_) * this.c0.y + _loc2_ * this.c.y;
            this.a0 = (1 - _loc2_) * this.a0 + _loc2_ * this.a;
            this.t0 = t;
         }
      }
   }
}

