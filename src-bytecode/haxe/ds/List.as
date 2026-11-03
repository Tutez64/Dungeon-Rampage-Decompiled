package haxe.ds
{
   import flash.Boot;
   import haxe.ds._List.ListIterator;
   import haxe.ds._List.ListKeyValueIterator;
   import haxe.ds._List.ListNode;
   
   public class List
   {
      
      public var q:ListNode;
      
      public var length:int;
      
      public var h:ListNode;
      
      public function List()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         length = 0;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "";
         var _loc2_:Boolean = true;
         var _loc3_:ListNode = h;
         _loc1_ += "{";
         while(_loc3_ != null)
         {
            if(_loc2_)
            {
               _loc2_ = false;
            }
            else
            {
               _loc1_ += ", ";
            }
            _loc1_ += Std.string(Std.string(_loc3_.item));
            _loc3_ = _loc3_.next;
         }
         return _loc1_ + "}";
      }
      
      public function remove(v:Object) : Boolean
      {
         var _loc2_:ListNode = null;
         var _loc3_:ListNode = h;
         while(_loc3_ != null)
         {
            if(_loc3_.item == v)
            {
               if(_loc2_ == null)
               {
                  h = _loc3_.next;
               }
               else
               {
                  _loc2_.next = _loc3_.next;
               }
               if(q == _loc3_)
               {
                  q = _loc2_;
               }
               --length;
               return true;
            }
            _loc2_ = _loc3_;
            _loc3_ = _loc3_.next;
         }
         return false;
      }
      
      public function push(item:Object) : void
      {
         var _loc2_:ListNode = new ListNode(item,h);
         h = _loc2_;
         if(q == null)
         {
            q = _loc2_;
         }
         ++length;
      }
      
      public function pop() : Object
      {
         if(h == null)
         {
            return null;
         }
         var _loc1_:Object = h.item;
         h = h.next;
         if(h == null)
         {
            q = null;
         }
         --length;
         return _loc1_;
      }
      
      public function map(f:Function) : List
      {
         var _loc4_:* = null as Object;
         var _loc2_:List = new List();
         var _loc3_:ListNode = h;
         while(_loc3_ != null)
         {
            _loc4_ = _loc3_.item;
            _loc3_ = _loc3_.next;
            _loc2_.add(f(_loc4_));
         }
         return _loc2_;
      }
      
      public function last() : Object
      {
         if(q == null)
         {
            return null;
         }
         return q.item;
      }
      
      public function keyValueIterator() : ListKeyValueIterator
      {
         return new ListKeyValueIterator(h);
      }
      
      public function join(sep:String) : String
      {
         var _loc2_:String = "";
         var _loc3_:Boolean = true;
         var _loc4_:ListNode = h;
         while(_loc4_ != null)
         {
            if(_loc3_)
            {
               _loc3_ = false;
            }
            else
            {
               _loc2_ += Std.string(sep);
            }
            _loc2_ += Std.string(_loc4_.item);
            _loc4_ = _loc4_.next;
         }
         return _loc2_;
      }
      
      public function iterator() : ListIterator
      {
         return new ListIterator(h);
      }
      
      public function isEmpty() : Boolean
      {
         return h == null;
      }
      
      public function first() : Object
      {
         if(h == null)
         {
            return null;
         }
         return h.item;
      }
      
      public function filter(f:Function) : List
      {
         var _loc4_:* = null as Object;
         var _loc2_:List = new List();
         var _loc3_:ListNode = h;
         while(_loc3_ != null)
         {
            _loc4_ = _loc3_.item;
            _loc3_ = _loc3_.next;
            if(f(_loc4_))
            {
               _loc2_.add(_loc4_);
            }
         }
         return _loc2_;
      }
      
      public function clear() : void
      {
         h = null;
         q = null;
         length = 0;
      }
      
      public function add(item:Object) : void
      {
         var _loc2_:ListNode = null;
         var _loc3_:ListNode = new ListNode(item,_loc2_);
         if(h == null)
         {
            h = _loc3_;
         }
         else
         {
            q.next = _loc3_;
         }
         q = _loc3_;
         ++length;
      }
   }
}

