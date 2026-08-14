package Brain.WorkLoop
{
   import Brain.Utils.MemoryTracker;
   import flash.utils.Dictionary;
   
   public class SimplePriorityQueue
   {
      
      private var _heap:Array;
      
      private var _size:int;
      
      private var _count:int;
      
      private var _posLookup:Dictionary;
      
      public function SimplePriorityQueue(size:int)
      {
         super();
         _heap = new Array(_size = size + 1);
         _posLookup = new Dictionary(true);
         _count = 0;
         MemoryTracker.track(_heap,"Array - heap storage size=" + size + " in SimplePriorityQueue()","brain");
         MemoryTracker.track(_posLookup,"Dictionary - position lookup in SimplePriorityQueue()","brain");
      }
      
      public function get front() : IPrioritizable
      {
         return _heap[1];
      }
      
      public function get maxSize() : int
      {
         return _size;
      }
      
      public function enqueue(obj:IPrioritizable) : Boolean
      {
         if(_count + 1 < _size)
         {
            _count = _count + 1;
            _heap[_count] = obj;
            _posLookup[obj] = _count;
            walkUp(_count);
            return true;
         }
         return false;
      }
      
      public function dequeue() : IPrioritizable
      {
         var _loc1_:* = undefined;
         if(_count >= 1)
         {
            _loc1_ = _heap[1];
            delete _posLookup[_loc1_];
            _heap[1] = _heap[_count];
            walkDown(1);
            delete _heap[_count];
            _count = _count - 1;
            return _loc1_;
         }
         return null;
      }
      
      public function reprioritize(obj:IPrioritizable, newPriority:int) : Boolean
      {
         if(!_posLookup[obj])
         {
            return false;
         }
         var _loc4_:int = obj.priority;
         obj.priority = newPriority;
         var _loc3_:int = int(_posLookup[obj]);
         newPriority > _loc4_ ? walkUp(_loc3_) : walkDown(_loc3_);
         return true;
      }
      
      public function remove(obj:IPrioritizable) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:* = undefined;
         if(_count >= 1)
         {
            _loc2_ = int(_posLookup[obj]);
            _loc3_ = _heap[_loc2_];
            delete _posLookup[_loc3_];
            _heap[_loc2_] = _heap[_count];
            walkDown(_loc2_);
            delete _heap[_count];
            delete _posLookup[_count];
            _count = _count - 1;
            return true;
         }
         return false;
      }
      
      public function contains(obj:*) : Boolean
      {
         var _loc2_:int = 0;
         _loc2_ = 1;
         while(_loc2_ <= _count)
         {
            if(_heap[_loc2_] === obj)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function clear() : void
      {
         _heap = new Array(_size);
         _posLookup = new Dictionary(true);
         _count = 0;
      }
      
      public function get size() : int
      {
         return _count;
      }
      
      public function isEmpty() : Boolean
      {
         return _count == 0;
      }
      
      public function toArray() : Array
      {
         return _heap.slice(1,_count + 1);
      }
      
      public function toString() : String
      {
         return "[SimplePriorityQueue, size=" + _size + "]";
      }
      
      public function dump() : String
      {
         var _loc2_:int = 0;
         if(_count == 0)
         {
            return "SimplePriorityQueue (empty)";
         }
         var _loc1_:String = "SimplePriorityQueue\n{\n";
         var _loc3_:int = _count + 1;
         _loc2_ = 1;
         while(_loc2_ < _loc3_)
         {
            _loc1_ += "\t" + _heap[_loc2_] + "\n";
            _loc2_++;
         }
         return _loc1_ + "\n}";
      }
      
      private function walkUp(index:int) : void
      {
         var _loc5_:IPrioritizable = null;
         var _loc3_:int = index >> 1;
         var _loc4_:IPrioritizable = _heap[index];
         var _loc2_:int = _loc4_.priority;
         while(_loc3_ > 0)
         {
            _loc5_ = _heap[_loc3_];
            if(_loc2_ - _loc5_.priority <= 0)
            {
               break;
            }
            _heap[index] = _loc5_;
            _posLookup[_loc5_] = index;
            index = _loc3_;
            _loc3_ >>= 1;
         }
         _heap[index] = _loc4_;
         _posLookup[_loc4_] = index;
      }
      
      private function walkDown(index:int) : void
      {
         var _loc3_:IPrioritizable = null;
         var _loc5_:int = index << 1;
         var _loc4_:IPrioritizable = _heap[index];
         var _loc2_:int = _loc4_.priority;
         while(_loc5_ < _count)
         {
            if(_loc5_ < _count - 1)
            {
               if(_heap[_loc5_].priority - _heap[int(_loc5_ + 1)].priority < 0)
               {
                  _loc5_++;
               }
            }
            _loc3_ = _heap[_loc5_];
            if(_loc2_ - _loc3_.priority >= 0)
            {
               break;
            }
            _heap[index] = _loc3_;
            _posLookup[_loc3_] = index;
            _posLookup[_loc4_] = _loc5_;
            index = _loc5_;
            _loc5_ <<= 1;
         }
         _heap[index] = _loc4_;
         _posLookup[_loc4_] = index;
      }
   }
}

