package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMAura extends GMItem
   {
      
      public var HostileBuffGiven:String;
      
      public var FriendlyBuffGiven:String;
      
      public var Duration:Number;
      
      public var DrainsMana:Number;
      
      public var Description:String;
      
      public var AuraEffect:String;
      
      public var AreaRadius:Number;
      
      public function GMAura(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            AuraEffect = jsonAsset.AuraEffect;
            Description = jsonAsset.Description;
         }
      }
   }
}

