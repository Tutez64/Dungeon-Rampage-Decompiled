package UI.Training
{
   import Brain.Logger.Logger;
   import Brain.Utils.TextUtil;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class UIStatTooltipBox extends MovieClip
   {
      
      private static const DESCRIPTION_BOTTOM_LIMIT:Number = -32;
      
      private static const BOX_CORNER:Number = 16;
      
      protected var mRoot:MovieClip;
      
      protected var mTitleLabel:TextField;
      
      protected var mDescription:TextField;
      
      private var mDescriptionSize:Number;
      
      private var mBackground:Shape;
      
      private var mBackgroundBounds:Rectangle;
      
      private var mBackgroundY:Number;
      
      private var mTitleY:Number;
      
      private var mDescriptionY:Number;
      
      public function UIStatTooltipBox(templateClass:Class)
      {
         var _loc2_:Number = NaN;
         super();
         mRoot = new templateClass();
         addChild(mRoot);
         mTitleLabel = mRoot.title_label;
         mDescription = mRoot.stat_description_label;
         mDescription.wordWrap = true;
         mDescription.multiline = true;
         mDescription.autoSize = "center";
         mDescriptionSize = Number(mDescription.defaultTextFormat.size);
         mTitleY = mTitleLabel.y;
         mDescriptionY = mDescription.y;
         mBackground = findBackground();
         if(mBackground != null)
         {
            mBackgroundBounds = mBackground.getBounds(mRoot);
            mBackgroundY = mBackground.y;
            _loc2_ = mDescription.getBounds(mRoot).top;
            mBackground.scale9Grid = new Rectangle(mBackgroundBounds.left + 16,_loc2_,mBackgroundBounds.width - 2 * 16,-32 - 16 - _loc2_);
         }
         else
         {
            Logger.warn("UIStatTooltipBox: stat_tooltip has no box shape; long descriptions will overflow it");
         }
      }
      
      public function destroy() : void
      {
         removeChild(mRoot);
         mRoot = null;
         mTitleLabel = null;
         mDescription = null;
         mBackground = null;
      }
      
      protected function setTexts(title:String, description:String, descriptionSizeModifier:Number) : void
      {
         TextUtil.setText(mTitleLabel,title);
         TextUtil.setText(mDescription,description,Math.max(TextUtil.modifierForSize(mDescriptionSize),descriptionSizeModifier));
         fitBox();
      }
      
      private function findBackground() : Shape
      {
         var _loc2_:int = 0;
         var _loc1_:Shape = null;
         _loc2_ = 0;
         while(_loc2_ < mRoot.numChildren)
         {
            _loc1_ = mRoot.getChildAt(_loc2_) as Shape;
            if(_loc1_ != null)
            {
               return _loc1_;
            }
            _loc2_++;
         }
         return null;
      }
      
      private function fitBox() : void
      {
         if(mBackground == null)
         {
            return;
         }
         mDescription.y = mDescriptionY;
         var _loc1_:Number = Math.max(0,mDescription.getBounds(mRoot).bottom - -32);
         mTitleLabel.y = mTitleY - _loc1_;
         mDescription.y = mDescriptionY - _loc1_;
         mBackground.scaleY = 1 + _loc1_ / mBackgroundBounds.height;
         mBackground.y = mBackgroundY;
         mBackground.y += mBackgroundBounds.bottom - mBackground.getBounds(mRoot).bottom;
      }
   }
}

