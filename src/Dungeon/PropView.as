package Dungeon
{
   import Brain.Render.MovieClipRenderController;
   import Facade.DBFacade;
   import Floor.FloorView;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class PropView extends FloorView
   {
      
      private var mBody:MovieClip;
      
      public function PropView(dbFacade:DBFacade, gameObject:Prop)
      {
         super(dbFacade,gameObject);
         mRoot.name = "PropView_" + gameObject.id;
         mRoot.mouseEnabled = false;
         mRoot.mouseChildren = false;
      }
      
      public function set body(clip:MovieClip) : void
      {
         mBody = clip;
         mRoot.addChild(mBody);
         for each(var _loc2_:DisplayObject in FloorView.findNavCollisions(mBody))
         {
            _loc2_.parent.removeChild(_loc2_);
         }
         for each(var _loc3_:DisplayObject in FloorView.findCombatCollisions(mBody))
         {
            _loc3_.parent.removeChild(_loc3_);
         }
         mMovieClipRenderer = new MovieClipRenderController(mFacade,mBody);
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
      
      override public function destroy() : void
      {
         mBody = null;
         super.destroy();
      }
   }
}

