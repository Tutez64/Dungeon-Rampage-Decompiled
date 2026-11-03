package UI.Hud.StarlingConverted
{
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public class ArtChildState
   {
      
      public var child:int;
      
      public var matrix:Matrix;
      
      public var alpha:Number;
      
      public var visible:Boolean;
      
      public var blendMode:String;
      
      public var colorTransform:ColorTransform;
      
      public var frame:int = 0;
      
      internal var filterState:int = 0;
      
      internal var parentClip:Rectangle;
      
      public function ArtChildState()
      {
         super();
      }
   }
}

