package NetworkCode.Transport
{
   import Brain.Logger.Logger;
   
   public final class ConnectDiagnostics
   {
      
      private static const MAX_TEXT:int = 160;
      
      private static const STALL_MIN_MS:int = 4000;
      
      public function ConnectDiagnostics()
      {
         super();
         throw new Error("ConnectDiagnostics is a set of functions, not a thing to build.");
      }
      
      public static function summarize(attempts:Array) : String
      {
         var _loc4_:int = 0;
         var _loc2_:int = int(attempts?.length);
         var _loc3_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_.push(describeAttempt(attempts[_loc4_]));
            _loc4_++;
         }
         return "no transport connected after " + _loc2_ + " attempt(s): " + _loc3_.join("; ");
      }
      
      public static function describeAttempt(attempt:Object) : String
      {
         var _loc2_:String = attempt.name + " " + int(attempt.elapsedMs) + "ms ";
         _loc2_ += attempt.closed ? "closed " + attempt.code : String(attempt.code);
         var _loc4_:String = TransportFailureText.tidy(attempt.text,160);
         if(_loc4_ != "")
         {
            _loc2_ += " " + _loc4_;
         }
         var _loc3_:String = describeCertificate(attempt.cert);
         if(_loc3_ != "")
         {
            _loc2_ += " " + _loc3_;
         }
         var _loc5_:String = TransportFailureText.tidy(attempt.certDetail,160);
         if(_loc5_ != "")
         {
            _loc2_ += " [" + _loc5_ + "]";
         }
         return _loc2_;
      }
      
      public static function describeCertificate(status:String) : String
      {
         if(status == null || status == "")
         {
            return "";
         }
         if(status == "invalid")
         {
            return "cert=invalid (no certificate)";
         }
         if(status == "unknown")
         {
            return "cert=unknown (not validated)";
         }
         return "cert=" + status + " (certificate received)";
      }
      
      public static function looksLikeStall(attempts:Array) : Boolean
      {
         var _loc2_:Boolean = false;
         for each(var _loc3_:Object in attempts)
         {
            if(_loc3_.closed || _loc3_.code != 602 || int(_loc3_.elapsedMs) < 4000 || _loc3_.cert != "" && _loc3_.cert != "invalid")
            {
               return false;
            }
            if(_loc3_.cert == "invalid")
            {
               _loc2_ = true;
            }
         }
         return _loc2_;
      }
      
      public static function isIpLiteral(host:String) : Boolean
      {
         if(host == null || host == "")
         {
            return false;
         }
         if(host.indexOf(":") >= 0)
         {
            return true;
         }
         return /^\d{1,3}(\.\d{1,3}){3}$/.test(host);
      }
      
      public static function run(attempts:Array, endpoints:GameEndpoints, webServicesUrl:String) : void
      {
         Logger.warnch("WS",summarize(attempts));
         if(endpoints == null || endpoints.address == null || endpoints.address == "")
         {
            return;
         }
         new HttpsProbe("healthz","https://" + endpoints.authority + "/healthz");
         if(webServicesUrl != null && webServicesUrl != "")
         {
            new HttpsProbe("game-status",webServicesUrl + "/game-status");
         }
         if(isIpLiteral(endpoints.address))
         {
            Logger.infoch("WS","dns " + endpoints.address + " skipped (IP literal)");
         }
         else
         {
            new DnsLookup(endpoints.address);
         }
      }
   }
}

import Brain.Logger.Logger;
import NetworkCode.Transport.TransportSettings;
import flash.events.DNSResolverEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.dns.AAAARecord;
import flash.net.dns.ARecord;
import flash.net.dns.DNSResolver;
import flash.net.dns.ResourceRecord;
import flash.utils.getTimer;

class HttpsProbe
{
   
   private var mLabel:String;
   
   private var mUrl:String;
   
   private var mStartedAt:int;
   
   private var mStatus:int = 0;
   
   private var mAnsweredBy:String = "";
   
   private var mLoader:URLLoader;
   
   private var mReported:Boolean;
   
   public function HttpsProbe(label:String, url:String)
   {
      var _loc3_:URLRequest = null;
      super();
      mStartedAt = getTimer();
      mLabel = label;
      mUrl = url;
      try
      {
         _loc3_ = new URLRequest(url);
         _loc3_.method = "GET";
         _loc3_.useCache = false;
         _loc3_.cacheResponse = false;
         _loc3_.idleTimeout = TransportSettings.connectTimeoutMilliseconds;
         mLoader = new URLLoader();
         mLoader.addEventListener("httpResponseStatus",onResponseStatus);
         mLoader.addEventListener("complete",onComplete);
         mLoader.addEventListener("ioError",onError);
         mLoader.addEventListener("securityError",onError);
         mLoader.load(_loc3_);
      }
      catch(error:Error)
      {
         report("could not start: " + error.message);
      }
   }
   
   private function onResponseStatus(event:HTTPStatusEvent) : void
   {
      var _loc2_:String = null;
      mStatus = event.status;
      try
      {
         for each(var _loc3_:URLRequestHeader in event.responseHeaders)
         {
            _loc2_ = _loc3_.name.toLowerCase();
            if(_loc2_ == "server" || _loc2_ == "via")
            {
               mAnsweredBy += " " + _loc2_ + "=" + _loc3_.value;
            }
         }
      }
      catch(error:Error)
      {
      }
   }
   
   private function onComplete(event:Event) : void
   {
      report(String(mStatus) + mAnsweredBy);
   }
   
   private function onError(event:ErrorEvent) : void
   {
      report((mStatus != 0 ? mStatus + " " : "") + event.type + ": " + event.text + mAnsweredBy);
   }
   
   private function report(outcome:String) : void
   {
      if(mReported)
      {
         return;
      }
      mReported = true;
      Logger.warnch("WS","probe " + mLabel + " " + mUrl + " -> " + outcome + " in " + (getTimer() - mStartedAt) + "ms");
      if(mLoader != null)
      {
         mLoader.removeEventListener("httpResponseStatus",onResponseStatus);
         mLoader.removeEventListener("complete",onComplete);
         mLoader.removeEventListener("ioError",onError);
         mLoader.removeEventListener("securityError",onError);
         mLoader = null;
      }
   }
}

class DnsLookup
{
   
   private static const MAX_ADDRESSES:int = 4;
   
   private var mHost:String;
   
   private var mA:String;
   
   private var mAAAA:String;
   
   private var mStartedAt:int;
   
   private var mResolvers:Array = [];
   
   private var mReported:Boolean;
   
   public function DnsLookup(host:String)
   {
      super();
      mHost = host;
      mStartedAt = getTimer();
      if(!DNSResolver.isSupported)
      {
         Logger.warnch("WS","dns " + host + " skipped (DNSResolver unsupported)");
         return;
      }
      lookup(ARecord,"A");
      lookup(AAAARecord,"AAAA");
   }
   
   private function lookup(recordType:Class, label:String) : void
   {
      var resolver:DNSResolver;
      try
      {
         resolver = new DNSResolver();
         resolver.addEventListener("lookup",function(param1:DNSResolverEvent):void
         {
            var _loc2_:Array = [];
            for each(var _loc4_:ResourceRecord in param1.resourceRecords)
            {
               _loc2_.push("address" in _loc4_ ? _loc4_["address"] : _loc4_.name);
            }
            var _loc3_:String = _loc2_.slice(0,4).join(",");
            if(_loc2_.length > 4)
            {
               _loc3_ += ",+" + (_loc2_.length - 4);
            }
            answer(label,_loc2_.length == 0 ? "none" : _loc3_);
         });
         resolver.addEventListener("error",function(param1:ErrorEvent):void
         {
            answer(label,"error(" + param1.text + ")");
         });
         mResolvers.push(resolver);
         resolver.lookup(mHost,recordType);
      }
      catch(error:Error)
      {
         answer(label,"error(" + error.message + ")");
      }
   }
   
   private function answer(label:String, value:String) : void
   {
      if(mReported)
      {
         return;
      }
      if(label == "A" && mA == null)
      {
         mA = value;
      }
      else if(label == "AAAA" && mAAAA == null)
      {
         mAAAA = value;
      }
      if(mA == null || mAAAA == null)
      {
         return;
      }
      mReported = true;
      Logger.warnch("WS","dns " + mHost + " A=" + mA + " AAAA=" + mAAAA + " in " + (getTimer() - mStartedAt) + "ms");
      mResolvers = [];
   }
}

const CHANNEL:String = "WS";
