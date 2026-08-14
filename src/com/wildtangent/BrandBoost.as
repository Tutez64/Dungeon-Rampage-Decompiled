package com.wildtangent
{
   public final class BrandBoost extends Core
   {
      
      public function BrandBoost()
      {
         super();
      }
      
      public function launch(param1:Object) : void
      {
         if(vexReady)
         {
            if(param1.promoName == null)
            {
               throw new Error("Please provide a valid promoName when calling BrandBoost.launch");
            }
            myVex.launchBrandBoost(param1);
         }
         else
         {
            storeMethod(launch,param1);
         }
      }
      
      public function getPromo(param1:Object) : Boolean
      {
         var _loc2_:Boolean = false;
         if(vexFailed)
         {
            if(_handlePromo != null)
            {
               _handlePromo.call(null,{"available":false});
            }
            return false;
         }
         if(vexReady)
         {
            _loc2_ = Boolean(myVex.addPromo(param1));
            if(_loc2_)
            {
               myVex.initialize();
            }
            return _loc2_;
         }
         storeMethod(getPromo,param1);
         return true;
      }
      
      public function resumeAfterLogin(param1:Object) : void
      {
         myVex.userId = param1.userId;
      }
      
      public function sendExistingParameters() : void
      {
         if(_closed != null)
         {
            myVex.closed = _closed;
         }
         if(_error != null)
         {
            myVex.error = _error;
         }
         if(_handlePromo != null)
         {
            myVex.handlePromo = _handlePromo;
         }
         if(_requireLogin != null)
         {
            myVex.requireLogin = _requireLogin;
         }
      }
      
      public function set closed(param1:Function) : void
      {
         if(vexReady)
         {
            myVex.closed = param1;
         }
         else
         {
            _closed = param1;
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
      
      public function set handlePromo(param1:Function) : void
      {
         if(vexReady)
         {
            myVex.handlePromo = param1;
         }
         else
         {
            _handlePromo = param1;
         }
      }
      
      public function set requireLogin(param1:Function) : void
      {
         if(vexReady)
         {
            myVex.requireLogin = param1;
         }
         else
         {
            _requireLogin = param1;
         }
      }
   }
}

