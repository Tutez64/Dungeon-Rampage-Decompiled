package Brain.SceneGraph
{
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Render.Layer;
   import Brain.Render.LayerGroup;
   import Brain.Render.SortOnAddLayer;
   import Brain.Render.SortedLayer;
   import Brain.Utils.MemoryTracker;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class SceneGraphManager
   {
      
      public static var BOTTOM_HEIGHT:Number = 160;
      
      public static const GROUND:int = 5;
      
      public static const BACKGROUND:int = 10;
      
      public static const SORTED:int = 20;
      
      public static const FOREGROUND:int = 30;
      
      public static const COLLISION:int = 40;
      
      public static const GAMEFADE:int = 42;
      
      public static const OVERFADE:int = 46;
      
      public static const UI:int = 50;
      
      public static const UITopCenterBackGround:int = 51;
      
      public static const UI1:int = 53;
      
      public static const UI2:int = 52;
      
      public static const UI3:int = 54;
      
      public static const UI4:int = 55;
      
      public static const UI5:int = 56;
      
      public static const UI6:int = 57;
      
      public static const UI7:int = 59;
      
      public static const UI8:int = 58;
      
      public static const UI9:int = 60;
      
      public static const UI10:int = 63;
      
      public static const UI11:int = 61;
      
      public static const UI12:int = 62;
      
      public static const GROUNDDRAGDROP:int = 70;
      
      public static const DRAGANDDROP:int = 75;
      
      public static const FADE:int = 100;
      
      public static const UIPopUpCurtainLayer:int = 104;
      
      public static const POPUP:int = 105;
      
      public static const UICenterPopup:int = 106;
      
      public static const TOOLTIP:int = 107;
      
      public static const UI7T:int = 162;
      
      public static const UI9T:int = 163;
      
      public static const CURSOR:int = 200;
      
      protected var mFacade:Facade;
      
      protected var mWorldLayerGroup:LayerGroup;
      
      protected var mUILayerGroup:LayerGroup;
      
      protected var mUILayerGroupT:LayerGroup;
      
      protected var mGroundLayer:Layer;
      
      protected var mGroundDragDropLayerd:Layer;
      
      protected var mBackgroundLayer:Layer;
      
      protected var mSortedLayer:SortedLayer;
      
      protected var mForegroundLayer:Layer;
      
      protected var mCollisionLayer:Layer;
      
      protected var mGameFadeLayer:Layer;
      
      protected var mOverFadeLayer:Layer;
      
      protected var mUILayer:Layer;
      
      protected var mUILayerT:Layer;
      
      protected var mUITopCenterBackGround:Layer;
      
      protected var mUI1:Layer;
      
      protected var mUI2:Layer;
      
      protected var mUI3:Layer;
      
      protected var mUI4:Layer;
      
      protected var mUI5:Layer;
      
      protected var mUI6:Layer;
      
      protected var mUI7:Layer;
      
      protected var mUI8:Layer;
      
      protected var mUI9:Layer;
      
      protected var mUI10:Layer;
      
      protected var mUI11:Layer;
      
      protected var mUI12:Layer;
      
      protected var mUICenterPopup:Layer;
      
      protected var mUI7T:Layer;
      
      protected var mUI9T:Layer;
      
      protected var mDragAndDropLayer:Layer;
      
      protected var mTooltipLayer:Layer;
      
      protected var mUIPopUpCurtainLayer:Layer;
      
      protected var mPopupLayer:Layer;
      
      protected var mFadeLayer:Layer;
      
      public var mCursorLayer:Layer;
      
      protected var mLayers:Map = new Map();
      
      private var mCurtainReferenceCount:uint = 0;
      
      private var mPopupCurtain:Sprite;
      
      public function SceneGraphManager(facade:Facade)
      {
         super();
         mFacade = facade;
         mWorldLayerGroup = new LayerGroup();
         mWorldLayerGroup.name = "SceneGraphManager.worldLayerGroup";
         mFacade.addRootDisplayObject(mWorldLayerGroup);
         mGroundLayer = this.createLayer(5,mWorldLayerGroup,"GroundLayer");
         mBackgroundLayer = this.createSortOnAddLayer(10,mWorldLayerGroup,"BackgroundLayer");
         mSortedLayer = this.createSortedLayer(20,mWorldLayerGroup,"SortedLayer");
         mForegroundLayer = this.createLayer(30,mWorldLayerGroup,"ForegroundLayer");
         mCollisionLayer = this.createLayer(40,mWorldLayerGroup,"CollisionLayer");
         mGameFadeLayer = this.createLayer(42,mWorldLayerGroup,"GameFadeLayer");
         mOverFadeLayer = this.createLayer(46,mWorldLayerGroup,"OverFadeLayer");
         mFacade.layerRenderWorkManager.doEveryFrame(mWorldLayerGroup.onFrame,"SceneGraphManager.WorldLayerGroup");
         mUILayerGroup = new LayerGroup();
         mUILayerGroup.name = "SceneGraphManager.UILayerGroup";
         mFacade.addRootDisplayObject(mUILayerGroup);
         mUILayerGroupT = new LayerGroup();
         mUILayerGroupT.name = "SceneGraphManager.UILayerGroupT";
         mFacade.addRootDisplayObject(mUILayerGroupT);
         mUILayer = this.createLayer(50,mUILayerGroup,"UILayer");
         mUITopCenterBackGround = this.createLayer(51,mUILayerGroup,"TopCenterBackGround");
         mUI1 = this.createLayer(53,mUILayerGroup,"UI1");
         mUI2 = this.createLayer(52,mUILayerGroup,"UI2");
         mUI3 = this.createLayer(54,mUILayerGroup,"UI3");
         mUI4 = this.createLayer(55,mUILayerGroup,"UI4");
         mUI5 = this.createLayer(56,mUILayerGroup,"UI5");
         mUI6 = this.createLayer(57,mUILayerGroup,"UI6");
         mUI7 = this.createLayer(59,mUILayerGroup,"UI7");
         mUI8 = this.createLayer(58,mUILayerGroup,"UI8");
         mUI9 = this.createLayer(60,mUILayerGroup,"UI9");
         mUI10 = this.createLayer(63,mUILayerGroup,"UI10");
         mUI11 = this.createLayer(61,mUILayerGroup,"UI11");
         mUI12 = this.createLayer(62,mUILayerGroup,"UI12");
         mUIPopUpCurtainLayer = this.createLayer(104,mUILayerGroup,"UIPopUpCurtainLayer");
         mUICenterPopup = this.createLayer(106,mUILayerGroup,"UICenterPopup");
         mGroundDragDropLayerd = this.createLayer(70,mWorldLayerGroup,"GroundLayer2");
         mDragAndDropLayer = this.createLayer(75,mUILayerGroup,"DragAndDropLayer");
         mTooltipLayer = this.createLayer(107,mUILayerGroup,"TooltipLayer");
         mPopupLayer = this.createLayer(105,mUILayerGroup,"PopupLayer");
         mFadeLayer = this.createLayer(100,mUILayerGroup,"FadeLayer");
         mUI7T = this.createLayer(162,mUILayerGroupT,"UI7T");
         mUI9T = this.createLayer(163,mUILayerGroupT,"UI9T");
         mCursorLayer = this.createLayer(200,mUILayerGroup,"CursorLayer");
         mFacade.layerRenderWorkManager.doEveryFrame(mUILayerGroup.onFrame,"SceneGraphManager.UILayerGroup");
         mPopupCurtain = new Sprite();
         mPopupCurtain.alpha = 0.5;
         mPopupCurtain.x = 0;
         mPopupCurtain.y = 0;
         mPopupCurtain.graphics.clear();
         mPopupCurtain.graphics.beginFill(0);
         mPopupCurtain.graphics.drawRect(0,0,mFacade.viewWidth,mFacade.viewHeight);
         mPopupCurtain.graphics.endFill();
         mPopupCurtain.mouseEnabled = mFacade.popupCurtainBlockMouse;
         mFacade.stageRef.addEventListener("resize",onResize);
         onResize();
         MemoryTracker.track(this,"SceneGraphManager - created in SceneGraphManager()","brain");
      }
      
      public static function setBottomHeight(value:Number) : void
      {
         BOTTOM_HEIGHT = value;
      }
      
      public static function getLayerFromName(layerName:String) : int
      {
         var _loc2_:int = 20;
         switch(layerName)
         {
            case "ground":
               _loc2_ = 5;
               break;
            case "background":
               _loc2_ = 10;
               break;
            case "sorted":
               _loc2_ = 20;
               break;
            case "foreground":
               _loc2_ = 30;
               break;
            case "ui":
               _loc2_ = 50;
               break;
            case "overfade":
               _loc2_ = 46;
               break;
            default:
               Logger.error("Unknown prop layer: " + layerName + " defaulting to SORTED.");
               _loc2_ = 20;
         }
         return _loc2_;
      }
      
      public static function getGrayScaleSaturationFilter(amount:Number) : ColorMatrixFilter
      {
         amount /= 100;
         var _loc6_:ColorMatrixFilter = new ColorMatrixFilter();
         var _loc2_:Array = [1,0,0,0,0];
         var _loc3_:Array = [0,1,0,0,0];
         var _loc8_:Array = [0,0,1,0,0];
         var _loc4_:Array = [0,0,0,1,0];
         var _loc5_:Array = [0.3,0.59,0.11,0,0];
         var _loc7_:Array = [];
         _loc7_ = _loc7_.concat(interpolateArrays(_loc5_,_loc2_,amount));
         _loc7_ = _loc7_.concat(interpolateArrays(_loc5_,_loc3_,amount));
         _loc7_ = _loc7_.concat(interpolateArrays(_loc5_,_loc8_,amount));
         _loc7_ = _loc7_.concat(_loc4_);
         _loc6_.matrix = _loc7_;
         return _loc6_;
      }
      
      public static function setGrayScaleSaturation(object:DisplayObject, amount:Number) : void
      {
         if(amount >= 100)
         {
            object.filters = [];
         }
         else
         {
            object.filters = [getGrayScaleSaturationFilter(amount)];
         }
      }
      
      public static function interpolateArrays(ary1:Array, ary2:Array, t:Number) : Object
      {
         var _loc4_:Array = ary1.length >= ary2.length ? ary1.slice() : ary2.slice();
         var _loc5_:int = int(_loc4_.length);
         while(_loc5_--)
         {
            _loc4_[_loc5_] = ary1[_loc5_] + (ary2[_loc5_] - ary1[_loc5_]) * t;
         }
         return _loc4_;
      }
      
      public static function debugPrintNode(node:DisplayObject, level:int = 0) : void
      {
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:String = "";
         _loc4_ = 0;
         while(_loc4_ < level)
         {
            _loc3_ += " ";
            _loc4_++;
         }
         _loc3_ += node.toString() + " " + node.name;
         var _loc5_:DisplayObjectContainer = node as DisplayObjectContainer;
         if(_loc5_)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_.numChildren)
            {
               debugPrintNode(_loc5_.getChildAt(_loc6_),level + 1);
               _loc6_++;
            }
         }
      }
      
      public function ui1_9visible(val:Boolean) : void
      {
         mUI1.visible = val;
         mUI2.visible = val;
         mUI3.visible = val;
         mUI4.visible = val;
         mUI5.visible = val;
         mUI6.visible = val;
         mUI7.visible = val;
         mUI8.visible = val;
         mUI9.visible = val;
      }
      
      public function cleanBackgroundLayer() : void
      {
         while(mBackgroundLayer.numChildren > 0)
         {
            mBackgroundLayer.removeChildAt(0);
         }
      }
      
      public function get worldLayerGroup() : LayerGroup
      {
         return mWorldLayerGroup;
      }
      
      public function get UILayerGroup() : LayerGroup
      {
         return mUILayerGroup;
      }
      
      public function setUIScale(value:Number) : void
      {
         mUITopCenterBackGround.scaleX = value;
         mUITopCenterBackGround.scaleY = value;
         mUI1.scaleX = value;
         mUI1.scaleY = value;
         mUI2.scaleX = value;
         mUI2.scaleY = value;
         mUI3.scaleX = value;
         mUI3.scaleY = value;
         mUI4.scaleX = value;
         mUI4.scaleY = value;
         mUI5.scaleX = value;
         mUI5.scaleY = value;
         mUI6.scaleX = value;
         mUI6.scaleY = value;
         mUI7.scaleX = value;
         mUI7.scaleY = value;
         mUI7T.scaleX = value;
         mUI7T.scaleY = value;
         mUI8.scaleX = value;
         mUI8.scaleY = value;
         mUI9.scaleX = value;
         mUI9.scaleY = value;
         mUI9T.scaleX = value;
         mUI9T.scaleY = value;
         mUI10.scaleX = value;
         mUI10.scaleY = value;
         mUI11.scaleX = value;
         mUI11.scaleY = value;
         mUI12.scaleX = value;
         mUI12.scaleY = value;
         mUICenterPopup.scaleX = value;
         mUICenterPopup.scaleY = value;
      }
      
      public function showPopupCurtain() : void
      {
         mCurtainReferenceCount = mCurtainReferenceCount + 1;
         if(!mUIPopUpCurtainLayer.contains(mPopupCurtain))
         {
            mUIPopUpCurtainLayer.addChild(mPopupCurtain);
            if(mCurtainReferenceCount > 1)
            {
               Logger.error("Curtain reference count is greater than one but no curtain was up.");
            }
         }
      }
      
      public function removePopupCurtain() : void
      {
         if(mCurtainReferenceCount == 0)
         {
            Logger.error("Lower curtain called without a curtain being up.");
            return;
         }
         mCurtainReferenceCount = mCurtainReferenceCount - 1;
         if(mCurtainReferenceCount == 0)
         {
            if(mUIPopUpCurtainLayer.contains(mPopupCurtain))
            {
               mUIPopUpCurtainLayer.removeChild(mPopupCurtain);
            }
            else
            {
               Logger.error("Lower Curtain called, reference count dropped to 0, but no curtain was up.");
            }
         }
      }
      
      private function createLayer(sortIndex:uint, group:LayerGroup, name:String) : Layer
      {
         var _loc4_:Layer = new Layer(sortIndex);
         _loc4_.name = name;
         group.addLayer(_loc4_);
         mLayers.add(sortIndex,_loc4_);
         return _loc4_;
      }
      
      private function createSortedLayer(sortIndex:uint, group:LayerGroup, name:String) : SortedLayer
      {
         var _loc4_:SortedLayer = new SortedLayer(sortIndex);
         _loc4_.name = name;
         group.addLayer(_loc4_);
         mLayers.add(sortIndex,_loc4_);
         return _loc4_;
      }
      
      private function createSortOnAddLayer(sortIndex:uint, group:LayerGroup, name:String) : SortOnAddLayer
      {
         var _loc4_:SortOnAddLayer = new SortOnAddLayer(sortIndex);
         _loc4_.name = name;
         group.addLayer(_loc4_);
         mLayers.add(sortIndex,_loc4_);
         return _loc4_;
      }
      
      private function onResize(event:Event = null) : void
      {
         var _loc5_:Number = 160;
         var _loc3_:uint = Math.round(0);
         var _loc6_:uint = Math.round(mFacade.viewWidth * 0.5);
         var _loc8_:uint = Math.round(mFacade.viewWidth);
         var _loc2_:uint = Math.round(0);
         var _loc4_:uint = Math.round((mFacade.viewHeight - BOTTOM_HEIGHT) * 0.5);
         var _loc7_:uint = Math.round(mFacade.viewHeight - BOTTOM_HEIGHT);
         var _loc9_:uint = Math.round(mFacade.viewHeight);
         mUITopCenterBackGround.x = _loc6_;
         mUITopCenterBackGround.y = _loc2_;
         mUI1.x = _loc3_;
         mUI1.y = _loc2_;
         mUI2.x = _loc6_;
         mUI2.y = _loc2_;
         mUI3.x = _loc8_;
         mUI3.y = _loc2_;
         mUI4.x = _loc3_;
         mUI4.y = _loc4_;
         mUI5.x = _loc6_;
         mUI5.y = _loc4_;
         mUI6.x = _loc8_;
         mUI6.y = _loc4_;
         mUI7.x = _loc3_;
         mUI7.y = _loc7_;
         mUI7T.x = _loc3_;
         mUI7T.y = _loc7_;
         mUI8.x = _loc6_;
         mUI8.y = _loc7_;
         mUI9.x = _loc8_;
         mUI9.y = _loc7_;
         mUI9T.x = _loc8_;
         mUI9T.y = _loc7_;
         mUI10.x = _loc3_;
         mUI10.y = _loc9_;
         mUI11.x = _loc6_;
         mUI11.y = _loc9_;
         mUI12.x = _loc8_;
         mUI12.y = _loc9_;
         mUICenterPopup.x = _loc6_;
         mUICenterPopup.y = _loc4_;
         mPopupCurtain.graphics.clear();
         mPopupCurtain.graphics.beginFill(0);
         mPopupCurtain.graphics.drawRect(0,0,mFacade.viewWidth,mFacade.viewHeight);
         mPopupCurtain.graphics.endFill();
      }
      
      public function getLayer(layerIndex:int) : Layer
      {
         return mLayers.itemFor(layerIndex);
      }
      
      public function get worldTransformNode() : Sprite
      {
         return mWorldLayerGroup.transformNode;
      }
      
      public function contains(child:DisplayObject, layerIndex:int) : Boolean
      {
         var _loc3_:Layer = mLayers.itemFor(layerIndex);
         if(_loc3_)
         {
            return _loc3_.contains(child);
         }
         Logger.error("contains: layerIndex not found: " + layerIndex.toString());
         return false;
      }
      
      public function addChild(child:DisplayObject, layerIndex:int) : DisplayObject
      {
         var _loc3_:Layer = mLayers.itemFor(layerIndex);
         if(_loc3_)
         {
            return _loc3_.addChild(child);
         }
         Logger.error("layerIndex not found");
         return child;
      }
      
      public function addChildAt(child:DisplayObject, layerIndex:int, childIndex:int) : DisplayObject
      {
         var _loc4_:Layer = mLayers.itemFor(layerIndex);
         if(_loc4_)
         {
            return _loc4_.addChildAt(child,childIndex);
         }
         Logger.error("layerIndex not found");
         return child;
      }
      
      public function removeChild(child:DisplayObject) : DisplayObject
      {
         if(child && child.parent)
         {
            return child.parent.removeChild(child);
         }
         return child;
      }
      
      public function saturateLayers(value:Number, listOfLayersToBeAvoided:Array) : void
      {
         var _loc3_:Array = mLayers.keysToArray();
         for each(var _loc4_:int in _loc3_)
         {
            if(listOfLayersToBeAvoided.indexOf(_loc4_) == -1)
            {
               setGrayScaleSaturation(mLayers.itemFor(_loc4_),value);
            }
         }
      }
      
      public function debugPrint() : void
      {
         var _loc4_:Layer = null;
         var _loc5_:DisplayObject = null;
         var _loc1_:* = 0;
         var _loc3_:* = 0;
         var _loc2_:IMapIterator = mLayers.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc4_ = _loc2_.next();
            Logger.debug("Layer: " + _loc4_.name + " children: " + _loc4_.numChildren.toString());
            _loc3_ = 0;
            while(_loc3_ < _loc4_.numChildren)
            {
               _loc5_ = _loc4_.getChildAt(_loc3_);
               _loc1_ = uint(_loc5_ is DisplayObjectContainer ? DisplayObjectContainer(_loc5_).numChildren : 0);
               Logger.debug("    child " + _loc3_.toString() + ": " + _loc5_.toString() + " name: " + _loc5_.name + " children: " + _loc1_);
               _loc3_++;
            }
         }
      }
      
      public function destroy() : void
      {
         mFacade = null;
         mWorldLayerGroup.destroy();
         mUILayerGroup.destroy();
         mGroundDragDropLayerd = null;
         mGroundLayer = null;
         mBackgroundLayer = null;
         mSortedLayer = null;
         mForegroundLayer = null;
         mGameFadeLayer = null;
         mOverFadeLayer = null;
         mUILayer = null;
         mUITopCenterBackGround = null;
         mUI1 = null;
         mUI2 = null;
         mUI3 = null;
         mUI4 = null;
         mUI5 = null;
         mUI6 = null;
         mUI7 = null;
         mUI7T = null;
         mUI8 = null;
         mUI9 = null;
         mUI9T = null;
         mUI10 = null;
         mUI11 = null;
         mUI12 = null;
         mUICenterPopup = null;
         mDragAndDropLayer = null;
         mTooltipLayer = null;
         mPopupLayer = null;
         mFadeLayer = null;
         mCursorLayer = null;
         mLayers.clear();
         mLayers = null;
      }
   }
}

