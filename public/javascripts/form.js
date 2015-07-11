$(document).ready(function(){

	$("#pln_token").val("0");

	$("#demoForm").on('submit', function() {
		var formData = new FormData($(this)[0]);
		var pln_token = $("#pln_token").val();
		$.ajax({ 
			url: '/'+pln_token,
			type: "POST",
			data: formData,
			cache: false,             
      processData: false, 
      contentType: false,
			success: function(msg){
				$("#output_text").html(msg);
			}
		});
		return false;
	});

	$("#pln_token").on('change', function(e) {
		$("#new_params").html("");
		var pln_token = $("#pln_token").val();
		if(pln_token!=0 && pln_token!='0'){
			$.ajax({ 
				url: '/tokeninfo',
				type: "GET",
				data: { token: pln_token },
				success: function(msg){
					var json = JSON.parse(msg);
					for(var k in json.parameters){
						$("#new_params").append("<p class=\"subtitle\">"+k+":</p>");
						if(json.parameters[k].type == "textarea"){
							$("#new_params").append("<textarea class=\"code\" id=\""+k+"\" name=\""+k+"\"/>")
						}
						else{
							$("#new_params").append("<input class=\"code\" type=\""+json.parameters[k].type+"\" id=\""+k+"\" name=\""+k+"\"/>");
						}
					}
				}
			});
		}
		return false;
	});

});

