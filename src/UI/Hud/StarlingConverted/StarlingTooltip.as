package UI.Hud.StarlingConverted
{
   import Brain.Clock.GameClock;
   import Brain.WorkLoop.DoLater;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import starling.display.DisplayObject;
   
   public class StarlingTooltip
   {
      
      private var mFacade:DBFacade;
      
      private var mOwner:DisplayObject;
      
      private var mSpace:DisplayObject;
      
      private var mClip:MovieClip;
      
      private var mOffset:Point;
      
      private var mDelay:Number;
      
      private var mTask:DoLater;
      
      private var mMatrix:Matrix = new Matrix();
      
      private var mHovered:Boolean;
      
      private var mStagePosition:Boolean;
      
      private var mOriginalX:Number;
      
      private var mOriginalY:Number;
      
      public function StarlingTooltip(facade:DBFacade, owner:DisplayObject, space:DisplayObject, clip:MovieClip, delay:Number = 0, offset:Point = null, stagePosition:Boolean = false)
      {
         super();
         mFacade = facade;
         mOwner = owner;
         mSpace = space;
         mClip = clip;
         mOriginalX = clip.x;
         mOriginalY = clip.y;
         mDelay = delay;
         mStagePosition = stagePosition;
         mOffset = offset ?? new Point(clip.x,clip.y);
         clip.mouseEnabled = clip.mouseChildren = false;
         if(clip.parent != null)
         {
            clip.parent.removeChild(clip);
         }
      }
      
      public function rollOver() : void
      {
         hide();
         mHovered = true;
         if(mDelay == 0)
         {
            show();
         }
         else
         {
            mTask = mFacade.preRenderWorkManager.doLater(mDelay,show,false,"StarlingTooltip");
         }
      }
      
      private function show(clock:GameClock = null) : void
      {
         try
         {
            mTask = null;
            if(!mHovered || mClip == null)
            {
               return;
            }
            mOwner.getTransformationMatrix(mSpace,mMatrix);
            mClip.x = mMatrix.a * mOffset.x + mMatrix.c * mOffset.y + mMatrix.tx;
            mClip.y = mMatrix.b * mOffset.x + mMatrix.d * mOffset.y + mMatrix.ty;
            mFacade.sceneGraphManager.addChild(mClip,107);
            if(mStagePosition)
            {
               mClip.x = mOffset.x;
               mClip.y = mOffset.y;
            }
            mClip.visible = true;
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      public function hide() : void
      {
         mHovered = false;
         if(mTask != null)
         {
            mTask.destroy();
         }
         mTask = null;
         if(mClip != null && mClip.parent != null)
         {
            mClip.parent.removeChild(mClip);
         }
      }
      
      public function dispose() : void
      {
         hide();
         if(mClip != null)
         {
            mClip.x = mOriginalX;
            mClip.y = mOriginalY;
         }
         mClip = null;
         mOwner = mSpace = null;
         mFacade = null;
      }
   }
}

