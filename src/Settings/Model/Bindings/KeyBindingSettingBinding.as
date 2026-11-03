package Settings.Model.Bindings
{
   import Facade.DBFacade;
   import Input.KeyBindings.KeyBindings;
   import Settings.Model.KeyBindingValue;
   
   public class KeyBindingSettingBinding implements ISettingBinding
   {
      
      private var mKeyBindings:KeyBindings;
      
      private var mAction:String;
      
      public function KeyBindingSettingBinding(dbFacade:DBFacade, action:String)
      {
         super();
         mKeyBindings = dbFacade.keyBindings;
         mAction = action;
      }
      
      public function read() : *
      {
         return KeyBindingValue.make(mKeyBindings.getPrimary(mAction),mKeyBindings.getAlternate(mAction));
      }
      
      public function write(value:*) : void
      {
         mKeyBindings.setBinding(mAction,KeyBindingValue.primary(value),KeyBindingValue.alternate(value));
      }
      
      public function writeInitial(value:*) : void
      {
         write(value);
      }
      
      public function destroy() : void
      {
         mKeyBindings = null;
      }
   }
}

