/**
 * musicalsymbols.js
 *
 * Modified from charmap.js, originally by
 * Moxiecode Systems AB (Copyright 2009)
 * Released under LGPL License.
 *
 * License: http://tinymce.moxiecode.com/license
 * Contributing: http://tinymce.moxiecode.com/contributing
 */

tinyMCEPopup.requireLangPack();

var charmap = [
	['',    '&#x266d;',  true, 'flat'],
	['',     '&#x266e;',   true, 'natural'],
	['',    '&#x266f;',   true, 'sharp'],
	['',    '&#x1d12a;',   true, 'double sharp'],
	['',    '&#x1d12b;',   true, 'double flat'],
	['',    '&#x1d134;',   true, 'common time'],
	['',    '&#x1d135;',   true, 'cut time']
];

tinyMCEPopup.onInit.add(function() {
	tinyMCEPopup.dom.setHTML('charmapView', renderCharMapHTML());
	addKeyboardNavigation();
});

function addKeyboardNavigation(){
	var tableElm, cells, settings;

	cells = tinyMCEPopup.dom.select("a.charmaplink", "charmapgroup");

	settings ={
		root: "charmapgroup",
		items: cells
	};
	cells[0].tabindex=0;
	tinyMCEPopup.dom.addClass(cells[0], "mceFocus");
	if (tinymce.isGecko) {
		cells[0].focus();		
	} else {
		setTimeout(function(){
			cells[0].focus();
		}, 100);
	}
	tinyMCEPopup.editor.windowManager.createInstance('tinymce.ui.KeyboardNavigation', settings, tinyMCEPopup.dom);
}

function renderCharMapHTML() {
	var charsPerRow = 20, tdWidth=20, tdHeight=20, i;
	var html = '<div id="charmapgroup" aria-labelledby="charmap_label" tabindex="0" role="listbox">'+
	'<table role="presentation" border="0" cellspacing="1" cellpadding="0" width="' + (tdWidth*charsPerRow) + 
	'"><tr height="' + tdHeight + '">';
	var cols=-1;

	for (i=0; i<charmap.length; i++) {
		var previewCharFn;

		if (charmap[i][2]==true) {
			cols++;
			previewCharFn = 'previewChar(\'' + charmap[i][1].substring(1,charmap[i][1].length) + '\',\'' + charmap[i][0].substring(1,charmap[i][0].length) + '\',\'' + charmap[i][3] + '\');';
			html += ''
				+ '<td class="charmap">'
				+ '<a class="charmaplink" role="button" onmouseover="'+previewCharFn+'" onfocus="'+previewCharFn+'" href="javascript:void(0)" onclick="insertChar(\'' + charmap[i][1].substring(2,charmap[i][1].length-1) + '\');" onclick="return false;" onmousedown="return false;" title="' + charmap[i][3] + ' '+ tinyMCEPopup.editor.translate("advanced_dlg.charmap_usage")+'">'
				+ charmap[i][1]
				+ '</a></td>';
			if ((cols+1) % charsPerRow == 0)
				html += '</tr><tr height="' + tdHeight + '">';
		}
	 }

	if (cols % charsPerRow > 0) {
		var padd = charsPerRow - (cols % charsPerRow);
		for (var i=0; i<padd-1; i++)
			html += '<td width="' + tdWidth + '" height="' + tdHeight + '" class="charmap">&nbsp;</td>';
	}

	html += '</tr></table></div>';
	html = html.replace(/<tr height="20"><\/tr>/g, '');

	return html;
}

function insertChar(chr) {
	tinyMCEPopup.execCommand('mceInsertContent', false, '&#' + chr + ';');

	// Refocus in window
	if (tinyMCEPopup.isWindow)
		window.focus();

	tinyMCEPopup.editor.focus();
	tinyMCEPopup.close();
}

function previewChar(codeA, codeB, codeN) {
	var elmA = document.getElementById('codeA');
	var elmB = document.getElementById('codeB');
	var elmV = document.getElementById('codeV');
	var elmN = document.getElementById('codeN');

	if (codeA=='#160;') {
		elmV.innerHTML = '__';
	} else {
		elmV.innerHTML = '&' + codeA;
	}

	elmB.innerHTML = '&amp;' + codeA;
	elmA.innerHTML = '&amp;' + codeB;
	elmN.innerHTML = codeN;
}
