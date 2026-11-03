package Actor
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Utils.TextUtil;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class ChatBalloon extends Sprite
   {
      
      private static const TEXT_SIZE_MODIFIER:Number = 1.05;
      
      internal const renderContent:Sprite = new Sprite();
      
      internal var cutOverlay:ChatBalloonOverlay;
      
      internal var cutRegistered:Boolean = false;
      
      private var mText:TextField;
      
      private var mTypingClip:MovieClip;
      
      private var mBubbleSmall:MovieClip;
      
      private var mBubbleMedium:MovieClip;
      
      private var mBubbleMediumScaledDown:MovieClip;
      
      private var mBubbleLargeScaledDown:MovieClip;
      
      private var mAuthoredSizes:Dictionary = new Dictionary();
      
      private var mSizeModifier:Number = 1;
      
      private var mGrowsDown:Boolean = false;
      
      private var mIsInitialized:Boolean = false;
      
      public function ChatBalloon()
      {
         super();
         addChild(renderContent);
      }
      
      override public function set visible(value:Boolean) : void
      {
         super.visible = value;
         if(cutRegistered)
         {
            ChatBalloonOverlay.visibilityChanged(this);
         }
      }
      
      override public function get visible() : Boolean
      {
         return super.visible;
      }
      
      public function initializeChatBalloon(swfAsset:SwfAsset, typingClip:MovieClip = null, sizeModifier:Number = 1) : void
      {
         mTypingClip = typingClip;
         mSizeModifier = sizeModifier;
         var _loc4_:Class = swfAsset.getClass("UI_speechbubble");
         mBubbleSmall = new _loc4_();
         _loc4_ = swfAsset.getClass("UI_speechbubble_02");
         mBubbleMedium = new _loc4_();
         _loc4_ = swfAsset.getClass("UI_speechbubble_03");
         mBubbleMediumScaledDown = new _loc4_();
         _loc4_ = swfAsset.getClass("UI_speechbubble_04");
         mBubbleLargeScaledDown = new _loc4_();
         for each(var _loc5_:MovieClip in [mBubbleSmall,mBubbleMedium,mBubbleMediumScaledDown,mBubbleLargeScaledDown])
         {
            mAuthoredSizes[_loc5_] = Number(TextField(_loc5_.chatMessage).defaultTextFormat.size);
         }
         if(mTypingClip)
         {
            renderContent.addChild(mTypingClip);
            hidePlayerTyping();
         }
         mIsInitialized = true;
      }
      
      public function set sizeModifier(value:Number) : void
      {
         mSizeModifier = value;
      }
      
      public function set growsDown(value:Boolean) : void
      {
         mGrowsDown = value;
      }
      
      public function showPlayerTyping() : void
      {
         mTypingClip.visible = true;
      }
      
      public function hidePlayerTyping() : void
      {
         mTypingClip.visible = false;
      }
      
      public function showBalloon() : void
      {
         this.visible = true;
      }
      
      public function hideBalloon() : void
      {
         this.visible = false;
      }
      
      public function set text(value:String) : void
      {
         var _loc2_:MovieClip = null;
         if(mIsInitialized)
         {
            if(mText != null)
            {
               mText.parent.parent.removeChild(mText.parent);
            }
            _loc2_ = mBubbleSmall;
            mText = _loc2_.chatMessage;
            mText.text = value;
            if(mText.numLines > 3)
            {
               _loc2_ = mBubbleMedium;
            }
            mText = _loc2_.chatMessage;
            mText.text = value;
            if(mText.numLines > 4)
            {
               _loc2_ = mBubbleMediumScaledDown;
            }
            mText = _loc2_.chatMessage;
            mText.text = value;
            if(mText.numLines > 6)
            {
               _loc2_ = mBubbleLargeScaledDown;
            }
            mText = _loc2_.chatMessage;
            mText.text = value;
            scaleBubbleToFloor(_loc2_);
            renderContent.addChild(_loc2_);
            _loc2_.addChild(mText);
         }
      }
      
      private function scaleBubbleToFloor(bubble:MovieClip) : void
      {
         var _loc4_:Number = TextUtil.scaleToFloor(mAuthoredSizes[bubble],mSizeModifier * 1.05);
         var _loc3_:Rectangle = bubble.getBounds(bubble);
         var _loc2_:Number = mGrowsDown ? _loc3_.top : _loc3_.bottom;
         bubble.scaleX = bubble.scaleY = _loc4_;
         bubble.y = _loc2_ * (1 - _loc4_);
      }
      
      public function get text() : String
      {
         if(mText)
         {
            return mText.text;
         }
         return "";
      }
   }
}

