package NetworkCode
{
   public interface DcSocketGenerate
   {
      
      function ObjectFactoryOwner(classId:uint, do_id:uint, game_packet:DcNetworkPacket) : void;
      
      function ObjectFactoryVisible(classId:uint, do_id:uint, game_packet:DcNetworkPacket) : void;
   }
}

