/**
* @author chutiwat.s@beryl8.com
* @07/09/2015 createddate
*/
global class CampaignSharing_Service {
	/*public static Boolean runOnce = false;
	global class Response {
        webservice Boolean success{get;set;}
        webservice String msg{get;set;}
	}
	
	global class CampaignSharingException extends Exception{}

	webservice static Response shareCampaign(String campaignString) {
		Response resp = new Response();

		try {
            Campaign campaignObj = (Campaign) JSON.deserialize(campaignString, Campaign.class);
            getSubordinateAndCreateNewEvent(campaignObj);

            resp.success = true;
        } catch(Exception ex) {
            resp.success = false;
            resp.msg = ex.getMessage();
        }

		return resp;	
	}

	global static void getSubordinateAndCreateNewEvent(Campaign campaignObj) {
		try {
			//List<User> userList = UserRoleUtils.getInstance().userList;
    		List<Event> newEventList = new List<Event>();
			List<EventRelation> newEventRelationList = new List<EventRelation>();
			List<CampaignShare> campaignShareList = new List<CampaignShare>();
			campaignShareList = [SELECT UserOrGroupId,CampaignId FROM CampaignShare WHERE CampaignId=:campaignObj.Id];
    		//for (User user : userList) {
    			// Create 2 Event
    			// 1st Event
    			Event invitationEvent = new Event();
    			invitationEvent.OwnerId = campaignObj.OwnerId;
    			invitationEvent.StartDateTime = campaignObj.Attendee_Confirmation_Date__c;
    			invitationEvent.EndDateTime = ((Datetime) campaignObj.Attendee_Confirmation_Date__c).addHours(1);
    			invitationEvent.Subject = campaignObj.Name+' Confirmation Date';
				invitationEvent.Type = GlobalConstants.INVITATION;
				invitationEvent.WhatID = campaignObj.ID;

				// 2nd Event
				Event campaignEvent = new Event();
    			campaignEvent.OwnerId = campaignObj.OwnerId;
    			campaignEvent.StartDateTime = campaignObj.Start_Date_Time__c;
    			campaignEvent.EndDateTime = campaignObj.End_Date_Time__c;
    			campaignEvent.Subject = 'New Event:'+campaignObj.Name;
				campaignEvent.Type = GlobalConstants.EVENT;
				campaignEvent.WhatID = campaignObj.ID;

				// add new event
				newEventList.add(invitationEvent);
				newEventList.add(campaignEvent);
			//}

			insert newEventList;
			for (CampaignShare eachCampaignShare : campaignShareList) {
				if(eachCampaignShare.UserOrGroupId!=campaignObj.OwnerId){
					newEventRelationList.add(new EventRelation(
	                    EventId = invitationEvent.Id,
	                    RelationId = eachCampaignShare.UserOrGroupId
	                ));
	                newEventRelationList.add(new EventRelation(
	                    EventId = campaignEvent.Id,
	                    RelationId = eachCampaignShare.UserOrGroupId
	                ));
	            }
			}
			insert newEventRelationList;
			if (!campaignShareList.isEmpty()) {
				//shareCampaign(campaignObj);
				sendEmail(campaignShareList);
			} else {
				throw new CampaignSharingException('No Subordinate User');
			}
		} catch (Exception ex) {
			throw new CampaignSharingException(ex.getMessage());
		}

	}

	global static void shareCampaign(Campaign campaignObj) {
		try {
			List<CampaignShare> campaignShareList = new List<CampaignShare>(); 
    		List<Group> groupList = new List<Group>();
    		groupList = [SELECT Id,Type FROM Group WHERE RelatedId = :UserInfo.getUserRoleId() AND Type = :GlobalConstants.ROLE_AND_SUBORDINATE];
    	
    		if (!groupList.isEmpty()) {
    			for (Group eachGroup : groupList) {
					CampaignShare cmpShare = new CampaignShare();
					cmpShare.CampaignAccessLevel = GlobalConstants.READ;
					cmpShare.UserOrGroupId = eachGroup.Id;
					cmpShare.CampaignId = campaignObj.Id;
    				campaignShareList.add(cmpShare);
    			}
    		
    			insert campaignShareList;
    		} else {
    			throw new CampaignSharingException('No Group of Subordinate User');
    		}
		} catch (Exception ex) {
			throw new CampaignSharingException(ex.getMessage());
		}
		
	}

	global static void sendEmail(List<CampaignShare> campaignShareList) {
		try {
			EmailTemplate emailNewTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :GlobalConstants.SME_EMAIL_TEMPLATE_NEW_EVENT LIMIT 1];
        	List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

			for(CampaignShare eachCampaignShare : campaignShareList) {
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            	email.setTemplateId(emailNewTemplate.Id);
            	email.setTargetObjectId(eachCampaignShare.UserOrGroupId);
            	email.setSaveAsActivity(false);
            	emails.add(email);
			}

			Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
		} catch (Exception ex) {
			throw new CampaignSharingException(ex.getMessage());
		}	
		
	}*/
}