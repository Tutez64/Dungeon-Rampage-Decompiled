package com.greensock.plugins
{
   import com.greensock.*;
   
   public class EndArrayPlugin extends TweenPlugin
   {
      
      public static const API:Number = 1;
      
      protected var _a:Array;
      
      protected var _info:Array = [];
      
      public function EndArrayPlugin()
      {
         super();
         this.propName = "endArray";
         this.overwriteProps = ["endArray"];
      }
      
      public function init(start:Array, end:Array) : void
      {
         _a = start;
         var _loc3_:* = int(end.length);
         while(_loc3_--)
         {
            if(start[_loc3_] != end[_loc3_] && start[_loc3_] != null)
            {
               _info[_info.length] = new ArrayTweenInfo(_loc3_,_a[_loc3_],end[_loc3_] - _a[_loc3_]);
            }
         }
      }
      
      override public function onInitTween(target:Object, value:*, tween:TweenLite) : Boolean
      {
         if(!(target is Array) || !(value is Array))
         {
            return false;
         }
         init(target as Array,value);
         return true;
      }
      
      override public function set changeFactor(n:Number) : void
      {
         var _loc3_:ArrayTweenInfo = null;
         var _loc4_:Number = NaN;
         var _loc2_:* = int(_info.length);
         if(this.round)
         {
            while(_loc2_--)
            {
               _loc3_ = _info[_loc2_];
               _loc4_ = _loc3_.start + _loc3_.change * n;
               if(_loc4_ > 0)
               {
                  _a[_loc3_.index] = _loc4_ + 0.5 >> 0;
               }
               else
               {
                  _a[_loc3_.index] = _loc4_ - 0.5 >> 0;
               }
            }
         }
         else
         {
            while(_loc2_--)
            {
               _loc3_ = _info[_loc2_];
               _a[_loc3_.index] = _loc3_.start + _loc3_.change * n;
            }
         }
      }
   }
}

class ArrayTweenInfo
{
   
   public var change:Number;
   
   public var start:Number;
   
   public var index:uint;
   
   public function ArrayTweenInfo(index:uint, start:Number, change:Number)
   {
      super();
      this.index = index;
      this.start = start;
      this.change = change;
   }
}
