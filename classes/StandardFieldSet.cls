public class StandardFieldSet {

    public StandardFieldSet(Schema.FieldSetMember f) {
        this.DBRequired = f.DBRequired;
        this.APIName = f.fieldPath;
        this.Label = f.label;
        this.Required = f.required;
        this.Type = String.valueOf(f.getType());
    }
    
    public StandardFieldSet(Boolean DBRequired) {
        this.DBRequired = DBRequired;
    }
    
    @AuraEnabled
    public Boolean DBRequired { get;set; }
    
    @AuraEnabled
    public String DefaultValue { get;set; }

    @AuraEnabled
    public String APIName { get;set; }
    
    @AuraEnabled
    public String Label { get;set; }
    
    @AuraEnabled
    public Boolean Required { get;set; }
    
    @AuraEnabled
    public String Type { get; set; }

    @AuraEnabled
    public Boolean isPicklist { get; set; }

    @AuraEnabled
    public Boolean isManualPicklist { get; set; }

    @AuraEnabled
    public Map<String,String> picklistValues { get; set; }
}