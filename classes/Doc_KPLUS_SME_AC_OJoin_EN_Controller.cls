public class Doc_KPLUS_SME_AC_OJoin_EN_Controller extends uPDFBuilder.VirtualPDFControllerV2 {
public String html {get;set;}
    public Doc_KPLUS_SME_AC_OJoin_EN_Controller(ApexPages.StandardController stdController) {
        SObject record = stdController.getRecord();
            // set variable in class
            // static resource name
            setSourceName('Doc_KPLUS_SME_AC_OJoin_EN');
            // record to get data
            setRecord(record);
            // modified data
            executeTranformPDF();
            html = tranformedHTML;
    }
}