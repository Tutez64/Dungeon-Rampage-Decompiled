package com.greensock
{
   import com.greensock.core.*;
   
   public final class OverwriteManager
   {
      
      public static var enabled:Boolean;
      
      public static var mode:int;
      
      public static const version:Number = 6.1;
      
      public static const NONE:int = 0;
      
      public static const ALL_IMMEDIATE:int = 1;
      
      public static const AUTO:int = 2;
      
      public static const CONCURRENT:int = 3;
      
      public static const ALL_ONSTART:int = 4;
      
      public static const PREEXISTING:int = 5;
      
      public function OverwriteManager()
      {
         super();
      }
      
      public static function getGlobalPaused(tween:TweenCore) : Boolean
      {
         var _loc2_:Boolean = false;
         while(tween)
         {
            if(tween.cachedPaused)
            {
               _loc2_ = true;
               break;
            }
            tween = tween.timeline;
         }
         return _loc2_;
      }
      
      public static function init(defaultMode:int = 2) : int
      {
         if(TweenLite.version < 11.6)
         {
            throw new Error("Warning: Your TweenLite class needs to be updated to work with OverwriteManager (or you may need to clear your ASO files). Please download and install the latest version from http://www.tweenlite.com.");
         }
         TweenLite.overwriteManager = OverwriteManager;
         mode = defaultMode;
         enabled = true;
         return mode;
      }
      
      public static function manageOverwrites(tween:TweenLite, props:Object, targetTweens:Array, mode:int) : Boolean
      {
         var _loc5_:* = 0;
         var _loc6_:Boolean = false;
         var _loc7_:TweenLite = null;
         var _loc13_:int = 0;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:TweenCore = null;
         var _loc17_:Number = NaN;
         var _loc18_:SimpleTimeline = null;
         if(mode >= 4)
         {
            _loc13_ = int(targetTweens.length);
            _loc5_ = 0;
            while(_loc5_ < _loc13_)
            {
               _loc7_ = targetTweens[_loc5_];
               if(_loc7_ != tween)
               {
                  if(_loc7_.setEnabled(false,false))
                  {
                     _loc6_ = true;
                  }
               }
               else if(mode == 5)
               {
                  break;
               }
               _loc5_++;
            }
            return _loc6_;
         }
         var _loc8_:Number = tween.cachedStartTime + 1e-10;
         var _loc9_:Array = [];
         var _loc10_:Array = [];
         var _loc11_:* = 0;
         var _loc12_:* = 0;
         _loc5_ = int(targetTweens.length);
         while(--_loc5_ > -1)
         {
            _loc7_ = targetTweens[_loc5_];
            if(!(_loc7_ == tween || _loc7_.gc || !_loc7_.initted && _loc8_ - _loc7_.cachedStartTime <= 2e-10))
            {
               if(_loc7_.timeline != tween.timeline)
               {
                  if(!getGlobalPaused(_loc7_))
                  {
                     var _loc19_:Number;
                     _loc10_[_loc19_ = _loc11_++] = _loc7_;
                  }
               }
               else if(_loc7_.cachedStartTime <= _loc8_ && _loc7_.cachedStartTime + _loc7_.totalDuration + 1e-10 > _loc8_ && !_loc7_.cachedPaused && !(tween.cachedDuration == 0 && _loc8_ - _loc7_.cachedStartTime <= 2e-10))
               {
                  _loc9_[_loc19_ = _loc12_++] = _loc7_;
               }
            }
         }
         if(_loc11_ != 0)
         {
            _loc14_ = tween.cachedTimeScale;
            _loc15_ = _loc8_;
            _loc18_ = tween.timeline;
            while(_loc18_)
            {
               _loc14_ *= _loc18_.cachedTimeScale;
               _loc15_ += _loc18_.cachedStartTime;
               _loc18_ = _loc18_.timeline;
            }
            _loc8_ = _loc14_ * _loc15_;
            _loc5_ = int(_loc11_);
            while(--_loc5_ > -1)
            {
               _loc16_ = _loc10_[_loc5_];
               _loc14_ = _loc16_.cachedTimeScale;
               _loc15_ = _loc16_.cachedStartTime;
               _loc18_ = _loc16_.timeline;
               while(_loc18_)
               {
                  _loc14_ *= _loc18_.cachedTimeScale;
                  _loc15_ += _loc18_.cachedStartTime;
                  _loc18_ = _loc18_.timeline;
               }
               _loc17_ = _loc14_ * _loc15_;
               if(_loc17_ <= _loc8_ && (_loc17_ + _loc16_.totalDuration * _loc14_ + 1e-10 > _loc8_ || _loc16_.cachedDuration == 0))
               {
                  _loc9_[_loc19_ = _loc12_++] = _loc16_;
               }
            }
         }
         if(_loc12_ == 0)
         {
            return _loc6_;
         }
         _loc5_ = int(_loc12_);
         if(mode == 2)
         {
            while(--_loc5_ > -1)
            {
               _loc7_ = _loc9_[_loc5_];
               if(_loc7_.killVars(props))
               {
                  _loc6_ = true;
               }
               if(_loc7_.cachedPT1 == null && _loc7_.initted)
               {
                  _loc7_.setEnabled(false,false);
               }
            }
         }
         else
         {
            while(--_loc5_ > -1)
            {
               if(TweenLite(_loc9_[_loc5_]).setEnabled(false,false))
               {
                  _loc6_ = true;
               }
            }
         }
         return _loc6_;
      }
   }
}

