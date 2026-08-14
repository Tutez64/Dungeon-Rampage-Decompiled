package Brain.Utils
{
   import flash.display.Stage;
   import flash.events.Event;
   import flash.sampler.*;
   import flash.utils.Dictionary;
   
   public class MemoryTracker
   {
      
      public static const CATEGORY_POOL:String = "pool";
      
      private static var m_count:int = 0;
      
      private static var m_stage:Stage = null;
      
      private static var m_generation:int = 0;
      
      private static var m_checkpointGeneration:int = 0;
      
      private static var m_currentFilter:Object = null;
      
      private static var m_tracking:Dictionary = new Dictionary(true);
      
      public function MemoryTracker()
      {
         super();
      }
      
      public static function set stage(s:Stage) : void
      {
         m_stage = s;
      }
      
      public static function track(obj:*, label:String, category:String = "default") : void
      {
      }
      
      public static function nextGeneration() : void
      {
      }
      
      private static function parseFilter(filterString:String) : Object
      {
         var _loc2_:String = null;
         if(!filterString || filterString.length == 0)
         {
            return null;
         }
         var _loc6_:Array = [];
         var _loc3_:Array = [];
         var _loc5_:Array = filterString.split(/\s+/);
         for each(var _loc4_:String in _loc5_)
         {
            if(_loc4_.length != 0)
            {
               if(_loc4_.charAt(0) == "!")
               {
                  _loc2_ = _loc4_.substring(1);
                  if(_loc2_.length > 0)
                  {
                     _loc3_.push(_loc2_);
                  }
               }
               else
               {
                  _loc6_.push(_loc4_);
               }
            }
         }
         if(_loc6_.length == 0 && _loc3_.length == 0)
         {
            return null;
         }
         return {
            "incl":_loc6_,
            "excl":_loc3_
         };
      }
      
      private static function passesCategoryFilter(category:String, filter:Object) : Boolean
      {
         if(!filter)
         {
            return true;
         }
         if(filter.excl.length > 0)
         {
            if(filter.excl.indexOf(category) >= 0)
            {
               return false;
            }
         }
         if(filter.incl.length > 0)
         {
            if(filter.incl.indexOf(category) < 0)
            {
               return false;
            }
         }
         return true;
      }
      
      private static function getFilterDescription(filter:Object) : String
      {
         if(!filter)
         {
            return "";
         }
         var _loc2_:Array = [];
         if(filter.incl.length > 0)
         {
            _loc2_.push("include: " + filter.incl.join(", "));
         }
         if(filter.excl.length > 0)
         {
            _loc2_.push("exclude: " + filter.excl.join(", "));
         }
         return " (" + _loc2_.join("; ") + ")";
      }
      
      public static function get generation() : int
      {
         return m_generation;
      }
      
      public static function memoryReport(filterString:String = null) : void
      {
      }
      
      public static function get trackedCount() : int
      {
         var _loc1_:int = 0;
         for(var _loc2_:Object in m_tracking)
         {
            _loc1_++;
         }
         return _loc1_;
      }
      
      public static function get trackedCountSinceCheckpoint() : int
      {
         var _loc3_:Object = null;
         var _loc1_:int = 0;
         for(var _loc2_:Object in m_tracking)
         {
            _loc3_ = m_tracking[_loc2_];
            if(_loc3_.generation >= m_checkpointGeneration)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      private static function _forEachTracked(fn:Function) : void
      {
         for(var _loc2_:Object in m_tracking)
         {
            fn(_loc2_,m_tracking[_loc2_]);
         }
      }
      
      public static function getAllTracked() : Array
      {
         return [];
      }
      
      public static function getGrowingLeaks() : Array
      {
         return [];
      }
      
      public static function getPoolLeakCandidates() : Array
      {
         return [];
      }
      
      public static function findTrackedByLabel(labelSubstring:String) : Array
      {
         return [];
      }
      
      private static function _gc(e:Event) : void
      {
      }
      
      private static function _doLastGC() : void
      {
      }
   }
}

