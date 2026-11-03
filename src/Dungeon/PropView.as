package Dungeon
{
   import Brain.Render.MovieClipRenderController;
   import Facade.DBFacade;
   import Floor.FloorView;
   import Starling.StarlingView;
   import Starling.SwfFallbackDebug;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class PropView extends FloorView
   {
      
      private var mBody:MovieClip;
      
      private var mStarlingView:StarlingView;
      
      private var mStarlingViewVisible:Boolean = true;
      
      public function PropView(dbFacade:DBFacade, gameObject:Prop)
      {
         super(dbFacade,gameObject);
         mRoot.name = "PropView_" + gameObject.id;
         mRoot.mouseEnabled = false;
         mRoot.mouseChildren = false;
      }
      
      public function set starlingView(value:StarlingView) : void
      {
         mStarlingView = value;
         if(mStarlingView != null)
         {
            removeSwfFallbackOutline();
            if(mStarlingViewVisible)
            {
               mStarlingView.addToStage();
            }
            else
            {
               mStarlingView.removeFromStage();
            }
         }
         else
         {
            applySwfFallbackOutline();
         }
      }
      
      public function get starlingView() : StarlingView
      {
         return mStarlingView;
      }
      
      public function set body(clip:MovieClip) : void
      {
         mBody = clip;
         mRoot.addChild(mBody);
         applySwfFallbackOutline();
         for each(var _loc2_:DisplayObject in FloorView.findNavCollisions(mBody))
         {
            _loc2_.parent.removeChild(_loc2_);
         }
         for each(var _loc3_:DisplayObject in FloorView.findCombatCollisions(mBody))
         {
            _loc3_.parent.removeChild(_loc3_);
         }
         mMovieClipRenderer = new MovieClipRenderController(mDBFacade,mBody);
         if(mBody.totalFrames == 1 && !mDBFacade.featureFlags.getFlagValue("want-zoom"))
         {
            mRoot.cacheAsBitmap = true;
            mMovieClipRenderer.play(0,false);
         }
         else
         {
            mMovieClipRenderer.play(0,true);
         }
      }
      
      override public function addToStage() : void
      {
         super.addToStage();
         mStarlingViewVisible = true;
         if(mStarlingView != null)
         {
            mStarlingView.addToStage();
         }
      }
      
      override public function removeFromStage() : void
      {
         super.removeFromStage();
         mStarlingViewVisible = false;
         if(mStarlingView != null)
         {
            mStarlingView.removeFromStage();
         }
      }
      
      private function applySwfFallbackOutline() : void
      {
         if(mStarlingView == null)
         {
            SwfFallbackDebug.applyOutline(mDBFacade,mBody,"PROP");
         }
      }
      
      private function removeSwfFallbackOutline() : void
      {
         SwfFallbackDebug.removeOutline(mBody);
      }
      
      override public function destroy() : void
      {
         mBody = null;
         if(mStarlingView != null)
         {
            mStarlingView.dispose();
            mStarlingView = null;
         }
         super.destroy();
      }
   }
}

