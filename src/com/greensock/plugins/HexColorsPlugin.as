package com.greensock.plugins
{
   import com.greensock.*;
   
   public class HexColorsPlugin extends TweenPlugin
   {
      
      public static const API:Number = 1;
      
      protected var _colors:Array;
      
      public function HexColorsPlugin()
      {
         super();
         this.propName = "hexColors";
         this.overwriteProps = [];
         _colors = [];
      }
      
      override public function killProps(lookup:Object) : void
      {
         var _loc2_:* = int(_colors.length - 1);
         while(_loc2_ > -1)
         {
            if(lookup[_colors[_loc2_][1]] != undefined)
            {
               _colors.splice(_loc2_,1);
            }
            _loc2_--;
         }
         super.killProps(lookup);
      }
      
      public function initColor(target:Object, propName:String, start:uint, end:uint) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(start != end)
         {
            _loc5_ = start >> 16;
            _loc6_ = start >> 8 & 0xFF;
            _loc7_ = start & 0xFF;
            _colors[_colors.length] = [target,propName,_loc5_,(end >> 16) - _loc5_,_loc6_,(end >> 8 & 0xFF) - _loc6_,_loc7_,(end & 0xFF) - _loc7_];
            this.overwriteProps[this.overwriteProps.length] = propName;
         }
      }
      
      override public function set changeFactor(n:Number) : void
      {
         var _loc3_:Array = null;
         var _loc2_:int = int(_colors.length);
         while(--_loc2_ > -1)
         {
            _loc3_ = _colors[_loc2_];
            _loc3_[0][_loc3_[1]] = _loc3_[2] + n * _loc3_[3] << 16 | _loc3_[4] + n * _loc3_[5] << 8 | _loc3_[6] + n * _loc3_[7];
         }
      }
      
      override public function onInitTween(target:Object, value:*, tween:TweenLite) : Boolean
      {
         var _loc4_:String = null;
         for(_loc4_ in value)
         {
            initColor(target,_loc4_,uint(target[_loc4_]),uint(value[_loc4_]));
         }
         return true;
      }
   }
}

