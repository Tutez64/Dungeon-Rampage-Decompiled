package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMInfiniteDungeon
   {
      
      public var RewardFloors:Vector.<uint>;
      
      public var Name:String;
      
      public var Id:int;
      
      public var FloorRewardsMap:GMMap;
      
      public var DModFloorStart:Vector.<uint>;
      
      public var Constant:String;
      
      public function GMInfiniteDungeon(json:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         Id = int(json.Id);
         Constant = json.Constant;
         Name = json.Name;
         DModFloorStart = new Vector.<uint>();
         DModFloorStart.push(uint(json.DMod1FloorStart));
         DModFloorStart.push(uint(json.DMod2FloorStart));
         DModFloorStart.push(uint(json.DMod3FloorStart));
         DModFloorStart.push(uint(json.DMod4FloorStart));
         RewardFloors = new Vector.<uint>();
         RewardFloors.push(uint(json.Reward1Floor));
         RewardFloors.push(uint(json.Reward2Floor));
         RewardFloors.push(uint(json.Reward3Floor));
         RewardFloors.push(uint(json.Reward4Floor));
         FloorRewardsMap = new GMMap();
         FloorRewardsMap.add(uint(json.Reward1Floor),json.Reward1);
         FloorRewardsMap.add(uint(json.Reward2Floor),json.Reward2);
         FloorRewardsMap.add(uint(json.Reward3Floor),json.Reward3);
         FloorRewardsMap.add(uint(json.Reward4Floor),json.Reward4);
      }
   }
}

