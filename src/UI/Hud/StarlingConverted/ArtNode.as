package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedPages;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class ArtNode
   {
      
      public static const CONTAINER:String = "container";
      
      public static const STATIC:String = "static";
      
      public static const TEXT:String = "text";
      
      public static const STATES:String = "states";
      
      public static const TIMELINE:String = "timeline";
      
      public static const FLIPBOOK:String = "flipbook";
      
      private static var sEvictCells:Dictionary = new Dictionary();
      
      private static var sEvictNodes:Dictionary = new Dictionary();
      
      public var name:String;
      
      public var kind:String = "container";
      
      public var key:String;
      
      public var matrix:Matrix = new Matrix();
      
      public var alpha:Number = 1;
      
      public var visible:Boolean = true;
      
      public var blendMode:String = "normal";
      
      public var colorTransform:ColorTransform = new ColorTransform();
      
      public var children:Vector.<ArtNode> = new Vector.<ArtNode>(0);
      
      public var cell:BakedCell;
      
      internal var hitCell:BakedCell;
      
      public var frames:Vector.<ArtFrame> = new Vector.<ArtFrame>(0);
      
      public var labels:Object = {};
      
      public var totalFrames:int = 1;
      
      public var authoredFrames:int = 1;
      
      public var loopFrame:int = -1;
      
      public var labelLoop:int = 0;
      
      public var stageRate:Boolean = false;
      
      public var wantsSilhouette:Boolean = false;
      
      public var masked:Boolean = false;
      
      internal var parentClip:Rectangle;
      
      internal var filterStates:Vector.<Array> = new Vector.<Array>(0);
      
      public var barFill:Boolean = false;
      
      public var registrationWidth:Number = 0;
      
      public var model:TextField;
      
      internal var textBounds:Rectangle;
      
      internal var textFontKeys:Vector.<String>;
      
      internal var grayFontKeys:Vector.<String>;
      
      internal var textFontSize:Number = NaN;
      
      public var textPages:BakedPages;
      
      public var pixelScale:Number = 1;
      
      public var initialText:String;
      
      public var alignment:String = "left";
      
      public var failures:int = 0;
      
      internal var maximalBounds:Rectangle;
      
      private var mCells:Vector.<BakedCell> = new Vector.<BakedCell>(0);
      
      private var mOwners:Vector.<BakedPages> = new Vector.<BakedPages>(0);
      
      private var mReleased:Boolean = false;
      
      internal var lease:Object;
      
      internal var mCachePrevious:ArtNode;
      
      internal var mCacheNext:ArtNode;
      
      internal var mCacheKey:String;
      
      internal var mCacheArt:Object;
      
      internal var mCachePages:BakedPages;
      
      internal var mPinned:Boolean = false;
      
      private var mViews:int = 0;
      
      internal var sweep:StarlingSweepArt;
      
      public function ArtNode()
      {
         super();
      }
      
      internal function retainView() : void
      {
         mViews = mViews + 1;
         pinCells(1);
         if(lease != null)
         {
            lease.views++;
         }
      }
      
      internal function releaseView() : void
      {
         mViews = mViews - 1;
         pinCells(-1);
         if(lease == null)
         {
            return;
         }
         lease.views--;
         if(lease.retired && lease.views == 0)
         {
            lease.release(lease);
         }
      }
      
      private function pinCells(delta:int) : void
      {
         var _loc2_:BakedCell = null;
         var _loc3_:ArtNode = null;
         for each(_loc2_ in mCells)
         {
            if(_loc2_ is HudCell)
            {
               HudCell(_loc2_).mLiveViews = HudCell(_loc2_).mLiveViews + delta;
            }
         }
         for each(_loc3_ in children)
         {
            _loc3_.pinCells(delta);
         }
      }
      
      internal function canEvict() : Boolean
      {
         var _loc1_:Object = null;
         try
         {
            if(!countCachedCells(sEvictCells,sEvictNodes))
            {
               return false;
            }
            var _loc6_:int = 0;
            var _loc5_:Dictionary = sEvictCells;
            while(true)
            {
               for(_loc1_ in _loc5_)
               {
                  if(BakedCell(_loc1_).refCount > int(sEvictCells[_loc1_]))
                  {
                     return false;
                  }
               }
               return true;
            }
         }
         finally
         {
            for(_loc1_ in sEvictCells)
            {
               delete sEvictCells[_loc1_];
            }
            for(_loc1_ in sEvictNodes)
            {
               delete sEvictNodes[_loc1_];
            }
         }
         return false;
      }
      
      internal function pinStartupTree() : void
      {
         var _loc1_:BakedCell = null;
         var _loc2_:ArtNode = null;
         mPinned = true;
         for each(_loc1_ in mCells)
         {
            if(_loc1_ is HudCell)
            {
               HudCell(_loc1_).mPinned = true;
            }
         }
         for each(_loc2_ in children)
         {
            _loc2_.pinStartupTree();
         }
      }
      
      private function countCachedCells(cells:Dictionary, seen:Dictionary) : Boolean
      {
         var _loc3_:BakedCell = null;
         var _loc4_:ArtNode = null;
         if(seen[this])
         {
            return true;
         }
         seen[this] = true;
         if(mPinned || mViews > 0)
         {
            return false;
         }
         for each(_loc3_ in mCells)
         {
            if(_loc3_ is HudCell && (HudCell(_loc3_).mPinned || HudCell(_loc3_).mLiveViews > 0 || HudCell(_loc3_).mSource != null && HudCell(_loc3_).mSource.mLiveViews > 0))
            {
               return false;
            }
            cells[_loc3_] = int(cells[_loc3_]) + 1;
         }
         for each(_loc4_ in children)
         {
            if(!_loc4_.countCachedCells(cells,seen))
            {
               return false;
            }
         }
         return true;
      }
      
      public function find(path:String) : ArtNode
      {
         var _loc2_:ArtNode = null;
         var _loc6_:int = 0;
         if(path == null || path.length == 0 || path == name)
         {
            return this;
         }
         var _loc4_:Array = path.split(".");
         var _loc3_:* = this;
         var _loc5_:int = _loc4_[0] == name ? 1 : 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc2_ = null;
            _loc6_ = 0;
            while(_loc6_ < _loc3_.children.length)
            {
               if(_loc3_.children[_loc6_].name == _loc4_[_loc5_])
               {
                  _loc2_ = _loc3_.children[_loc6_];
                  break;
               }
               _loc6_++;
            }
            if(_loc2_ == null)
            {
               return null;
            }
            _loc3_ = _loc2_;
            _loc5_++;
         }
         return _loc3_;
      }
      
      internal function hold(value:BakedCell, owner:BakedPages = null) : BakedCell
      {
         if(value != null)
         {
            mCells.push(value);
            mOwners.push(owner);
         }
         return value;
      }
      
      public function release(pages:BakedPages) : void
      {
         releaseTree(pages,new Dictionary());
      }
      
      private function releaseTree(pages:BakedPages, visited:Dictionary) : void
      {
         var _loc5_:ArtNode = null;
         var _loc3_:BakedCell = null;
         var _loc4_:int = 0;
         if(mReleased || visited[this])
         {
            return;
         }
         visited[this] = true;
         mReleased = true;
         HudArt.removeCached(this);
         mCacheArt = null;
         mCachePages = null;
         _loc4_ = 0;
         while(_loc4_ < mCells.length)
         {
            _loc3_ = mCells[_loc4_];
            (mOwners[_loc4_] ?? pages).release(_loc3_);
            if(!_loc3_.alive)
            {
               HudArtConverter.forgetPixels(_loc3_);
            }
            _loc4_++;
         }
         mCells.length = 0;
         mOwners.length = 0;
         for each(_loc5_ in children)
         {
            _loc5_.releaseTree(pages,visited);
         }
      }
   }
}

