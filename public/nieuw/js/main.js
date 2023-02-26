$(window).load(function() {

	var viewport = $(window);
	var background = $("#background-wrapper img");

	function resizeBackground()
	{
		viewport_ratio = viewport.width() / viewport.height()
		background_ratio = background.width() / background.height()

		if (viewport_ratio > background_ratio)
		{
			background.css("width", "100%");
			background.css("height", "auto");
		}
		else
		{
			background.css("height", "100%");
			background.css("width", "auto");
		}
	}

	viewport.resize(function() {
		resizeBackground();
	});

	viewport.trigger("resize");
});