package Box2D.Common
{
   import Box2D.Common.Math.b2Math;
   import flash.Boot;
   
   public class b2Color
   {
      
      public var r:Number;
      
      public var g:Number;
      
      public var color:int;
      
      public var b:Number;
      
      public var _r:int;
      
      public var _g:int;
      
      public var _b:int;
      
      public function b2Color(rr:Number = 0, gg:Number = 0, bb:Number = 0)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _r = int(255 * b2Math.clamp(rr,0,1));
         _g = int(255 * b2Math.clamp(gg,0,1));
         _b = int(255 * b2Math.clamp(bb,0,1));
      }
      
      public function set_r(rr:Number) : Number
      {
         return _r = int(255 * b2Math.clamp(rr,0,1));
      }
      
      public function set_g(gg:Number) : Number
      {
         return _g = int(255 * b2Math.clamp(gg,0,1));
      }
      
      public function set_b(bb:Number) : Number
      {
         return _b = int(255 * b2Math.clamp(bb,0,1));
      }
      
      public function set(rr:Number, gg:Number, bb:Number) : void
      {
         Set(rr,gg,bb);
      }
      
      public function get_color() : int
      {
         return _r << 16 | _g << 8 | _b;
      }
      
      public function getString(alpha:Number = 1) : String
      {
         return GetString(alpha);
      }
      
      public function Set(rr:Number, gg:Number, bb:Number) : void
      {
         _r = int(255 * b2Math.clamp(rr,0,1));
         _g = int(255 * b2Math.clamp(gg,0,1));
         _b = int(255 * b2Math.clamp(bb,0,1));
      }
      
      public function GetString(alpha:Number = 1) : String
      {
         if(alpha == 1)
         {
            return "#" + StringTools.hex((_r & 0xFF) << 16 | (_g & 0xFF) << 8 | _b & 0xFF);
         }
         return "rgba(" + _r + "," + _g + "," + _b + "," + alpha + ")";
      }
   }
}

