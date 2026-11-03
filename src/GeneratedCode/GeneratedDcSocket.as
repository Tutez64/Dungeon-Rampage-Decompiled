package GeneratedCode
{
   import Facade.DBFacade;
   import NetworkCode.DcNetworkPacket;
   import NetworkCode.DcSocket;
   import NetworkCode.DcSocketGenerate;
   
   public class GeneratedDcSocket extends DcSocket implements DcSocketGenerate
   {
      
      public const CLID_Trash:uint = 0;
      
      public const CLID_DistributedDistrict:uint = 19;
      
      public const CLID_ObjectServer:uint = 23;
      
      public const CLID_StatAccumulator:uint = 25;
      
      public const CLID_AreaManager:uint = 26;
      
      public const CLID_DistributedNPCGameObject:uint = 27;
      
      public const CLID_HeroGameObject:uint = 28;
      
      public const CLID_PlayerGameObject:uint = 30;
      
      public const CLID_PresenceManager:uint = 31;
      
      public const CLID_DistributedDungeonFloor:uint = 33;
      
      public const CLID_DistributedTownFloor:uint = 34;
      
      public const CLID_DistributedDungionArea:uint = 37;
      
      public const CLID_DistributedDungeonSummary:uint = 39;
      
      public const CLID_DistributedTownArea:uint = 40;
      
      public const CLID_DistributedDooberGameObject:uint = 41;
      
      public const CLID_DistributedBuffGameObject:uint = 42;
      
      public const CLID_MatchMaker:uint = 43;
      
      public const DcHash:uint = 1832072657;
      
      public function GeneratedDcSocket(facade:DBFacade, host:String, port:int, playtoken:String, demographics:String, account:uint)
      {
         super(facade,host,port,playtoken,demographics,account);
      }
      
      override public function getDcHash() : uint
      {
         return 1832072657;
      }
      
      public function ObjectFactoryOwner(classid:uint, do_id:uint, game_packet:DcNetworkPacket) : void
      {
         switch(int(classid) - 28)
         {
            case 0:
               Doid_NetInterfaces[String(do_id)] = HeroGameObjectOwnerNetworkComponent.ownerFactory(game_packet,this,do_id);
               break;
            case 2:
               Doid_NetInterfaces[String(do_id)] = PlayerGameObjectOwnerNetworkComponent.ownerFactory(game_packet,this,do_id);
         }
      }
      
      public function ObjectFactoryVisible(classid:uint, do_id:uint, game_packet:DcNetworkPacket) : void
      {
         switch(int(classid) - 27)
         {
            case 0:
               Doid_NetInterfaces[String(do_id)] = DistributedNPCGameObjectNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 1:
               Doid_NetInterfaces[String(do_id)] = HeroGameObjectNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 3:
               Doid_NetInterfaces[String(do_id)] = PlayerGameObjectNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 4:
               Doid_NetInterfaces[String(do_id)] = PresenceManagerNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 6:
               Doid_NetInterfaces[String(do_id)] = DistributedDungeonFloorNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 7:
               Doid_NetInterfaces[String(do_id)] = DistributedTownFloorNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 10:
               Doid_NetInterfaces[String(do_id)] = DistributedDungionAreaNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 12:
               Doid_NetInterfaces[String(do_id)] = DistributedDungeonSummaryNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 13:
               Doid_NetInterfaces[String(do_id)] = DistributedTownAreaNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 14:
               Doid_NetInterfaces[String(do_id)] = DistributedDooberGameObjectNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 15:
               Doid_NetInterfaces[String(do_id)] = DistributedBuffGameObjectNetworkComponent.netFactory(game_packet,this,do_id);
               break;
            case 16:
               Doid_NetInterfaces[String(do_id)] = MatchMakerNetworkComponent.netFactory(game_packet,this,do_id);
         }
      }
   }
}

