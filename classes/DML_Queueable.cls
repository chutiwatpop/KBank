global class DML_Queueable implements Queueable {
	private List<DML_Object> listDmlObject = new List<DML_Object>();
	public enum ENUM_OPERATION {INSERT_OPERATION,UPDATE_OPERATION,DELETE_OPERATION,UPSERT_OPERATION}

	public class DML_Object {
		List<SObject> dmlList;
		DML_Queueable.ENUM_OPERATION operation;
		Schema.SObjectField externalField;
		String bypassTriggerName;
	}

	public void setDmlList(List<SObject> inputDmlList,ENUM_OPERATION operation){
		DML_Object dataStore = new DML_Object();
		dataStore.dmlList = inputDmlList;
		dataStore.operation = operation;
		listDmlObject.add(dataStore);
	}

	public void setDmlList(List<SObject> inputDmlList,ENUM_OPERATION operation,String bypassTrigger){
		DML_Object dataStore = new DML_Object();
		dataStore.dmlList = inputDmlList;
		dataStore.operation = operation;
		dataStore.bypassTriggerName = bypassTrigger;
		listDmlObject.add(dataStore);
	}

	public void setDmlList(List<SObject> inputDmlList,Schema.SObjectField externalField,ENUM_OPERATION operation){
		DML_Object dataStore = new DML_Object();
		dataStore.dmlList = inputDmlList;
		dataStore.operation = operation;
		dataStore.externalField = externalField;
		listDmlObject.add(dataStore);
	}

	public void setDmlList(List<SObject> inputDmlList,Schema.SObjectField externalField,ENUM_OPERATION operation,String bypassTrigger){
		DML_Object dataStore = new DML_Object();
		dataStore.dmlList = inputDmlList;
		dataStore.operation = operation;
		dataStore.externalField = externalField;
		dataStore.bypassTriggerName = bypassTrigger;
		listDmlObject.add(dataStore);
	}

	public void execute(QueueableContext context) {
		for(DML_Object dataStore : listDmlObject){
			if(dataStore.bypassTriggerName != null){
				TriggerHandler.bypass(dataStore.bypassTriggerName);
			}
	        if(dataStore.operation == ENUM_OPERATION.INSERT_OPERATION){
	        	Database.insert(dataStore.dmlList,false);
	        }else if(dataStore.operation == ENUM_OPERATION.UPDATE_OPERATION){
	        	Database.update(dataStore.dmlList,false);
	        }else if(dataStore.operation == ENUM_OPERATION.DELETE_OPERATION){
	        	Database.delete(dataStore.dmlList,false);
	        }else if(dataStore.operation == ENUM_OPERATION.UPSERT_OPERATION){
	        	Database.upsert(dataStore.dmlList,dataStore.externalField);
	        }
		}
	}
}