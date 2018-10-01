({
	helperMethod : function() {
	},
	onChangeCustomerType : function(component) {
		var selectCmp = component.find("inputCustomerType");
        if(selectCmp.get("v.value") === "Individual") {
            component.set("v.isIndividual", true);
            document.getElementById("individualPanel").className = "";
            document.getElementById("organizationPanel").className = "hide";
        } else {
            component.set("v.isIndividual", false);
            document.getElementById("individualPanel").className = "hide";
            document.getElementById("organizationPanel").className = "";
        }
	}
})