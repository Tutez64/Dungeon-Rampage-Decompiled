package Brain.UI
{
   import Brain.Facade.Facade;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class UIRadioButton extends UIButton
   {
      
      private static var mAllRadioButtons:Vector.<UIRadioButton> = new Vector.<UIRadioButton>();
      
      protected var mGroup:String;
      
      public function UIRadioButton(facade:Facade, root:MovieClip, group:String)
      {
         super(facade,root);
         mGroup = group;
         mAllRadioButtons.push(this);
      }
      
      protected static function deselectAllInGroup(selectedButton:UIRadioButton) : void
      {
         for each(var _loc2_:UIRadioButton in mAllRadioButtons)
         {
            if(_loc2_ != selectedButton && _loc2_.group == selectedButton.group)
            {
               _loc2_.selected = false;
               _loc2_.enabled = _loc2_.enabled;
            }
         }
      }
      
      override public function destroy() : void
      {
         mAllRadioButtons.splice(mAllRadioButtons.indexOf(this),1);
         super.destroy();
      }
      
      override public function set selected(value:Boolean) : void
      {
         super.selected = value;
         mRoot.buttonMode = !value;
         mRoot.tabEnabled = !value;
         if(mSelected)
         {
            deselectAllInGroup(this);
         }
      }
      
      public function get group() : String
      {
         return mGroup;
      }
      
      public function set group(value:String) : void
      {
         mGroup = value;
      }
      
      override protected function onRelease(event:MouseEvent) : void
      {
         this.selected = true;
         super.onRelease(event);
      }
   }
}

