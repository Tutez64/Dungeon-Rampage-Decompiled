package Brain.Utils
{
   import flash.system.System;
   
   public class MemoryUtil
   {
      
      public function MemoryUtil()
      {
         super();
      }
      
      public static function pauseForGCWithLogging(logPrefix:String = "", collectionProbabilityThreshold:Number = 0.25) : void
      {
         System.pauseForGCIfCollectionImminent(collectionProbabilityThreshold);
      }
   }
}

