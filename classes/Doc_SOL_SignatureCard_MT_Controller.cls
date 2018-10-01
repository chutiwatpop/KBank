/*
06/12/2017  Form Doc_SOL_SignatureCard_Maintain
*/
public class Doc_SOL_SignatureCard_MT_Controller extends uPDFBuilder.VirtualPDFControllerV2 {
public String html {get;set;}
    public Doc_SOL_SignatureCard_MT_Controller(ApexPages.StandardController stdController) {
        SObject record = stdController.getRecord();
            // set variable in class
            // static resource name
            setSourceName('Doc_SOL_SignatureCard_MT');
            // record to get data
            setRecord(record);
            // modified data
            executeTranformPDF();
            html = tranformedHTML;
    }
}