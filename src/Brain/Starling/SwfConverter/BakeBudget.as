package Brain.Starling.SwfConverter
{
   import flash.display3D.Context3D;
   import flash.system.Capabilities;
   import flash.utils.getTimer;
   import starling.core.Starling;
   
   public class BakeBudget
   {
      
      public static const POOL_HUD_STARLING:String = "hudStarling";
      
      public static var HUD_STARLING_CAP_MIB:Number = 64;
      
      public static const POOL_WORLD:String = "world";
      
      private static const MIB:Number = 1048576;
      
      public static const HEADROOM_MIB:Number = 32;
      
      public static const RECTANGLE_BUDGET_MIB:Number = 512;
      
      public static const OTHER_RECTANGLES_MIB:Number = 256;
      
      public static const MAX_FIGHT_DEFER_MS:int = 4000;
      
      public static const FIGHT_ALLOW_MS:int = 500;
      
      private static var sMajor:int = -1;
      
      private static var sRectangleUsed:Number = 0;
      
      private static var sDeferredSince:int = -1;
      
      private static var sAllowUntil:int = -1;
      
      private static var sUsed:Object = {};
      
      public function BakeBudget()
      {
         super();
      }
      
      public static function get mayAllocate() : Boolean
      {
         var _loc1_:Boolean = !BakeScheduler.loading && !BakeScheduler.fighting;
         if(_loc1_)
         {
            sDeferredSince = -1;
         }
         return _loc1_;
      }
      
      public static function get admitting() : Boolean
      {
         return mayAllocate || fightWaitOver();
      }
      
      public static function accountedBytes(width:int, height:int, rectangle:Boolean) : Number
      {
         return width * height * 4 * (rectangle ? 1 : 1.5);
      }
      
      public static function get effectiveRuntimeCapMiB() : Number
      {
         return separateRectangleBudget ? 504 : 2040;
      }
      
      public static function get separateRectangleBudget() : Boolean
      {
         var _loc1_:Array = null;
         if(sMajor < 0)
         {
            _loc1_ = Capabilities.version.match(/(\d+),/);
            sMajor = _loc1_ != null ? int(_loc1_[1]) : 0;
         }
         return sMajor > 0 && sMajor <= 32;
      }
      
      public static function capBytes(pool:String) : Number
      {
         switch(pool)
         {
            case "hudStarling":
               return HUD_STARLING_CAP_MIB * 1048576;
            case "world":
               return 8 * 1048576;
            default:
               return 0;
         }
      }
      
      public static function usedBytes(pool:String) : Number
      {
         return Number(sUsed[pool]) || 0;
      }
      
      public static function get gpuBytes() : Number
      {
         var _loc1_:Context3D = Starling.context;
         if(_loc1_ == null || !("totalGPUMemory" in _loc1_))
         {
            return -1;
         }
         return Number(_loc1_["totalGPUMemory"]);
      }
      
      public static function reserve(pool:String, width:int, height:int, force:Boolean, rectangle:Boolean) : Boolean
      {
         if(!force && !admitting)
         {
            return false;
         }
         var _loc6_:Number = accountedBytes(width,height,rectangle);
         if(usedBytes(pool) + _loc6_ > capBytes(pool) || !fitsHeadroom(_loc6_,rectangle))
         {
            return false;
         }
         sUsed[pool] = usedBytes(pool) + _loc6_;
         if(rectangle)
         {
            sRectangleUsed += _loc6_;
         }
         return true;
      }
      
      public static function unreserve(pool:String, width:int, height:int, rectangle:Boolean) : void
      {
         var _loc5_:Number = accountedBytes(width,height,rectangle);
         sUsed[pool] = Math.max(0,usedBytes(pool) - _loc5_);
         if(rectangle)
         {
            sRectangleUsed = Math.max(0,sRectangleUsed - _loc5_);
         }
      }
      
      private static function fitsHeadroom(bytes:Number, rectangle:Boolean) : Boolean
      {
         var _loc3_:Number = gpuBytes;
         if(rectangle && separateRectangleBudget)
         {
            if(sRectangleUsed + bytes > (512 - 256 - 32) * 1048576)
            {
               return false;
            }
            return _loc3_ < 0 || _loc3_ + bytes <= (effectiveRuntimeCapMiB + 512 - 32) * 1048576;
         }
         return _loc3_ < 0 || _loc3_ + bytes <= (effectiveRuntimeCapMiB - 32) * 1048576;
      }
      
      private static function fightWaitOver() : Boolean
      {
         var _loc1_:int = getTimer();
         if(BakeScheduler.loading)
         {
            sDeferredSince = -1;
            return false;
         }
         if(sAllowUntil >= 0 && _loc1_ < sAllowUntil)
         {
            return true;
         }
         sAllowUntil = -1;
         if(sDeferredSince < 0)
         {
            sDeferredSince = _loc1_;
            return false;
         }
         if(_loc1_ - sDeferredSince < 4000)
         {
            return false;
         }
         sDeferredSince = -1;
         sAllowUntil = _loc1_ + 500;
         return true;
      }
   }
}

