xquery version "3.1";

declare namespace exist="http://exist.sourceforge.net/NS/exist";

import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace config="https://github.com/edirom/mermeid/config" at "config.xqm";

import module namespace console="http://exist-db.org/xquery/console";

declare option exist:serialize "method=xml media-type=application/xml";

let $inputDoc := (doc(request:get-attribute('transform.doc')), request:get-data())[1]

return transform:transform($inputDoc, doc(request:get-attribute('transform.stylesheet')), <parameters>
                <param name="xslt.resources-endpoint" value="{config:get-property('exist_endpoint')}/resources"/>
                <param name="xslt.exist-endpoint-seen-from-orbeon" value="{$config:exist-endpoint-seen-from-orbeon}"/>
                <param name="xslt.orbeon-endpoint" value="{$config:orbeon-endpoint}"/>
                <param name="xslt.server-name" value="{config:get-property('exist_endpoint')}"/>
                <param name="xslt.exist-dir" value="/"/>
                <param name="xslt.document-root" value="/data/"/>
</parameters>, <attributes></attributes>, "method=xml media-type=application/xml")