Ext.require([
    'Ext.grid.*',
    'Ext.data.*',
    'Ext.util.*',
    'Ext.state.*',
    'Ext.grid.filters.Filters',
    'Ext.Deferred.*',
    'Ext.tab.Panel',
    'Ext.toolbar.Paging',
    'Ext.PagingToolbar',
    'Ext.panel.*',
    'Ext.form.*',
    'Ext.toolbar.*'
    //'font-pictos'
]);
Ext.define("CustomJs.view.YearGrid", {
    extend: 'Ext.grid.Panel',
    alias  : 'widget.yearendgrid',
    plugins: 'gridfilters',
    loadMask: true,
    multiColumnSort: true,
    enableLocking: true,
    collapsed: false,
    collapsible: false,
    width: 1, //dummy
    height: 500,
    getSorters_tmp: function () {
        var sorters = [];
        var bbar = this.down('#bbar'+this.id);
        
        Ext.each(bbar.query('splitbutton'), function(button) {
            sorters.push(button.sortData);
        }, this);

        return sorters;
    },
    changeSortDirection_tmp: function (button, changeDirection) {
        var sortData = button.sortData,
            iconCls  = button.iconCls;
        
        if (sortData) {
            if (changeDirection !== false) {
                button.sortData.direction = Ext.String.toggle(button.sortData.direction, "ASC", "DESC");
                button.setIconCls(Ext.String.toggle(iconCls, "sort_ASC", "sort_DESC"));
            }
            this.doSort();
        }
    },
    doSort: function () {
        var sorters = this.getSorters_tmp();
        if(sorters.length > 0) this.store.sort(sorters);
        else {//this.store.defaultSort
            this.store.sort({property:'Id',direction:'ASC'});
        }
    },
    createSorterButtonConfig: function (config) {
        var me = this;
        config = config || {};
        Ext.applyIf(config, {
            listeners: {
                click: function(button, e) {
                    me.changeSortDirection_tmp(button, true);
                }
            },
            iconCls: 'sort_' + config.sortData.direction,
            xtype: 'splitbutton',
            arrowHandler: function(){
                this.destroy();
                var bbar = me.down('#bbar'+me.id);
                Ext.each(bbar.query('splitbutton'), function(button,index) {
                    if(button.sortData.sortIndex != index){
                        button.sortData.sortIndex = index;
                        button.setText((index+1)+'. '+button.sortData.sortText);
                    }
                });
                me.doSort();
            },
        });
        return config;
    },
    onDestroy : function(){
        this.menu.destroy();
        this.callParent(arguments);
    },
    onItemContextMenu : function(view,rec,item,index,event){
        event.stopEvent();
        this.menu.showAt(event.getXY());
    },
    listeners: {
        headerclick: function(header, column, e, t,eOpts){
            var grid = this;
            if(column.dataIndex!="" && grid && grid.getView() && typeof grid.getView() != "undefined" && grid.getView().getSelectionModel() && typeof grid.getView().getSelectionModel()!="undefined"){
                grid.getView().getSelectionModel().deselectAll();
            }
        },
        afterlayout: function(){
            var allimgs = document.images;
            for (var i = 0; i < allimgs.length; i++) {
                allimgs[i].onerror = function() {
                    this.style.display = "none";
                }
            }
        },
        afterrender: function(grid) {
            //console.log('grid',grid);
            //var grid = this;
            grid.store.sync();
            grid.store.reload();
        }
    },
    pageItemContainer:{},
    currentlyLoading:false,
    initComponent: function () {
        var me = this;
        this.pageItemContainer = Ext.create('Ext.container.Container', {
            layout: 'column',
            //autoScroll: true,
            //scrollable:true,
            //align:'stretch',
            // layout: {
            //     type: 'hbox',
            //     align: 'stretch'
            // },
            maxWidth:700,
            defaults: {
                style: {
                    //float: 'left',
                    //display: 'inline-block'
                }
            },
            items : [],
        });
        this.bbar = Ext.create('Ext.PagingToolbar', {
            store: me.store,
            itemId: 'bbar'+this.id,
            displayInfo: true,
            refreshText:'Refresh',
            displayMsg: 'Displaying records {0} - {1} of {2}',
            emptyMsg: 'no records found',
            items:[
                this.pageItemContainer,
                {
                    xtype: 'button',
                    text:'Clear All',
                    cls: 'ClearAll',
                    handler: function(){
                        console.log('bbar');
                        me.store.remoteFilter = false;

                        me.pageItemContainer.items.each(function(item, index, len) {
                            //console.log(item, index,len);
                            this.remove(item, true); //and remove from DOM !
                        },me.pageItemContainer);

                        if(me.getView() && typeof me.getView() != "undefined" && me.getView().getSelectionModel() && typeof me.getView().getSelectionModel()!="undefined")
                            me.getView().getSelectionModel().deselectAll();

                        me.store.getFilters().each(function(filter) {
                            if(typeof filter.default === "undefined"){
                                filter.setValue('');
                            }
                        });

                        me.filters.clearFilters();
                    

                        me.store.getFilters().each(function(filter) {
                            console.log(filter);
                            if(typeof filter.default === "undefined"){
                                me.store.removeFilter(filter.getProperty());
                            }
                        });

                        me.store.remoteFilter = true;
                        
                        if(typeof me.clearAll!== "undefined") me.clearAll();
                        
                        me.doSort();
                    }
                }
            ],
            hidden: me.bbarhidden
        });

        if(me.store.getSorters().items.length)
            for(var i=0;i<me.store.getSorters().items.length;i++){
                if(!me.store.getSorters().items[i].notInclude){
                    var sortText = me.columns.filter(function(obj){
                        return obj.dataIndex == me.store.getSorters().items[i]['_property'];
                    })[0].text;
                    this.pageItemContainer.add(
                        me.createSorterButtonConfig({
                            text: (i+1)+'. '+sortText,
                            sortData: {
                                sortIndex: i,
                                sortText: sortText,
                                property: me.store.getSorters().items[i]['_property'],
                                direction: "ASC"
                            }
                        }));
                }
            }
        me.store.on({
            beforeload: function (store, options) {//this function need optimize
                if(store.sorters.items.length){
                    //store.remoteFilter = false;
                    for(var i=0; i < me.columns.length; i++) {
                        var currentCol = me.columns[i];
                        for(var j=0; j < store.sorters.items.length; j++) {
                            var oldSortParam = store.sorters.items[j].getProperty();
                            if(currentCol.sortable && currentCol.customSort && currentCol.dataIndex == oldSortParam) {
                                store.sorters.items[j].setProperty(currentCol.customSort);
                                break;
                            }
                        }
                    }
                }
            }
        });
        me.on({
            headerclick:function(header, column, e, t,eOpts){
                //me.currentlyLoading = true;//console.log(2);
                if (!column.isCheckerHd && column.sortable) {
                    var bbar = this.down('#bbar'+this.id);
                    var inArray = false;
                    var alength = 1;
                    Ext.each(bbar.query('splitbutton'), function(button) {
                        if(button.sortData.property == column.dataIndex){
                            inArray = true;
                            button.sortData.direction = Ext.String.toggle(button.sortData.direction, "ASC", "DESC");
                            button.setIconCls('sort_' + button.sortData.direction);
                        }
                        alength++;
                    });
                    if(!inArray){
                        this.pageItemContainer.add(
                            me.createSorterButtonConfig({
                            text: alength +'. '+ column.text,//column.fullColumnIndex +'.' + 
                            sortData: {
                                sortIndex: alength,
                                sortText: column.text,
                                property: column.dataIndex,
                                direction: "ASC"
                            }
                        }));
                    }
                    me.doSort();
                }
                // else{
                //     console.log(this);
                //     var isChecked = header.el.hasCls(Ext.baseCSSPrefix + 'grid-row-checker');
                //     if (isChecked) {                
                //         //this.deselectAll(true);
                //         //YOUR CODE ON UNCHECK 
                //         console.log('all unchecked');
                //     } else {                
                //         //this.selectAll(true);
                //         //YOUR CODE ON CHECK
                //         console.log('all checked');
                //     }
                // }
            }
        });
        this.callParent();
    }
});
Ext.Date.parseFunctions["SFDC"] = function(v) {
    if ((v == null) || (v == ''))
        return null;
    date_as_sent = new Date(parseInt(v));
    return new Date(date_as_sent.getUTCFullYear(),
        date_as_sent.getUTCMonth(),
        date_as_sent.getUTCDate());
};

function createGridObject(title, grid_id, model_store, column, extraParams, notPagination) {
    var merged = Ext.Object.merge({
        xtype: 'yearendgrid',
        title: title,
        id: grid_id,
        store: model_store,
        columns: column,
        bbarhidden:(!notPagination) ? false : true
        // bbar: Ext.create('Ext.PagingToolbar', {
        //     store: model_store,
        //     displayInfo: true,
        //     displayMsg: 'Displaying objects {0} - {1} of {2}',
        //     emptyMsg: 'no records found',
        //     hidden: (!notPagination) ? false : true
        // })
    }, extraParams);
    //merged.bbar.hidden =  (!notPagination) ? false : true;
    return merged;
};

function createGridObject_backup(title, grid_id, model_store, column, extraParams, notPagination) {
    var merged = Ext.Object.merge({
        //xtype: 'grid',
        title: title,
        plugins: 'gridfilters',
        id: grid_id,
        loadMask: true,
        store: model_store,
        //multiColumnSort: true,
        columns: column,
        bbar: Ext.create('Ext.PagingToolbar', {
            store: model_store,
            displayInfo: true,
            displayMsg: 'Displaying objects {0} - {1} of {2}',
            emptyMsg: 'no records found',
            hidden: (!notPagination) ? false : true
        }),
        enableLocking: true,
        collapsed: false,
        collapsible: false,
        width: 1, //dummy
        height: 500,
        onDestroy : function(){
            this.menu.destroy();
            this.callParent(arguments);
        },
        onItemContextMenu : function(view,rec,item,index,event){
            event.stopEvent();
            this.menu.showAt(event.getXY());
        },
        listeners: {
            headerclick:function(header, column, e, t,eOpts){
                var grid = this;
                if(column.dataIndex!="" && grid && grid.getView() && typeof grid.getView() != "undefined" && grid.getView().getSelectionModel() && typeof grid.getView().getSelectionModel()!="undefined"){
                    grid.getView().getSelectionModel().deselectAll();
                }
            },
            'afterlayout':function(){
                var allimgs = document.images;
                for (var i = 0; i < allimgs.length; i++) {
                    allimgs[i].onerror = function() {
                        this.style.display = "none";
                    }
                }
            }
        }
    }, extraParams);
    return Ext.create('Ext.grid.Panel', merged);
};

function mappingFieldType(extfields, fieldData) {
    for (var i = 0; i < fieldData.length; i++) {
        var field = {
            name: fieldData[i].name,
            type: fieldData[i].fieldType
        };
        if (fieldData[i].fieldType == "datetime") {
            field.dateFormat = "time";
            field.type = "date";
        } else if (fieldData[i].fieldType == "date") {
            field.type = "date";
            field.dateReadFormat = "SFDC"
            field.dateWriteFormat = "c";
        } else if (fieldData[i].fieldType == "double") {
            field.type = "float";
        } else if (fieldData[i].fieldType == "boolean") {
            field.type = "bool";
        } else if ((fieldData[i].fieldType == "integer") || (fieldData[i].fieldType == "boolean")) {
            field.type = fieldData[i].fieldType;
        } else {
            field.type = "string";
        }
        if (field.name == 'Id') {
            field.persist = false;
        }
        extfields.push(field);
    }
    return extfields;
};

function createColumns(fieldData) {
    var columns = [];
    for (var i = 0; i < fieldData.length; i++) {
        if (fieldData[i].name != 'Id') { //skip id
            console.log(fieldData[i].sortable);
            var col = {
                    dataIndex: fieldData[i].name,
                    text: fieldData[i].label,
                    sortable: fieldData[i].sortable,
                    width: 150,
                    renderer: Ext.util.Format.htmlDecode
                }
                //if(fieldData[i].name == 'Id') col.locked = true;
            if ((fieldData[i].fieldType == "integer") || (fieldData[i].fieldType == "double")) {
                col.xtype = 'numbercolumn';
                if (fieldData[i].fieldType == "integer") {
                    col.format = '0,000';
                }
            } else if (fieldData[i].fieldType == "boolean") {
                col.xtype = 'booleancolumn';
                col.trueText = 'Yes';
                col.falseText = 'No';
            } else if ((fieldData[i].fieldType == "date") || (fieldData[i].fieldType == "datetime")) {
                col.xtype = 'datecolumn';
            }
            if (fieldData[i].modifiable) {
                if (fieldData[i].fieldType == "date") {
                    col.editor = {
                        xtype: 'datefield'
                    };
                } else if (fieldData[i].fieldType == "boolean") {
                    var options = [
                        [true, 'Yes'],
                        [false, 'No']
                    ];
                    if (fieldData[i].nillable) {
                        options.push(['', null]);
                    }
                    col.editor = {
                        xtype: 'combobox',
                        store: options
                    };
                } else if (fieldData[i].fieldType == "picklist") {
                    col.editor = {
                        xtype: 'combobox',
                        store: fieldData[i].picklistValues
                    };
                } else if ((fieldData[i].fieldType == "integer") || (fieldData[i].fieldType == "double")) {
                    col.editor = {
                        xtype: 'numberfield'
                    };
                } else {
                    col.editor = {
                        xtype: 'textfield'
                    };
                }
                col.editor.allowBlank = fieldData[i].nillable;
                if (fieldData[i].fieldType == "double") {
                    col.editor.allowDecimals = true;
                }
                if ((fieldData[i].fieldType == "url") || (fieldData[i].fieldType == "email")) {
                    col.editor.vtype = fieldData[i].fieldType;
                }
            }
            columns.push(col);
        }
    }
    return columns;
};

function getFieldDescription(obj, fieldlist) {
    var deferred = new Ext.Deferred();
    RemoterExtensions.describeFields(obj, fieldlist, function(fieldData, e) {
        if (!e.status) {
            deferred.reject(e.message);
        } else {
            deferred.resolve(fieldData);
        }
    });
    return deferred.promise;
};
function getFieldMapDescription(obj, fieldlist) {
    var deferred = new Ext.Deferred();
    RemoterExtensions.describeMapFields(obj, fieldlist, function(fieldData, e) {

        if (!e.status) {
            deferred.reject(e.message);
        } else {
            deferred.resolve(fieldData);
        }
    });
    return deferred.promise;
};
function getFieldMapPicklistDescription(obj, fieldlist) {
    var deferred = new Ext.Deferred();
    RemoterExtensions.describeMapFieldsWithPickList(obj, fieldlist, function(fieldData, e) {
        if (!e.status) {
            deferred.reject(e.message);
        } else {
            deferred.resolve(fieldData);
        }
    });

    return deferred.promise;
};

function getFieldList(fields) {
    var fieldlist;
    if ((fields == null) || (fields == '') || (fields == '[]')) {
        Ext.Msg.alert('no fields were supplied to this component');
        return;
    }
    if (fields.substr(0, 1) == '[') {
        fieldlist = fields.substr(1, fields.length - 2).split(', ');
    } else {
        fieldlist = fields.split(',');
    }
    return fieldlist;
};

function createModel(modelName, roots, idProp, modelFields, controller, extraParams) {
    Ext.define(modelName, {
        extend: 'Ext.data.Model',
        
        fields: (modelFields!='')?modelFields:[],
        idProperty: idProp,
        proxy: {
            type: 'direct',
            $configStrict: false,
            api: {
                read: controller
            },
            limitParam: 'recordCount', // because "limit" is an Apex keyword
            sortParam: 'sortParams', // because "sort" is a keyword too
            groupParam: 'groupy',
            pageParam: undefined, // suppress sending "page", we don't need it
            // encodeFilters: function(filters) {
            //     console.log(filters);
            //     return filters;
            // },
            // encodeFilters: function(filters) {console.log(filters);
            //     var out = [],
            //         length = filters.length,
            //         i, op;
            //     for (i = 0; i < length; i++) {
            //         console.log(filters[i].serialize);
            //         out[i] = filters[i].serialize();
            //     }
            //     console.log('out',out);
            //     return this.applyEncoding(out);
            // },
            reader: {
                type: 'json',
                rootProperty: roots,
                messageProperty: 'errorMessage'
            },
            writer: {
                type: 'sfdc',
                rootProperty: roots,
                writeAllFields: false,
                allowSingle: false, // need to always be an array for code simplification
                encode: false, // docs say "set this to false when using DirectProxy"
            },
            listeners: {
                exception: {
                    fn: function(proxy, response, operation) {
                        console.log('got exception with response=', response, 'operation=', operation);
                        if (response.data) {
                            if (response.data.errorMessage) {
                                // my custom field is present; let's use it
                                Ext.Msg.alert('Error', response.data.errorMessage);
                            } else {
                                Ext.Msg.alert('Error', operation.action + ' failed: ' + response.data.message);
                            }
                        }
                    }
                }
            },
            extraParams: extraParams  
        }
    });
};

function createStaticStore(fields,data){
    var staticStore = Ext.create('Ext.data.Store', {
        fields: fields,
        data : data
    });
    return staticStore;
}

function createStoreModel(modelName, pagesize, addition) {
    addition = typeof addition !== 'undefined' ? addition : {};

    var store_array = Ext.merge({
        model: modelName,
        pageSize: pagesize,
        remoteSort: true,
        remoteFilter: true,
        sortOnLoad: true,
        autoLoad: true,
        multiSortLimit:50,
        defaultSort:[],
        sort:function(field, direction, mode){
            console.log(field);
            console.log(direction);
            console.log(mode);
            var me = this;
            //Ext.suspendLayouts();
            if (arguments.length === 0) {
                if (me.getRemoteSort()) {
                    me.load();
                } else {
                    me.forceLocalSort();
                }
            } else {
                if(me.getSorters().items.length){
                    var found = false;
                    if(!found) me.getSorters().addSort(field, direction, mode);
                }
            }
        }
    }, addition);
    if(typeof addition.sorters !== "undefined" && addition.sorters.length){
        store_array.defaultSort = addition.sorters;
    }else addition.sorters = [];

    if(typeof addition.filters !== "undefined" && addition.filters.length){
        Ext.each(addition.filters, function(filter) {
            if(typeof filter.default === "undefined") filter.default = true;
        });
    }

    // if(typeof addition.extraParams !== "undefined"){
    //     store_array.extraParams = addition.extraParams;
    // }

    var store_model = new Ext.data.Store(store_array);
    return store_model;
};

function createStaticComboxbox(fieldLabel,fieldName,store,queryMode,displayField,valueField,addition){
    addition = typeof addition !== 'undefined' ? addition : {};
    var combobox_array = Ext.merge({
        fieldLabel: fieldLabel,
        name: fieldName,
        store: store,
        queryMode: queryMode,
        displayField: displayField,
        valueField: valueField,
        editable: false,
        labelStyle: 'width:120px'
    }, addition);
    var comboBox = new Ext.form.ComboBox(combobox_array);
    return comboBox;
}

function createComboxbox(fieldLabel, fieldName, hidden, store, emptyText, displayField, valueField, editable, allowBlank, addition) {
    addition = typeof addition !== 'undefined' ? addition : {};
    var combobox_array = Ext.merge({
        fieldLabel: fieldLabel,
        name: fieldName,
        hidden: hidden,
        store: store,
        emptyText: emptyText,
        displayField: displayField,
        valueField: valueField,
        editable: editable,
        allowBlank: allowBlank,
        labelStyle: 'width:120px'
    }, addition);
    var combobox = new Ext.form.ComboBox(combobox_array);
    return combobox;
};

function createCustomComboxbox(fieldLabel, fieldName, hidden, store, emptyText, displayField, valueField, editable, allowBlank, addition) {
    addition = typeof addition !== 'undefined' ? addition : {};
    var combobox_array = Ext.merge({
        fieldLabel: fieldLabel,
        name: fieldName,
        hidden: hidden,
        store: store,
        emptyText: emptyText,
        displayField: displayField,
        displayTpl :'<tpl for=".">{[typeof values === "string" ? values : Ext.util.Format.htmlDecode(values["pname"])]}<tpl if="xindex < xcount">, </tpl></tpl>',
        valueField: valueField,
        editable: editable,
        allowBlank: allowBlank,
        labelStyle: 'width:120px'
    }, addition);
    var combobox = new Ext.form.ComboBox(combobox_array);
    return combobox;
};

function createStorePicklistModel(controller, extraParams, autoLoad, addition) {
    var picklist_array = Ext.merge({
        proxy: {
            type: 'direct',
            api: {
                read: controller
            },
            sortParam: undefined,
            limitParam: undefined,
            pageParam: undefined,
            autoLoad: autoLoad,
            reader: {
                type: 'json',
                rootProperty: 'records',
                messageProperty: 'errorMessage'
            },
            writer: {
                type: 'sfdc',
                rootProperty: 'records',
                writeAllFields: false,
                allowSingle: false, // need to always be an array for code simplification
                encode: false // docs say "set this to false when using DirectProxy"
            },
            listeners: {
                exception: {
                    fn: function(proxy, response, operation) {
                        console.log('got exception with response=', response, 'operation=', operation);
                        if (response.data) {
                            if (response.data.errorMessage) {
                                Ext.Msg.alert('Error', response.data.errorMessage);
                            } else {
                                Ext.Msg.alert('Error', operation.action + ' failed: ' + response.data.message);
                            }
                        }
                    }
                }
            },
            extraParams: extraParams
        }
    },addition);
    var picklistStore = Ext.create('Ext.data.Store',picklist_array);
    return picklistStore;
};

function createPanel(panel_config) {
    var panel_array = Ext.merge({
        bodyPadding: 5,
        width: 350,
        modal: true,
        closable: true,
        closeAction: 'hide',
        floating: true,
        listeners: {
            'beforerender': function(formPanel) {
                var i, len, items, item;
                items = formPanel.query('[allowBlank=false]');
                for (i = 0, len = items.length; i < len; i++) {
                    item = items[i];
                    item.afterLabelTextTpl = (item.afterLabelTextTpl || "") + '<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>';
                }
                return true;
            }
        },
        getInvalidFields: function() {
            var invalidFields = [];
            Ext.suspendLayouts();
            this.form.getFields().filterBy(function(field) {
                if (field.validate()) return;
                invalidFields.push(field);
            });
            Ext.resumeLayouts(true);
            return invalidFields;
        }
    }, panel_config);
    var panel_box = Ext.create('Ext.form.Panel', panel_array);
    return panel_box;
};

function mappingColumn(mapping ,listFields){
    var results = [];
    var arrayLength = listFields.length;
    for (var i = 0; i < arrayLength; i++) {
        var field_object = fields_base[listFields[i]];
        if(typeof field_object === "undefined")
            field_object = {
                "dataIndex": listFields[i],
                "text": listFields[i],
                "sortable": true,
                "width": 150
            };
        if(typeof mapping[listFields[i]] !== "undefined"){
            field_object.text = mapping[listFields[i]].label;
            if(typeof mapping[listFields[i]].picklistValues!=="undefined"){
                if(typeof field_object.filter==="undefined")
                    field_object.filter = {
                        type: 'list',
                        labelField: 'property',
                        idField: 'value',
                        updateBuffer: 1000
                    };
                if(typeof field_object.filter.options==="undefined")
                    field_object.filter.options = [];

                var var_store = {
                    fields: [
                        'property',
                        'value'
                    ],
                    data: []
                };

                for (var j = 0;j < mapping[listFields[i]].picklistValues.length;j++) {
                    //console.log(mapping[listFields[i]].picklistValues[j]);
                    if(typeof mapping[listFields[i]].picklistValues[j] !=="undefined"){
                        //console.log(mapping[listFields[i]].picklistValues[j]);

                        var_store.data.push(
                            mapping[listFields[i]].picklistValues[j]
                        );
                        field_object.filter.options.push({
                            property: mapping[listFields[i]].picklistValues[j][0],
                            value: mapping[listFields[i]].picklistValues[j][1]
                        });
                    }
                }
                field_object.filter.store = new Ext.data.ArrayStore(var_store);
                // for (var value in mapping[listFields[i]].picklistValues) {
                //     if (mapping[listFields[i]].picklistValues.hasOwnProperty(value)) {
                //         field_object.filter.options.push({
                //             field_name: value,
                //             field_value: mapping[listFields[i]].picklistValues[value]
                //         });
                //     }
                // }
            }
        }else if(!field_object.text) field_object.text = listFields[i];
        results.push(field_object);
    }
    return results;
};
/*Pan Rein*/
function createLocalModel(modelName,fields,configObj){
    var model = Ext.define(modelName, mergeConfig({
        extend: 'Ext.data.Model',
        fields: fields
    },configObj));
    return model;
};
function createLocalStore(model,data,configObj){
    var store = Ext.create('Ext.data.Store', mergeConfig({
        autoDestroy: true,
        model: model,
        data: data
    },configObj));
    return store;
};
function createDynamicStore(controller,configObj){
       var store = Ext.create('Ext.data.Store', mergeConfig({
            proxy: {
                type: 'direct',
                api: {
                    read: controller
                },
                sortParam: undefined,
                limitParam: undefined,
                pageParam: undefined,
                autoLoad: autoLoad,
                reader: {
                    type: 'json',
                    rootProperty: 'records',
                    messageProperty: 'errorMessage'
                },
                writer: {
                    type: 'sfdc',
                    rootProperty: 'records',
                    writeAllFields: false,
                    allowSingle: false, // need to always be an array for code simplification
                    encode: false // docs say "set this to false when using DirectProxy"
                },
                listeners: {
                    exception: {
                        fn: function(proxy, response, operation) {
                            console.log('got exception with response=', response, 'operation=', operation);
                            if (response.data) {
                                if (response.data.errorMessage) {
                                    Ext.Msg.alert('Error', response.data.errorMessage);
                                } else {
                                    Ext.Msg.alert('Error', operation.action + ' failed: ' + response.data.message);
                                }
                            }
                        }
                    }
                }
            }
        },configObj));
        return store;
}
function createLocalComboBox(label,displayField,valueField,store,configObj){
    var comboBox = Ext.create('Ext.form.field.ComboBox', mergeConfig({
        fieldLabel: label,
        displayField: displayField,
        valueField:valueField,
        store: store,
        // queryMode: 'local',
        editable: false,
        typeAhead: true,
    },configObj));
    return comboBox;
};
function createSimpleGrid(title,store,columnsConfig,configObj){
    var grid = Ext.create('Ext.grid.Panel', mergeConfig({
        title: title,
        store: store,
        columnLines: true,
        columns:columnsConfig
        },configObj)
    );
    return grid;
}
function mergeConfig(obj1,obj2){
    for (var attrname in obj2){
        obj1[attrname] = obj2[attrname];
    }
    return obj1;
}
function createColumn(config){
    var column = Ext.create('Ext.grid.column.Column', config);
    return column;
}
function createButton(buttonLabel,config){
    var button = Ext.create('Ext.Button', mergeConfig({
                    text: buttonLabel
                },config));
    return button;
}
function createToolbarSpacer(config){
    var spacer = Ext.create('Ext.toolbar.Spacer',mergeConfig({
                        flex:1
                }),config);
    return spacer;
}

/*Pan Rein*/

