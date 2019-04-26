xquery version "3.1" encoding "UTF-8";

module namespace v="http://kb.dk/this/version";

import module namespace login="http://kb.dk/this/login" at "./login.xqm";
import module namespace rd="http://kb.dk/this/redirect" at "./redirect_host.xqm";

declare function v:version() as xs:string {
    let $log-in := login:function()
    let $version := unparsed-text(concat("http://",rd:host(),"/editor/version.txt"))
    return $version
};
