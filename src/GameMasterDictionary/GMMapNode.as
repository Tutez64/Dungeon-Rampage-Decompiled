package GameMasterDictionary
{
   public class GMMapNode extends GMItem
   {
      
      public static const DUNGEON_NODE_TYPE:String = "DUNGEON";
      
      public static const BOSS_NODE_TYPE:String = "BOSS";
      
      public static const INFINITE_NODE_TYPE:String = "INFINITE";
      
      public static const TAVERN_NODE_TYPE:String = "TAVERN";
      
      public var DifficultyName:String;
      
      public var ColiseumType:uint;
      
      public var NodeType:String;
      
      public var TierRank:String;
      
      public var InfiniteDungeon:String;
      
      public var BasicKeys:uint;
      
      public var PremiumKeys:uint;
      
      public var PayEverytime:Boolean;
      
      public var RevealNodes:Array;
      
      public var ChildNodes:Array;
      
      public var ParentNodes:Array;
      
      public var PrefixupParentNode:String;
      
      public var StorySwfPath:String;
      
      public var StoryAssetClass:String;
      
      public var StoryPlayEverytime:Boolean;
      
      public var NodeIcon:String;
      
      public var GoalRoomTileset:String;
      
      public var GoalRoom:String;
      
      public var LevelRequirement:uint;
      
      public var TrophyRequirement:uint;
      
      public var CompletionXPBonus:uint;
      
      public var IsWeeklyChallenge:Boolean;
      
      public var AlwaysVisible:Boolean;
      
      public var MinTreasure:uint;
      
      public var BitIndex:uint;
      
      public var IsInfiniteDungeon:Boolean;
      
      public function GMMapNode(jsonAsset:Object)
      {
         super(jsonAsset);
         BitIndex = jsonAsset.BitIndex;
         DifficultyName = jsonAsset.DifficultyName;
         ColiseumType = mapColiseumType(jsonAsset.ColiseumType);
         NodeType = jsonAsset.NodeType;
         TierRank = jsonAsset.TierRank;
         InfiniteDungeon = jsonAsset.InfiniteDungeon;
         IsInfiniteDungeon = InfiniteDungeon != null;
         NodeIcon = jsonAsset.NodeIcon;
         GoalRoomTileset = jsonAsset.GoalRoomTileset;
         GoalRoom = jsonAsset.GoalRoom;
         LevelRequirement = jsonAsset.LevelReq;
         TrophyRequirement = jsonAsset.TrophyReq;
         BasicKeys = jsonAsset.BasicKeys;
         PremiumKeys = jsonAsset.PremiumKeys;
         PayEverytime = jsonAsset.PayEverytime;
         StorySwfPath = jsonAsset.StoryScene;
         StoryAssetClass = jsonAsset.AssetClassName;
         StoryPlayEverytime = jsonAsset.PlayEverytime;
         RevealNodes = [jsonAsset.RevealNode1,jsonAsset.RevealNode2,jsonAsset.RevealNode3,jsonAsset.RevealNode4,jsonAsset.RevealNode5,jsonAsset.RevealNode6,jsonAsset.RevealNode7,jsonAsset.RevealNode8,jsonAsset.RevealNode9,jsonAsset.RevealNode10];
         ChildNodes = [jsonAsset.ChildNode1,jsonAsset.ChildNode2,jsonAsset.ChildNode3];
         PrefixupParentNode = jsonAsset.ParentNode;
         ParentNodes = [];
         IsWeeklyChallenge = jsonAsset.IsWeeklyChallenge;
         AlwaysVisible = jsonAsset.AlwaysVisible;
         CompletionXPBonus = jsonAsset.CompletionXPBonus;
         MinTreasure = jsonAsset.MinTreasure;
      }
      
      private function mapColiseumType(type:String) : uint
      {
         if(type == "DINO_JUNGLE")
         {
            return 2;
         }
         if(type == "ICE_CAVES")
         {
            return 3;
         }
         if(type == "SKY_PAGODA")
         {
            return 4;
         }
         return 1;
      }
   }
}

