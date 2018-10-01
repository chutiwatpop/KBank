global class SME_FCDResultResponse {
	//public getFCDResponse_model returnResponse
 //   {
 //       get
 //       {
 //           if(returnResponse==null)
 //               returnResponse=new getFCDResponse_model();
 //               return returnResponse;
 //       }
 //       set;    
 //   }
	global class getFCDResponse_model extends CIBaseResponseModel
    {
        public FCD_Model FCDModel
        {
            get
            {
                if(FCDModel==null)
                    FCDModel=new FCD_Model();
                    return FCDModel;
            }
            set;
        }
    }
    public class FCD_Model{
         public Detail Detail {get;set;}
    }
    public class Detail{
         public String IP_ID {get;set;}
         public AR_DTL_LIST AR_DTL_LIST {get;set;}
    }
    public class AR_DTL_LIST{
         public List<FCD_AR_DTL_INF> FCD_AR_DTL_INF {get;set;}
    }
    public class FCD_AR_DTL_INF {
        public String  POS_DT{get;set;}
        public String  AR_ID{get;set;}
        public String  AR_ID_TXT{
            set;
            get{
                AR_ID = GlobalUtility.toValue(AR_ID);
                SUB_AR = GlobalUtility.toValue(SUB_AR);
                if(PD_TP_CD == '3101'){
                    return formatARIDTXT(AR_ID) + '/ '+ SUB_AR;
                }else{
                    return formatARIDTXT(AR_ID);
                }
            }
        }
        public String  SUB_AR{get;set;} 
        public String  AR_NM{get;set;} 
        public String  OPN_DT{
            set;
            get{
                return GlobalUtility.toValue(OPN_DT);
            }
        } 
        public String  CLS_DT{
            set;
            get{
                return GlobalUtility.toValue(CLS_DT);
            }
        } 
        public String  FCD_TP_CD{
            set;
            get{
                return GlobalUtility.toValue(FCD_TP_CD);
            }
        }
        public String  PD_TP_CD{get;set;}
        public String  PD_TP_CD_TXT{
            set;
            get{
                AR_TERM = GlobalUtility.toValue(AR_TERM);
                AR_TERM_UOM_TP_CD = GlobalUtility.toValue(AR_TERM_UOM_TP_CD);
                if(PD_TP_CD == '1101'){
                    PD_TP_CD_TXT = 'กระแสรายวัน';
                }else if(PD_TP_CD == '2101' || PD_TP_CD == '2102'){
                    PD_TP_CD_TXT = 'ออมทรัพย์';
                }else if(PD_TP_CD == '3101'){
                    PD_TP_CD_TXT = 'ฝากประจำ ' + AR_TERM + AR_TERM_UOM_TP_CD;
                }else{
                    PD_TP_CD_TXT = GlobalUtility.toValue(PD_TP_CD);
                }
                return PD_TP_CD_TXT;
            }
        } 
        public String  AR_TERM{get;set;} 
        public String  AR_TERM_UOM_TP_CD{get;set;} 
        public String  CCY_CD{
            set;
            get{
                return GlobalUtility.toValue(CCY_CD);
            }
        } 
        public String  CCY_OTSND_BAL{
            set;
            get{
                return GlobalUtility.toValue(CCY_OTSND_BAL);
            }
        } 
        public String  MID_RATE{get;set;} 
        public String  CNVR_OTSND_BAL{
            set;
            get{
                List<String>splitCompo = CNVR_OTSND_BAL.split('\\.');
                CNVR_OTSND_BAL = splitCompo[0]+'.'+splitCompo[1].subString(0,2);
                return GlobalUtility.toValue(CNVR_OTSND_BAL);
            }
        } 
        public String  AR_LCS_TP_CD{get;set;}
        public String  AR_LCS_TP_CD_TXT{
            set;
            get{
                if(AR_LCS_TP_CD == '0'){
                    AR_LCS_TP_CD_TXT = 'Active';
                }else if(AR_LCS_TP_CD == '4'){
                    AR_LCS_TP_CD_TXT = 'Closed';
                }else{
                    AR_LCS_TP_CD_TXT = '';
                }
                return AR_LCS_TP_CD_TXT;
            }
        } 
        public String AR_OWN_TP_CD{get;set;} 
        public String AR_OWN_TP_CD_TYPE {
            set;
            get {
                String accountTypeText = '';
                switch on AR_OWN_TP_CD {
                    when '0' {
                        accountTypeText = 'บัญชีร่วมรอง';
                    }
                    when '1' {
                        accountTypeText = 'บัญชีร่วมหลัก';
                    }
                    when '2' {
                        accountTypeText = 'บัญชีเดี่ยว';
                    }
                }
                return accountTypeText;
            }
        }

        public String  SRC_STM_ID{get;set;} 

    }

     public static getFCDResponse_model parse(String json) {
        return (getFCDResponse_model) System.JSON.deserialize(json, getFCDResponse_model.class);
    }

    private static String formatARIDTXT(String aRIDTXT){
        return aRIDTXT.subString(0,4)+'XXXX'+aRIDTXT.subString(8,10);
    }
}