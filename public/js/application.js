$('#home').live('pageshow',function(){
	document.ontouchmove = function(event){  event.preventDefault();  }
})

$('#home').live('pagehide', function() {
	document.ontouchmove = function(event){  }
})