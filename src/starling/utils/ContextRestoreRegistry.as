package starling.utils
{
   import flash.display.Stage3D;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class ContextRestoreRegistry
   {
      
      private var _priority:int;
      
      private var _restore:Function;
      
      private var _lists:Dictionary;
      
      private var _numAdded:Number;
      
      public function ContextRestoreRegistry(priority:int, restore:Function)
      {
         super();
         _priority = priority;
         _restore = restore;
         _lists = new Dictionary(true);
         _numAdded = 0;
      }
      
      public function add(object:Object, stage3D:Stage3D) : Dictionary
      {
         var _loc3_:Dictionary = _lists[stage3D];
         if(_loc3_ == null)
         {
            _loc3_ = new Dictionary(true);
            _lists[stage3D] = _loc3_;
            stage3D.addEventListener("context3DCreate",onContextCreated,false,_priority);
         }
         _loc3_[object] = ++_numAdded;
         return _loc3_;
      }
      
      private function onContextCreated(event:Event) : void
      {
         var object:Object;
         var firstError:*;
         var list:Dictionary = _lists[event.currentTarget];
         var objects:Array = [];
         var failed:Boolean = false;
         for(object in list)
         {
            if(object)
            {
               objects[objects.length] = object;
            }
         }
         objects.sort(function(param1:Object, param2:Object):Number
         {
            return list[param1] - list[param2];
         });
         for each(object in objects)
         {
            if(object in list)
            {
               try
               {
                  _restore(object,event);
               }
               catch(e:*)
               {
                  if(!failed)
                  {
                     failed = true;
                     firstError = e;
                  }
               }
            }
         }
         if(failed)
         {
            throw firstError;
         }
      }
   }
}

