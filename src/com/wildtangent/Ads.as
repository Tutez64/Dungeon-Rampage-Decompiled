package com.wildtangent
{
   public final class Ads extends Core
   {
      
      public function Ads()
      {
         super();
      }
      
      public function show(param1:Object = null) : Boolean
      {
         if(vexFailed)
         {
            if(_adComplete != null)
            {
               _adComplete.call(null,param1);
            }
            return false;
         }
         if(vexReady)
         {
            return myVex.showAd(param1);
         }
         storeMethod(show,param1);
         return true;
      }
      
      public function sendExistingParameters() : void
      {
         if(_adComplete != null)
         {
            myVex.adComplete = _adComplete;
         }
         if(_error != null)
         {
            myVex.error = _error;
         }
      }
      
      public function set complete(param1:Function) : void
      {
         if(vexReady)
         {
            myVex.adComplete = param1;
         }
         else
         {
            _adComplete = param1;
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

