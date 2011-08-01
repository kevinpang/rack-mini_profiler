var MiniProfiler = {
	fetchResult: function(id) {
		$.ajax({
			url: "http://localhost:3000/mini-profiler-results?id=" + id,
			datatype: "json",
			success: function(json) {
				MiniProfiler.showButton(json, true);
			}
		});
	},
	
	showButton: function(json, isAjaxResult) {
		var cssClass = isAjaxResult ? "mini-profiler-ajax-result" : "mini-profiler-page-result";
		$("#mini_profiler_results").append("<li id='mini_profiler_result_" + json.id + "' class='" + cssClass + "'>" + json.response_time + " ms<div id='mini_profiler_result_details_" + json.id + "' class='mini-profiler-result-details'>" + json.url + "</div></li>");
		$("#mini_profiler_result_details_" + json.id).hide();
	}
};

$(document).ready(function() {
	// Intercept AJAX calls
	$(document).ajaxComplete(function (e, xhr, settings) {
	    if (xhr) {
	        var mini_profiler_id = xhr.getResponseHeader("X-Mini-Profiler-Id");

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