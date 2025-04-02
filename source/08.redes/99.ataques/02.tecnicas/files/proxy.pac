function FindProxyForURL(url, host){
   var port = url.replace(new RegExp("\\w+://[\\.\\w]+(?::(\\d+))?.*"), "$1");
   alert("Puerto: " + port);
   return "DIRECT";
}
