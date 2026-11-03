package Actor.StarlingConvertedOverlay
{
   import flash.filters.GlowFilter;
   
   public class FloaterStyle
   {
      
      public static const CRIT_GLOW:GlowFilter = new GlowFilter(16777062,1,0.4,0.4,30,1);
      
      public var text:String;
      
      public var color:uint;
      
      public var scale:Number;
      
      public var directionX:Number;
      
      public var directionY:Number;
      
      public var rotation:Number;
      
      public var crit:Boolean;
      
      public function FloaterStyle()
      {
         super();
      }
   }
}

