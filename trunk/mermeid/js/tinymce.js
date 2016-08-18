// adding custom buttons to tinymce.
// to activate, add 'musicalsymbols' to 'plugins' and 'theme_advanced_buttons1' below.

var meiElementName = "";
var meiAtts = {};
var defaultMeiAtts = {};

tinymce.PluginManager.add('musicalsymbols', function(editor, url) {
    function showDialog() {            
       	// for testing 
        //editor.focus();
        //editor.selection.setContent('Hello world! ');
        var MusSymWin = window.open("/../editor/js/musicalsymbols.html", "", "width=580, height=260");
    }

	editor.addCommand('mceShowMusSymb', showDialog);

	editor.addButton('musicalsymbols', {
		title       : 'Musical symbols',
        image       : '/../editor/images/warning.png',
		cmd: 'mceShowMusSymb'
	});

});


// Plugins and buttons for adding MEI elements encoded as HTML span elements
// to activate, add 'persName' to 'plugins' and 'theme_advanced_buttons1' below.
tinymce.PluginManager.add('meiElement', function(editor) {

	function editMeiAttributes() {
        var selection = editor.selection, dom = editor.dom, selectedElm, anchorElm;
        selectedElm = selection.getNode();
      	anchorElm = dom.getParent(selectedElm, 'span[title]');

        if (anchorElm) {

            // Element already exists. Check if the existing markup represents a different MEI element 
            titleAttr = dom.getAttrib(anchorElm,"title");
            existingMei = titleAttr.slice(titleAttr.indexOf('mei:')+4,titleAttr.length);
            
            if (existingMei != meiElementName) {
                alert("This text is already marked up as MEI <" + existingMei + ">. It cannot be marked up as MEI <" + meiElementName + "> also.");
                return false;
            } else {
                // OK. Read the class attribute and decode the MEI attributes 
        		// Assumed a string like mei:atts[role(arranger),auth(VIAF),authURI(http://www.viaf.org),dbkey(123)]
        		classAttr = dom.getAttrib(anchorElm,"class");
        		valStr = classAttr.slice(classAttr.indexOf("[")+1, classAttr.indexOf("]"));
        		attrArray = valStr.split(",");
        		for (i in attrArray) {
        		  meiAtts[attrArray[i].slice(0,attrArray[i].indexOf("("))] = attrArray[i].slice(attrArray[i].indexOf("(")+1,attrArray[i].indexOf(")"));
        		}
            }

    	} else {
    	   //default attributes and values
            meiAtts = defaultMeiAtts;
        }
        
        if (!anchorElm && selection.getContent() == '') {
            alert('Nothing selected. To mark up text, select the text and click the desired MEI markup button');
            return false;
        }

        var count = 0;
        for (var key in meiAtts) {
            count++;
        }
        var popupHeight = 25*count + 50;
        tinyMCE.activeEditor.windowManager.open({
            url : '/../editor/js/set_mei_attributes.html',
            width : 450,
            height : popupHeight,
            title: 'Set &lt;' + meiElementName + '&gt; attribute values',
            inline: 1
        }, {
            newElm: !anchorElm  
        });
            
    }

    function insertMeiElement(){
        
        var data = {}, selection = editor.selection, dom = editor.dom, selectedElm, anchorElm, initialText;
     
		function isOnlyTextSelected(anchorElm) {
			var html = selection.getContent();

			// Partial html and not a fully selected anchor element
			if (/</.test(html) && (!/^<span [^>]+>[^<]+<\/span>$/.test(html) || html.indexOf('title=') == -1)) {
				return false;
			}

			if (anchorElm) {
				var nodes = anchorElm.childNodes, i;
				if (nodes.length === 0) {
					return false;
				}
				for (i = nodes.length - 1; i >= 0; i--) {
					if (nodes[i].nodeType != 3) {
						return false;
					}
				}
			}
			return true;
		}

      	selectedElm = selection.getNode();
      	anchorElm = dom.getParent(selectedElm, 'span[title]');
      	onlyText = isOnlyTextSelected();

        var attList = "";
        for (var key in meiAtts) {
            value = meiAtts[key];
            attList += key + '(' + value + '),';
        }
        attList = attList.substr(0,attList.length-1);
        
        bgColors = { persName: '#dfd', geogName: '#ddf', corpName: '#fcf4a0', title: '#fcf'};
        bgColor = bgColors[meiElementName] ? bgColors[meiElementName] : '#ddd';

        var atts = {
    		class: "mei:atts[" + attList + "]",
    		title: "mei:" + meiElementName,
    		style: "background-color:" + bgColor
    	};


    	if (anchorElm) {
    		editor.focus();

    		if (onlyText && data.text != initialText) {
    			if ("innerText" in anchorElm) {
    				anchorElm.innerText = data.text;
    			} else {
    				anchorElm.textContent = data.text;
    			}
    		}
    		dom.setAttribs(anchorElm, atts);
    		selection.select(anchorElm);
    		editor.undoManager.add();
    	} else {
    		if (onlyText) {
                // insert the value
    			editor.selection.setContent(dom.createHTML('span', atts, dom.encode(selection.getContent())));
    		} else {			
    			alert('MEI semantic markup may not contain other markup at this point');
    		}
    	}

    } //end callback function

    function removeMeiElement(){
    
        var selection = editor.selection, dom = editor.dom, selectedElm, anchorElm;

      	selectedElm = selection.getNode();
      	anchorElm = dom.getParent(selectedElm, 'span[title]');

    	if (anchorElm) {
    		editor.focus();
    		editor.dom.remove(anchorElm, true);
    		editor.undoManager.add();
    	} 
    	
    } //end remove function

    editor.addCommand('mceInsertMeiElement', insertMeiElement);
    editor.addCommand('mceRemoveMeiElement', removeMeiElement);
    editor.addCommand('mceEditMeiAttributes', editMeiAttributes);    

});

// Add a plugin and a button for each MEI element

tinymce.PluginManager.add('persName', function(editor) {
                
    function insertPersName() {
        var selection = editor.selection, dom = editor.dom, selectedElm, anchorElm;
        meiElementName = 'persName';
        defaultMeiAtts = {role: "", auth: "VIAF", authURI: "http://www.viaf.org", dbkey: ""};
        editor.execCommand('mceEditMeiAttributes', false);
    }

	editor.addCommand('mceInsertPersName', insertPersName);

	editor.addButton('persName', {
        image: '/../editor/images/mei_person.png',
		tooltip: 'Person name',
		title: 'Person name (MEI <persName>)',
		onclick: insertPersName,
		stateSelector: 'span[title]'
	});

});

tinymce.PluginManager.add('geogName', function(editor) {
                
    function insertGeogName() {
        var selection = editor.selection, dom = editor.dom, selectedElm, anchorElm;
        meiElementName = 'geogName';
        defaultMeiAtts = {role: "", auth: "VIAF", authURI: "http://www.viaf.org", dbkey: ""};
        editor.execCommand('mceEditMeiAttributes', false);
    }

	editor.addCommand('mceInsertGeogName', insertGeogName);

	editor.addButton('geogName', {
        image: '/../editor/images/mei_geographical.png',
		tooltip: 'Geographical name',
		title: 'Geographical name (MEI <geogName>)',
		onclick: insertGeogName,
		stateSelector: 'span[title]'
	});

});


tinymce.PluginManager.add('corpName', function(editor) {
                
    function insertCorpName() {
        var selection = editor.selection, dom = editor.dom, selectedElm, anchorElm;
        meiElementName = 'corpName';
        defaultMeiAtts = {role: "", auth: "VIAF", authURI: "http://www.viaf.org", dbkey: ""};
        editor.execCommand('mceEditMeiAttributes', false);
    }

	editor.addCommand('mceInsertCorpName', insertCorpName);

	editor.addButton('corpName', {
        image: '/../editor/images/mei_corporate.png',
		tooltip: 'Corporate name',
		title: 'Corporate name (MEI <corpName>)',
		onclick: insertCorpName,
		stateSelector: 'span[title]'
	});

});


tinymce.PluginManager.add('title', function(editor) {
                
    function insertTitle() {
        var selection = editor.selection, dom = editor.dom, selectedElm, anchorElm;
        meiElementName = 'title';
        defaultMeiAtts = {type: "", auth: "VIAF", authURI: "http://www.viaf.org", dbkey: ""};
        editor.execCommand('mceEditMeiAttributes', false);
    }

	editor.addCommand('mceInsertTitle', insertTitle);

	editor.addButton('title', {
        image: '/../editor/images/mei_title.png',
		tooltip: 'Title',
		title: 'Title (MEI <title>)',
		onclick: insertTitle,
		stateSelector: 'span[title]'
	});

});


    // according to the orbeon documentation,
    // the variable declaration is supposed to be 'var TINYMCE_CUSTOM_CONFIG'
    // but that doesn't seem to have any effect...
    
    // bullist and numlist buttons are temporarily disabled because the list elements 
    // are not handled correctly by the filter yet
    
    YAHOO.xbl.fr.Tinymce.DefaultConfig = {
    mode:                                   "exact",
    language:                               "en",
    skin:                                   "thebigreason",
    plugins:                                "inlinepopups,spellchecker,style,table,save,iespell,paste,visualchars,nonbreaking,xhtmlxtras,template,fullscreen,meiElement,persName,geogName,corpName,title",
    gecko_spellcheck:                       true,
    encoding:                               "xml",
    entity_encoding:                        "raw",
    forced_root_block:                      "p",
    remove_redundant_brs:                   true,
    verify_html:                            true,
    theme_advanced_buttons1:                "bold,italic,underline,strikethrough,|,sup,sub,|,forecolor,fontselect,fontsizeselect,charmap,|,undo,redo,removeformat,|,link,unlink,|,fullscreen,code,|,persName,corpName,geogName,title",
    theme_advanced_buttons2:                "",
    theme_advanced_buttons3:                "",
    theme_advanced_buttons4:                "",
    theme_advanced_toolbar_location:        "top",
    theme_advanced_toolbar_align:           "left",
    theme_advanced_resizing:                true,
    theme_advanced_blockformats:            "p",
    theme_advanced_statusbar_location:      "none",
    theme_advanced_path:                    false,
    visual_table_class:                     "fr-tinymce-table",
    editor_css:                             "",
    theme_advanced_fonts:                   "Arial=arial,helvetica,sans-serif;"+
                                            "Courier New=courier new,courier;"+
                                            "Helvetica=helvetica,arial,sans-serif;"+
                                            "Times New Roman=times new roman,times,serif;"+
                                            "Bravura Text (SMuFL Music Font)=Bravura Text;"+
                                            "Bach (Music Font)=Bach Regular, Bach;"+
                                            "Bach Slur (Slurs for Bach Music Font)=Bach-slurs Regular, Bach-slurs;"+
                                            "Bach TS (Time Signatures for Bach Music Font)=Bach-ts Regular,Bach-ts;"+
                                            "Hnias (Runic Font)=Hnias;"+
                                            "Symbol=symbol;"+
                                            "Webdings=webdings;"+
                                            "Wingdings=wingdings,zapf dingbats",
    popup_css:                              "/../editor/style/tinymce_popup.css"
    };
    