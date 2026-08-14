package GameMasterDictionary
{
   import org.as3commons.collections.Map;
   
   public class GMInfiniteDungeon
   {
      
      public var Id:int;
      
      public var Constant:String;
      
      public var Name:String;
      
      public var DModFloorStart:Vector.<uint>;
      
      public var RewardFloors:Vector.<uint>;
      
      public var FloorRewardsMap:Map;
      
      public function GMInfiniteDungeon(json:Object)
      {
         super();
         Id = json.Id;
         Constant = json.Constant;
         Name = json.Name;
         DModFloorStart = new Vector.<uint>();
         DModFloorStart.push(json.DMod1FloorStart);
         DModFloorStart.push(json.DMod2FloorStart);
         DModFloorStart.push(json.DMod3FloorStart);
         DModFloorStart.push(json.DMod4FloorStart);
         RewardFloors = new Vector.<uint>();
         RewardFloors.push(json.Reward1Floor);
         RewardFloors.push(json.Reward2Floor);
         RewardFloors.push(json.Reward3Floor);
         RewardFloors.push(json.Reward4Floor);
         FloorRewardsMap = new Map();
         FloorRewardsMap.add(json.Reward1Floor,json.Reward1);
         FloorRewardsMap.add(json.Reward2Floor,json.Reward2);
         FloorRewardsMap.add(json.Reward3Floor,json.Reward3);
         FloorRewardsMap.add(json.Reward4Floor,json.Reward4);
      }
   }
}

