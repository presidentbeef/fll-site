fllloader = function(stuff) {
if($.browser.msie) {
	$(document).ready(stuff);
}
else {
	window.onload = stuff;
}
}
fllloader(function() { Nifty("ul#nav a","none transparent");$("ul#nav a").dropShadow({top:-1});$("div.content_border").dropShadow({top:-1,left:3});Nifty("div.lang_list");
		if($('#disqus').length>0) {
		var links = document.getElementsByTagName('a');var query = '?';for(var i = 0; i < links.length; i++) {
		if(links[i].href.indexOf('#disqus_thread') >= 0) {query += 'url' + i + '=' + encodeURIComponent(links[i].href) + '&';}};
		$('#disqus').append('<script charset="utf-8" type="text/javascript" src="http://disqus.com/forums/fll/get_num_replies.js' + query + '"></' + 'script>');}
		if($('#langform').length>0){$("#langform").validate({submitHandler:function(form){if(form.preview.checked){window.open("","preview","width=1000,height=800,toolbar=0,scrollbars=yes");form.action="/preview";form.target="preview";}
			else{form.action="/submit";form.target="_self";}
			form.submit();}});$('#captcha-spacer').prepend('<input name="captcha_session" type="hidden" value="3122"/><img id="captcha-image" src="http://captchator.com/captcha/image/3122"/>');}});
window.onresize=function(){$("ul#nav a").redrawShadow();$("div.content_border").redrawShadow();}
togglecomments = function() {
	var d = $('#disqus');
	if(d.css('display') == 'block') {
		d.css({display: 'none'});
		$('#comment_link').text('View Comments');
		$("div.content_border").redrawShadow();
		$("ul#nav a").redrawShadow();
		$("div.content_border").redrawShadow();
	}
	else {
		$('#comment_link').text('Hide Comments');
		d.css({display: 'block'});
		$("ul#nav a").redrawShadow();
		$("div.content_border").redrawShadow();
	}
}
