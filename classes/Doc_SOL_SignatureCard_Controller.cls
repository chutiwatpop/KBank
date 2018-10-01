/*
20/04/2017 ISCR109 Form SOL_SignatureCard
*/
public class Doc_SOL_SignatureCard_Controller extends uPDFBuilder.VirtualPDFControllerV2 {
public String html {get;set;}
    public Doc_SOL_SignatureCard_Controller(ApexPages.StandardController stdController) {
        SObject record = stdController.getRecord();
            // set variable in class
            // static resource name
            setSourceName('Doc_SOL_SignatureCard');
            // record to get data
            setRecord(record);
            // modified data
            executeTranformPDF();
            html = tranformedHTML;
    }
}