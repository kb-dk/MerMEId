xquery version "3.0" encoding "UTF-8";

declare namespace request="http://exist-db.org/xquery/request";

import module namespace config="https://github.com/edirom/mermeid/config" at "config.xqm";

let $content := request:get-data()
return
  config:replace-properties($content)