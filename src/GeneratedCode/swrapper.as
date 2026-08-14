package GeneratedCode
{
   import NetworkCode.DcNetworkPacket;
   
   public class swrapper
   {
      
      public var fileName:String;
      
      public function swrapper()
      {
         super();
      }
      
      public static function readFromPacket(packet:DcNetworkPacket) : swrapper
      {
         var _loc2_:swrapper = new swrapper();
         _loc2_.fileName = packet.readUTF();
         return _loc2_;
      }
      
      public function writeToPacket(outpacket:DcNetworkPacket) : void
      {
         outpacket.writeUTF(fileName);
      }
   }
}

