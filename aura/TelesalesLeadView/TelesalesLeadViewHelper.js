({
	getFirstQuestion : function(component, data, helper) {
		var resp = JSON.parse(data);
        if(resp != null) {
             for (var i = 0; i < Object.keys(resp).length; i++) {
                         if(Object.values(resp)[i].isFirst == 'true'){                            
                             var radioData = [];
                             var answers = Object.values(resp)[i].answer;
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
                            component.set("v.numberQuestion", Object.values(resp)[i].name);
                        	component.set("v.question", Object.values(resp)[i].text);
                            component.set("v.idQuestion", Object.values(resp)[i].id);         
                            component.set("v.options", radioData);
                            component.set("v.radioGrpValue", radioData[0].value);
                 			var questionNameList = component.get("v.questionNameList");
                            questionNameList.push(Object.values(resp)[i].name);
                            component.set("v.questionNameList", questionNameList);
                        	break;
                         }
                    }                          
          }
        component.set("v.mapQuestions",{});
        component.set("v.questionList",[]);
        component.set("v.answerList",[]);
		component.set("v.lastQuestion",[]);
		component.set("v.lastAnswer",[]);
		component.set("v.dateStringList", []);
		component.set("v.numberText", '');
		component.set("v.noteText", '');
		component.set("v.freeNumberList",[]);
		component.set("v.freeTextList",[]);
		component.set("v.freeNumberListHistory",[]);
		component.set("v.freeTextListHistory",[]);
		component.set("v.statusLeadList", []);
		component.set("v.onlineStatusList", []);
		component.set("v.questionNameList", []);
		component.set("v.isHasDate", false);
		helper.checkDisableBackButton(component); 
	},
     saveQuestion : function(component, helper) {
        var mRecordId = component.get('v.recordId');
         if(mRecordId == null){
            //mRecordId = '00Q0l000004sLaAEAU';
        }
        if(mRecordId != null){
            var questions = component.get("v.questionList");
            var answers = component.get("v.answerList");
            var contactDate = component.get("v.dateStringList");
            var freeTexts = component.get("v.freeTextList");
            var freeNumbers = component.get("v.freeNumberList");
            var statusLead = component.get("v.statusLeadList");
            var onlineStatus = component.get("v.onlineStatusList");
            var questionNames = component.get("v.questionNameList");
            
            var dataTeleSaleLead = { "leadId": mRecordId, "questions": questions, "answers": answers
                                    , "contactDate": contactDate, "notes": freeTexts, "numbers": freeNumbers
                                   , "statusLead": statusLead, "onlineStatus": onlineStatus, "questionNames": questionNames};
            var leadData = JSON.stringify(dataTeleSaleLead);
            //console.log('dataTeleSaleLead : ' + leadData);
            var saveTeleSalesAllQuestion = component.get('c.save');
             saveTeleSalesAllQuestion.setParams({
                 "fieldListJSON" : leadData
            });
            saveTeleSalesAllQuestion.setCallback(this, function(a){
                var state = a.getState(); // get the response state
                if(state == 'SUCCESS') {
                    var resp = JSON.parse(a.getReturnValue());
                    //console.log('value Save : '+resp);
                    if(resp.result == 'SUCCESS') {
                        $A.get('e.force:refreshView').fire();
                        //alert('หมดชุดคำถาม ระบบได้ทำการบันทึกข้อมูลเรียบร้อยแล้ว');
                        helper.showToast('หมดชุดคำถาม ระบบได้ทำการบันทึกข้อมูลเรียบร้อยแล้ว', 'success');
                        //component.set("v.questionList",[]);
                        //component.set("v.answerList",[]); 
                        helper.getFirstQuestion(component,component.get("v.allQuestions"),helper);
                    }else{
                        helper.showToast(resp.message, 'error');
                    }
            	}
            })
            
            $A.enqueueAction(saveTeleSalesAllQuestion);   
        }
                                
     } ,
     checkDisableBackButton : function(component) {
        var lastQuestion = component.get("v.lastQuestion");
        var lastAnswer = component.get("v.lastAnswer");
        if(lastQuestion.length == 0 && lastAnswer.length == 0){
           var disableBackButton = component.find("backButton");
           $A.util.removeClass(disableBackButton, 'ShowButton') 
        } 
     },
     checkDisableInput : function(component, value) {
         var showInputNumber = component.find("inputNumber");
         var showInputText = component.find("freeText");
         var showInputDate = component.find("inputDate");        
        if(value.isNumberInput == 'true'){
          $A.util.removeClass(showInputNumber, 'HideInput');
          component.set("v.isHasNumber", true);
        }else{
          $A.util.addClass(showInputNumber, 'HideInput');
          component.set("v.isHasNumber", false);
        }
        if(value.isFreeText == 'true'){
          $A.util.removeClass(showInputText, 'HideInput');
          component.set("v.isHasText", true);
        }else{
          $A.util.addClass(showInputText, 'HideInput');
          component.set("v.isHasText", false);  
       }
         if(!component.get("v.isHasDate")){     
            if(value.isContactDate == 'true'){
              $A.util.removeClass(showInputDate, 'HideInput');
              component.set("v.isHasDate", true);
           }else{
             $A.util.addClass(showInputDate, 'HideInput');  
           } 
         }  
       
         if(value.status != null){
             component.set("v.isHasStatusLead", true); 
         }else{
             component.set("v.isHasStatusLead", false); 
         }
         if(value.onlineStatus != null){
             component.set("v.isHasOnlineStatus", true); 
         }else{
             component.set("v.isHasOnlineStatus", false); 
         }
     },
    showToast: function(message, type) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "mode": "dismissible",
            "message": message,
            "type": type,
            "duration": "5000"
        });
        resultsToast.fire();
    }
})