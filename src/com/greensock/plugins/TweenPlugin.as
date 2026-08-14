package com.greensock.plugins
{
   import com.greensock.*;
   import com.greensock.core.*;
   
   public class TweenPlugin
   {
      
      public static const VERSION:Number = 1.4;
      
      public static const API:Number = 1;
      
      public var activeDisable:Boolean;
      
      public var onInitAllProps:Function;
      
      protected var _tweens:Array = [];
      
      public var onDisable:Function;
      
      public var propName:String;
      
      public var onEnable:Function;
      
      public var round:Boolean;
      
      public var priority:int = 0;
      
      public var overwriteProps:Array;
      
      public var onComplete:Function;
      
      protected var _changeFactor:Number = 0;
      
      public function TweenPlugin()
      {
         super();
      }
      
      public static function activate(plugins:Array) : Boolean
      {
         var _loc3_:Object = null;
         TweenLite.onPluginEvent = TweenPlugin.onTweenEvent;
         var _loc2_:* = int(plugins.length);
         while(_loc2_--)
         {
            if(plugins[_loc2_].hasOwnProperty("API"))
            {
               _loc3_ = new (plugins[_loc2_] as Class)();
               TweenLite.plugins[_loc3_.propName] = plugins[_loc2_];
            }
         }
         return true;
      }
      
      private static function onTweenEvent(type:String, tween:TweenLite) : Boolean
      {
         var _loc4_:Boolean = false;
         var _loc5_:Array = null;
         var _loc6_:* = 0;
         var _loc3_:PropTween = tween.cachedPT1;
         if(type == "onInitAllProps")
         {
            _loc5_ = [];
            _loc6_ = 0;
            while(_loc3_)
            {
               var _loc7_:Number;
               _loc5_[_loc7_ = _loc6_++] = _loc3_;
               _loc3_ = _loc3_.nextNode;
            }
            _loc5_.sortOn("priority",Array.NUMERIC | Array.DESCENDING);
            while(--_loc6_ > -1)
            {
               PropTween(_loc5_[_loc6_]).nextNode = _loc5_[_loc6_ + 1];
               PropTween(_loc5_[_loc6_]).prevNode = _loc5_[_loc6_ - 1];
            }
            _loc3_ = tween.cachedPT1 = _loc5_[0];
         }
         while(_loc3_)
         {
            if(_loc3_.isPlugin && Boolean(_loc3_.target[type]))
            {
               if(_loc3_.target.activeDisable)
               {
                  _loc4_ = true;
               }
               _loc3_.target[type]();
            }
            _loc3_ = _loc3_.nextNode;
         }
         return _loc4_;
      }
      
      public function set changeFactor(n:Number) : void
      {
         updateTweens(n);
         _changeFactor = n;
      }
      
      protected function updateTweens(changeFactor:Number) : void
      {
         var _loc3_:PropTween = null;
         var _loc4_:Number = NaN;
         var _loc2_:int = int(_tweens.length);
         if(this.round)
         {
            while(--_loc2_ > -1)
            {
               _loc3_ = _tweens[_loc2_];
               _loc4_ = _loc3_.start + _loc3_.change * changeFactor;
               if(_loc4_ > 0)
               {
                  _loc3_.target[_loc3_.property] = _loc4_ + 0.5 >> 0;
               }
               else
               {
                  _loc3_.target[_loc3_.property] = _loc4_ - 0.5 >> 0;
               }
            }
         }
         else
         {
            while(--_loc2_ > -1)
            {
               _loc3_ = _tweens[_loc2_];
               _loc3_.target[_loc3_.property] = _loc3_.start + _loc3_.change * changeFactor;
            }
         }
      }
      
      protected function addTween(object:Object, propName:String, start:Number, end:*, overwriteProp:String = null) : void
      {
         var _loc6_:Number = NaN;
         if(end != null)
         {
            _loc6_ = typeof end == "number" ? Number(end) - start : Number(end);
            if(_loc6_ != 0)
            {
               _tweens[_tweens.length] = new PropTween(object,propName,start,_loc6_,overwriteProp || propName,false);
            }
         }
      }
      
      public function onInitTween(target:Object, value:*, tween:TweenLite) : Boolean
      {
         addTween(target,this.propName,target[this.propName],value,this.propName);
         return true;
      }
      
      public function get changeFactor() : Number
      {
         return _changeFactor;
      }
      
      public function killProps(lookup:Object) : void
      {
         var _loc2_:int = int(this.overwriteProps.length);
         while(--_loc2_ > -1)
         {
            if(this.overwriteProps[_loc2_] in lookup)
            {
               this.overwriteProps.splice(_loc2_,1);
            }
         }
         _loc2_ = int(_tweens.length);
         while(--_loc2_ > -1)
         {
            if(PropTween(_tweens[_loc2_]).name in lookup)
            {
               _tweens.splice(_loc2_,1);
            }
         }
      }
   }
}

