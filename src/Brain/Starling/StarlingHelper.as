package Brain.Starling
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.utils.getQualifiedClassName;
   
   public class StarlingHelper
   {
      
      public function StarlingHelper()
      {
         super();
      }
      
      public static function findNavCollisions(inSearchNode:DisplayObjectContainer) : Array
      {
         return findChildrenOfClass(inSearchNode,["NavCollisionCircle","NavCollisionRectangle"]);
      }
      
      public static function findCombatCollisions(searchNode:DisplayObjectContainer) : Array
      {
         return findChildrenOfClass(searchNode,["CombatCollisionCircle","CombatCollisionRectangle"]);
      }
      
      public static function findChildrenOfClass(inSearchNode:DisplayObjectContainer, classNames:Array) : Array
      {
         var _loc3_:Array = [];
         recursiveFindChildrenOfClass(_loc3_,inSearchNode,classNames);
         return _loc3_;
      }
      
      private static function recursiveFindChildrenOfClass(foundArray:Array, node:DisplayObject, classNames:Array) : void
      {
         var _loc5_:int = 0;
         var _loc6_:String = getQualifiedClassName(node);
         if(classNames.indexOf(_loc6_) != -1)
         {
            foundArray.push(node);
         }
         var _loc4_:DisplayObjectContainer = node as DisplayObjectContainer;
         if(_loc4_)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.numChildren)
            {
               recursiveFindChildrenOfClass(foundArray,_loc4_.getChildAt(_loc5_),classNames);
               _loc5_++;
            }
         }
      }
   }
}

