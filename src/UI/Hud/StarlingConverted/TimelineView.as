package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedCell;
   import starling.display.DisplayObject;
   import starling.styles.MeshStyle;
   
   public class TimelineView extends StatesView implements IHudTick
   {
      
      private var mTicker:HudTicker;
      
      private var mPlaying:Boolean = false;
      
      private var mPlayHead:Number = 0;
      
      private var mPlayRate:Number = 1;
      
      private var mLoop:Boolean = false;
      
      private var mComplete:Function;
      
      private var mPlayedIntro:Boolean = false;
      
      private var mStageRate:Boolean = false;
      
      private var mSweep:StarlingSweepMesh;
      
      private var mSweepColor:StarlingColorStyle;
      
      private var mSweepDefault:MeshStyle;
      
      public var advanceWhileHidden:Boolean = false;
      
      public function TimelineView(art:ArtNode, ticker:HudTicker = null)
      {
         var _loc4_:int = 0;
         var _loc3_:Vector.<Number> = undefined;
         super(art);
         mTicker = ticker;
         mStageRate = art.stageRate;
         if(art.sweep != null)
         {
            _loc4_ = 1;
            for each(_loc3_ in art.sweep.arcs)
            {
               if(_loc3_ != null)
               {
                  _loc4_ = Math.max(_loc4_,_loc3_.length / 2);
               }
            }
            mSweep = new StarlingSweepMesh(art.sweep.cx,art.sweep.cy,_loc4_ * 11);
            mSweep.cell = art.cell;
            mSweepColor = new StarlingColorStyle();
            mSweepDefault = mSweep.style;
            addChild(mSweep);
         }
      }
      
      public function play(startFrame:Number = 0, loop:Boolean = false, onComplete:Function = null) : void
      {
         mComplete = onComplete;
         mLoop = onComplete != null ? loop : (mArt.labelLoop == 0 ? loop : mArt.labelLoop > 0);
         mPlayHead = startFrame;
         mPlayedIntro = false;
         resetChildren();
         applyHead();
         mPlaying = mArt.totalFrames > 1;
         if(mPlaying && mTicker != null)
         {
            mTicker.register(this);
         }
         else if(!mPlaying && mComplete != null)
         {
            complete();
         }
      }
      
      public function stop() : void
      {
         mPlaying = false;
         if(mTicker != null)
         {
            mTicker.unregister(this);
         }
      }
      
      override public function gotoAndStop(frame:Object) : void
      {
         stop();
         mPlayHead = frame is String ? int(mArt.labels[String(frame)]) : Number(frame);
         mPlayedIntro = false;
         mPlayHead = Math.max(0,Math.min(mArt.totalFrames - 1,mPlayHead));
         resetChildren();
         applyHead();
      }
      
      public function tick(tickLength:Number, stageFrame:Boolean) : void
      {
         if(!mPlaying || stageRate && !stageFrame)
         {
            return;
         }
         var _loc3_:DisplayObject = this;
         var _loc4_:Boolean = true;
         while(_loc3_ != null)
         {
            if(!_loc3_.visible || _loc3_.alpha <= 0)
            {
               _loc4_ = false;
               break;
            }
            _loc3_ = _loc3_.parent;
         }
         if(!_loc4_ && !advanceWhileHidden)
         {
            return;
         }
         mPlayHead += stageRate ? mPlayRate : 24 * tickLength * mPlayRate;
         if(mPlayHead > mArt.totalFrames - 1 && !mLoop)
         {
            mPlayHead = mArt.totalFrames - 1;
            applyHead();
            stop();
            complete();
            return;
         }
         if(_loc4_)
         {
            applyHead();
         }
      }
      
      private function complete() : void
      {
         var _loc1_:Function = mComplete;
         mComplete = null;
         if(_loc1_ != null)
         {
            _loc1_();
         }
      }
      
      private function applyHead() : void
      {
         driveHead(mPlayHead);
      }
      
      internal function driveHead(head:Number) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = mArt.kind == "flipbook" ? mArt.totalFrames : mArt.authoredFrames;
         if(mArt.loopFrame >= 0 && mPlayedIntro)
         {
            _loc2_ = mArt.authoredFrames - mArt.loopFrame;
            _loc3_ = Math.round((head - mArt.loopFrame - 2) % _loc2_) + mArt.loopFrame;
         }
         else
         {
            _loc3_ = Math.round(head % _loc2_);
            if(mArt.loopFrame >= 0 && head >= mArt.authoredFrames)
            {
               mPlayedIntro = true;
            }
         }
         showFrame(Math.max(0,Math.min(mArt.totalFrames - 1,_loc3_)));
         driveChildren(head);
      }
      
      override protected function showFrame(index:int) : void
      {
         if(index == mFrame)
         {
            return;
         }
         super.showFrame(index);
         if(mSweep != null)
         {
            mSweep.setArcs(mArt.sweep.arcs[index + 1]);
         }
      }
      
      override protected function applyContentColor(red:Number, green:Number, blue:Number, offsetRed:Number, offsetGreen:Number, offsetBlue:Number) : void
      {
         if(mSweep == null)
         {
            return;
         }
         var _loc7_:Boolean = red == 1 && green == 1 && blue == 1 && offsetRed == 0 && offsetGreen == 0 && offsetBlue == 0;
         var _loc8_:MeshStyle = _loc7_ ? mSweepDefault : mSweepColor;
         if(mSweep.style != _loc8_)
         {
            mSweep.style = _loc8_;
         }
         if(!_loc7_)
         {
            mSweepColor.setTransform(red,green,blue,offsetRed,offsetGreen,offsetBlue);
         }
      }
      
      override protected function applyChildFrame(child:ArtDisplay, frame:int) : void
      {
         if(!(child is TimelineView))
         {
            super.applyChildFrame(child,frame);
         }
      }
      
      internal function resetIntro() : void
      {
         stop();
         mPlayedIntro = false;
      }
      
      public function get playRate() : Number
      {
         return mPlayRate;
      }
      
      public function set playRate(value:Number) : void
      {
         mPlayRate = value;
      }
      
      public function get stageRate() : Boolean
      {
         return mStageRate;
      }
      
      public function set stageRate(value:Boolean) : void
      {
         if(value == mStageRate)
         {
            return;
         }
         mStageRate = value;
         setStageRate(value);
      }
      
      public function get isPlaying() : Boolean
      {
         return mPlaying;
      }
      
      internal function get playHead() : Number
      {
         return mPlayHead;
      }
      
      override internal function setGrayscale(value:Boolean) : Boolean
      {
         var _loc2_:Boolean = super.setGrayscale(value);
         if(mSweep != null)
         {
            mSweep.cell = value ? HudArtConverter.grayCell(mArt.cell) : mArt.cell;
         }
         return _loc2_;
      }
      
      override public function dispose() : void
      {
         stop();
         super.dispose();
      }
   }
}

