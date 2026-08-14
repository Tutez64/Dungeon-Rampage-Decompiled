package Brain.UI
{
   import Brain.Facade.Facade;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class UISliderHandleButton extends UIButton
   {
      
      private var mSliderWidth:Number;
      
      private var mSliderHeight:Number;
      
      private var mOrientation:uint;
      
      private var mSlideCallback:Function;
      
      public function UISliderHandleButton(facade:Facade, root:MovieClip, orientation:uint, sliderWidth:Number, sliderHeight:Number)
      {
         super(facade,root);
         mOrientation = orientation;
         mSliderWidth = sliderWidth;
         mSliderHeight = sliderHeight;
      }
      
      override public function destroy() : void
      {
         mSlideCallback = null;
         super.destroy();
      }
      
      public function set slideCallback(value:Function) : void
      {
         mSlideCallback = value;
      }
      
      override protected function onPress(event:MouseEvent) : void
      {
         super.onPress(event);
         if(mOrientation == 0)
         {
            mRoot.startDrag(false,new Rectangle(0,0,mSliderWidth,0));
         }
         else
         {
            mRoot.startDrag(false,new Rectangle(0,0,0,mSliderHeight));
         }
         mFacade.stageRef.addEventListener("mouseMove",onMouseMove);
      }
      
      override protected function onRelease(event:MouseEvent) : void
      {
         super.onRelease(event);
         mFacade.stageRef.removeEventListener("mouseMove",onMouseMove);
      }
      
      override protected function onMouseUp(event:MouseEvent) : void
      {
         super.onMouseUp(event);
         mRoot.stopDrag();
         mSlideCallback();
      }
      
      override protected function onMouseMove(event:MouseEvent) : void
      {
         if(mSlideCallback != null)
         {
            mSlideCallback();
         }
         super.onMouseMove(event);
      }
   }
}

