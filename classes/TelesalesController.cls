public with sharing class TelesalesController {

    private static final Set<String> leadStatusExcluedStampDate = new Set<String>{'Waiting for Contact Again','รอติดต่อลูกค้าอีกครั้ง'};

    @AuraEnabled
    public static String getAllQuestions(String leadId){
        String json = getAllQuestionsAndAnswers(leadId);
        if(json == null){
            return '';
        }
        return json;
    }
    
    public static Map<String,Map<String,String>> getFlow(){ 
        Map<String,Map<String,String>> mapFlow;
        try {
            mapFlow = new Map<String,Map<String,String>>();
            Map<String,String> flow = new Map<String,String>();
        	List<Telesales_Lead_Flow__c> teleSalesFlow = [select id,F_Question__c,F_Answer__c,F_Next_Question__c from Telesales_Lead_Flow__c where RecordType.Name = 'Flow'];
  
            for (Telesales_Lead_Flow__c f: teleSalesFlow) {
                if(mapFlow.containsKey(f.F_Answer__c)){
                    flow = mapFlow.get(f.F_Answer__c);
                }else{
                    flow = new Map<String,String>();
                }
                flow.put('question',f.F_Question__c);
                flow.put('next',f.F_Next_Question__c);
                mapFlow.put(f.F_Answer__c,flow);
            }
        }
        catch(Exception e){
            //e.getMessage();
            System.debug('getFlow : '+e.getMessage());
        }
        //System.debug('getFlow : '+ JSON.serialize(mapFlow));
        return mapFlow;
    }
    
    public static Map<String,Map<String,Map<String,String>>> getAllAnswers(String leadId){
        String condition = '';
        Map<String,String> conditions = getAllConditionAttributes(leadId);
        Map<String,Map<String,String>> flows = TelesalesController.getFlow();
        if(flows == null){
            return null;
        }
        
        Map<String,Map<String,Map<String,String>>> objectAnswers;
        try {
            objectAnswers = new Map<String,Map<String,Map<String,String>>>();
        	List<Telesales_Lead_Flow__c> teleSalesAnswers = [select id,Name,Script__c,A_Field__c,A_Object__c,A_Operation__c,A_Value__c,A_Required_Next_Contact_Date__c,A_Free_Text_Answer__c,A_Number_Answer__c,A_Status__c,A_Online_Status__c from Telesales_Lead_Flow__c where RecordType.Name = 'Answer' order by A_Operation__c desc];
            Map<String,Map<String,String>> answers;
            Map<String,String> answerAttrs;
            Map<String,String> flow;
            Set<String> checker;
            Map<String,Set<String>> duplicateChecker = new Map<String,Set<String>>();
            String questionId = '';
            String objectVal = '';
            //System.Debug('conditions' + conditions);
            for (Telesales_Lead_Flow__c teleSaleAnswer: teleSalesAnswers) {
            	Boolean hasCondition = false;
                //Check condition
                if(teleSaleAnswer.A_Field__c!=null){
                	objectVal = teleSaleAnswer.A_Object__c.toUpperCase() == 'LEAD' ? '' : teleSaleAnswer.A_Object__c+'__R.';
                    objectVal = objectVal + teleSaleAnswer.A_Field__c;
                    objectVal = objectVal.toUpperCase();
                    condition = conditions.get(objectVal);
                    //System.Debug('condition{' + condition + '}');
                    if(condition == null){
                        continue; //Skip when answer has condition but attribute for this condition is not exists.
                    }
                    if(!checkCondition(condition,teleSaleAnswer.A_Value__c ,teleSaleAnswer.A_Operation__c)){
                        System.Debug('NOT_MATCH:{'+teleSaleAnswer.Id+'},{' + condition +'} ,'+ teleSaleAnswer.A_Value__c +' ,' + teleSaleAnswer.A_Operation__c);
                        continue;
                    }
                    System.Debug('MATCH:{' + teleSaleAnswer.Id + '},{' + condition +'} ,'+ teleSaleAnswer.A_Value__c +' ,' + teleSaleAnswer.A_Operation__c);
                    hasCondition = true;
                }
                    
                //Check flow
                flow = flows.get(teleSaleAnswer.id);
                if(flow == null){
                    continue;
                } 
                questionId = flow.get('question');
                if(objectAnswers.containsKey(questionId)){
                    answers = objectAnswers.get(questionId);
                }else{
                    answers = new Map<String,Map<String,String>>();
                }
                
                //Check question duplicate
                if(duplicateChecker.containsKey(questionId)){
                    checker = duplicateChecker.get(questionId);
                    if(checker != null && checker.contains(teleSaleAnswer.Script__c)){
                    	continue; 
                    }
                }else{
                    checker = new Set<String>();
                }
                checker.add(teleSaleAnswer.Script__c);
                duplicateChecker.put(questionId,checker);
                
                answerAttrs = new Map<String,String>();
                answerAttrs.put('id',teleSaleAnswer.Id);
                answerAttrs.put('name',teleSaleAnswer.Name);
                answerAttrs.put('text',teleSaleAnswer.Script__c);
                answerAttrs.put('next',flow.get('next'));
                answerAttrs.put('condition',hasCondition?'True':'False');
                answerAttrs.put('status',teleSaleAnswer.A_Status__c);
                answerAttrs.put('onlineStatus',teleSaleAnswer.A_Online_Status__c);
                answerAttrs.put('isContactDate',teleSaleAnswer.A_Required_Next_Contact_Date__c?'true':'false');
                answerAttrs.put('isFreeText',teleSaleAnswer.A_Free_Text_Answer__c?'true':'false');
                answerAttrs.put('isNumberInput',teleSaleAnswer.A_Number_Answer__c?'true':'false');     
                answers.put(teleSaleAnswer.id,answerAttrs);
                objectAnswers.put(questionId,answers);
			}
        } catch (Exception e) {
            //e.getMessage();
            System.debug('getAllAnswers : '+e.getMessage());
        }
        //System.debug('getAllAnswers : '+ JSON.serialize(objectAnswers));
        return objectAnswers;
    }
    
    private static String getAllQuestionsAndAnswers(String leadId) {
        Map<String,Map<String,Map<String,String>>> answers = getAllAnswers(leadId);
        if(answers == null){
            return null;
        }
        Map<String,Map<String,String>> answer;
        Map<String,Map<String,Object >> questions;
        try {
            questions = new Map<String,Map<String,Object >>();
        	List<Telesales_Lead_Flow__c> teleSalesQuestions = [SELECT Id, RecordType.Name,Name,Q_First_Question__c,Script__c from Telesales_Lead_Flow__c where RecordType.Name = 'Question' order by Q_First_Question__c desc];
            Map<String,Object> questionAttrs;
            
            for (Telesales_Lead_Flow__c question: teleSalesQuestions) {
                if(questions.containsKey(question.Id)){
                    questionAttrs = questions.get(question.Id);
                }else{
                    questionAttrs = new Map<String,Object>();
                }
                questionAttrs.put('id',question.Id);
                questionAttrs.put('name',question.Name);
                questionAttrs.put('text',question.Script__c);
                questionAttrs.put('isFirst',question.Q_First_Question__c?'true':'false');
                
                answer = answers.get(question.id);
                //System.debug('answer: '+JSON.serialize(answer));
                if(answer == null){
                    continue;
                }
                
                questionAttrs.put('answer',answer.values());
                questions.put(question.Id,questionAttrs);
                //System.debug('question: '+JSON.serialize(questions));
			}
        } catch (Exception e) {
            //e.getMessage();
            System.debug('getAllQuestionsAndAnswers : '+e.getMessage());
        }
        
        if(questions == null){
            //System.debug('getAllQuestionsAndAnswers : Cannot create question map');
            return null;
        }
        //System.debug('getAllQuestionsAndAnswers : '+JSON.serialize(questions.values()));
        return JSON.serialize(questions);
    }
    
    private static Map<String,String> getAllConditionAttributes(String leadId){
        if(leadId == null){
            return null;
        }
        
        Map<String,String> attributes = new Map<String,String>();
        try {
            //Get all fields for conditions
        	List<Telesales_Lead_Flow__c> teleSalesAnswers = [select A_Object__c, A_Field__c from Telesales_Lead_Flow__c];
            Set<String> fields = new Set<String>();
            String key = '';
            String objectVal = '';
            for (Telesales_Lead_Flow__c condition: teleSalesAnswers) {
                if(condition.A_Object__c == null){
                    continue;
                }
                objectVal = condition.A_Object__c == 'Lead' ? '' : condition.A_Object__c+'__r.';
                key = objectVal + condition.A_Field__c;
                fields.add(key.toUpperCase());
			}
			//Format query for conditions
			//"Select field1,field2 from object"
            
			if(fields == null || fields.size() == 0){
                    return null;
            }
			String strFields = fields + '';
            Integer strFieldsLen = strFields.length();
            if(strFieldsLen > 1){
                strFields = strFields.substring(1,strFieldsLen - 1);
            }
            //System.debug('QueryCondition : select '+strFields+' from Lead');
            String data = '';
          	String strInnerObj = '';
            Object innerObj;
            Map<String, Object> meta;
            Map<String, Object> innerMap;
            List<Lead> objs = database.query('select '+strFields+' from Lead where id = \''+leadId+'\'');
            List<String> nonUseIds = new list<String>{ 'attributes' , 'Id' , 'RecordTypeId' };
            //System.debug('objs : ' + objs);
            for (Lead obj : objs){
                data = JSON.serialize(obj);
                //System.debug('dataAll : '+data);
                meta = (Map<String, Object>) JSON.deserializeUntyped(data);
                //System.debug('dataMeta : '+meta.keySet());
                for(String k : meta.keySet()){
                    //System.debug('K : '+k +' fields : '+fields);
                    if(fields.contains(k.toUpperCase())||k.toUpperCase().endsWith('__R')){
                        innerObj = meta.get(k);
                        //System.debug('K : '+k +' meta : '+meta.get(k));
                        if(k.toUpperCase().endsWith('__R')){
                            innerMap = (Map<String, Object>)innerObj;
                            for(String innerKey : innerMap.keySet()){
                                if(!nonUseIds.contains(innerKey)){
                                    //System.debug('innerKey : '+innerKey);
                                    strInnerObj =  innerMap.get(innerKey) + '';
                            		attributes.put(k.toUpperCase()+'.'+innerKey.toUpperCase(),strInnerObj);
                                }
                            }
                        } else {
                            strInnerObj = innerObj+'';
                            attributes.put(k.toUpperCase(),strInnerObj);
                        }
                    } 
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        //System.debug(JSON.serialize(attributes));
        return attributes;
    }
    
    public static Boolean checkCondition(String val1,String val2,String operation){
        Decimal number1 = null;
        Decimal number2 = null;
        if(isDecimal(val1) && isDecimal(val2)){
            number1 = decimal.valueOf(val1); 
            number2 = decimal.valueOf(val2); 
        }
        //System.debug('Number : '+number1+', '+number2);
        switch on operation {
            when 'เท่ากับ'{
                if(number1 != null){
                    return (number1 == number2);
                }
                return (val1 == val2);
            }
            when 'ไม่เท่ากับ'{
                if(number1 != null){
                    return (number1 != number2);
                }
                return (val1 != val2);
            }
            when 'มากกว่า'{
                if(number1 != null){
                    return (number1 > number2);
                }
                return (val1 > val2);
            }
            when 'มากกว่าเท่ากับ'{
                if(number1 != null){
                    return (number1 >= number2);
                }
				return (val1 >= val2);                
            }
            when 'น้อยกว่า'{
                if(number1 != null){
                    return (number1 < number2);
                }
                return (val1 < val2);
            }
            when 'น้อยกว่าเท่ากับ'{
                if(number1 != null){
                    return (number1 <= number2);
                }
                return (val1 <= val2);
            }
            when else {
                return false;
            }
        }
    }

     public static Boolean isDecimal(String s){
        Boolean ReturnValue;
        try{
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
    
    @AuraEnabled
    public static String save(String fieldListJSON){
        
        DataTeleSaleLead dataLeadBody = (DataTeleSaleLead) JSON.deserialize(fieldListJSON, DataTeleSaleLead.class);
        ResultResponse resp = new ResultResponse();
        try {
            List<Lead> leads = database.query('select Id from Lead where id = \''+dataLeadBody.leadId+'\'');
            if(leads.size() != 1){
                 resp.result = 'ERROR';
            	 resp.message = 'Cannot find lead';
            } else {
                Lead lead = leads[0];
                Integer index = 0;
                String answer = '';
                Decimal numberVal;
                String freeTextAnswer = '';
                String numberAnswer = '';
                String leadStatus = '';
                String statusOnline = '';
                Datetime dateContact;
                Datetime dateContactLead; 

                List<Telesales_Lead_Historical__c> clearHistorical = [Select Id, Lead__c, Latest__c from Telesales_Lead_Historical__c where Lead__c =: lead.Id and Latest__c =: true];
                if(clearHistorical.size() > 0){
                    for(Telesales_Lead_Historical__c clearFlag : clearHistorical){
                        clearFlag.Latest__c = false;
                    }

                    update clearHistorical;   
                }
                
                List<Telesales_Lead_Historical__c> historicals = new List<Telesales_Lead_Historical__c>();
                for(String question : dataLeadBody.questions){
                    dateContact = dataLeadBody.contactDate.get(index) != '' ? (DateTime)Json.deserialize('"' + dataLeadBody.contactDate.get(index) + '"', DateTime.class) : null;
                    answer = dataLeadBody.answers.get(index);
                    numberVal = (dataLeadBody.numbers.get(index) != '') ? decimal.valueOf(dataLeadBody.numbers.get(index).trim()) : null;
                	Telesales_Lead_Historical__c historical = new Telesales_Lead_Historical__c();
                	historical.Answer__c = answer;
                	historical.Question__c = question;
                	historical.Lead__c = lead.Id;
                	historical.CreatedById = UserInfo.getUserId();
                	historical.OwnerId = UserInfo.getUserId();
                    historical.Latest__c = true;
                    historical.Next_Contact_Date__c = dateContact;
                    historical.Free_Text_Answer__c = dataLeadBody.notes.get(index);
                    historical.Number_Answer__c = numberVal;
                    historical.Lead_Status__c = dataLeadBody.statusLead.get(index);
                    historical.Online_Status__c = dataLeadBody.onlineStatus.get(index);
                    historicals.add(historical);
                    if(dateContact != null){
                        dateContactLead = dateContact;
                    }
                    if(dataLeadBody.notes.get(index) != ''){
                        freeTextAnswer += dataLeadBody.questionNames.get(index) + '.' + dataLeadBody.notes.get(index) + ',';
                    }
                    if(numberVal != null){
                        numberAnswer += dataLeadBody.questionNames.get(index) + '.' + numberVal + ',';
                    }
                    if(dataLeadBody.statusLead.get(index) != ''){
                        leadStatus = dataLeadBody.statusLead.get(index);
                    }
                    if(dataLeadBody.onlineStatus.get(index) != ''){
                        statusOnline = dataLeadBody.onlineStatus.get(index);
                    }
                    index++;
            	}
                //insert historicals;
                List<Database.SaveResult> results = Database.insert(historicals);               
                if(leadStatus != ''){
                    lead.status = leadStatus;
                    if(!leadStatusExcluedStampDate.contains(leadStatus)){
                        dateContactLead = null;
                        lead.Next_Contact_Date__c = dateContactLead;
                    }
                }
                if(dateContactLead != null){
                    lead.Next_Contact_Date__c = dateContactLead;
                }
                lead.Script_Free_Text_Answer__c = freeTextAnswer.removeEnd(',');
                lead.Script_Number_Answer__c = numberAnswer.removeEnd(',');
                if(statusOnline != ''){
                    lead.Online_Status__c = statusOnline;
                }
                //TriggerHandler.bypass('LeadTriggerHandler');
                update lead;
                //TriggerHandler.clearBypass('LeadTriggerHandler');
                
                resp.result = 'SUCCESS';
                resp.message = 'Saved results: ' + results;
                //System.debug(resp.message);
            }
        } catch (Exception e) {
            resp.result = 'ERROR';
            resp.message = e.getMessage();
        }
        return JSON.serialize(resp);
    }

	public class ResultResponse{
        public String result;
        public String message;
        //public List<Telesales_Lead_Flow__c> telesales;
        public ResultResponse() {
            result = 'SUCCESS';
        }
    }

    public class DataTeleSaleLead{
        public String leadId;
        public String[] questions;
        public String[] answers;
        public String[] contactDate;
        public String[] notes;
        public String[] numbers;
        public String[] statusLead;
        public String[] onlineStatus;
        public String[] questionNames;

        public DataTeleSaleLead() {
        }
    }
    
}