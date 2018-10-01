public class Doc_SME_Bundling_App_Controller extends uPDFBuilder.VirtualPDFControllerV2 {
public String html {get;set;}
    public Doc_SME_Bundling_App_Controller(ApexPages.StandardController stdController) {
        SObject record = stdController.getRecord();
            // set variable in class
            // static resource name
            setSourceName('Doc_SME_Bundling_App');
            // record to get data
            setRecord(record);
            // modified data
            executeTranformPDF();
            html = tranformedHTML;
    }
}