public with sharing class AccountLeadUpdate_Queue implements Queueable {

	public List<Account> updateAccountList;
	public AccountLeadUpdate_Queue(List<Account> updateAccountList) {
		this.updateAccountList = new List<Account>(updateAccountList);
	}

	public void execute(QueueableContext context) {
		try{
            update updateAccountList;
        } catch(Exception dex){
            System.debug('AccountLeadUpdate_Queue Exception:' + dex);
        }
	}
}