package Floor
{
   import Brain.GameObject.View;
   import Brain.Logger.Logger;
   import Dungeon.NavCollider;
   import Facade.DBFacade;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Vector3D;
   
   public class FloorView extends View
   {
      
      protected var mParentFloorObject:FloorObject;
      
      protected var mLayer:int = 0;
      
      protected var mDBFacade:DBFacade;
      
      public function FloorView(facade:DBFacade, floorObject:FloorObject)
      {
         mDBFacade = facade;
         super(facade);
         mParentFloorObject = floorObject;
      }
      
      public static function findNavCollisions(searchNode:DisplayObjectContainer) : Array
      {
         return findChildrenOfClass(searchNode,["NavCollisionCircle","NavCollisionRectangle"]);
      }
      
      public static function findCombatCollisions(searchNode:DisplayObjectContainer) : Array
      {
         return findChildrenOfClass(searchNode,["CombatCollisionCircle","CombatCollisionRectangle"]);
      }
      
      override public function set position(pos:Vector3D) : void
      {
         super.position = pos;
         for each(var _loc2_:NavCollider in mParentFloorObject.navCollisions)
         {
            _loc2_.position = pos;
         }
      }
      
      public function get worldCenter() : Vector3D
      {
         return mParentFloorObject.worldCenter;
      }
      
      public function addToStage() : void
      {
         if(this.layer == 0)
         {
            Logger.error("Tried to addToStage with layer == 0");
         }
         else
         {
            mSceneGraphComponent.addChild(this.root,this.layer);
            checkoutMovieClipRenderers();
         }
      }
      
      public function removeFromStage() : void
      {
         if(this.layer && mSceneGraphComponent.contains(this.root,this.layer))
         {
            mSceneGraphComponent.removeChild(this.root);
         }
         checkinMovieClipRenderers();
      }
      
      protected function checkoutMovieClipRenderers() : void
      {
      }
      
      protected function checkinMovieClipRenderers() : void
      {
      }
      
      public function set layer(value:int) : void
      {
         mLayer = value;
      }
      
      override public function destroy() : void
      {
         mParentFloorObject = null;
         mDBFacade = null;
         super.destroy();
      }
      
      public function get layer() : int
      {
         return mLayer;
      }
   }
}

