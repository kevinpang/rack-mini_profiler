var MiniProfiler = {
	fetchResults: function(id) {
		$.ajax({
			url: "http://localhost:3000/mini-profiler-results?id=" + id,
			datatype: "json",
			success: function(json) {
				$("#mini_profiler_results").append("<li class='ajax-result'>" + json.response_time + " ms</li>");
			}
		});
	}
};

// Intercept AJAX calls
$(document).ajaxComplete(function (e, xhr, settings) {
    if (xhr) {
        var mini_profiler_id = xhr.getResponseHeader("X-Mini-Profiler-Id");

		if (mini_profiler_id)
			MiniProfiler.fetchResults(mini_profiler_id);
    }
});