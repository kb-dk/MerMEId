xquery version "1.0" encoding "UTF-8";

module  namespace  layout="http://kb.dk/this/app/layout";


declare function layout:head($title as xs:string) as node() {
  let $head :=
  <head>
    <title>{$title}</title>
      
    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
      
    <link type="text/css" href="/editor/style/dcm.css" rel="stylesheet" />
    <link type="text/css" href="/editor/style/cnw.css" rel="stylesheet" />

    <link 
       rel="styleSheet" 
       href="/editor/style/public_list_style.css" 
       type="text/css"/>

    <link href="/editor/jquery/jquery-ui-1.10.3/css/base/jquery-ui.css" 
       rel="stylesheet" 
       type="text/css"/>

    <link href="/editor/jquery/jquery-ui-1.10.3/css/style.css" 
       rel="stylesheet"  
       type="text/css"/>
      
    <script type="text/javascript" src="/editor/js/confirm.js">
      //
    </script>
      
    <script type="text/javascript" src="/editor/js/checkbox.js">
      //
    </script>
      
    <script type="text/javascript" src="/editor/js/publishing.js">
      //
    </script>

    <script type="text/javascript" src="/editor/jquery/jquery-ui-1.10.3/js/jquery-1.9.1.js">
      //
    </script>

    <script type="text/javascript" src="/editor/jquery/jquery-ui-1.10.3/js/jquery-ui-1.10.3.custom.js">
      //
    </script>
    <script type="text/javascript" src="/editor/jquery/jquery-ui-1.10.3/slider.js">
      //
    </script>

  </head>

  return $head

};

declare function layout:page-head(
                        $title as xs:string,
			$subtitle as xs:string) as node()
{
  let $header :=
  <div id="header">
    <div class="kb_logo">
      <a href="http://www.kb.dk" title="Det Kongelige Bibliotek"><img
         id="KBLogo"
	 title="Det Kongelige Bibliotek" 
	 alt="KB Logo" src="/editor/images/kb_white.png"/><img
	 id="KBLogo_print"
	 title="Det Kongelige Bibliotek" 
	 alt="KB Logo" src="/editor/images/kb.png"/></a>
    </div>
    <h1>{$title}</h1>
    <h2>{$subtitle}</h2>
  </div>

  return $header

};

declare function layout:page-menu($mode as xs:string) as node()
{
  let $menu := 
  <div id="menu">
    { 
    let $browse:= if ($mode="") then "selected" else ""
    return (<a href="navigation.xq" class="{$browse}">Browse catalogue</a>)
    }
    { 
    let $alpha:= if ($mode="alpha") then "selected" else ""
    return (<a href="navigation.xq?itemsPerPage=9999&amp;c=CNW&amp;sortby=null%2Ctitle&amp;mode=alpha" 
      class="{$alpha}">Alphabetic list</a>)
    }
    { 
    let $sys:= if ($mode="sys") then "selected" else ""
    return (<a href="navigation.xq?itemsPerPage=9999&amp;c=CNW&amp;sortby=work_number%2Ctitle&amp;mode=sys" 
      class="{$sys}">Systematic list</a>)
    }

    <a href="example-page.xq">About CNW</a> 
  </div> 

  return $menu

};


declare function layout:page-footer($mode as xs:string) as node()
{
  let $footer :=
  <div id="footer">
    <a href="http://www.kb.dk/dcm" title="DCM" 
    style="text-decoration:none;"><img 
    style="border: 0px; vertical-align:middle;" 
    alt="DCM Logo" 
    src="/editor/images/dcm_logo_small_white.png"
    id="dcm_logo"/><img 
    style="border: 0px; vertical-align:middle;" 
    alt="DCM Logo" 
    src="/editor/images/dcm_logo_small.png"
    id="dcm_logo_print"
    /></a>
    2013 Danish Centre for Music Publication | The Royal Library, Copenhagen | <a name="www.kb.dk" id="www.kb.dk" href="http://www.kb.dk/dcm">www.kb.dk/dcm</a>
  </div> 

  return $footer

};

