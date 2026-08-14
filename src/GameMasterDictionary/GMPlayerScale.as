package GameMasterDictionary
{
   import org.as3commons.collections.Map;
   
   public class GMPlayerScale
   {
      
      public static var HPBoostByPlayers:Map = new Map();
      
      public var Players:uint;
      
      public var HPBoost:Number;
      
      public function GMPlayerScale(jsonAsset:Object)
      {
         super();
         Players = jsonAsset.Players;
         HPBoost = jsonAsset.HP_BOOST;
         HPBoostByPlayers.add(Players,HPBoost);
      }
   }
}

