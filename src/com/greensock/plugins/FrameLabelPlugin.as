package com.greensock.plugins
{
   import com.greensock.*;
   import flash.display.*;
   
   public class FrameLabelPlugin extends FramePlugin
   {
      
      public static const API:Number = 1;
      
      public function FrameLabelPlugin()
      {
         super();
         this.propName = "frameLabel";
      }
      
      override public function onInitTween(target:Object, value:*, tween:TweenLite) : Boolean
      {
         if(!tween.target is MovieClip)
         {
            return false;
         }
         _target = target as MovieClip;
         this.frame = _target.currentFrame;
         var _loc4_:Array = _target.currentLabels;
         var _loc5_:String = value;
         var _loc6_:int = _target.currentFrame;
         var _loc7_:* = int(_loc4_.length);
         while(_loc7_--)
         {
            if(_loc4_[_loc7_].name == _loc5_)
            {
               _loc6_ = int(_loc4_[_loc7_].frame);
               break;
            }
         }
         if(this.frame != _loc6_)
         {
            addTween(this,"frame",this.frame,_loc6_,"frame");
         }
         return true;
      }
   }
}

