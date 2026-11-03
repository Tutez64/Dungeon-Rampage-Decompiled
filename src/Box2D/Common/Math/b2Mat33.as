package Box2D.Common.Math
{
   import flash.Boot;
   
   public class b2Mat33
   {
      
      public var col3:b2Vec3;
      
      public var col2:b2Vec3;
      
      public var col1:b2Vec3;
      
      public function b2Mat33(c1:b2Vec3 = undefined, c2:b2Vec3 = undefined, c3:b2Vec3 = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         col1 = new b2Vec3();
         col2 = new b2Vec3();
         col3 = new b2Vec3();
         if(c1 == null && c2 == null && c3 == null)
         {
            col1.setZero();
            col2.setZero();
            col3.setZero();
         }
         else
         {
            col1.setV(c1);
            col2.setV(c2);
            col3.setV(c3);
         }
      }
      
      public function solve33(out:b2Vec3, bX:Number, bY:Number, bZ:Number) : b2Vec3
      {
         return Solve33(out,bX,bY,bZ);
      }
      
      public function solve22(out:b2Vec2, bX:Number, bY:Number) : b2Vec2
      {
         return Solve22(out,bX,bY);
      }
      
      public function setZero() : void
      {
         SetZero();
      }
      
      public function setVVV(c1:b2Vec3, c2:b2Vec3, c3:b2Vec3) : void
      {
         SetVVV(c1,c2,c3);
      }
      
      public function setM(m:b2Mat33) : void
      {
         SetM(m);
      }
      
      public function setIdentity() : void
      {
         SetIdentity();
      }
      
      public function copy() : b2Mat33
      {
         return Copy();
      }
      
      public function addM(m:b2Mat33) : void
      {
         AddM(m);
      }
      
      public function Solve33(out:b2Vec3, bX:Number, bY:Number, bZ:Number) : b2Vec3
      {
         var _loc5_:Number = col1.x;
         var _loc6_:Number = col1.y;
         var _loc7_:Number = col1.z;
         var _loc8_:Number = col2.x;
         var _loc9_:Number = col2.y;
         var _loc10_:Number = col2.z;
         var _loc11_:Number = col3.x;
         var _loc12_:Number = col3.y;
         var _loc13_:Number = col3.z;
         var _loc14_:Number = _loc5_ * (_loc9_ * _loc13_ - _loc10_ * _loc12_) + _loc6_ * (_loc10_ * _loc11_ - _loc8_ * _loc13_) + _loc7_ * (_loc8_ * _loc12_ - _loc9_ * _loc11_);
         if(_loc14_ != 0)
         {
            _loc14_ = 1 / _loc14_;
         }
         out.x = _loc14_ * (bX * (_loc9_ * _loc13_ - _loc10_ * _loc12_) + bY * (_loc10_ * _loc11_ - _loc8_ * _loc13_) + bZ * (_loc8_ * _loc12_ - _loc9_ * _loc11_));
         out.y = _loc14_ * (_loc5_ * (bY * _loc13_ - bZ * _loc12_) + _loc6_ * (bZ * _loc11_ - bX * _loc13_) + _loc7_ * (bX * _loc12_ - bY * _loc11_));
         out.z = _loc14_ * (_loc5_ * (_loc9_ * bZ - _loc10_ * bY) + _loc6_ * (_loc10_ * bX - _loc8_ * bZ) + _loc7_ * (_loc8_ * bY - _loc9_ * bX));
         return out;
      }
      
      public function Solve22(out:b2Vec2, bX:Number, bY:Number) : b2Vec2
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
         col3.x = 0;
         col1.y = 0;
         col2.y = 0;
         col3.y = 0;
         col1.z = 0;
         col2.z = 0;
         col3.z = 0;
      }
      
      public function SetVVV(c1:b2Vec3, c2:b2Vec3, c3:b2Vec3) : void
      {
         col1.setV(c1);
         col2.setV(c2);
         col3.setV(c3);
      }
      
      public function SetM(m:b2Mat33) : void
      {
         col1.setV(m.col1);
         col2.setV(m.col2);
         col3.setV(m.col3);
      }
      
      public function SetIdentity() : void
      {
         col1.x = 1;
         col2.x = 0;
         col3.x = 0;
         col1.y = 0;
         col2.y = 1;
         col3.y = 0;
         col1.z = 0;
         col2.z = 0;
         col3.z = 1;
      }
      
      public function Copy() : b2Mat33
      {
         return new b2Mat33(col1,col2,col3);
      }
      
      public function AddM(m:b2Mat33) : void
      {
         col1.x += m.col1.x;
         col1.y += m.col1.y;
         col1.z += m.col1.z;
         col2.x += m.col2.x;
         col2.y += m.col2.y;
         col2.z += m.col2.z;
         col3.x += m.col3.x;
         col3.y += m.col3.y;
         col3.z += m.col3.z;
      }
   }
}

