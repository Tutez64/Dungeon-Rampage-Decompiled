package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMPlayerScale
   {
      
      public static var HPBoostByPlayers:GMMap = new GMMap();
      
      public var Players:uint;
      
      public var HPBoost:Number;
      
      public function GMPlayerScale(jsonAsset:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         Players = uint(jsonAsset.Players);
         HPBoost = Number(jsonAsset.HP_BOOST);
         GMPlayerScale.HPBoostByPlayers.add(Players,HPBoost);
      }
   }
}

