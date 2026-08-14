package Brain.Render
{
   import Brain.Clock.GameClock;
   import Brain.Utils.MemoryTracker;
   import flash.display.Sprite;
   import org.as3commons.collections.SortedMap;
   import org.as3commons.collections.framework.core.SortedMapIterator;
   
   public class LayerGroup extends Sprite
   {
      
      private var mTransformNode:Sprite;
      
      private var mLayers:SortedMap = new SortedMap(new LayerComparator());
      
      private var mNeedsSort:Boolean = false;
      
      public function LayerGroup()
      {
         super();
         mTransformNode = new Sprite();
         mTransformNode.name = "LayerGroup.transformNode";
         this.addChild(mTransformNode);
         MemoryTracker.track(this,"LayerGroup - created in LayerGroup()","brain");
      }
      
      public function get transformNode() : Sprite
      {
         return mTransformNode;
      }
      
      private function markDirty() : void
      {
         mNeedsSort = true;
      }
      
      public function getLayer(layerIndex:int) : Layer
      {
         return mLayers.itemFor(layerIndex);
      }
      
      public function addLayer(layer:Layer) : void
      {
         if(mLayers.has(layer))
         {
            throw new Error("Layer already in LayerGroup");
         }
         mLayers.add(layer.sortIndex,layer);
         mTransformNode.addChild(layer);
         this.markDirty();
      }
      
      public function removeLayer(layer:Layer) : Boolean
      {
         var _loc2_:Boolean = mLayers.remove(layer);
         mTransformNode.removeChild(layer);
         this.markDirty();
         return _loc2_;
      }
      
      private function sortLayers() : void
      {
         var _loc3_:Layer = null;
         var _loc1_:SortedMapIterator = mLayers.iterator() as SortedMapIterator;
         var _loc2_:int = 0;
         while(_loc1_.hasNext())
         {
            _loc3_ = _loc1_.next();
            if(mTransformNode.getChildAt(_loc2_) != _loc3_)
            {
               mTransformNode.setChildIndex(_loc3_,_loc2_);
            }
            _loc2_++;
         }
         mNeedsSort = false;
      }
      
      public function onFrame(gameClock:GameClock) : void
      {
         var _loc3_:Layer = null;
         if(this.stage == null)
         {
            return;
         }
         if(mNeedsSort)
         {
            sortLayers();
         }
         var _loc2_:SortedMapIterator = mLayers.iterator() as SortedMapIterator;
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next();
            _loc3_.render();
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:Layer = null;
         var _loc1_:SortedMapIterator = mLayers.iterator() as SortedMapIterator;
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            _loc2_.destroy();
         }
         mLayers.clear();
         mLayers = null;
         if(mTransformNode.parent)
         {
            mTransformNode.parent.removeChild(mTransformNode);
         }
      }
   }
}

import org.as3commons.collections.framework.IComparator;

class LayerComparator implements IComparator
{
   
   public function LayerComparator()
   {
      super();
   }
   
   public function compare(layer1:*, layer2:*) : int
   {
      if(layer1.sortIndex < layer2.sortIndex)
      {
         return -1;
      }
      if(layer1.sortIndex > layer2.sortIndex)
      {
         return 1;
      }
      return 0;
   }
}
