package NetworkCode
{
   public interface DcSocketGenerate
   {
      
      function ObjectFactoryOwner(classid:uint, do_id:uint, game_packet:DcNetworkPacket) : void;
      
      function ObjectFactoryVisible(classid:uint, do_id:uint, game_packet:DcNetworkPacket) : void;
   }
}

