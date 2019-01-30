fllloader = function(stuff) {
if($.browser.msie) {
	$(document).ready(stuff);
}
else {
	window.onload = stuff;
}
}
fllloader(function() { 
		if($('#disqus').length>0) {
		var links = document.getElementsByTagName('a');var query = '?';for(var i = 0; i < links.length; i++) {
		if(links[i].href.indexOf('#disqus_thread') >= 0) {query += 'url' + i + '=' + encodeURIComponent(links[i].href) + '&';}};
		$('#disqus').append('<script charset="utf-8" type="text/javascript" src="http://disqus.com/forums/fll/get_num_replies.js' + query + '"></' + 'script>');}
		if($('#langform').length>0){$("#langform").validate({submitHandler:function(form){if(form.preview.checked){window.open("","preview","width=1000,height=800,toolbar=0,scrollbars=yes");form.action="/preview";form.target="preview";}
			else{form.action="/submit";form.target="_self";}
			form.submit();}});$('#captcha-spacer').prepend('<input name="captcha_session" type="hidden" value="3122"/><img id="captcha-image" src="http://captchator.com/captcha/image/3122"/>');}});
togglecomments = function() {
	var d = $('#disqus');
	if(d.css('display') == 'block') {
		d.css({display: 'none'});
		$('#comment_link').text('View Comments');
	}
	else {
		$('#comment_link').text('');
		d.css({display: 'block'});
	}
}

var toggle_sort  = function(turn_on) {
	var a = $('#byalpha');
	var b = $('#byadded');
	var c = $('#byupdated');
	var d = $('#byalphalink');
	var e = $('#byaddedlink');
	var f = $('#byupdatedlink');

	if(turn_on == "alpha") {
    a.css({display: 'block'});
		b.css({display: 'none'});
    c.css({display: 'none'});
    d.css({'font-weight': 'bold'});
    e.css({'font-weight': 'normal'});
    f.css({'font-weight': 'normal'});
	}
  else if(turn_on == "added") {
    a.css({display: 'none'});
		b.css({display: 'block'});
    c.css({display: 'none'});

    d.css({'font-weight': 'normal'});
    e.css({'font-weight': 'bold'});
    f.css({'font-weight': 'normal'});
	}
  else if(turn_on == "updated") {
    a.css({display: 'none'});
		b.css({display: 'none'});
    c.css({display: 'block'});

    d.css({'font-weight': 'normal'});
    e.css({'font-weight': 'normal'});
    f.css({'font-weight': 'bold'});
	}
}
