import module namespace login="http://kb.dk/this/login" at "./login.xqm";
import module namespace rd="http://kb.dk/this/redirect" at "./redirect_host.xqm";

declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace uuid="java:java.util.UUID";

declare option    exist:serialize "method=xml media-type=text/html"; 

declare variable $dcmroot      := "/db/dcm/";
declare variable $old_name     := request:get-parameter("doc", "");
declare variable $name         := request:get-parameter("name", "");
declare variable $doc_path     := concat("http://",rd:host(),"/storage/dcm/");
declare variable $old_name_abs := concat($doc_path,$old_name);
declare variable $now          := fn:current-dateTime() cast as xs:string;
declare variable $isodate      := concat(substring($now,1,23),"Z");


declare function local:id($element_name) {
    (: generate an ID :)
    let $id := concat($element_name,"_",substring(uuid:to-string(uuid:random-UUID()),1,13))
    return $id
};

declare function local:add_revision($document, $user, $desc) {
    (: add a comment to the revision history :)
    let $change := 
      <change isodate="{$isodate}" xml:id="{local:id('change')}" xmlns="http://www.music-encoding.org/ns/mei">
        <respStmt>
            <resp>{$user}</resp>
        </respStmt>
        <changeDesc xml:id="{local:id('changeDesc')}">
            <p>{$desc}</p>
        </changeDesc>
      </change>            
    let $add := update insert $change into $document/m:meiHead/m:revisionDesc 
    return ""
};

declare function local:replace_target ($target as node(), $new_name) {
    (: update @target value :)
    let $old_name_abs := concat($doc_path,$old_name)
    let $new_name_abs := concat($doc_path,$new_name)
    let $replace :=
        if (starts-with($target,$old_name)) then
           let $upd := update replace $target[string()] with concat($new_name,substring-after($target,$old_name))
           return $upd           
        else 
        if (starts-with($target,$old_name_abs)) then
           let $upd := update replace $target[string()] with concat($doc_path,$new_name,substring-after($target,$old_name))
           return $upd
        else
           ""
    return $replace
};

declare function local:change_targets ($document, $new_name) {
    (: update references (@target) pointing to the renamed file :)
    let $update :=
      for $target in $document/*//@target[contains(.,$old_name)]
        return local:replace_target($target, $new_name) 
    
    (: add a comment to the revision history :)
    let $change := local:add_revision($document, "MerMEId", concat("file reference updated (a file was renamed from ",$old_name," to ",$new_name,")")) 
    return ""

};


let $log-in := login:function()

let $new_name := 
    if (substring($name,string-length($name)-3,4)=".xml") then
        $name
    else
        concat($name,".xml")

let $result:=
  if ($old_name!="" and $name!="") then 
    xdb:rename($dcmroot, $old_name, $new_name)
  else 
    ""

(: update all references to the renamed file :)
let $list   := 
    for $doc in collection($dcmroot)/m:mei[*//@target[starts-with(.,$old_name) or starts-with(.,$old_name_abs)]]
       return local:change_targets($doc,$new_name)

(: add a comment to the revision history :)
let $change := local:add_revision(fn:doc(concat($dcmroot,$new_name))/m:mei, "MerMEId user", concat("file renamed from ",$old_name," to ",$new_name)) 


let $return_to := concat("http://",rd:host(),"/storage/list_files.xq")
let $res := response:redirect-to($return_to cast as xs:anyURI)   

return $change

    