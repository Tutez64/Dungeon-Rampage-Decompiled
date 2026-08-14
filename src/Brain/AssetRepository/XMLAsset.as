package Brain.AssetRepository
{
   public class XMLAsset extends Asset
   {
      
      protected var mXML:XML;
      
      public function XMLAsset(xml:XML)
      {
         super();
         mXML = xml;
      }
      
      public function get xml() : XML
      {
         return mXML;
      }
      
      override public function destroy() : void
      {
         mXML = null;
         super.destroy();
      }
   }
}

