/**
* @author Chrnun.t@beryl8.com
* @08/09/2015 create new
*/
public without sharing class SME_BulkAssignment_Model{
    public class SelectedName {
    	public String selectedbyname;
    	public String selectedByRMName;
    	public String selectedbyAHname;
        public String selectedTeamName;
        public String selectedAreaName;
    	public String filterByRMName;
        public String portPoolpanel;
        public String serviceRMpanel;
        public String temporaryRMpanel;
        public String selectedByTeamRCCode;
        public String selectedByUserId;
        public String requestReason;
        public String requestReasonText;
        public String rejectReason;
        public String rejectReasonText;
        public String portPanel;

    }
    public class SavingRequest {
        public String contx;
        public SelectedName selectName;
        public List<String> bulkCISlist;
        public List<SalesTarget> salesTargets;
        public List<String> approvalIdList;
        public String gridName;
        public Boolean fromCBS;
        public Boolean fromAF;
    }

    public class SalesTarget {
        public String salesTargetId;
        public String transactionFeeNewTarget;
        public String mainOperatingBankNewTarget;
        public String dealBaseFeeNewTarget;
    }
}