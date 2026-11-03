package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMMapNode extends GMItem
   {
      
      public static var DUNGEON_NODE_TYPE:String = "DUNGEON";
      
      public static var BOSS_NODE_TYPE:String = "BOSS";
      
      public static var INFINITE_NODE_TYPE:String = "INFINITE";
      
      public static var TAVERN_NODE_TYPE:String = "TAVERN";
      
      public var TrophyRequirement:uint;
      
      public var TierRank:String;
      
      public var StorySwfPath:String;
      
      public var StoryPlayEverytime:Boolean;
      
      public var StoryAssetClass:String;
      
      public var RevealNodes:Array;
      
      public var PremiumKeys:uint;
      
      public var PrefixupParentNode:String;
      
      public var PayEverytime:Boolean;
      
      public var ParentNodes:Array;
      
      public var NodeType:String;
      
      public var NodeIcon:String;
      
      public var MinTreasure:uint;
      
      public var LevelRequirement:uint;
      
      public var IsWeeklyChallenge:Boolean;
      
      public var IsInfiniteDungeon:Boolean;
      
      public var InfiniteDungeon:String;
      
      public var GoalRoomTileset:String;
      
      public var GoalRoom:String;
      
      public var DifficultyName:String;
      
      public var CompletionXPBonus:uint;
      
      public var ColiseumType:uint;
      
      public var ChildNodes:Array;
      
      public var BitIndex:uint;
      
      public var BasicKeys:uint;
      
      public var AlwaysVisible:Boolean;
      
      public function GMMapNode(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            BitIndex = uint(jsonAsset.BitIndex);
            DifficultyName = jsonAsset.DifficultyName;
            ColiseumType = mapColiseumType(jsonAsset.ColiseumType);
            NodeType = jsonAsset.NodeType;
            TierRank = jsonAsset.TierRank;
            InfiniteDungeon = jsonAsset.InfiniteDungeon;
            IsInfiniteDungeon = InfiniteDungeon != null;
            NodeIcon = jsonAsset.NodeIcon;
            GoalRoomTileset = jsonAsset.GoalRoomTileset;
            GoalRoom = jsonAsset.GoalRoom;
            LevelRequirement = uint(jsonAsset.LevelReq);
            TrophyRequirement = uint(jsonAsset.TrophyReq);
            BasicKeys = uint(jsonAsset.BasicKeys);
            PremiumKeys = uint(jsonAsset.PremiumKeys);
            PayEverytime = Boolean(jsonAsset.PayEverytime);
            StorySwfPath = jsonAsset.StoryScene;
            StoryAssetClass = jsonAsset.AssetClassName;
            StoryPlayEverytime = Boolean(jsonAsset.PlayEverytime);
            RevealNodes = [jsonAsset.RevealNode1,jsonAsset.RevealNode2,jsonAsset.RevealNode3,jsonAsset.RevealNode4,jsonAsset.RevealNode5,jsonAsset.RevealNode6,jsonAsset.RevealNode7,jsonAsset.RevealNode8,jsonAsset.RevealNode9,jsonAsset.RevealNode10];
            ChildNodes = [jsonAsset.ChildNode1,jsonAsset.ChildNode2,jsonAsset.ChildNode3];
            PrefixupParentNode = jsonAsset.ParentNode;
            ParentNodes = [];
            IsWeeklyChallenge = Boolean(jsonAsset.IsWeeklyChallenge);
            AlwaysVisible = Boolean(jsonAsset.AlwaysVisible);
            CompletionXPBonus = uint(jsonAsset.CompletionXPBonus);
            MinTreasure = uint(jsonAsset.MinTreasure);
         }
      }
      
      public function mapColiseumType(type:String) : uint
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

