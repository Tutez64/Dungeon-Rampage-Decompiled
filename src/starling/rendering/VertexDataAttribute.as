package starling.rendering
{
   internal class VertexDataAttribute
   {
      
      private static const FORMAT_SIZES:Object = {
         "bytes4":4,
         "float1":4,
         "float2":8,
         "float3":12,
         "float4":16
      };
      
      public var name:String;
      
      public var format:String;
      
      public var isColor:Boolean;
      
      public var offset:int;
      
      public var size:int;
      
      public function VertexDataAttribute(name:String, format:String, offset:int)
      {
         super();
         if(!(format in FORMAT_SIZES))
         {
            throw new ArgumentError("Invalid attribute format: " + format + ". " + "Use one of the following: \'float1\'-\'float4\', \'bytes4\'");
         }
         this.name = name;
         this.format = format;
         this.offset = offset;
         this.size = FORMAT_SIZES[format];
         this.isColor = name.indexOf("color") != -1 || name.indexOf("Color") != -1;
      }
   }
}

