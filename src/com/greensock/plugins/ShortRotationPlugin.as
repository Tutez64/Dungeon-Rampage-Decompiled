package com.greensock.plugins
{
   import com.greensock.*;
   
   public class ShortRotationPlugin extends TweenPlugin
   {
      
      public static const API:Number = 1;
      
      public function ShortRotationPlugin()
      {
         super();
         this.propName = "shortRotation";
         this.overwriteProps = [];
      }
      
      override public function onInitTween(target:Object, value:*, tween:TweenLite) : Boolean
      {
         var _loc4_:String = null;
         if(typeof value == "number")
         {
            return false;
         }
         for(_loc4_ in value)
         {
            initRotation(target,_loc4_,target[_loc4_],typeof value[_loc4_] == "number" ? Number(value[_loc4_]) : target[_loc4_] + Number(value[_loc4_]));
         }
         return true;
      }
      
      public function initRotation(target:Object, propName:String, start:Number, end:Number) : void
      {
         var _loc5_:Number = (end - start) % 360;
         if(_loc5_ != _loc5_ % 180)
         {
            _loc5_ = _loc5_ < 0 ? _loc5_ + 360 : _loc5_ - 360;
         }
         addTween(target,propName,start,start + _loc5_,propName);
         this.overwriteProps[this.overwriteProps.length] = propName;
      }
   }
}

