package UI.InfiniteIsland
{
   import com.maccherone.json.JSON;
   
   public class II_ChampionsboardTopScore
   {
      
      public var name:String;
      
      public var score:int;
      
      public var skinId:int;
      
      private var mWeaponsJson:Vector.<Object>;
      
      public function II_ChampionsboardTopScore(nameVal:String, scoreVal:int, skinVal:int, weapon1:String, weapon2:String, weapon3:String)
      {
         super();
         name = nameVal;
         score = scoreVal;
         skinId = skinVal;
         mWeaponsJson = new Vector.<Object>();
         if(weapon1 != null)
         {
            mWeaponsJson.push(com.maccherone.json.JSON.decode(weapon1));
         }
         else
         {
            mWeaponsJson.push(null);
         }
         if(weapon1 != null)
         {
            mWeaponsJson.push(com.maccherone.json.JSON.decode(weapon2));
         }
         else
         {
            mWeaponsJson.push(null);
         }
         if(weapon1 != null)
         {
            mWeaponsJson.push(com.maccherone.json.JSON.decode(weapon3));
         }
         else
         {
            mWeaponsJson.push(null);
         }
      }
      
      public function get weaponsJson() : Vector.<Object>
      {
         return mWeaponsJson;
      }
   }
}

