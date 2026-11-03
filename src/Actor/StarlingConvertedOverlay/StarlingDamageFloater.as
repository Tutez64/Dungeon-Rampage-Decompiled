package Actor.StarlingConvertedOverlay
{
   import Brain.Render.Tweens.Quad;
   import Brain.Render.Tweens.Quint;
   import Brain.Starling.SwfConverter.BakedGlyphFont;
   import Brain.Starling.SwfConverter.BakedGlyphText;
   import starling.display.Sprite;
   
   internal class StarlingDamageFloater extends Sprite
   {
      
      private static const DEG_TO_RAD:Number = 0.017453292519943295;
      
      public var big:Boolean;
      
      public var crit:Boolean;
      
      private var mCrit:BakedGlyphText;
      
      private var mGlow:BakedGlyphText;
      
      private var mFill:BakedGlyphText;
      
      private var mBuff:Boolean;
      
      private var mElapsed:Number;
      
      private var mHold:Number;
      
      private var mTotal:Number;
      
      private var mStartX:Number;
      
      private var mStartY:Number;
      
      private var mEndX:Number;
      
      private var mEndY:Number;
      
      private var mStartScale:Number;
      
      private var mEndScale:Number;
      
      private var mPeakY:Number;
      
      public function StarlingDamageFloater()
      {
         super();
      }
      
      private static function placeRow(row:BakedGlyphText, x:Number, y:Number, scaleX:Number, scaleY:Number) : void
      {
         row.x = x;
         row.y = y;
         row.scaleX = scaleX;
         row.scaleY = scaleY;
      }
      
      private static function ratio(time:Number, duration:Number) : Number
      {
         if(time <= 0)
         {
            return 0;
         }
         if(duration <= 0 || time >= duration)
         {
            return 1;
         }
         return time / duration;
      }
      
      public function setFonts(glow:BakedGlyphFont, fill:BakedGlyphFont, crit:BakedGlyphFont) : void
      {
         setCritFont(crit);
         if(glow != null)
         {
            if(mGlow == null)
            {
               mGlow = new BakedGlyphText(glow);
               addChildAt(mGlow,mCrit != null ? 1 : 0);
            }
            else if(mGlow.font != glow)
            {
               mGlow.font = glow;
            }
            mGlow.visible = true;
         }
         else if(mGlow != null)
         {
            mGlow.visible = false;
         }
         if(mFill == null)
         {
            mFill = new BakedGlyphText(fill);
            addChild(mFill);
         }
         else if(mFill.font != fill)
         {
            mFill.font = fill;
         }
      }
      
      private function setCritFont(crit:BakedGlyphFont) : void
      {
         if(crit == null)
         {
            if(mCrit != null)
            {
               mCrit.visible = false;
            }
            return;
         }
         if(mCrit == null)
         {
            mCrit = new BakedGlyphText(crit);
            addChildAt(mCrit,0);
         }
         else if(mCrit.font != crit)
         {
            mCrit.font = crit;
         }
         mCrit.visible = true;
      }
      
      public function setText(text:String, color:uint) : Number
      {
         if(mCrit != null && mCrit.visible)
         {
            mCrit.setText(text);
         }
         if(mGlow != null && mGlow.visible)
         {
            mGlow.setText(text);
         }
         mFill.setText(text);
         mFill.color = color;
         return mFill.textWidth;
      }
      
      public function placeRows(x:Number, y:Number, scaleX:Number, scaleY:Number) : void
      {
         placeRow(mFill,x,y,scaleX,scaleY);
         if(mGlow != null)
         {
            placeRow(mGlow,x,y,scaleX,scaleY);
         }
         if(mCrit != null)
         {
            placeRow(mCrit,x,y,scaleX,scaleY);
         }
      }
      
      public function start(x:Number, y:Number, scale:Number, rotationDegrees:Number, directionX:Number, directionY:Number, hold:Number, total:Number, scaleDampening:Number, speed:Number, buff:Boolean) : void
      {
         var _loc13_:Number = NaN;
         var _loc12_:Number = NaN;
         this.x = mStartX = x;
         this.y = mStartY = y;
         scaleX = scaleY = mStartScale = scale;
         rotation = rotationDegrees * 0.017453292519943295;
         alpha = 1;
         mEndScale = scale * scaleDampening;
         mElapsed = 0;
         mHold = hold;
         mTotal = total;
         mBuff = buff;
         if(buff)
         {
            _loc13_ = speed * total * 2;
            mEndX = x + directionX * _loc13_;
            mPeakY = y + directionY * _loc13_ * 0.5;
            mEndY = mPeakY - directionY * _loc13_ * 0.7;
         }
         else
         {
            _loc12_ = speed * total;
            mEndX = x + directionX * _loc12_;
            mEndY = y + directionY * _loc12_;
         }
      }
      
      public function advance(seconds:Number) : Boolean
      {
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         mElapsed += seconds;
         var _loc3_:Number = mElapsed;
         if(!mBuff)
         {
            _loc4_ = mTotal * 0.8;
            _loc5_ = Quint.easeOut(ratio(_loc3_ - mHold,_loc4_));
            x = mStartX + (mEndX - mStartX) * _loc5_;
            y = mStartY + (mEndY - mStartY) * _loc5_;
            scaleX = scaleY = mStartScale + (mEndScale - mStartScale) * _loc5_;
            alpha = 1 - Quad.easeOut(ratio(_loc3_ - mHold - _loc4_,mTotal * 0.2));
            return _loc3_ < mHold + mTotal;
         }
         _loc5_ = Quad.easeOut(ratio(_loc3_,mTotal));
         x = mStartX + (mEndX - mStartX) * _loc5_;
         scaleX = scaleY = mStartScale + (mEndScale - mStartScale) * _loc5_;
         alpha = 1 - Quad.easeOut(ratio(_loc3_ - mTotal * 0.7,mTotal * 0.3));
         var _loc2_:Number = mTotal * 0.1;
         if(_loc3_ < _loc2_)
         {
            y = mStartY + (mPeakY - mStartY) * Quint.easeOut(ratio(_loc3_,_loc2_));
         }
         else
         {
            y = mPeakY + (mEndY - mPeakY) * Quint.easeIn(ratio(_loc3_ - _loc2_,mTotal * 0.7));
         }
         return _loc3_ < mTotal;
      }
   }
}

