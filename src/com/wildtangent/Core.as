package com.wildtangent
{
   import flash.display.Sprite;
   
   public class Core extends Sprite
   {
      
      public var vexReady:Boolean = false;
      
      public var vexFailed:Boolean = false;
      
      public var myVex:* = null;
      
      private var callbacks:Object;
      
      private var _dpName:String;
      
      private var _gameName:String;
      
      private var _partnerName:String;
      
      private var _siteName:String;
      
      private var _userId:String;
      
      private var _cipherKey:String;
      
      private var _vexUrl:String = "http://vex.wildtangent.com";
      
      private var _sandbox:Boolean = false;
      
      private var _javascriptReady:Boolean = false;
      
      public var _adComplete:Function;
      
      public var _closed:Function;
      
      public var _error:Function;
      
      public var _handlePromo:Function;
      
      public var _redeemCode:Function;
      
      public var _requireLogin:Function;
      
      protected var _itemHandler:Function;
      
      public var methodStorage:Array = [];
      
      public function Core()
      {
         super();
      }
      
      public function storeMethod(param1:Function, param2:Object) : void
      {
         methodStorage.push({
            "tempMethod":param1,
            "obj":param2
         });
      }
      
      public function launchMethods() : void
      {
         var _loc1_:String = null;
         for(_loc1_ in methodStorage)
         {
            if(methodStorage[_loc1_].obj != null)
            {
               methodStorage[_loc1_].tempMethod.call(null,methodStorage[_loc1_].obj);
            }
            else
            {
               methodStorage[_loc1_].tempMethod.call(null);
            }
         }
         methodStorage = [];
      }
      
      public function checkTop() : void
      {
         var _loc1_:* = root;
         var _loc2_:* = parent;
         _loc1_.setChildIndex(_loc1_.getChildByName(_loc2_.name),_loc1_.numChildren - 1);
      }
   }
}

