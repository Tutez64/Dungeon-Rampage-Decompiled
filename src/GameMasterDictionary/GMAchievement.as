package GameMasterDictionary
{
   public class GMAchievement
   {
      
      public var Id:String;
      
      public var Name:String;
      
      public var Descriptions:String;
      
      public var ImageLink:String;
      
      public var Points:uint;
      
      public function GMAchievement(jsonAsset:Object)
      {
         super();
         Id = jsonAsset.Id;
         Name = jsonAsset.Name;
         Descriptions = jsonAsset.Descriptions;
         ImageLink = jsonAsset.ImageLink;
         Points = jsonAsset.Points;
      }
   }
}

