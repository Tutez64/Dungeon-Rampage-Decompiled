package UI.Hud.StarlingConverted
{
   import flash.utils.Dictionary;
   import starling.display.DisplayObject;
   
   public class ArtView
   {
      
      private var mArt:ArtNode;
      
      private var mRoot:ArtDisplay;
      
      private var mObjects:Dictionary = new Dictionary();
      
      public function ArtView(art:ArtNode, ticker:HudTicker = null)
      {
         super();
         mArt = art;
         mArt.retainView();
         try
         {
            mRoot = buildDisplay(art,ticker,mObjects);
            mRoot.prepareTextFilters();
         }
         catch(error:Error)
         {
            try
            {
               if(mRoot != null)
               {
                  mRoot.dispose();
               }
            }
            finally
            {
               mRoot = null;
               mArt.releaseView();
            }
            throw error;
         }
      }
      
      public static function build(art:ArtNode, ticker:HudTicker = null) : ArtView
      {
         return new ArtView(art,ticker);
      }
      
      internal static function buildDisplay(art:ArtNode, ticker:HudTicker, objects:Dictionary) : ArtDisplay
      {
         var _loc5_:ArtDisplay = null;
         var _loc6_:ArtNode = null;
         var _loc4_:ArtDisplay = null;
         if(art.kind == "text")
         {
            _loc5_ = new StarlingText(art,art.textPages,art.pixelScale,art.name == "NametagText" || art.name == "AlertText" ? "baked" : "auto",ticker);
         }
         else if(art.kind == "timeline" || art.kind == "flipbook")
         {
            _loc5_ = new TimelineView(art,ticker);
         }
         else if(art.kind == "states")
         {
            _loc5_ = new StatesView(art);
         }
         else
         {
            _loc5_ = new ArtDisplay(art);
         }
         try
         {
            objects[art] = _loc5_;
            if(art.kind == "static" || art.kind == "flipbook" || art.kind == "states" && art.children.length == 0)
            {
               _loc5_.buildImages();
            }
            for each(_loc6_ in art.children)
            {
               _loc4_ = buildDisplay(_loc6_,ticker,objects);
               _loc5_.addArt(_loc4_);
               if(_loc6_.parentClip != null)
               {
                  _loc4_.prepareClip();
               }
            }
            if(_loc5_ is StatesView)
            {
               StatesView(_loc5_).gotoAndStop(0);
            }
            if(_loc5_ is TimelineView && art.stageRate)
            {
               TimelineView(_loc5_).play(0,true);
            }
            _loc5_.refresh();
            return _loc5_;
         }
         catch(buildError:Error)
         {
            _loc5_.dispose();
            throw buildError;
         }
      }
      
      public function get root() : DisplayObject
      {
         return mRoot;
      }
      
      public function node(path:String) : DisplayObject
      {
         return mObjects[mArt.find(path)] as DisplayObject;
      }
      
      public function artNode(path:String) : ArtNode
      {
         return mArt.find(path);
      }
      
      public function dispose() : void
      {
         if(mRoot != null)
         {
            try
            {
               mRoot.removeFromParent(true);
            }
            finally
            {
               mRoot = null;
               mArt.releaseView();
            }
         }
         mObjects = new Dictionary();
      }
   }
}

