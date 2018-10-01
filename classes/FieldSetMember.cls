public class FieldSetMember {
    
    public FieldSetMember(Schema.FieldSetMember f) {
        this.DBRequired = f.DBRequired;
        this.fieldPath = f.fieldPath;
        this.label = f.label;
        this.required = f.required;
        this.type = '' + f.getType();
    }
    
    public FieldSetMember(Boolean DBRequired) {
        this.DBRequired = DBRequired;
    }
    
    @AuraEnabled
    public Boolean DBRequired { get;set; }
    
    @AuraEnabled
    public String fieldPath { get;set; }
    
    @AuraEnabled
    public String label { get;set; }
    
    @AuraEnabled
    public Boolean required { get;set; }
    
    @AuraEnabled
    public String type { get; set; }
}