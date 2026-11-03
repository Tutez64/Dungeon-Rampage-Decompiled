package UI.Hud.StarlingConverted
{
   import starling.rendering.MeshEffect;
   import starling.rendering.RenderState;
   import starling.styles.MeshStyle;
   
   public class StarlingColorStyle extends MeshStyle
   {
      
      private var mValues:Vector.<Number> = new <Number>[1,1,1,1,0,0,0,0];
      
      public function StarlingColorStyle()
      {
         super();
      }
      
      public function setTransform(red:Number, green:Number, blue:Number, offsetRed:Number, offsetGreen:Number, offsetBlue:Number) : void
      {
         mValues[0] = red;
         mValues[1] = green;
         mValues[2] = blue;
         mValues[4] = offsetRed / 255;
         mValues[5] = offsetGreen / 255;
         mValues[6] = offsetBlue / 255;
         setRequiresRedraw();
      }
      
      override public function copyFrom(style:MeshStyle) : void
      {
         var _loc2_:int = 0;
         super.copyFrom(style);
         var _loc3_:StarlingColorStyle = style as StarlingColorStyle;
         if(_loc3_ != null)
         {
            _loc2_ = 0;
            while(_loc2_ < mValues.length)
            {
               mValues[_loc2_] = _loc3_.mValues[_loc2_];
               _loc2_++;
            }
         }
      }
      
      override public function canBatchWith(style:MeshStyle) : Boolean
      {
         var _loc2_:int = 0;
         if(!super.canBatchWith(style))
         {
            return false;
         }
         var _loc3_:StarlingColorStyle = style as StarlingColorStyle;
         _loc2_ = 0;
         while(_loc2_ < mValues.length)
         {
            if(mValues[_loc2_] != _loc3_.mValues[_loc2_])
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      override public function createEffect() : MeshEffect
      {
         return new StarlingColorEffect();
      }
      
      override public function updateEffect(effect:MeshEffect, state:RenderState) : void
      {
         super.updateEffect(effect,state);
         StarlingColorEffect(effect).values = mValues;
      }
   }
}

