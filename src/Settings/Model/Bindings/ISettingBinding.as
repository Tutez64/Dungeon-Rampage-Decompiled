package Settings.Model.Bindings
{
   public interface ISettingBinding
   {
      
      function read() : *;
      
      function write(value:*) : void;
      
      function writeInitial(value:*) : void;
      
      function destroy() : void;
   }
}

