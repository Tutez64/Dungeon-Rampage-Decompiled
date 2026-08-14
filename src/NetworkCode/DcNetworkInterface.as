package NetworkCode
{
   public interface DcNetworkInterface
   {
      
      function recvById(packet:DcNetworkPacket, fieldid:uint) : void;
      
      function generate(packet:DcNetworkPacket) : void;
      
      function destroy() : void;
   }
}

