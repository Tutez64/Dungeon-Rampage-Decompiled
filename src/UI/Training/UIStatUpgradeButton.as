package UI.Training
{
   import Brain.Facade.Facade;
   import Brain.UI.UIButton;
   import DBGlobals.DBGlobal;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class UIStatUpgradeButton extends UIButton
   {
      
      private var mUpgradeEnabled:Boolean = true;
      
      public function UIStatUpgradeButton(facade:Facade, root:MovieClip)
      {
         super(facade,root);
      }
      
      public function get upgradeEnabled() : Boolean
      {
         return mUpgradeEnabled;
      }
      
      override public function canBeFocused() : Boolean
      {
         return visible;
      }
      
      public function set upgradeEnabled(value:Boolean) : void
      {
         mUpgradeEnabled = value;
         mRoot.buttonMode = value;
         refreshVisualState();
         if(value && (mIsHovered || mIsFocused))
         {
            DBGlobal.highlightButton(this);
         }
         else if(!value)
         {
            DBGlobal.unHighlightButton(this);
         }
      }
      
      override protected function refreshVisualState() : void
      {
         if(!mRoot)
         {
            return;
         }
         if(!mUpgradeEnabled)
         {
            showState(3);
            return;
         }
         super.refreshVisualState();
      }
      
      override protected function onPress(event:MouseEvent) : void
      {
         if(!mUpgradeEnabled)
         {
            event.stopImmediatePropagation();
            return;
         }
         super.onPress(event);
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         super.onRollOver(event);
         if(mUpgradeEnabled)
         {
            DBGlobal.highlightButton(this);
         }
      }
      
      override protected function onRollOut(event:MouseEvent) : void
      {
         super.onRollOut(event);
         DBGlobal.unHighlightButton(this);
      }
      
      override protected function onKey(event:KeyboardEvent) : void
      {
         if(!mUpgradeEnabled)
         {
            event.stopImmediatePropagation();
            return;
         }
         super.onKey(event);
      }
      
      override public function click() : void
      {
         if(mUpgradeEnabled)
         {
            super.click();
         }
      }
      
      override public function onSelected(fromController:Boolean = false) : void
      {
         if(mUpgradeEnabled)
         {
            super.onSelected(fromController);
         }
      }
   }
}

