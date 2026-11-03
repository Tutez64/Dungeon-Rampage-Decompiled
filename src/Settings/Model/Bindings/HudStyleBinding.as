package Settings.Model.Bindings
{
   import Brain.Event.EventComponent;
   import Events.UIHudChangeEvent;
   import Facade.DBFacade;
   
   public class HudStyleBinding implements ISettingBinding
   {
      
      private var mEventComponent:EventComponent;
      
      private var mCurrent:uint;
      
      public function HudStyleBinding(dbFacade:DBFacade)
      {
         super();
         mEventComponent = new EventComponent(dbFacade);
         mCurrent = 0;
      }
      
      public function read() : *
      {
         return mCurrent;
      }
      
      public function write(value:*) : void
      {
         mCurrent = value;
         mEventComponent.dispatchEvent(new UIHudChangeEvent(mCurrent));
      }
      
      public function writeInitial(value:*) : void
      {
         mCurrent = value;
      }
      
      public function destroy() : void
      {
         if(mEventComponent)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
      }
   }
}

