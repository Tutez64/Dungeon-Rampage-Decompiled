package UI
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public class ControllerIconData
   {
      
      public var mControllerGlyph:DisplayObject;
      
      public var mOwner:MovieClip;
      
      public var mIsHidden:Boolean;
      
      public var mActionName:String;
      
      public var mGlyphFilePath:String;
      
      public var mPosition:Vector3D;
      
      public var mScale:Point;
      
      public function ControllerIconData(inControllerGlyph:DisplayObject, inOwner:MovieClip, inIsHidden:Boolean = true)
      {
         super();
         mControllerGlyph = inControllerGlyph;
         mOwner = inOwner;
         mIsHidden = inIsHidden;
      }
      
      public function destroy() : void
      {
         mControllerGlyph = null;
         mOwner = null;
      }
   }
}

