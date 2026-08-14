package Actor
{
   import Brain.Render.IRenderer;
   import Brain.Render.MovieClipRenderController;
   import Facade.DBFacade;
   import Floor.FloorView;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ActorMovieClipRenderer extends MovieClipRenderController implements IRenderer
   {
      
      public static var MOVIE_CLIP_RENDERER_TYPE:String = "MovieClipRenderer";
      
      protected var mDBFacade:DBFacade;
      
      protected var mHeading:Number;
      
      public function ActorMovieClipRenderer(dbFacade:DBFacade, movieClip:MovieClip)
      {
         super(dbFacade,movieClip);
         mDBFacade = dbFacade;
         for each(var _loc3_:DisplayObject in FloorView.findNavCollisions(movieClip))
         {
            _loc3_.parent.removeChild(_loc3_);
         }
         for each(var _loc4_:DisplayObject in FloorView.findCombatCollisions(movieClip))
         {
            _loc4_.parent.removeChild(_loc4_);
         }
      }
      
      public function get displayObject() : DisplayObject
      {
         return mClip;
      }
      
      public function get rendererType() : String
      {
         return MOVIE_CLIP_RENDERER_TYPE;
      }
      
      public function set heading(value:Number) : void
      {
         mHeading = value;
      }
      
      override public function destroy() : void
      {
         mDBFacade = null;
         super.destroy();
      }
   }
}

