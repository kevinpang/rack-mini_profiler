var MiniProfiler = {
	fetchResult: function(id) {
		$.ajax({
			url: "http://localhost:3000/mini-profiler-results?id=" + id,
			datatype: "json",
			success: function(json) {
				MiniProfiler.showResult(json);
			}
		});
	},
	
	showResult: function(json) {
		$("#mini_profiler_result_template").tmpl(json).appendTo("#mini_profiler_results");
	}
};

$(document).ready(function() {
	// Intercept AJAX calls
	$(document).ajaxComplete(function (e, xhr, settings) {
	    if (xhr) {
	        var mini_profiler_id = xhr.getResponseHeader("X-Mini-Profiler-Result-Id");

			if (mini_profiler_id)
				MiniProfiler.fetchResult(mini_profiler_id);
	    }
	});
	
	$("[id^=mini_profiler_result_]").live("click", function() {
		var id = this.id.substr("mini_profiler_result_".length, this.id.length);
		$(".mini-profiler-result-details").not("#mini_profiler_result_details_" + id).hide();
		$("#mini_profiler_result_details_" + id).toggle();
	});
});