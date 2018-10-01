public class SME_PurgeEnliteBatch_Controller {
    private String objectName;
    public static final Integer MAXYEAR = 5;
    public static final String FNCRTO = 'Financial_Ratio_Enlite__c';
    public static final String BALSHEET = 'BalanceSheetEnlite__c';
    public static final String INCSTM = 'Income_Statement_Enlite__c';
    public SME_PurgeEnliteBatch_Controller(String objectToPuge){
        this.objectName = objectToPuge;
    }

    public Boolean executeBatch(){
        SME_DistinctAccountIDForEnlite_Batch purgeBatch;
        if(objectName == FNCRTO){
            purgeBatch = new SME_DistinctAccountIDForEnlite_Batch(FNCRTO,MAXYEAR);
        }
        else if(objectName == BALSHEET){
            // //Modified for fix INC000000491317
            purgeBatch = new SME_DistinctAccountIDForEnlite_Batch(BALSHEET,MAXYEAR);
        }
        else if(objectName == INCSTM){
            purgeBatch = new SME_DistinctAccountIDForEnlite_Batch(INCSTM,MAXYEAR);
        }else{
            return false;
        }
        Database.executeBatch(purgeBatch);
        return true;
    }

}