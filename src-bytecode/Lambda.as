package
{
   import haxe.ds.List;
   
   public class Lambda
   {
      
      public function Lambda()
      {
      }
      
      public static function array(it:Object) : Array
      {
         var _loc4_:* = null as Object;
         var _loc2_:Array = [];
         var _loc3_:* = it.iterator();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc2_.push(_loc4_);
         }
         return _loc2_;
      }
      
      public static function list(it:Object) : List
      {
         var _loc4_:* = null as Object;
         var _loc2_:List = new List();
         var _loc3_:* = it.iterator();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc2_.add(_loc4_);
         }
         return _loc2_;
      }
      
      public static function map(it:Object, f:Function) : Array
      {
         var _loc5_:* = null as Object;
         var _loc3_:Array = [];
         var _loc4_:* = it.iterator();
         while(_loc4_.hasNext())
         {
            _loc5_ = _loc4_.next();
            _loc3_.push(f(_loc5_));
         }
         return _loc3_;
      }
      
      public static function mapi(it:Object, f:Function) : Array
      {
         var _loc6_:* = null as Object;
         var _loc3_:int = 0;
         var _loc4_:Array = [];
         var _loc5_:* = it.iterator();
         while(_loc5_.hasNext())
         {
            _loc6_ = _loc5_.next();
            _loc4_.push(f(_loc3_++,_loc6_));
         }
         return _loc4_;
      }
      
      public static function flatten(it:Object) : Array
      {
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc6_:* = null as Object;
         var _loc2_:Array = [];
         var _loc3_:* = it.iterator();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc5_ = _loc4_.iterator();
            while(_loc5_.hasNext())
            {
               _loc6_ = _loc5_.next();
               _loc2_.push(_loc6_);
            }
         }
         return _loc2_;
      }
      
      public static function flatMap(it:Object, f:Function) : Array
      {
         var _loc5_:* = null as Object;
         var _loc7_:* = null;
         var _loc8_:* = null;
         var _loc3_:Array = [];
         var _loc4_:* = it.iterator();
         while(_loc4_.hasNext())
         {
            _loc5_ = _loc4_.next();
            _loc3_.push(f(_loc5_));
         }
         var _loc6_:Array = [];
         _loc4_ = _loc3_.iterator();
         while(_loc4_.hasNext())
         {
            _loc7_ = _loc4_.next();
            _loc8_ = _loc7_.iterator();
            while(_loc8_.hasNext())
            {
               _loc5_ = _loc8_.next();
               _loc6_.push(_loc5_);
            }
         }
         return _loc6_;
      }
      
      public static function has(it:Object, elt:Object) : Boolean
      {
         var _loc4_:* = null as Object;
         var _loc3_:* = it.iterator();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            if(_loc4_ == elt)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function exists(it:Object, f:Function) : Boolean
      {
         var _loc4_:* = null as Object;
         var _loc3_:* = it.iterator();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            if(f(_loc4_))
            {
               return true;
            }
         }
         return false;
      }
      
      public static function foreach(it:Object, f:Function) : Boolean
      {
         var _loc4_:* = null as Object;
         var _loc3_:* = it.iterator();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            if(!Boolean(f(_loc4_)))
            {
               return false;
            }
         }
         return true;
      }
      
      public static function iter(it:Object, f:Function) : void
      {
         var _loc4_:* = null as Object;
         var _loc3_:* = it.iterator();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            f(_loc4_);
         }
      }
      
      public static function filter(it:Object, f:Function) : Array
      {
         var _loc5_:* = null as Object;
         var _loc3_:Array = [];
         var _loc4_:* = it.iterator();
         while(_loc4_.hasNext())
         {
            _loc5_ = _loc4_.next();
            if(f(_loc5_))
            {
               _loc3_.push(_loc5_);
            }
         }
         return _loc3_;
      }
      
      public static function fold(it:Object, f:Function, first:Object) : Object
      {
         var _loc5_:* = null as Object;
         var _loc4_:* = it.iterator();
         while(_loc4_.hasNext())
         {
            _loc5_ = _loc4_.next();
            first = f(_loc5_,first);
         }
         return first;
      }
      
      public static function foldi(it:Object, f:Function, first:Object) : Object
      {
         var _loc6_:* = null as Object;
         var _loc4_:int = 0;
         var _loc5_:* = it.iterator();
         while(_loc5_.hasNext())
         {
            _loc6_ = _loc5_.next();
            first = f(_loc6_,first,_loc4_);
            _loc4_++;
         }
         return first;
      }
      
      public static function count(it:Object, pred:Object = undefined) : int
      {
         var _loc4_:* = null;
         var _loc5_:* = null as Object;
         var _loc3_:int = 0;
         if(pred == null)
         {
            _loc4_ = it.iterator();
            while(_loc4_.hasNext())
            {
               _loc5_ = _loc4_.next();
               _loc3_++;
            }
         }
         else
         {
            _loc4_ = it.iterator();
            while(_loc4_.hasNext())
            {
               _loc5_ = _loc4_.next();
               if(pred(_loc5_))
               {
                  _loc3_++;
               }
            }
         }
         return _loc3_;
      }
      
      public static function empty(it:Object) : Boolean
      {
         return !Boolean(it.iterator().hasNext());
      }
      
      public static function indexOf(it:Object, v:Object) : int
      {
         var _loc5_:* = null as Object;
         var _loc3_:int = 0;
         var _loc4_:* = it.iterator();
         while(_loc4_.hasNext())
         {
            _loc5_ = _loc4_.next();
            if(v == _loc5_)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      public static function find(it:Object, f:Function) : Object
      {
         var _loc4_:* = null as Object;
         var _loc3_:* = it.iterator();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            if(f(_loc4_))
            {
               return _loc4_;
            }
         }
         return null;
      }
      
      public static function findIndex(it:Object, f:Function) : int
      {
         var _loc5_:* = null as Object;
         var _loc3_:int = 0;
         var _loc4_:* = it.iterator();
         while(_loc4_.hasNext())
         {
            _loc5_ = _loc4_.next();
            if(f(_loc5_))
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      public static function concat(a:Object, b:Object) : Array
      {
         var _loc5_:* = null as Object;
         var _loc3_:Array = [];
         var _loc4_:* = a.iterator();
         while(_loc4_.hasNext())
         {
            _loc5_ = _loc4_.next();
            _loc3_.push(_loc5_);
         }
         _loc4_ = b.iterator();
         while(_loc4_.hasNext())
         {
            _loc5_ = _loc4_.next();
            _loc3_.push(_loc5_);
         }
         return _loc3_;
      }
   }
}

