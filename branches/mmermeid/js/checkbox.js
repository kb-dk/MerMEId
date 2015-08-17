    var d = document;
    var safari = (navigator.userAgent.toLowerCase().indexOf('safari') != -1) ? true : false;
    var gebtn = function(parEl,child) { return parEl.getElementsByTagName(child); };
    onload = function() {
        
        var body = gebtn(d,'body')[0];
        body.className = body.className && body.className != '' ? body.className + ' has-js' : 'has-js';
        
        if (!d.getElementById || !d.createTextNode) return;
        var ls = gebtn(d,'label');
        for (var i = 0; i < ls.length; i++) {
            var l = ls[i];
            if (l.className.indexOf('publishedIsGreen') == -1 && l.className.indexOf('pendingIsYellow') == -1 && l.className.indexOf('unpublishedIsRed') == -1) continue;
            var inp = gebtn(l,'input')[0];
            if (l.className == 'publishedIsGreen') {
                l.className = (safari && inp.checked == true || inp.checked) ? 'publishedIsGreen c_on' : 'publishedIsGreen c_off';
                l.onclick = check_it_green;
            };
            if (l.className == 'pendingIsYellow') {
                l.className = (safari && inp.checked == true || inp.checked) ? 'pendingIsYellow c_on' : 'pendingIsYellow c_off';
                l.onclick = check_it_yellow;
            };
            if (l.className == 'unpublishedIsRed') {
                l.className = (safari && inp.checked == true || inp.checked) ? 'unpublishedIsRed c_on' : 'unpublishedIsRed c_off';
                l.onclick = check_it_red;
            };
        };
    };

    var check_it_green = function() {
        var inp = gebtn(this,'input')[0];
        if (this.className == 'publishedIsGreen c_off' || (!safari && inp.checked)) {
            this.className = 'publishedIsGreen c_on';
            if (safari) inp.click();
        } else {
            this.className = 'publishedIsGreen c_off';
            if (safari) inp.click();
        };
    };

    var check_it_yellow = function() {
        var inp = gebtn(this,'input')[0];
        if (this.className == 'pendingIsYellow c_off' || (!safari && inp.checked)) {
            this.className = 'pendingIsYellow c_on';
            if (safari) inp.click();
        } else {
            this.className = 'pendingIsYellow c_off';
            if (safari) inp.click();
        };
    };

    var check_it_red = function() {
        var inp = gebtn(this,'input')[0];
        if (this.className == 'unpublishedIsRed c_off' || (!safari && inp.checked)) {
            this.className = 'unpublishedIsRed c_on';
            if (safari) inp.click();
        } else {
            this.className = 'unpublishedIsRed c_off';
            if (safari) inp.click();
        };
    };

