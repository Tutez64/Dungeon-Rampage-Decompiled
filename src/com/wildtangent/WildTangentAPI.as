package com.wildtangent
{
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol43")]
   public class WildTangentAPI extends Sprite
   {
      
      public var Ads:com.wildtangent.Ads = new com.wildtangent.Ads();
      
      public var BrandBoost:com.wildtangent.BrandBoost = new com.wildtangent.BrandBoost();
      
      public var Stats:com.wildtangent.Stats = new com.wildtangent.Stats();
      
      public var Vex:com.wildtangent.Vex = new com.wildtangent.Vex();
      
      public var Store:com.wildtangent.Store = new com.wildtangent.Store();
      
      protected var myVex:* = null;
      
      protected var _vexReady:Boolean = false;
      
      private var _dpName:String;
      
      private var _gameName:String;
      
      private var _adServerGameName:String;
      
      private var _partnerName:String;
      
      private var _siteName:String;
      
      private var _userId:String;
      
      private var _cipherKey:String;
      
      private var _vexUrl:String = "http://vex.wildtangent.com";
      
      private var _sandbox:Boolean = false;
      
      private var _javascriptReady:Boolean = false;
      
      private var _adComplete:Function;
      
      private var _closed:Function;
      
      private var _error:Function;
      
      private var _handlePromo:Function;
      
      private var _redeemCode:Function;
      
      private var _requireLogin:Function;
      
      private var _localMode:Boolean = false;
      
      protected var methodStorage:Array = [];
      
      public function WildTangentAPI()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,loadVex);
      }
      
      private function loadVex(param1:Event) : void
      {
         var context:LoaderContext = null;
         var request:URLRequest = null;
         var e:Event = param1;
         var loader:Loader = new Loader();
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadAPI);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadFailure);
         loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
         try
         {
            _localMode = loaderInfo.url.indexOf("file") == 0;
         }
         catch(e:*)
         {
         }
         if(!_localMode)
         {
            context = new LoaderContext();
            context.securityDomain = SecurityDomain.currentDomain;
            request = new URLRequest(_vexUrl + "/swf/VexAPI");
            request.data = new URLVariables("cache=" + new Date().time);
            request.method = URLRequestMethod.POST;
            loader.load(request,context);
         }
         else
         {
            loader.load(new URLRequest("VexAPI.swf"));
         }
      }
      
      private function loadAPI(param1:Event) : void
      {
         var e:Event = param1;
         myVex = e.target.content;
         addChild(myVex);
         if(root.loaderInfo.parameters.canvasSize != null)
         {
            myVex.canvasSize = root.loaderInfo.parameters.canvasSize;
         }
         vexReady = true;
         myVex.loaderParameters = root.loaderInfo.parameters;
         try
         {
            myVex.localMode = _localMode;
         }
         catch(e:*)
         {
         }
         sendExistingParameters();
         initBrandBoost();
         initVex();
         initStats();
         initAds();
         initStore();
         dispatchEvent(e);
      }
      
      private function initBrandBoost() : void
      {
         BrandBoost.myVex = myVex;
         BrandBoost.sendExistingParameters();
         BrandBoost.launchMethods();
      }
      
      private function initVex() : void
      {
         Vex.myVex = myVex;
         Vex.sendExistingParameters();
         Vex.launchMethods();
      }
      
      private function initStats() : void
      {
         Stats.myVex = myVex;
         Stats.sendExistingParameters();
         Stats.launchMethods();
      }
      
      private function initAds() : void
      {
         Ads.myVex = myVex;
         Ads.sendExistingParameters();
         Ads.launchMethods();
      }
      
      private function initStore() : void
      {
         Store.myVex = myVex;
         Store.sendExistingParameters();
         Store.launchMethods();
      }
      
      private function onLoadFailure(param1:IOErrorEvent) : void
      {
         trace("[VEX] failed to load API");
         Ads.vexFailed = true;
         Ads.launchMethods();
         BrandBoost.vexFailed = true;
         BrandBoost.launchMethods();
      }
      
      private function onSecurityError(param1:SecurityErrorEvent) : void
      {
         trace("[VEX] security error trying to load files");
         Ads.vexFailed = true;
         Ads.launchMethods();
         BrandBoost.vexFailed = true;
         BrandBoost.launchMethods();
      }
      
      private function sendExistingParameters() : void
      {
         if(_dpName)
         {
            myVex.dpName = _dpName;
         }
         if(_gameName)
         {
            myVex.gameName = _gameName;
         }
         if(_adServerGameName)
         {
            myVex.adServerGameName = _adServerGameName;
         }
         if(_partnerName)
         {
            myVex.partnerName = _partnerName;
         }
         if(_siteName)
         {
            myVex.siteName = _siteName;
         }
         if(_userId)
         {
            myVex.userId = _userId;
         }
         if(_sandbox)
         {
            myVex.sandbox = _sandbox;
         }
         if(_cipherKey)
         {
            myVex.cipherKey = _cipherKey;
         }
         if(_adComplete != null)
         {
            myVex.adComplete = _adComplete;
         }
         if(_closed != null)
         {
            myVex.closed = _closed;
         }
         if(_error != null)
         {
            myVex.error = _error;
         }
         if(_redeemCode != null)
         {
            myVex.redeemCode = _redeemCode;
         }
      }
      
      private function set vexReady(param1:Boolean) : void
      {
         BrandBoost.vexReady = param1;
         Ads.vexReady = param1;
         Stats.vexReady = param1;
         Vex.vexReady = param1;
         Store.vexReady = param1;
         _vexReady = param1;
      }
      
      private function get vexReady() : Boolean
      {
         return _vexReady;
      }
      
      private function set javascriptReady(param1:Boolean) : void
      {
         if(vexReady)
         {
            myVex.javascriptReady = param1;
         }
         else
         {
            _javascriptReady = param1;
         }
      }
      
      public function get userId() : String
      {
         return vexReady ? myVex.userId : _userId;
      }
      
      public function set userId(param1:String) : void
      {
         if(vexReady)
         {
            myVex.userId = param1;
         }
         else
         {
            _userId = param1;
         }
      }
      
      public function set partnerName(param1:String) : void
      {
         if(vexReady)
         {
            myVex.partnerName = param1;
         }
         else
         {
            _partnerName = param1;
         }
      }
      
      public function get partnerName() : String
      {
         return vexReady ? myVex.partnerName : _partnerName;
      }
      
      public function set siteName(param1:String) : void
      {
         if(vexReady)
         {
            myVex.siteName = param1;
         }
         else
         {
            _siteName = param1;
         }
      }
      
      public function get siteName() : String
      {
         return vexReady ? myVex.siteName : _siteName;
      }
      
      public function set gameName(param1:String) : void
      {
         if(vexReady)
         {
            myVex.gameName = param1;
         }
         else
         {
            _gameName = param1;
         }
      }
      
      public function get gameName() : String
      {
         return vexReady ? myVex.gameName : _gameName;
      }
      
      public function set adServerGameName(param1:String) : void
      {
         if(vexReady)
         {
            myVex.adServerGameName = param1;
         }
         else
         {
            _adServerGameName = param1;
         }
      }
      
      public function set dpName(param1:String) : void
      {
         if(vexReady)
         {
            myVex.dpName = param1;
         }
         else
         {
            _dpName = param1;
         }
      }
      
      public function get dpName() : String
      {
         return vexReady ? myVex.dpName : _dpName;
      }
      
      public function set sandbox(param1:Boolean) : void
      {
         _vexUrl = param1 ? "http://vex.bpi.wildtangent.com" : "http://vex.wildtangent.com";
         _sandbox = param1;
      }
      
      public function get VERSION() : String
      {
         return vexReady ? myVex.VERSION : "Not yet loaded";
      }
   }
}

