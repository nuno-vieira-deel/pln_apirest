$(document).ready(function(){

	$("#demoForm").on('submit', function(e) {
		e.preventDefault();
		var input_text = $("#input_text").val();
		var pln_token = $("#pln_token").val();
		var spline_token = $("#api_token").val();
		$.ajax({ 
			url: '/'+pln_token,
			type: "POST",
			data: { text: input_text, api_token: spline_token },
			success: function(msg){
				if ( msg.length <= 2 ) {
			        $.ajax({ 
						url: '/'+pln_token,
						type: "POST",
						data: { word: input_text, api_token: spline_token },
						success: function(msg){
						  	$("#output_text").html(msg);
						}
					});
			    }
			    else{
			    	$("#output_text").html(msg);
			    }
			}
		});
		return false;
	});

});

