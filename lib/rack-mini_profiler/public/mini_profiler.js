var MiniProfiler = {
	fetchResult: function(id) {
		$.ajax({
			url: "http://localhost:3000/mini-profiler-results?id=" + id,
			datatype: "json",
			success: function(json) {
				MiniProfiler.showResult(json, true);
			}
		});
	},
	
	showResult: function(json, isAjaxResult) {
		var cssClass = isAjaxResult ? "ajax-result" : "page-result";
		$("#mini_profiler_results").append("<li class='" + cssClass + "'>" + json.response_time + " ms</li>");
	}
};

// Intercept AJAX calls
$(document).ajaxComplete(function (e, xhr, settings) {
    if (xhr) {
        var mini_profiler_id = xhr.getResponseHeader("X-Mini-Profiler-Id");

		if (mini_profiler_id)
			MiniProfiler.fetchResult(mini_profiler_id);
    }
});