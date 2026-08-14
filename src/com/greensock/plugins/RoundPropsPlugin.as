package com.greensock.plugins
{
   import com.greensock.TweenLite;
   import com.greensock.core.PropTween;
   
   public class RoundPropsPlugin extends TweenPlugin
   {
      
      public static const API:Number = 1;
      
      protected var _tween:TweenLite;
      
      public function RoundPropsPlugin()
      {
         super();
         this.propName = "roundProps";
         this.overwriteProps = ["roundProps"];
         this.round = true;
         this.priority = -1;
         this.onInitAllProps = _initAllProps;
      }
      
      public function add(object:Object, propName:String, start:Number, change:Number) : void
      {
         addTween(object,propName,start,start + change,propName);
         this.overwriteProps[this.overwriteProps.length] = propName;
      }
      
      protected function _removePropTween(propTween:PropTween) : void
      {
         if(propTween.nextNode)
         {
            propTween.nextNode.prevNode = propTween.prevNode;
         }
         if(propTween.prevNode)
         {
            propTween.prevNode.nextNode = propTween.nextNode;
         }
         else if(_tween.cachedPT1 == propTween)
         {
            _tween.cachedPT1 = propTween.nextNode;
         }
         if(propTween.isPlugin && Boolean(propTween.target.onDisable))
         {
            propTween.target.onDisable();
         }
      }
      
      override public function onInitTween(target:Object, value:*, tween:TweenLite) : Boolean
      {
         _tween = tween;
         this.overwriteProps = this.overwriteProps.concat(value as Array);
         return true;
      }
      
      protected function _initAllProps() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc4_:PropTween = null;
         var _loc3_:Array = _tween.vars.roundProps;
         var _loc5_:int = int(_loc3_.length);
         while(--_loc5_ > -1)
         {
            _loc1_ = _loc3_[_loc5_];
            _loc4_ = _tween.cachedPT1;
            while(_loc4_)
            {
               if(_loc4_.name == _loc1_)
               {
                  if(_loc4_.isPlugin)
                  {
                     _loc4_.target.round = true;
                  }
                  else
                  {
                     add(_loc4_.target,_loc1_,_loc4_.start,_loc4_.change);
                     _removePropTween(_loc4_);
                     _tween.propTweenLookup[_loc1_] = _tween.propTweenLookup.roundProps;
                  }
               }
               else if(_loc4_.isPlugin && _loc4_.name == "_MULTIPLE_" && !_loc4_.target.round)
               {
                  _loc2_ = " " + _loc4_.target.overwriteProps.join(" ") + " ";
                  if(_loc2_.indexOf(" " + _loc1_ + " ") != -1)
                  {
                     _loc4_.target.round = true;
                  }
               }
               _loc4_ = _loc4_.nextNode;
            }
         }
      }
   }
}

