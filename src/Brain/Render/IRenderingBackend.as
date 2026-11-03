package Brain.Render
{
   public interface IRenderingBackend
   {
      
      function get backendType() : String;
      
      function get isReady() : Boolean;
      
      function addChildToLayer(displayObject:Object, layerIndex:int) : void;
      
      function removeChild(displayObject:Object) : void;
      
      function clearLayer(layerIndex:int) : void;
      
      function destroy() : void;
   }
}

