package com.junkbyte.console.vos
{
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   public class GraphGroup
   {
      
      public static const FPS:uint = 1;
      
      public static const MEM:uint = 2;
      
      public var type:uint;
      
      public var name:String;
      
      public var freq:int = 1;
      
      public var low:Number;
      
      public var hi:Number;
      
      public var fixed:Boolean;
      
      public var averaging:uint;
      
      public var inv:Boolean;
      
      public var interests:Array = [];
      
      public var rect:Rectangle;
      
      public var idle:int;
      
      public function GraphGroup(n:String)
      {
         super();
         this.name = n;
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
         while(_loc3_)
         {
            _loc2_.interests.push(GraphInterest.FromBytes(bytes));
            _loc3_--;
         }
         return _loc2_;
      }
      
      public function updateMinMax(v:Number) : void
      {
         if(!isNaN(v) && !this.fixed)
         {
            if(isNaN(this.low))
            {
               this.low = v;
               this.hi = v;
            }
            if(v > this.hi)
            {
               this.hi = v;
            }
            if(v < this.low)
            {
               this.low = v;
            }
         }
      }
      
      public function toBytes(bytes:ByteArray) : void
      {
         var _loc2_:GraphInterest = null;
         bytes.writeUTF(this.name);
         bytes.writeUnsignedInt(this.type);
         bytes.writeUnsignedInt(this.idle);
         bytes.writeDouble(this.low);
         bytes.writeDouble(this.hi);
         bytes.writeBoolean(this.inv);
         bytes.writeUnsignedInt(this.interests.length);
         for each(_loc2_ in this.interests)
         {
            _loc2_.toBytes(bytes);
         }
      }
   }
}

