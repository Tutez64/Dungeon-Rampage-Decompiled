package Town
{
   import Facade.DBFacade;
   import Facade.Locale;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class CreditsTownSubState extends TownSubState
   {
      
      private static const SCROLL_SPEED:uint = 250;
      
      private static const BITMAP_SCALE:uint = 2;
      
      private static const BOTTOM_OF_THE_SCREEN_Y:uint = 603;
      
      private static const KICKSTARTER_BACKER_HEADER_STRING:String = "Kickstarters Backers!";
      
      public static const NAME:String = "CreditsTownSubState";
      
      private static const Headers:Vector.<String> = Vector.<String>(["Dungeon Rampage\'s Revivalist","Gamebreaking Studios","Original Developers","Special Thanks","Additional Thanks","Kickstarters Backers!"]);
      
      private var mHeaderLines:Vector.<int> = Vector.<int>([]);
      
      private var mTween:TweenMax;
      
      private var mFile:File;
      
      private var mFileStream:FileStream;
      
      private var mFileContents:String;
      
      private var mHeaderFormat:TextFormat;
      
      private var mDevFormat:TextFormat;
      
      private var mBitMapData:BitmapData;
      
      private var mBitMapMatrix:Matrix;
      
      private var mBitMapCreator:Bitmap;
      
      private var mCreditsBitMap:Bitmap;
      
      public function CreditsTownSubState(dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,townStateMachine,"CreditsTownSubState");
      }
      
      override protected function setupState() : void
      {
         super.setupState();
         mHeaderFormat = new TextFormat();
         mHeaderFormat.color = 16711680;
         mHeaderFormat.bold = true;
         mHeaderFormat.size = 40;
         mDevFormat = new TextFormat();
         mDevFormat.size = 20;
      }
      
      override public function enterState() : void
      {
         super.enterState();
         mFile = File.applicationDirectory.resolvePath("Resources/credits.txt");
         mFileStream = new FileStream();
         mFileStream.open(mFile,"read");
         mFileContents = mFileStream.readUTFBytes(mFileStream.bytesAvailable);
         mFileStream.close();
         mTownStateMachine.townHeader.showCloseButton(true);
         mTownStateMachine.townHeader.title = Locale.getString("CREDITS_HEADER");
         mRootMovieClip.label.text = mFileContents;
         mRootMovieClip.label.selectable = false;
         mRootMovieClip.label.autoSize = "center";
         applyHeaderFormatting();
         mCreditsBitMap = textFieldToBitmap(mRootMovieClip.label);
         mRootMovieClip.addChild(mCreditsBitMap);
         mRootMovieClip.label.visible = false;
         mCreditsBitMap.y = 603 + 100;
         mCreditsBitMap.x = mRootMovieClip.label.x;
         mTween = TweenMax.to(mCreditsBitMap,250,{
            "y":603 - mRootMovieClip.label.height,
            "ease":Linear
         });
         mRoot.addEventListener("mouseUp",resumeAutoScroll);
         mRoot.addEventListener("mouseWheel",onScrollWheel);
         mRoot.addEventListener("mouseDown",stopAutoScroll);
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("CREDITS_MENU",mTownStateMachine.townHeader.determineCallback,mTownStateMachine.townHeader.closeButton,mTownStateMachine.townHeader.closeButton);
      }
      
      private function textFieldToBitmap(tf:TextField) : Bitmap
      {
         mBitMapData = new BitmapData(tf.width * 2,tf.height * 2,true,0);
         mBitMapMatrix = new Matrix();
         mBitMapMatrix.scale(2,2);
         mBitMapData.draw(tf,mBitMapMatrix,null,null,null,true);
         mBitMapCreator = new Bitmap(mBitMapData,"auto",true);
         mBitMapCreator.scaleX = mBitMapCreator.scaleY = 1 / 2;
         return mBitMapCreator;
      }
      
      private function applyHeaderFormatting() : void
      {
         var _loc5_:int = 0;
         var _loc3_:String = null;
         var _loc8_:int = 0;
         var _loc1_:int = 0;
         var _loc11_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:int = 0;
         var _loc12_:int = 0;
         var _loc9_:Array = mFileContents.split("\n");
         var _loc4_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < _loc9_.length)
         {
            _loc3_ = _loc9_[_loc5_];
            if(_loc3_.indexOf("Kickstarters Backers!") != -1)
            {
               _loc4_ = _loc5_;
            }
            for each(var _loc6_:String in Headers)
            {
               if(_loc3_.indexOf(_loc6_) != -1)
               {
                  mHeaderLines.push(_loc5_);
               }
            }
            _loc5_++;
         }
         _loc8_ = 0;
         while(_loc8_ <= _loc4_)
         {
            _loc1_ = int(mRootMovieClip.label.getLineOffset(_loc8_));
            _loc11_ = int(mRootMovieClip.label.getLineLength(_loc8_));
            mRootMovieClip.label.setTextFormat(mDevFormat,_loc1_,_loc1_ + _loc11_);
            _loc8_++;
         }
         _loc7_ = 0;
         while(_loc7_ < mHeaderLines.length)
         {
            _loc10_ = mHeaderLines[_loc7_];
            _loc2_ = int(mRootMovieClip.label.getLineOffset(_loc10_));
            _loc12_ = int(mRootMovieClip.label.getLineLength(_loc10_));
            mRootMovieClip.label.setTextFormat(mHeaderFormat,_loc2_,_loc2_ + _loc12_);
            _loc7_++;
         }
      }
      
      private function onScrollWheel(event:MouseEvent) : void
      {
         if(event.delta > 0)
         {
            mTween.reverse();
         }
         else if(event.delta < 0)
         {
            mTween.play();
         }
      }
      
      private function resumeAutoScroll(event:MouseEvent) : void
      {
         mTween.resume();
      }
      
      private function stopAutoScroll(event:MouseEvent) : void
      {
         mTween.pause();
      }
      
      override public function exitState() : void
      {
         mDBFacade.menuNavigationController.popLayer("CREDITS_MENU");
         super.exitState();
         mRoot.removeEventListener("mouseDown",stopAutoScroll);
         mRoot.removeEventListener("mouseUp",resumeAutoScroll);
         mRoot.removeEventListener("mouseWheel",onScrollWheel);
         mBitMapData.dispose();
         mRootMovieClip.removeChild(mCreditsBitMap);
         mBitMapData = null;
         mBitMapMatrix = null;
         mBitMapCreator = null;
         mCreditsBitMap = null;
         mFile = null;
         mFileStream = null;
         mFileContents = null;
         if(mTween)
         {
            mTween.kill();
         }
      }
      
      override public function destroy() : void
      {
         mHeaderLines = null;
         mHeaderFormat = null;
         mDevFormat = null;
         super.destroy();
      }
   }
}

