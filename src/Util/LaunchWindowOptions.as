package Util
{
   import Brain.Logger.Logger;
   import Brain.Utils.FeatureFlags;
   import flash.display.NativeWindow;
   import flash.display.Stage;
   
   public class LaunchWindowOptions
   {
      
      public function LaunchWindowOptions()
      {
         super();
      }
      
      public static function apply(stage:Stage, flags:FeatureFlags, arguments:Array) : void
      {
         var _loc5_:Array = null;
         var _loc6_:NativeWindow = null;
         for each(var _loc4_:String in arguments)
         {
            if(!(_loc4_ != "--windowed" && _loc4_.indexOf("--windowed=") != 0))
            {
               _loc5_ = _loc4_ == "--windowed" ? null : /^(\d{1,4})x(\d{1,4})$/i.exec(_loc4_.substr(11));
               if(_loc4_ != "--windowed" && (!_loc5_ || int(_loc5_[1]) < 1 || int(_loc5_[2]) < 1 || int(_loc5_[1]) > 8192 || int(_loc5_[2]) > 8192))
               {
                  Logger.warn("Expected --windowed or --windowed=WIDTHxHEIGHT (each dimension 1..8192)");
                  return;
               }
               flags.setFlagCliValue("start-windowed",true);
               stage.displayState = "normal";
               _loc6_ = stage.nativeWindow;
               _loc6_.restore();
               if(!_loc5_)
               {
                  return;
               }
               _loc6_.width += int(_loc5_[1]) - stage.stageWidth;
               _loc6_.height += int(_loc5_[2]) - stage.stageHeight;
               Logger.info("Windowed game size requested: " + _loc5_[1] + "x" + _loc5_[2]);
               return;
            }
         }
      }
   }
}

