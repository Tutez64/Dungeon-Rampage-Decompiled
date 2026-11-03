package UI.Hud.StarlingConverted
{
   internal class HudFatalError extends Error
   {
      
      public function HudFatalError(message:String)
      {
         super(message);
         name = "HudFatalError";
      }
   }
}

