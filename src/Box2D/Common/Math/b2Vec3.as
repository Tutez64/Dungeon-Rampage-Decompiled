package Box2D.Common.Math
{
   import flash.Boot;
   
   public class b2Vec3
   {
      
      public var z:Number;
      
      public var y:Number;
      
      public var x:Number;
      
      public function b2Vec3(x:Number = 0, y:Number = 0, z:Number = 0)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         this.x = x;
         this.y = y;
         this.z = z;
      }
      
      public function subtract(v:b2Vec3) : void
      {
         Subtract(v);
      }
      
      public function setZero() : void
      {
         SetZero();
      }
      
      public function setV(v:b2Vec3) : void
      {
         SetV(v);
      }
      
      public function set(x:Number, y:Number, z:Number) : void
      {
         Set(x,y,z);
      }
      
      public function negativeSelf() : void
      {
         NegativeSelf();
      }
      
      public function multiply(a:Number) : void
      {
         Multiply(a);
      }
      
      public function getNegative() : b2Vec3
      {
         return GetNegative();
      }
      
      public function copy() : b2Vec3
      {
         return Copy();
      }
      
      public function add(v:b2Vec3) : void
      {
         Add(v);
      }
      
      public function Subtract(v:b2Vec3) : void
      {
         x -= v.x;
         y -= v.y;
         z -= v.z;
      }
      
      public function SetZero() : void
      {
         x = y = Number(z = 0);
      }
      
      public function SetV(v:b2Vec3) : void
      {
         x = v.x;
         y = v.y;
         z = v.z;
      }
      
      public function Set(x:Number, y:Number, z:Number) : void
      {
         this.x = x;
         this.y = y;
         this.z = z;
      }
      
      public function NegativeSelf() : void
      {
         x = -x;
         y = -y;
         z = -z;
      }
      
      public function Multiply(a:Number) : void
      {
         x *= a;
         y *= a;
         z *= a;
      }
      
      public function GetNegative() : b2Vec3
      {
         return new b2Vec3(-x,-y,-z);
      }
      
      public function Copy() : b2Vec3
      {
         return new b2Vec3(x,y,z);
      }
      
      public function Add(v:b2Vec3) : void
      {
         x += v.x;
         y += v.y;
         z += v.z;
      }
   }
}

