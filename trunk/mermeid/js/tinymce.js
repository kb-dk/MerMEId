// adding a custom button to tinymce.
// to activate, add 'musicalsymbols' to 'plugins' and 'theme_advanced_buttons1' below.
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

    
    // according to the orbeon documentation,
    // the variable declaration is supposed to be 'var TINYMCE_CUSTOM_CONFIG'
    // but that doesn't seem to have any effect...
    
    // bullist and numlist buttons are temporarily disabled because the list elements 
    // are not handled correctly by the filter yet
    
    YAHOO.xbl.fr.Tinymce.DefaultConfig = {
    mode:                                   "exact",
    language:                               "en",
    skin:                                   "thebigreason",
    plugins:                                "spellchecker,style,table,save,iespell,paste,visualchars,nonbreaking,xhtmlxtras,template,fullscreen,musicalsymbols",
    gecko_spellcheck:                       true,
    encoding:                               "xml",
    entity_encoding:                        "raw",
    forced_root_block:                      "p",
    remove_redundant_brs:                   true,
    verify_html:                            true,
    theme_advanced_buttons1:                "bold,italic,underline,strikethrough,|,sup,sub,|,forecolor,fontselect,fontsizeselect,charmap,|,undo,redo,removeformat,|,link,unlink,|,fullscreen,code",
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
    