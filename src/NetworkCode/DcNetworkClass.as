package NetworkCode
{
   public class DcNetworkClass
   {
      
      private static var CREATION_ORDER_SEED:uint = 0;
      
      private var the_gamesocket:DcSocket;
      
      public var do_id:uint;
      
      private var mCreationOrder:uint;
      
      public function DcNetworkClass(trash:*, gs:DcSocket, id:uint)
      {
         super();
         do_id = id;
         the_gamesocket = gs;
         mCreationOrder = ++CREATION_ORDER_SEED;
      }
      
      public function get creationOrder() : uint
      {
         return mCreationOrder;
      }
      
      public function recvByIdLoop(packet:DcNetworkPacket) : void
      {
         var _loc4_:* = 0;
         var _loc2_:* = 0;
         var _loc3_:DcNetworkInterface = this as DcNetworkInterface;
         if(!packet.eof())
         {
            _loc4_ = packet.readUnsignedShort();
            while(!packet.eof())
            {
               _loc2_ = packet.readUnsignedShort();
               _loc3_.recvById(packet,_loc2_);
            }
         }
      }
      
      public function Process_SetFieldValue(packet:DcNetworkPacket) : void
      {
         var _loc3_:DcNetworkInterface = this as DcNetworkInterface;
         var _loc2_:uint = packet.readUnsignedShort();
         _loc3_.recvById(packet,_loc2_);
      }
      
      public function Send_packet(packet:DcNetworkPacket) : void
      {
         the_gamesocket.sendpacket(packet);
      }
      
      public function Prepare_FieldUpdate(packet:DcNetworkPacket, field_id:uint) : void
      {
         packet.writeShort(124);
         packet.writeUnsignedInt(do_id);
         packet.writeShort(field_id);
      }
      
      public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
      }
      
      public function generate(packet:DcNetworkPacket) : void
      {
      }
      
      public function destroy() : void
      {
      }
   }
}

