package Brain.UI
{
   import Brain.Facade.Facade;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class UIToggleButton extends UIButton
   {
      
      private var m_id:uint;
      
      private var selectionChangeCallback:Function;
      
      public function UIToggleButton(facade:Facade, id:uint, root:MovieClip, isSelected:Boolean, changeInStateCallback:Function, tooltipDrawLayer:int = 0)
      {
         super(facade,root,tooltipDrawLayer);
         m_id = id;
         selectionChangeCallback = changeInStateCallback;
         this.selected = isSelected;
      }
      
      override protected function onRelease(event:MouseEvent) : void
      {
         this.selected = !this.selected;
         selectionChangeCallback(m_id,this.selected);
         super.onRelease(event);
      }
   }
}

