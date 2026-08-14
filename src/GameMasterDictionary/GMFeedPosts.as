package GameMasterDictionary
{
   public class GMFeedPosts
   {
      
      public var Id:uint;
      
      public var Constant:String;
      
      public var FeedName:String;
      
      public var IdTrigger:uint;
      
      public var LevelTrigger:uint;
      
      public var Category:String;
      
      public var FeedCaption:String;
      
      public var FeedDescriptions:String;
      
      public var FeedActionsName:String;
      
      public var FeedActionsLink:String;
      
      public var FeedActionsReward:String;
      
      public var FeedImageLink:String;
      
      public function GMFeedPosts(jsonAsset:Object)
      {
         super();
         Id = jsonAsset.Id;
         Constant = jsonAsset.Constant;
         FeedName = jsonAsset.FeedName;
         IdTrigger = jsonAsset.IdTrigger;
         Category = jsonAsset.Category;
         FeedCaption = jsonAsset.FeedCaption;
         FeedDescriptions = jsonAsset.FeedDescriptions;
         FeedActionsName = jsonAsset.FeedActionsName;
         FeedActionsLink = jsonAsset.FeedActionsLink;
         FeedActionsReward = jsonAsset.FeedActionsReward;
         FeedImageLink = jsonAsset.FeedImageLink;
         LevelTrigger = jsonAsset.LevelTrigger;
      }
   }
}

