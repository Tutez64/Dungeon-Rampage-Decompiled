package starling.text
{
   import starling.display.MeshBatch;
   import starling.styles.MeshStyle;
   
   public interface ITextCompositor
   {
      
      function fillMeshBatch(meshBatch:MeshBatch, width:Number, height:Number, text:String, format:TextFormat, options:TextOptions = null) : void;
      
      function clearMeshBatch(meshBatch:MeshBatch) : void;
      
      function getDefaultMeshStyle(previousStyle:MeshStyle, format:TextFormat, options:TextOptions) : MeshStyle;
      
      function dispose() : void;
   }
}

