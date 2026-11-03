package Box2D.Common.Math
{
   import flash.Boot;
   
   public class b2Mat22
   {
      
      public var col2:b2Vec2;
      
      public var col1:b2Vec2;
      
      public function b2Mat22()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         col1 = new b2Vec2(1,0);
         col2 = new b2Vec2(0,1);
      }
      
      public static function fromAngle(angle:Number) : b2Mat22
      {
         var _loc2_:b2Mat22 = new b2Mat22();
         _loc2_.set(angle);
         return _loc2_;
      }
      
      public static function fromVV(c1:b2Vec2, c2:b2Vec2) : b2Mat22
      {
         var _loc3_:b2Mat22 = new b2Mat22();
         _loc3_.setVV(c1,c2);
         return _loc3_;
      }
      
      public static function FromAngle(angle:Number) : b2Mat22
      {
         return b2Mat22.fromAngle(angle);
      }
      
      public static function FromVV(c1:b2Vec2, c2:b2Vec2) : b2Mat22
      {
         return b2Mat22.fromVV(c1,c2);
      }
      
      public function solve(out:b2Vec2, bX:Number, bY:Number) : b2Vec2
      {
         return Solve(out,bX,bY);
      }
      
      public function setZero() : void
      {
         SetZero();
      }
      
      public function setVV(c1:b2Vec2, c2:b2Vec2) : void
      {
         SetVV(c1,c2);
      }
      
      public function setM(m:b2Mat22) : void
      {
         SetM(m);
      }
      
      public function setIdentity() : void
      {
         SetIdentity();
      }
      
      public function set(angle:Number) : void
      {
         Set(angle);
      }
      
      public function getInverse(out:b2Mat22) : b2Mat22
      {
         return GetInverse(out);
      }
      
      public function getAngle() : Number
      {
         return GetAngle();
      }
      
      public function copy() : b2Mat22
      {
         return Copy();
      }
      
      public function addM(m:b2Mat22) : void
      {
         AddM(m);
      }
      
      public function abs() : void
      {
         Abs();
      }
      
      public function Solve(out:b2Vec2, bX:Number, bY:Number) : b2Vec2
      {
         var _loc4_:Number = col1.x;
         var _loc5_:Number = col2.x;
         var _loc6_:Number = col1.y;
         var _loc7_:Number = col2.y;
         var _loc8_:Number = _loc4_ * _loc7_ - _loc5_ * _loc6_;
         if(_loc8_ != 0)
         {
            _loc8_ = 1 / _loc8_;
         }
         out.x = _loc8_ * (_loc7_ * bX - _loc5_ * bY);
         out.y = _loc8_ * (_loc4_ * bY - _loc6_ * bX);
         return out;
      }
      
      public function SetZero() : void
      {
         col1.x = 0;
         col2.x = 0;
         col1.y = 0;
         col2.y = 0;
      }
      
      public function SetVV(c1:b2Vec2, c2:b2Vec2) : void
      {
         col1.setV(c1);
         col2.setV(c2);
      }
      
      public function SetM(m:b2Mat22) : void
      {
         col1.setV(m.col1);
         col2.setV(m.col2);
      }
      
      public function SetIdentity() : void
      {
         col1.x = 1;
         col2.x = 0;
         col1.y = 0;
         col2.y = 1;
      }
      
      public function Set(angle:Number) : void
      {
         var _loc2_:Number = Math.cos(angle);
         var _loc3_:Number = Math.sin(angle);
         col1.x = _loc2_;
         col2.x = -_loc3_;
         col1.y = _loc3_;
         col2.y = _loc2_;
      }
      
      public function GetInverse(out:b2Mat22) : b2Mat22
      {
         var _loc2_:Number = col1.x;
         var _loc3_:Number = col2.x;
         var _loc4_:Number = col1.y;
         var _loc5_:Number = col2.y;
         var _loc6_:Number = _loc2_ * _loc5_ - _loc3_ * _loc4_;
         if(_loc6_ != 0)
         {
            _loc6_ = 1 / _loc6_;
         }
         out.col1.x = _loc6_ * _loc5_;
         out.col2.x = -_loc6_ * _loc3_;
         out.col1.y = -_loc6_ * _loc4_;
         out.col2.y = _loc6_ * _loc2_;
         return out;
      }
      
      public function GetAngle() : Number
      {
         return Math.atan2(col1.y,col1.x);
      }
      
      public function Copy() : b2Mat22
      {
         var _loc1_:b2Mat22 = new b2Mat22();
         _loc1_.setM(this);
         return _loc1_;
      }
      
      public function AddM(m:b2Mat22) : void
      {
         col1.x += m.col1.x;
         col1.y += m.col1.y;
         col2.x += m.col2.x;
         col2.y += m.col2.y;
      }
      
      public function Abs() : void
      {
         col1.abs();
         col2.abs();
      }
   }
}

