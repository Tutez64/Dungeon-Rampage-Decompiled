package SteamInput
{
   public class SteamInputAction
   {
      
      public var actionName:String;
      
      public var actionHandle:String;
      
      public function SteamInputAction(inActionName:String, inActionHandle:String)
      {
         super();
         actionName = inActionName;
         actionHandle = inActionHandle;
      }
   }
}

