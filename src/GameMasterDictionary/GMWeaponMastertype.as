package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMWeaponMastertype
   {
      
      public var UISwfFilepath:String;
      
      public var Name:String;
      
      public var Id:uint;
      
      public var Icon:String;
      
      public var DontShowInTavern:Boolean;
      
      public var Description:String;
      
      public var Constant:String;
      
      public function GMWeaponMastertype(jsonAsset:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         Id = uint(jsonAsset.Id);
         Constant = jsonAsset.Constant;
         Name = jsonAsset.Name;
         Icon = jsonAsset.Icon;
         UISwfFilepath = jsonAsset.UISwfFilepath;
         Description = jsonAsset.Description;
         DontShowInTavern = jsonAsset.DontShowInTavern != null && Boolean(jsonAsset.DontShowInTavern);
      }
   }
}

