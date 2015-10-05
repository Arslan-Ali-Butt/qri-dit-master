function qrid_alarm_change(elem){
	if(elem.checked){
		$('#tenant_qrid_alarm_code').val($('#site_alarm_code').text());
		$('#tenant_qrid_alarm_safeword').val($('#site_alarm_safeword').text());
		$('#tenant_qrid_alarm_company').val($('#site_alarm_company').text());
	}else{
		$('#tenant_qrid_alarm_code').val("");
		$('#tenant_qrid_alarm_safeword').val("");
		$('#tenant_qrid_alarm_company').val("");
	}
}
$(document).on("page:change",null,null,function(){
	$("#cancel_qrid").bind('ajax:complete', function(){
		$("#myModal form").submit(function(){
			window.clean_exit=true;
			//window.location.assign("/qrids");
		});
	});
});

$(document).ready(function(){
	$('.add-templates').click(function() {
		$(this).button('loading');
	});
});

$(document).on("page:receive", function(){
	$('.add-templates').button('reset');
});