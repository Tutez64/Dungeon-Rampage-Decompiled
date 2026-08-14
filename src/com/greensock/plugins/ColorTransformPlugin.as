package com.greensock.plugins
{
   import com.greensock.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   
   public class ColorTransformPlugin extends TintPlugin
   {
      
      public static const API:Number = 1;
      
      public function ColorTransformPlugin()
      {
         super();
         this.propName = "colorTransform";
      }
      
      override public function onInitTween(target:Object, value:*, tween:TweenLite) : Boolean
      {
         var _loc4_:ColorTransform = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc5_:ColorTransform = new ColorTransform();
         if(target is DisplayObject)
         {
            _transform = DisplayObject(target).transform;
            _loc4_ = _transform.colorTransform;
         }
         else
         {
            if(!(target is ColorTransform))
            {
               return false;
            }
            _loc4_ = target as ColorTransform;
         }
         _loc5_.concat(_loc4_);
         for(_loc6_ in value)
         {
            if(_loc6_ == "tint" || _loc6_ == "color")
            {
               if(value[_loc6_] != null)
               {
                  _loc5_.color = int(value[_loc6_]);
               }
            }
            else if(!(_loc6_ == "tintAmount" || _loc6_ == "exposure" || _loc6_ == "brightness"))
            {
               _loc5_[_loc6_] = value[_loc6_];
            }
         }
         if(!isNaN(value.tintAmount))
         {
            _loc7_ = value.tintAmount / (1 - (_loc5_.redMultiplier + _loc5_.greenMultiplier + _loc5_.blueMultiplier) / 3);
            _loc5_.redOffset *= _loc7_;
            _loc5_.greenOffset *= _loc7_;
            _loc5_.blueOffset *= _loc7_;
            _loc5_.redMultiplier = _loc5_.greenMultiplier = _loc5_.blueMultiplier = 1 - value.tintAmount;
         }
         else if(!isNaN(value.exposure))
         {
            _loc5_.redOffset = _loc5_.greenOffset = _loc5_.blueOffset = 255 * (value.exposure - 1);
            _loc5_.redMultiplier = _loc5_.greenMultiplier = _loc5_.blueMultiplier = 1;
         }
         else if(!isNaN(value.brightness))
         {
            _loc5_.redOffset = _loc5_.greenOffset = _loc5_.blueOffset = Math.max(0,(value.brightness - 1) * 255);
            _loc5_.redMultiplier = _loc5_.greenMultiplier = _loc5_.blueMultiplier = 1 - Math.abs(value.brightness - 1);
         }
         _ignoreAlpha = Boolean(tween.vars.alpha != undefined && value.alphaMultiplier == undefined);
         init(_loc4_,_loc5_);
         return true;
      }
   }
}

