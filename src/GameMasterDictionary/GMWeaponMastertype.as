package GameMasterDictionary
{
   public class GMWeaponMastertype
   {
      
      public var Id:uint;
      
      public var Constant:String;
      
      public var Name:String;
      
      public var Icon:String;
      
      public var UISwfFilepath:String;
      
      public var Description:String;
      
      public var DontShowInTavern:Boolean;
      
      public function GMWeaponMastertype(jsonAsset:Object)
      {
         super();
         Id = jsonAsset.Id;
         Constant = jsonAsset.Constant;
         Name = jsonAsset.Name;
         Icon = jsonAsset.Icon;
         UISwfFilepath = jsonAsset.UISwfFilepath;
         Description = jsonAsset.Description;
         DontShowInTavern = jsonAsset.DontShowInTavern ?? false;
      }
   }
}

