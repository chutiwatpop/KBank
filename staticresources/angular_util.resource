angular.module("services",[])
.filter('update', function() {
    return function(arr, grid) {
        grid.data = arr;
        return arr;
    };
})
.filter('slice', function() {
    return function(arr, start, limit) {
        return (arr)?arr.slice(start, start + limit):[];
    };
})
.filter('page', function() {
    return function(input, total, limit) {
        var index = Math.ceil(parseFloat(total)/limit);
        for (var i=0; i<index; i++)
            input.push(i);
        return input;
    };
})
.factory('Util', function() {
    return{
        isDate : function(date) {
            var reggie = /^(0[1-9]|[12][0-9]|3[01])[\/ /.](0[1-9]|1[12])[\/ /.](24[1-9][1-9]|25[1-9][1-9]|19[1-9][1-9]|20[1-9][1-9])$/;
            var dateArray = reggie.exec(date);

            if(dateArray!=null){
                var newDateString = dateArray[2]+'/'+dateArray[1]+'/'+dateArray[3];
                return ( (new Date(newDateString) !== "Invalid Date" && !isNaN(new Date(newDateString)) ));
            }
            return false;
        },
        del:function(instance,index){
            instance.splice(index, 1);
        },
        hard_del:function(instance,item,sourceKey,itemKey) {
            var targetid;
            var idx;
            if(item.constructor === Array){
                for (var i=0; i < item.length; i++) {
                    targetid = item[i][itemKey];
                    idx = _.objectindex(instance, targetid ,sourceKey);
                    if (idx > -1) 
                        this.del(instance,idx);
                }
            }else {
                targetid = item[itemKey];
                idx = _.objectindex(instance, targetid ,sourceKey);
                if (idx > -1)
                    this.del(instance,idx);
            }
        },
        force_sync:function(instance,item,sourceKey,itemKey,syncKey){
            var targetid;
            var idx;
            if(item.constructor === Array){
                for (var i=0; i < item.length; i++) {
                    targetid = item[i][itemKey];
                    idx = _.objectindex(instance, targetid ,sourceKey);
                    if (idx > -1) 
                        instance[idx][syncKey] = item[i][syncKey];
                }
            }else {
                targetid = item[itemKey];
                idx = _.objectindex(instance, targetid ,sourceKey);
                if (idx > -1) 
                    instance[idx][syncKey] = item[syncKey];
            }
        },
        add:function(instance,item){
            if(item.constructor === Array){
                for (var i=0; i < item.length; i++) {
                    instance.push( item[i] );
                }
            }else instance.push(item);
        },
        add_all:function(destination,item,deskey,itemkey){
            var valid = true;
            if(item.constructor === Array){
                for (var j=0; j < item.length; j++) {
                    valid = true;
                    for(var k=0; k < destination.length; k++){
                        if(destination[k][deskey]==item[j][itemkey]){
                            valid=false;
                            break;
                        }
                    }
                    if(valid)
                        destination.push( item[j] );
                }
            }else {
                for(var k=0; k < destination.length; k++){
                    if(destination[k][deskey]==item[itemkey]){
                        valid=false;
                        break;
                    }
                }
                if(valid)
                    destination.push( item );
            }
        },
        distinct_add:function(instance,item,key){
            var targetid;
            var idx;
            if(item.constructor === Array){
                for (var i=0; i < item.length; i++) {
                    targetid = item[i][key];
                    idx = _.objectindex(instance, targetid ,key);
                    if (idx == -1) 
                        instance.push( item[i] );
                }
            }else {
                targetid = item[key];
                idx = _.objectindex(instance, targetid ,key);
                if (idx == -1)
                    instance.push( item );
            }
        },
        hard_distinct_add:function(instance,item,sourceKey,desKey){
            var targetid;
            var idx;
            if(item.constructor === Array){
                for (var i=0; i < item.length; i++) {
                    targetid = item[i][sourceKey];
                    idx = _.objectindex(instance, targetid ,desKey);
                    if (idx == -1) 
                        instance.push( item[i] );
                }
            }else {
                targetid = item[sourceKey];
                idx = _.objectindex(instance, targetid ,desKey);
                if (idx == -1)
                    instance.push( item );
            }
        },
        copy_exist_to:function(current,destination,currentkey,deskey){
            var new_select_list = [];
            for(var i=0;i < current.length ; i++){
                for(var j=0;j<destination.length ; j++){
                    if(current[i][currentkey] == destination[j][deskey]){
                        current[i].selected = true;
                        new_select_list.push(destination[j]);
                    }else current[i].selected = false;
                }
            }
            destination.length = [];
            this.add(destination,new_select_list);
        }
    };
})
.factory('$grid', function(){
    return {
        order: {col: null, desc:false, page: 0, limit: 15},
        sort: function(field){
            this.order.desc = (this.order.prev == field)? !this.order.desc : false;
            this.order.prev = this.order.col = field;
        },
        data: [],
    };
});