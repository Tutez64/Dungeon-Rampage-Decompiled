package Town
{
   public interface ITownAdProvider
   {
      
      function CheckForAds(callback:Function) : void;
      
      function ShowingAdButton() : void;
      
      function ShowAdPlayer() : void;
      
      function SetResetCallback(callback:Function) : void;
   }
}

