function toggleHelpMenu(){
	helpMenu=$("#help-menu");
	if(helpMenu.hasClass("show-help-menu")){
		helpMenu.removeClass("show-help-menu");
		$("#help-menu-button").text("Show Menu");
	}else{
		helpMenu.addClass("show-help-menu");
		$("#help-menu-button").text("Hide Menu");
	}
}
