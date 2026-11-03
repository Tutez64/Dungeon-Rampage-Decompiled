package Brain.AssetRepository
{
   import starling.assets.AssetFactoryHelper;
   import starling.assets.AssetManager;
   import starling.assets.AssetReference;
   import starling.assets.XmlFactory;
   
   public class SafeXmlFactory extends XmlFactory
   {
      
      public static const PRIORITY:int = 1;
      
      public function SafeXmlFactory()
      {
         super();
      }
      
      override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:Function, onError:Function) : void
      {
         super.create(reference,helper,function(param1:String, param2:XML):void
         {
            var textureName:String;
            var name:String = param1;
            var xml:XML = param2;
            if(xml.localName() == "TextureAtlas")
            {
               textureName = helper.getNameFromUrl(xml.@imagePath.toString());
               helper.addPostProcessor(function(param1:AssetManager):void
               {
                  if(param1.getTexture(textureName) == null)
                  {
                     onError("Cannot create atlas: texture \'" + textureName + "\' is missing");
                  }
               },99);
            }
            onComplete(name,xml);
         },onError);
      }
   }
}

