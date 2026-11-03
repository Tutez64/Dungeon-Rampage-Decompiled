package Actor.StarlingConvertedOverlay
{
   import Brain.Starling.SwfConverter.BakedRoot;
   import starling.display.Sprite;
   
   internal class StarlingOverlayRoot extends BakedRoot
   {
      
      public const tags:Sprite = new Sprite();
      
      public const floaters:Sprite = new Sprite();
      
      public function StarlingOverlayRoot()
      {
         super();
         addChild(tags);
         addChild(floaters);
      }
   }
}

