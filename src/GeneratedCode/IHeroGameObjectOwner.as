package GeneratedCode
{
   public interface IHeroGameObjectOwner
   {
      
      function setOwnerNetworkComponentHeroGameObject(iface:HeroGameObjectOwnerNetworkComponent) : void;
      
      function ReportBuffEffect(byWho:uint, amount:int, buffId:uint, effectiveness:int) : void;
      
      function ReceivedBuffEffect(amount:int, buffId:uint, effectiveness:int) : void;
      
      function TooFullForDoober(isHealthDoober:uint) : void;
      
      function ProposeSelfRevive_Resp(yesno:uint, isParty:uint) : void;
   }
}

