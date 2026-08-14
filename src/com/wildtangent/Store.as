package com.wildtangent
{
   public final class Store extends Core
   {
      
      private var _windowClose:Function = null;
      
      private var _windowOpen:Function = null;
      
      public function Store()
      {
         super();
      }
      
      public function sendExistingParameters() : void
      {
         if(_closed != null)
         {
            myVex.itemStoreClosed = _closed;
         }
         if(_windowClose != null)
         {
            myVex.itemStoreWindowClose = _windowClose;
         }
         if(_windowOpen != null)
         {
            myVex.itemStoreWindowOpen = _windowOpen;
         }
      }
      
      public function showItem(param1:Object) : void
      {
         if(vexReady)
         {
            myVex.showItem(param1);
         }
         else
         {
            storeMethod(showItem,param1);
         }
      }
      
      public function set closed(param1:Function) : void
      {
         if(vexReady)
         {
            myVex.itemStoreClosed = param1;
         }
         else
         {
            _closed = param1;
         }
      }
      
      public function set windowClose(param1:Function) : void
      {
         if(vexReady)
         {
            myVex.itemStoreWindowClose = param1;
         }
         else
         {
            _windowClose = param1;
         }
      }
      
      public function set windowOpen(param1:Function) : void
      {
         if(vexReady)
         {
            myVex.itemStoreWindowOpen = param1;
         }
         else
         {
            _windowOpen = param1;
         }
      }
   }
}

