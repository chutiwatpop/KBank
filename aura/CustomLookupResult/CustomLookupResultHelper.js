({
	getValue : function(fieldAPIName, record) {
		var value;
        var tempRecord = record;
        var fields = fieldAPIName.split(".");
        for(var i = 0;i < fields.length;i++) {
            value = tempRecord[fields[i]];
            tempRecord = value;
        }
        return value;
	}
})