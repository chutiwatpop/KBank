({
	doInit : function(component, event, helper) {

        var today = new Date(); 
        component.set("v.today", today.toISOString());
        var mRecordId = component.get('v.recordId');
        if(mRecordId == null){
            //mRecordId = '00Q0l000004sLaAEAU';
        }
        //alert(mRecordId);
        var questionMap = {};
        var questionTelesale = {};
        
        var getTeleSalesAllQuestion = component.get('c.getAllQuestions');
         getTeleSalesAllQuestion.setParams({
            "leadId" :  mRecordId
        });
        getTeleSalesAllQuestion.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                //console.log('DataAllTeleSale : ' + a.getReturnValue());
                component.set("v.allQuestions", a.getReturnValue());
                helper.getFirstQuestion(component,a.getReturnValue(),helper);                      
            }
        });

           $A.enqueueAction(getTeleSalesAllQuestion); 	
	},
    handleChange: function (component, event) {
        //var changeValue = event.getParam("value");
        //component.set("v.radioGrpValue" , changeValue);
    },
    nextClick: function (component, event, helper) {
        var radioGrpValue = component.get("v.radioGrpValue");
        //alert(radioGrpValue); 
        if(radioGrpValue == null){
           alert('Please select answer!!!'); 
        }else{
            var answerData = radioGrpValue.split(",");  
                var freeNumberList = component.get("v.freeNumberList");
            	var freeNumberListHistory = component.get("v.freeNumberListHistory");
                if(answerData[3] == 'false'){
                    freeNumberList.push('');
                    component.set("v.freeNumberList",freeNumberList);
                }else{
                    var numberText = component.get("v.numberText");
                    if(numberText == '' || numberText == null){
                        alert('กรุณากรอกวงเงิน');
                        return;
                    }else{
                        freeNumberList.push(numberText.toString());
                        freeNumberListHistory.push(numberText.toString());
                    	component.set("v.freeNumberList",freeNumberList);
                        component.set("v.freeNumberListHistory",freeNumberListHistory);
                        component.set("v.numberText", '');
                    }
                } 
                var freeTextList = component.get("v.freeTextList");
            	var freeTextListHistory = component.get("v.freeTextListHistory");
                if(answerData[4] == 'false'){
                    freeTextList.push('');
                    component.set("v.freeTextList",freeTextList);
                }else{ 
                    var noteText = component.get("v.noteText");
                    if(noteText == ''){
						alert('กรุณากรอกรายละเอียด');
                        freeNumberList.pop();
                        component.set("v.freeNumberList",freeNumberList);
                        return;                        
                    }else{
                        freeTextList.push(noteText);
                        freeTextListHistory.push(noteText);
                        component.set("v.freeTextList",freeTextList);
                        component.set("v.freeTextListHistory",freeTextListHistory);
                        component.set("v.noteText", '');
                    } 
                }
            var dateStringList = component.get("v.dateStringList");
                if(answerData[2] == 'false'){
                    dateStringList.push('');
                    component.set("v.dateStringList", dateStringList);
                }else{
                    var todayVal = component.find("expdate").get("v.value");
                    dateStringList.push(todayVal);
          			component.set("v.dateStringList", dateStringList);
                } 
            var statusLeadList = component.get("v.statusLeadList");
                if(answerData[5] == 'null'){
                    statusLeadList.push('');
                    component.set("v.statusLeadList", statusLeadList); 
                }else{
                    statusLeadList.push(answerData[5]);
                    component.set("v.statusLeadList", statusLeadList); 
                }
            var onlineStatusList = component.get("v.onlineStatusList");
                if(answerData[6] == 'null'){
                    onlineStatusList.push('');
                    component.set("v.onlineStatusList", onlineStatusList); 
                }else{
                    onlineStatusList.push(answerData[6]);
                    component.set("v.onlineStatusList", onlineStatusList); 
                }
            
            var showBackButton = component.find("backButton");
    		$A.util.addClass(showBackButton, "ShowButton");
            //Save last 2 question
            var lastQuestion = component.get("v.lastQuestion");
            if(lastQuestion.length >= 2){
                //lastQuestion.shift();
            }
            lastQuestion.push(component.get("v.idQuestion"));
            component.set("v.lastQuestion", lastQuestion);
            var lastAnswer = component.get("v.lastAnswer");
            if(lastAnswer.length >= 2){
                //lastAnswer.shift();
            }
            lastAnswer.push(radioGrpValue);
            component.set("v.lastAnswer", lastAnswer);
            //Save Data
            var questionList = component.get("v.questionList");
            questionList.push(component.get("v.idQuestion"));
            component.set("v.questionList",questionList);
            var answerList = component.get("v.answerList");
            answerList.push(answerData[0]);
            component.set("v.answerList",answerList);    
                   
            var mapQuestions = component.get("v.mapQuestions");
            //console.log('mapQuestions0 : '+mapQuestions);
            mapQuestions[component.get("v.idQuestion")] = answerData[0];
            //console.log('mapQuestions : '+mapQuestions);
            component.set("v.mapQuestions",mapQuestions);
            
            //console.log('Next Question : '+answerData[1]);
            if(answerData[1] == 'null'){
                helper.saveQuestion(component, helper);
                return;
            }
            component.set("v.radioGrpValue",null)
            var allQuestions = JSON.parse(component.get("v.allQuestions"));
            //console.log('allQuestions : ', allQuestions);         
            if(allQuestions != null) {
                	var isNotHaveNextQuestion = true;
                    for (var i = 0; i < Object.keys(allQuestions).length; i++) {
                         if(Object.values(allQuestions)[i].id == answerData[1]){ 
                             var radioData = [];
                             var answers = Object.values(allQuestions)[i].answer;
                             if(answers != null){
                                 var sortName = answers.slice(0);
                                 sortName.sort(function(a,b) {
                                    var x = a.name.toLowerCase();
                                    var y = b.name.toLowerCase();
                                    return x < y ? -1 : x > y ? 1 : 0;
                                 });
                                 component.set("v.isHasDate", false);
                                 Object.entries(sortName).forEach(([key, value]) => {
                                     //console.log('Answer : ' +value.text);
                                     var element = {};
                                     element.label = value.text;
                            		 element.value = value.id+','+value.next+','+value.isContactDate+','+value.isNumberInput+','+value.isFreeText+','+value.status+','+value.onlineStatus;
                                     radioData.push(element);
                                 
                                 	 helper.checkDisableInput(component, value); 
                                 });
                             }
                            //console.log('RadioData : '+radioData);
                            component.set("v.numberQuestion", Object.values(allQuestions)[i].name);
                        	component.set("v.question", Object.values(allQuestions)[i].text);
                            component.set("v.idQuestion", Object.values(allQuestions)[i].id);         
                            component.set("v.options", radioData);
                            component.set("v.radioGrpValue", radioData[0].value);
                        	var questionNameList = component.get("v.questionNameList");
                            questionNameList.push(Object.values(allQuestions)[i].name);
                            component.set("v.questionNameList", questionNameList);
                        	isNotHaveNextQuestion = false;
                        	break;
                         }else{
                              //isNotAnyQuestion = true;           
                         }
                    }
            			if(isNotHaveNextQuestion){
                        	helper.showToast('ชุดข้อมูล Flow มีข้อผิดพลาด', 'error');
                        }
                }
        }
        
    },
    backClick: function (component, event, helper) {      
        helper.checkDisableBackButton(component);   
        //console.log('lastQuestionBack : '+lastQuestion);
        //Remove last array
    	var dateStringList = component.get("v.dateStringList");
        dateStringList.pop();
        component.set("v.dateStringList",dateStringList);    
        var questionList = component.get("v.questionList");
        questionList.pop();
        component.set("v.questionList",questionList);
        var answerList = component.get("v.answerList");
        answerList.pop();
        component.set("v.answerList",answerList);
    	var freeNumberList = component.get("v.freeNumberList");
        freeNumberList.pop();
        component.set("v.freeNumberList",freeNumberList);
    	var freeTextList = component.get("v.freeTextList");
        freeTextList.pop();
        component.set("v.freeTextList",freeTextList);
    	var statusLeadList = component.get("v.statusLeadList");
        statusLeadList.pop();
        component.set("v.statusLeadList",statusLeadList);
    	var onlineStatusList = component.get("v.onlineStatusList");
        onlineStatusList.pop();
        component.set("v.onlineStatusList",onlineStatusList);
    	var questionNameList = component.get("v.questionNameList");
        questionNameList.pop();
        component.set("v.questionNameList",questionNameList);
        
        var lastQuestion = component.get("v.lastQuestion");
        var lastAnswer = component.get("v.lastAnswer");
        var lastIdQuestion = lastQuestion.pop();
        var lastIdAnswer = lastAnswer.pop();
        var isLastFreeText = false;
    	var isLastFreeNumber = false;
        var allQuestions = JSON.parse(component.get("v.allQuestions"));
            //console.log('allQuestions : ', allQuestions);          
            if(allQuestions != null) {
                    for (var i = 0; i < Object.keys(allQuestions).length; i++) {
                         if(Object.values(allQuestions)[i].id == lastIdQuestion){                            
                             var radioData = [];
                             var answers = Object.values(allQuestions)[i].answer;
                             if(answers != null){
                                 var sortName = answers.slice(0);
                                 sortName.sort(function(a,b) {
                                    var x = a.name.toLowerCase();
                                    var y = b.name.toLowerCase();
                                    return x < y ? -1 : x > y ? 1 : 0;
                                 });
                                 component.set("v.isHasDate", false);
                                 Object.entries(sortName).forEach(([key, value]) => {
                                     //console.log('Answer : ' +value.text);
                                     var element = {};
                                     element.label = value.text;
                            		 element.value = value.id+','+value.next+','+value.isContactDate+','+value.isNumberInput+','+value.isFreeText+','+value.status+','+value.onlineStatus;
                                     radioData.push(element);
                                 
                                 	 helper.checkDisableInput(component, value);
                                 	 if(value.isFreeText == 'true'){
                                         isLastFreeText = true;
                                     }
                                 	 if(value.isNumberInput == 'true'){
                                 		 isLastFreeNumber = true;
                                     }
                                 });
                             }
                            //console.log('RadioData : '+radioData);
                            component.set("v.numberQuestion", Object.values(allQuestions)[i].name);
                        	component.set("v.question", Object.values(allQuestions)[i].text);
                            component.set("v.idQuestion", Object.values(allQuestions)[i].id);         
                            component.set("v.options", radioData);
                            //console.log('Last Answer2 : '+component.get("v.lastAnswer"));
                            component.set("v.radioGrpValue", lastIdAnswer);     
                            component.set("v.lastQuestion",lastQuestion); 
                            component.set("v.lastAnswer",lastAnswer);
                        	if(isLastFreeText){
                                var lastFreeText = component.get("v.freeTextListHistory");
                                component.set("v.noteText",lastFreeText.pop());
                                component.set("v.freeTextListHistory",lastFreeText); 
                            }
                        	if(isLastFreeNumber){
                                var lastFreeNumber = component.get("v.freeNumberListHistory");
                                component.set("v.numberText",lastFreeNumber.pop());
                                component.set("v.freeNumberListHistory",lastFreeNumber); 
                            }
                        	break;
                         }
                    }    
                       helper.checkDisableBackButton(component);              
                }
    },
    saveTeleSale: function (component, event, helper) {
        helper.saveQuestion(component);
    },
    cancelTeleSale: function (component, event, helper) {
       helper.getFirstQuestion(component,component.get("v.allQuestions"),helper);
    }
})