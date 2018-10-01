/*
02/03/2018 Form CDD K-eDoc_V2
*/
public class Doc_CDD_KeDoc_V2_Controller extends uPDFBuilder.VirtualPDFControllerV2 {
public String html {get;set;}
    public Doc_CDD_KeDoc_V2_Controller(ApexPages.StandardController stdController) {
        SObject record = stdController.getRecord();
            // set variable in class
            // static resource name
            setSourceName('Doc_CDD_KeDoc_V2');
            // record to get data
            setRecord(record);
            // modified data
            executeTranformPDF();
            html = tranformedHTML;
    }
}