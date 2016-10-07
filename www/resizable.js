<script type="text/javascript">
    
$(function() {
	$(".resizable").resizable({
		start: function(event, ui) {
			ui.element.append($("<div/>", {
				id: "iframe-barrier",
				css: {
					position: "absolute",
					top: 0,
					right: 0,
					bottom: 0,
					left: 0,
					"z-index": 10
			}
			}));
		},
		stop: function(event, ui) {
			$("#iframe-barrier", ui.element).remove();
		},
		resize: function(event, ui) {
			$("iframe", ui.element).width(ui.size.width).height(ui.size.height);
		}
	});
});

</script>
