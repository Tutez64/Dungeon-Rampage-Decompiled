package com.wildtangent
{
   public final class Vex extends Core
   {
      
      public function Vex()
      {
         super();
      }
      
      public function redemptionComplete(param1:Object) : Boolean
      {
         return myVex.redemptionComplete(param1);
      }
      
      public function sendExistingParameters() : void
      {
         if(_redeemCode != null)
         {
            myVex.redeemCode = _redeemCode;
         }
         if(_error != null)
         {
            myVex.error = _error;
         }
         if(_itemHandler != null)
         {
            myVex.itemHandler = _itemHandler;
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
      
      public function set redeemCode(param1:Function) : void
      {
         if(vexReady)
         {
            myVex.redeemCode = param1;
         }
         else
         {
            _redeemCode = param1;
         }
      }
      
      public function set itemHandler(param1:Function) : void
      {
         if(vexReady)
         {
            myVex.itemHandler = param1;
         }
         else
         {
            _itemHandler = param1;
         }
      }
   }
}

