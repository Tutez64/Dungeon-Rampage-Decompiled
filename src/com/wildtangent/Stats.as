package com.wildtangent
{
   import flash.events.Event;
   
   public final class Stats extends Core
   {
      
      public function Stats()
      {
         super();
      }
      
      public function getStats(param1:Object) : void
      {
         var obj:Object = param1;
         if(vexReady)
         {
            if(!myVex.hasEventListener(Event.COMPLETE))
            {
               myVex.addEventListener(Event.COMPLETE,function(param1:Event):void
               {
                  dispatchEvent(new StatsEvent(StatsEvent.STATS_COMPLETE,param1.target.statsData));
               });
            }
            myVex.getStats(obj);
         }
         else
         {
            storeMethod(getStats,obj);
         }
      }
      
      public function submit(param1:Object) : Boolean
      {
         if(vexReady)
         {
            return myVex.submitStats(param1);
         }
         storeMethod(submit,param1);
         return true;
      }
      
      public function sendExistingParameters() : void
      {
         if(_error != null)
         {
            myVex.error = _error;
         }
      }
      
      public function set error(param1:Function) : void
      {
         if(vexReady)
         {
            myVex.error = param1;
         }
         else
         {
            _error = param1;
         }
      }
   }
}

