$(function(){
	var vary = $("[title='inject_button']");
	vary.hide();

//	$("[title='RelatedPolicyByAccountPage']").parent().css('paddingLeft','0').css('borderBottom','0px solid #e3deb8');

//	$($("[title='RelatedPolicyByAccountPage']").parents('.pbSubsection')).prev().html('');
//	$($("[title='RelatedPolicyByAccountPage']").parents('.pbSubsection')).parent().next().remove();
	
	window.addEventListener('message', function(event) {
		var jmsg = $.parseJSON(event.data);
		//console.log(jmsg.title);
		if (jmsg.title!=undefined) {
			var ele = $("[title='"+jmsg.title+"']");
			ele.height(jmsg.height);
		}
	});
	
});