
# MerMEId filter

This filter replaces the legacy one written in java and it does not
try to be a general tool for transforming content upon GET and PUT
http requests.

It still transforms XML content upon 

* Orbeon retrieves XML files to us using [GET](src/read_get.xq)
* [POST](src/update_post.xq) is supported but we don't think Orbeon is using it
* Orbeon sends XML files to us using [PUT](src/update_put.xq) 

but only MEI and only with the transforms 

* [src/xsl]/filter_get.xsl is used by the GET filter
* [src/xsl]/filter_put.xsl is used by the PUT and POST filters
* [src/xsl]/null_transform.xsl is from the legacy filter. We no longer filter things that don't need it
