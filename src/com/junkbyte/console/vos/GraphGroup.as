package com.junkbyte.console.vos
{
   import flash.Boot;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   public class GraphGroup
   {
      
      public static var FPS:uint = 1;
      
      public static var MEM:uint = 2;
      
      public var type:uint;
      
      public var rect:Rectangle;
      
      public var name:String;
      
      public var low:Number;
      
      public var inv:Boolean;
      
      public var interests:Array;
      
      public var idle:int;
      
      public var hi:Number;
      
      public var freq:int;
      
      public var fixed:Boolean;
      
      public var averaging:uint;
      
      public function GraphGroup(n:String = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         idle = 0;
         rect = null;
         interests = [];
         inv = false;
         averaging = 0;
         fixed = false;
         hi = Number(Number.NaN);
         low = Number(Number.NaN);
         freq = 1;
         name = null;
         type = 0;
         name = n;
      }
      
      public static function FromBytes(bytes:ByteArray) : GraphGroup
      {
         var _loc2_:GraphGroup = new GraphGroup(bytes.readUTF());
         _loc2_.type = bytes.readUnsignedInt();
         _loc2_.idle = bytes.readUnsignedInt();
         _loc2_.low = bytes.readDouble();
         _loc2_.hi = bytes.readDouble();
         _loc2_.inv = bytes.readBoolean();
         var _loc3_:uint = bytes.readUnsignedInt();
         while(_loc3_ != 0)
         {
            _loc2_.interests.push(GraphInterest.FromBytes(bytes));
            _loc3_ -= 1;
         }
         return _loc2_;
      }
      
      public function updateMinMax(v:Number) : void
      {
         var _loc2_:Number = NaN;
         if(v == v && !fixed)
         {
            _loc2_ = low;
            if(_loc2_ != _loc2_)
            {
               low = v;
               hi = v;
            }
            if(v > hi)
            {
               hi = v;
            }
            if(v < low)
            {
               low = v;
            }
         }
      }
      
      public function toBytes(bytes:ByteArray) : void
      {
         var _loc4_:* = null as GraphInterest;
         bytes.writeUTF(name);
         bytes.writeUnsignedInt(type);
         bytes.writeUnsignedInt(idle);
         bytes.writeDouble(low);
         bytes.writeDouble(hi);
         bytes.writeBoolean(inv);
         bytes.writeUnsignedInt(int(interests.length));
         var _loc2_:int = 0;
         var _loc3_:Array = interests;
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            _loc4_.toBytes(bytes);
         }
      }
   }
}

