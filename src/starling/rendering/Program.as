package starling.rendering
{
   import com.adobe.utils.AGALMiniAssembler;
   import flash.display3D.Context3D;
   import flash.display3D.Program3D;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import starling.core.Starling;
   import starling.errors.MissingContextError;
   
   public class Program
   {
      
      private static var sAssembler:AGALMiniAssembler = new AGALMiniAssembler();
      
      private var _vertexShader:ByteArray;
      
      private var _fragmentShader:ByteArray;
      
      private var _program3D:Program3D;
      
      public function Program(vertexShader:ByteArray, fragmentShader:ByteArray)
      {
         super();
         _vertexShader = vertexShader;
         _fragmentShader = fragmentShader;
         Starling.current.stage3D.addEventListener("context3DCreate",onContextCreated,false,30,true);
      }
      
      public static function fromSource(vertexShader:String, fragmentShader:String, agalVersion:uint = 1) : Program
      {
         return new Program(sAssembler.assemble("vertex",vertexShader,agalVersion),sAssembler.assemble("fragment",fragmentShader,agalVersion));
      }
      
      public function dispose() : void
      {
         Starling.current.stage3D.removeEventListener("context3DCreate",onContextCreated);
         disposeProgram();
      }
      
      public function activate(context:Context3D = null) : void
      {
         if(context == null)
         {
            context = Starling.context;
            if(context == null)
            {
               throw new MissingContextError();
            }
         }
         if(_program3D == null)
         {
            _program3D = context.createProgram();
            _program3D.upload(_vertexShader,_fragmentShader);
         }
         context.setProgram(_program3D);
      }
      
      private function onContextCreated(event:Event) : void
      {
         disposeProgram();
      }
      
      private function disposeProgram() : void
      {
         if(_program3D)
         {
            _program3D.dispose();
            _program3D = null;
         }
      }
   }
}

