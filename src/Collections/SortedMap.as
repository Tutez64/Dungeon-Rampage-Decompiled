package Collections
{
   import collections.StringKeyStore;
   import flash.Boot;
   import flash.utils.Dictionary;
   
   public class SortedMap
   {
      
      public var _stringMap:StringKeyStore;
      
      public var _nodes:Array;
      
      public var _items:Dictionary;
      
      public var _comparator:IComparator;
      
      public function SortedMap(comparator:IComparator = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _comparator = comparator;
         _nodes = [];
         _items = new Dictionary();
         _stringMap = new StringKeyStore();
      }
      
      public function removeNodeAt(index:int) : void
      {
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc2_:SortedMapNode = _nodes[index];
         _nodes.splice(index,1);
         var _loc3_:* = _loc2_.key;
         if(_loc3_ is String)
         {
            _stringMap.remove(_loc2_.key);
         }
         else
         {
            _loc4_ = _items;
            _loc5_ = _loc2_.key;
            delete _loc4_[_loc5_];
         }
      }
      
      public function removeKey(key:*) : *
      {
         var _loc2_:* = nodeFor(key);
         if(typeof _loc2_ == "undefined")
         {
            return undefined;
         }
         removeNodeAt(_nodes.indexOf(_loc2_));
         return _loc2_.item;
      }
      
      public function remove(item:*) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:* = null;
         var _loc2_:int = 0;
         var _loc3_:int = int(_nodes.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc2_++;
            _loc5_ = _nodes[_loc4_].item;
            if(typeof _loc5_ == typeof item && _loc5_ == item)
            {
               removeNodeAt(_loc4_);
               return true;
            }
         }
         return false;
      }
      
      public function nodeFor(key:*) : *
      {
         if(key is String)
         {
            if(_stringMap.hasKey(key))
            {
               return _stringMap.get(key);
            }
            return undefined;
         }
         var _loc2_:* = _items;
         if(key in _loc2_)
         {
            return _items[key];
         }
         return undefined;
      }
      
      public function nodeAt(index:int) : SortedMapNode
      {
         if(index >= 0 && index < int(_nodes.length))
         {
            return _nodes[index];
         }
         return null;
      }
      
      public function iterator(cursor:* = undefined) : IIterator
      {
         return new SortedMapIterator(this);
      }
      
      public function itemFor(key:*) : *
      {
         var _loc2_:* = nodeFor(key);
         if(typeof _loc2_ == "undefined")
         {
            return undefined;
         }
         return _loc2_.item;
      }
      
      public function indexOfNode(node:SortedMapNode, hint:int) : int
      {
         if(hint >= 0 && hint < int(_nodes.length) && _nodes[hint] == node)
         {
            return hint;
         }
         return _nodes.indexOf(node);
      }
      
      public function has(item:*) : Boolean
      {
         var _loc4_:* = null as SortedMapNode;
         var _loc5_:* = null;
         var _loc2_:int = 0;
         var _loc3_:Array = _nodes;
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            _loc5_ = _loc4_.item;
            if(typeof _loc5_ == typeof item && _loc5_ == item)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get_size() : uint
      {
         return int(_nodes.length);
      }
      
      public function get size() : uint
      {
         return get_size();
      }
      
      public function clear() : Boolean
      {
         if(int(_nodes.length) == 0)
         {
            return false;
         }
         _nodes = [];
         _items = new Dictionary();
         _stringMap.clear();
         return true;
      }
      
      public function add(key:*, item:*) : Boolean
      {
         var _loc6_:int = 0;
         var _loc3_:* = nodeFor(key);
         if(typeof _loc3_ != "undefined")
         {
            return false;
         }
         var _loc4_:* = 0;
         var _loc5_:int = int(_nodes.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_ + _loc5_ >> 1;
            if(_comparator.compare(item,_nodes[_loc6_].item) == -1)
            {
               _loc5_ = _loc6_;
            }
            else
            {
               _loc4_ = _loc6_ + 1;
            }
         }
         var _loc7_:SortedMapNode = new SortedMapNode(key,item);
         _nodes.insert(_loc4_,_loc7_);
         if(key is String)
         {
            _stringMap.set(key,_loc7_);
         }
         else
         {
            _items[key] = _loc7_;
         }
         return true;
      }
   }
}

