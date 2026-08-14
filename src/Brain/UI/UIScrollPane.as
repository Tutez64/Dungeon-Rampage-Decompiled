package Brain.UI
{
   import Brain.Facade.Facade;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class UIScrollPane extends UIObject
   {
      
      private var mSlider:UISlider;
      
      private var mMouseWheelDeltaMultiplier:Number;
      
      private var mMouseFlickDeltaMultiplier:Number;
      
      private var mParentContainer:MovieClip;
      
      private var mFlickMouseDown:Boolean;
      
      private var mFlickMousePoint:Point;
      
      public function UIScrollPane(facade:Facade, root:MovieClip, tooltipDrawLayer:int = 0)
      {
         super(facade,root,tooltipDrawLayer);
         var _loc4_:Rectangle = new Rectangle(0,0,root.width,root.height);
         root.scrollRect = _loc4_;
         mFlickMousePoint = new Point();
      }
      
      public function scrollTo(sx:Number, sy:Number) : void
      {
         var _loc3_:Rectangle = root.scrollRect;
         _loc3_.x = sx;
         _loc3_.y = sy;
         root.scrollRect = _loc3_;
      }
      
      public function scrollBy(sx:Number, sy:Number) : void
      {
         var _loc3_:Rectangle = root.scrollRect;
         _loc3_.x += sx;
         _loc3_.y += sy;
         root.scrollRect = _loc3_;
      }
      
      public function scrollByX(value:Number) : void
      {
         this.scrollBy(value,0);
      }
      
      public function scrollByY(value:Number) : void
      {
         this.scrollBy(0,value);
      }
      
      public function scrollToX(value:Number) : void
      {
         this.scrollTo(value,root.scrollRect.y);
      }
      
      public function scrollToY(value:Number) : void
      {
         this.scrollTo(root.scrollRect.x,value);
      }
      
      public function addMouseWheelFunctionality(slider:UISlider, deltaMultiplier:Number = 20, parentContainer:MovieClip = null) : void
      {
         mParentContainer = parentContainer;
         mSlider = slider;
         mMouseWheelDeltaMultiplier = deltaMultiplier;
         if(parentContainer == null)
         {
            mRoot.addEventListener("mouseWheel",onMouseWheel);
         }
         else
         {
            mParentContainer.addEventListener("mouseWheel",onMouseWheel);
         }
      }
      
      public function onMouseWheel(mEvt:MouseEvent) : void
      {
         mSlider.valueWithCallback = mSlider.value - mEvt.delta * mMouseWheelDeltaMultiplier;
      }
      
      public function addMouseFlickFunctionality(slider:UISlider, deltaMultiplier:Number = 20, parentContainer:MovieClip = null) : void
      {
         mParentContainer = parentContainer;
         mSlider = slider;
         mMouseFlickDeltaMultiplier = deltaMultiplier;
         if(parentContainer == null)
         {
            mRoot.addEventListener("mouseDown",onMouseDown);
            mRoot.addEventListener("mouseMove",onMouseMove);
            mRoot.addEventListener("mouseUp",onMouseUp);
         }
         else
         {
            mParentContainer.addEventListener("mouseDown",onMouseDown);
            mParentContainer.addEventListener("mouseMove",onMouseMove);
            mParentContainer.addEventListener("mouseUp",onMouseUp);
         }
         mFacade.stageRef.addEventListener("mouseUp",onMouseUp);
      }
      
      public function onMouseDown(mEvt:MouseEvent) : void
      {
         mFlickMousePoint.x = mEvt.stageX;
         mFlickMousePoint.y = mEvt.stageY;
         mFlickMouseDown = true;
      }
      
      public function onMouseMove(mEvt:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         if(mFlickMouseDown && mSlider)
         {
            _loc2_ = 0;
            if(mSlider.orientation == 0)
            {
               _loc2_ = mEvt.stageX - mFlickMousePoint.x;
            }
            else if(mSlider.orientation == 1)
            {
               _loc2_ = mEvt.stageY - mFlickMousePoint.y;
            }
            mSlider.valueWithCallback = mSlider.value - _loc2_ * mMouseFlickDeltaMultiplier;
            mFlickMousePoint.x = mEvt.stageX;
            mFlickMousePoint.y = mEvt.stageY;
         }
      }
      
      public function onMouseUp(mEvt:MouseEvent) : void
      {
         mFlickMouseDown = false;
      }
      
      override public function destroy() : void
      {
         if(mSlider)
         {
            if(mParentContainer == null)
            {
               mRoot.removeEventListener("mouseWheel",onMouseWheel);
               mRoot.removeEventListener("mouseDown",onMouseDown);
               mRoot.removeEventListener("mouseMove",onMouseMove);
               mRoot.removeEventListener("mouseUp",onMouseUp);
            }
            else
            {
               mParentContainer.removeEventListener("mouseWheel",onMouseWheel);
               mParentContainer.removeEventListener("mouseDown",onMouseDown);
               mParentContainer.removeEventListener("mouseMove",onMouseMove);
               mParentContainer.removeEventListener("mouseUp",onMouseUp);
            }
            mFacade.stageRef.removeEventListener("mouseUp",onMouseUp);
         }
         mSlider = null;
         mParentContainer = null;
         super.destroy();
      }
   }
}

