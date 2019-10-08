xquery version "1.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";
import module namespace sm="http://exist-db.org/xquery/securitymanager";
import module namespace config="https://github.com/edirom/mermeid/config" at "modules/config.xqm";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

declare function local:set-options() as xs:string* {
    for $opt in available-environment-variables()[starts-with(., 'MERMEID_')]
    return
        config:set-property(substring($opt, 9), string(environment-variable($opt)))
};

(: set options passed as environment variables :)
local:set-options()
