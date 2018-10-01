public class UnitOfWork {

    @TestVisible
	protected List<Schema.SObjectType> sObjectList = new List<Schema.SObjectType>();
    protected Map<String, List<SObject>> newListMapByType = new Map<String, List<SObject>>();
    protected Map<String, Map<Id, SObject>> updateListMapByType = new Map<String, Map<Id, SObject>>();
    protected Map<String, Map<Id, SObject>> updateByPassListMapByType = new Map<String, Map<Id, SObject>>();
    protected Map<String, Map<Id, SObject>> deleteListMapByType = new Map<String, Map<Id, SObject>>();
    protected IDML mDML;

    private static UnitOfWork uowInstance;

    public UnitOfWork() {}

    private UnitOfWork(List<Schema.SObjectType> sObjectTypes) {
        this(sObjectTypes, new DBServiceDML());
    }

    private UnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml) {
        sObjectList = sObjectTypes.clone();
        for(Schema.SObjectType sObjectType : sObjectList) {
            handleRegisterType(sObjectType);
        }
        mDML = dml;
    }

    public static UnitOfWork getInstance() {
    	if(uowInstance == null) {
    		uowInstance = new UnitOfWork(new List<Schema.SObjectType>{// Add SObject Type here
    			Account.SObjectType,
                Contact.SObjectType
    		});
    	}
    	return uowInstance;
    }

    public void setSObjectList(List<Schema.SObjectType> sObjectTypes) {
        sObjectList = sObjectTypes.clone();
        for(Schema.SObjectType sObjectType : sObjectList) {
            handleRegisterType(sObjectType);
        }
    }

    public void setDML(IDML mDML) {
        this.mDML = mDML;
    }

    private void handleRegisterType(Schema.SObjectType sObjectType) {
        // add type to dml operation tracking
        newListMapByType.put(sObjectType.getDescribe().getName(), new List<SObject>());
        updateListMapByType.put(sObjectType.getDescribe().getName(), new Map<Id, SObject>());
        updateByPassListMapByType.put(sObjectType.getDescribe().getName(), new Map<Id, SObject>());
        deleteListMapByType.put(sObjectType.getDescribe().getName(), new Map<Id, SObject>());
    }

	public void registerNew(SObject record) {
        if(record.Id != null) {
            throw new UnitOfWorkException(Label.CANNOT_REGISTERED_NEW);
        }
		String sObjectType = record.getSObjectType().getDescribe().getName();
		if(!newListMapByType.containsKey(sObjectType)) {
			throw new UnitOfWorkException(String.format(Label.TYPE_NOT_SUPPORTED, new String[] { sObjectType }));
		}
		newListMapByType.get(sObjectType).add(record);
    }

    public void registerNew(List<SObject> records) {
        for(SObject record : records) {
            registerNew(record);
        }
    }

	public void registerUpdate(SObject record) {
        if(record.Id == null) {
            throw new UnitOfWorkException(Label.NEW_RECORD_CANNOT_UPDATE);
        }
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!updateListMapByType.containsKey(sObjectType)) {
            throw new UnitOfWorkException(String.format(Label.TYPE_NOT_SUPPORTED, new String[] { sObjectType }));
        }
        updateListMapByType.get(sObjectType).put(record.Id, record);
    }

    public void registerUpdate(List<SObject> records) {
        for(SObject record : records) {
            this.registerUpdate(record);
        }
    }

    public void registerUpdateByPass(SObject record) {
        if(record.Id == null) {
            throw new UnitOfWorkException(Label.NEW_RECORD_CANNOT_UPDATE);
        }
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!updateByPassListMapByType.containsKey(sObjectType)) {
            throw new UnitOfWorkException(String.format(Label.TYPE_NOT_SUPPORTED, new String[] { sObjectType }));
        }
        updateByPassListMapByType.get(sObjectType).put(record.Id, record);
    }

    public void registerUpdateByPass(List<SObject> records) {
        for(SObject record : records) {
            this.registerUpdateByPass(record);
        }
    }

    public void registerDeleted(SObject record) {
        if(record.Id == null) {
            throw new UnitOfWorkException(Label.NEW_RECORD_CANNOT_DELETE);
        }
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!deleteListMapByType.containsKey(sObjectType)) {
            throw new UnitOfWorkException(String.format(Label.TYPE_NOT_SUPPORTED, new String[] { sObjectType }));
        }
        deleteListMapByType.get(sObjectType).put(record.Id, record);
    }

    public void registerDeleted(List<SObject> records) {
        for(SObject record : records) {
            this.registerDeleted(record);
        }
    }

    public void commitWork() {
    	Savepoint sp = Database.setSavePoint();
    	try {
            mDML.commmitUnitOfWork(this);
		} catch(Exception ex) {
            Database.rollback(sp);
            throw ex;
		}
    }

    @TestVisible
    private class SimpleDML implements IDML {
        public void dmlInsert(List<SObject> objList){
            if(!objList.isEmpty())
            insert objList;
        }
        public void dmlUpdate(List<SObject> objList){
            if(!objList.isEmpty())
            update objList;
        }
        public void dmlDelete(List<SObject> objList){
            if(!objList.isEmpty())
            delete objList;
        }
        public void commmitUnitOfWork(UnitOfWork uow) {
            for(Schema.SObjectType sObjectType : uow.sObjectList) {
                dmlInsert(uow.newListMapByType.get(sObjectType.getDescribe().getName()));
            }   
            for(Schema.SObjectType sObjectType : uow.sObjectList) {
                dmlUpdate(uow.updateListMapByType.get(sObjectType.getDescribe().getName()).values());
            }
            Integer objectIdex = uow.sObjectList.size() - 1;
            while(objectIdex >= 0) {
                dmlDelete(uow.deleteListMapByType.get(uow.sObjectList[objectIdex--].getDescribe().getName()).values());
            }
        }
    }

    private class DBServiceDML implements IDMLUpdateWithByPassable, IDML {
    	List<Database.SaveResult> dbErrorList;

        public void dmlInsert(List<SObject> objList){
            if(!objList.isEmpty())
            this.dbErrorList = DB_Service.insertsObject(objList);
        }
        public void dmlUpdate(List<SObject> objList){
        	if(!objList.isEmpty())
            this.dbErrorList = DB_Service.updateSObject(objList, false);
        }
        public void dmlDelete(List<SObject> objList){
            if(!objList.isEmpty())
            delete objList;
        }
        public void dmlUpdateWithByPass(List<SObject> objList) {
            if(!objList.isEmpty())
            this.dbErrorList = DB_Service.updateSObjectWithBypass(objList, false);
        }
        public void commmitUnitOfWork(UnitOfWork uow) {
            for(Schema.SObjectType sObjectType : uow.sObjectList) {
                dmlInsert(uow.newListMapByType.get(sObjectType.getDescribe().getName()));
            }   
            for(Schema.SObjectType sObjectType : uow.sObjectList) {
                dmlUpdate(uow.updateListMapByType.get(sObjectType.getDescribe().getName()).values());
            }
            Integer objectIdex = uow.sObjectList.size() - 1;
            while(objectIdex >= 0) {
                dmlDelete(uow.deleteListMapByType.get(uow.sObjectList[objectIdex--].getDescribe().getName()).values());
            }
            for(Schema.SObjectType sObjectType : uow.sObjectList) {
                dmlUpdateWithByPass(uow.updateByPassListMapByType.get(sObjectType.getDescribe().getName()).values());
            }
        }
    }

    public interface IDMLUpdateWithByPassable {
        void dmlUpdateWithByPass(List<SObject> objList);
    }

    public interface IDML {
        void dmlInsert(List<SObject> objList);
        void dmlUpdate(List<SObject> objList);
        void dmlDelete(List<SObject> objList);
        void commmitUnitOfWork(UnitOfWork uow);
    }

	public class UnitOfWorkException extends Exception {}
}