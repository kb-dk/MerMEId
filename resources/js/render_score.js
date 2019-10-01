/* The MEI encoding to be rendered */
var data = document.getElementById('mei_score_data').innerHTML;
/* Render the data and insert it as content of the target div */
mode = (mode == 'plaineAndEasie') ? 'pae' : mode;

if ((mode == 'mei' && data.indexOf('score') > -1) || (mode == 'pae')) { 
    document.getElementById('score_container').innerHTML = vrvToolkit.renderData( 
      data, 
      { 
        inputFormat: mode,
        pageWidth: 3000,
        scale: 30,
        adjustPageHeight: 1,
        pageMarginTop:        0,
        pageMarginLeft:       0,
        noHeader:             1,
        noFooter:             1,
        breaks: 'encoded'
      } 
    ); 
} else {
    document.getElementById('score_container').innerHTML = 'There does not seem to be any &lt;score&gt; element to render. Did you remember to save your changes before clicking the &apos;View incipit&apos; button?';
}
