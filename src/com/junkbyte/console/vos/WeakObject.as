package com.junkbyte.console.vos
{
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   
   use namespace flash_proxy;
   
   public dynamic class WeakObject extends Proxy
   {
      
      private var _item:Array;
      
      private var _dir:Object;
      
      public function WeakObject()
      {
         super();
         this._dir = new Object();
      }
      
      public function set(n:String, obj:Object, strong:Boolean = false) : void
      {
         if(obj == null)
         {
            delete this._dir[n];
         }
         else
         {
            this._dir[n] = new WeakRef(obj,strong);
         }
      }
      
      public function get(n:String) : *
      {
         var _loc2_:WeakRef = this.getWeakRef(n);
         return _loc2_ ? _loc2_.reference : undefined;
      }
      
      public function getWeakRef(n:String) : WeakRef
      {
         return this._dir[n] as WeakRef;
      }
      
      override flash_proxy function getProperty(n:*) : *
      {
         return this.get(n);
      }
      
      override flash_proxy function callProperty(n:*, ... rest) : *
      {
         var _loc3_:Object = this.get(n);
         return _loc3_.apply(this,rest);
      }
      
      override flash_proxy function setProperty(n:*, v:*) : void
      {
         this.set(n,v);
      }
      
      override flash_proxy function nextName(index:int) : String
      {
         return this._item[index - 1];
      }
      
      override flash_proxy function nextValue(index:int) : *
      {
         return this[this.nextName(index)];
      }
      
      override flash_proxy function nextNameIndex(index:int) : int
      {
         var _loc2_:* = undefined;
         if(index == 0)
         {
            this._item = new Array();
            for(_loc2_ in this._dir)
            {
               this._item.push(_loc2_);
            }
         }
         if(index < this._item.length)
         {
            return index + 1;
         }
         return 0;
      }
      
      override flash_proxy function deleteProperty(name:*) : Boolean
      {
         return delete this._dir[name];
      }
      
      public function toString() : String
      {
         return "[WeakObject]";
      }
   }
}

