package Actor
{
   import Brain.AssetRepository.SwfAsset;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class ChatBalloon extends Sprite
   {
      
      private var mText:TextField;
      
      private var mTypingClip:MovieClip;
      
      private var mBubbleSmall:MovieClip;
      
      private var mBubbleMedium:MovieClip;
      
      private var mBubbleMediumScaledDown:MovieClip;
      
      private var mBubbleLargeScaledDown:MovieClip;
      
      private var mIsInitialized:Boolean = false;
      
      public function ChatBalloon()
      {
         super();
      }
      
      public function initializeChatBalloon(swfAsset:SwfAsset, typingClip:MovieClip = null) : void
      {
         mTypingClip = typingClip;
         var _loc3_:Class = swfAsset.getClass("UI_speechbubble");
         mBubbleSmall = new _loc3_();
         _loc3_ = swfAsset.getClass("UI_speechbubble_02");
         mBubbleMedium = new _loc3_();
         _loc3_ = swfAsset.getClass("UI_speechbubble_03");
         mBubbleMediumScaledDown = new _loc3_();
         _loc3_ = swfAsset.getClass("UI_speechbubble_04");
         mBubbleLargeScaledDown = new _loc3_();
         if(mTypingClip)
         {
            addChild(mTypingClip);
            hidePlayerTyping();
         }
         mIsInitialized = true;
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
            addChild(_loc2_);
            _loc2_.addChild(mText);
         }
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

