package Box2D.Common.Math
{
   import flash.Boot;
   
   public class b2Sweep
   {
      
      public var t0:Number;
      
      public var localCenter:b2Vec2;
      
      public var c0:b2Vec2;
      
      public var c:b2Vec2;
      
      public var a0:Number;
      
      public var a:Number;
      
      public function b2Sweep()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         localCenter = new b2Vec2();
         c0 = new b2Vec2();
         c = new b2Vec2();
      }
      
      public function set(other:b2Sweep) : void
      {
         Set(other);
      }
      
      public function getTransform(xf:b2Transform, alpha:Number) : void
      {
         GetTransform(xf,alpha);
      }
      
      public function copy() : b2Sweep
      {
         return Copy();
      }
      
      public function advance(t:Number) : void
      {
         Advance(t);
      }
      
      public function Set(other:b2Sweep) : void
      {
         localCenter.setV(other.localCenter);
         c0.setV(other.c0);
         c.setV(other.c);
         a0 = other.a0;
         a = other.a;
         t0 = other.t0;
      }
      
      public function GetTransform(xf:b2Transform, alpha:Number) : void
      {
         xf.position.x = (1 - alpha) * c0.x + alpha * c.x;
         xf.position.y = (1 - alpha) * c0.y + alpha * c.y;
         var _loc3_:Number = (1 - alpha) * a0 + alpha * a;
         xf.R.set(_loc3_);
         var _loc4_:b2Mat22 = xf.R;
         xf.position.x -= _loc4_.col1.x * localCenter.x + _loc4_.col2.x * localCenter.y;
         xf.position.y -= _loc4_.col1.y * localCenter.x + _loc4_.col2.y * localCenter.y;
      }
      
      public function Copy() : b2Sweep
      {
         var _loc1_:b2Sweep = new b2Sweep();
         _loc1_.localCenter.setV(localCenter);
         _loc1_.c0.setV(c0);
         _loc1_.c.setV(c);
         _loc1_.a0 = a0;
         _loc1_.a = a;
         _loc1_.t0 = t0;
         return _loc1_;
      }
      
      public function Advance(t:Number) : void
      {
         var _loc2_:Number = NaN;
         if(t0 < t && 1 - t0 > Number(Number.MIN_VALUE))
         {
            _loc2_ = (t - t0) / (1 - t0);
            c0.x = (1 - _loc2_) * c0.x + _loc2_ * c.x;
            c0.y = (1 - _loc2_) * c0.y + _loc2_ * c.y;
            a0 = (1 - _loc2_) * a0 + _loc2_ * a;
            t0 = t;
         }
      }
   }
}

