public with sharing class BatchToCheckTripIDs implements Database.Batchable<SObject>, Schedulable {
    private static final Integer TRIP_ID_LEN = 7;
    private static final String CASE_ORIGIN = 'Email';
    private static final String SEARCH_STRING = 'T#';

    public Database.queryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Description, Origin FROM Case');
    }

    public void execute (Database.BatchableContext bc, List<Case> cases) {
        Map<Id, String> tripIdByCaseId = new Map<Id, String>();  

        for (Case caseItem : cases) {
            Integer tripIdPosition = caseItem.Description.indexOf(SEARCH_STRING);
            if (caseItem.Origin == CASE_ORIGIN && tripIdPosition != -1) {
                tripIdByCaseId.put(caseItem.Id, caseItem.Description.substring(tripIdPosition, tripIdPosition + TRIP_ID_LEN));
            }
        }

        List<CustomersAndTrips__c> customerTrips = [
            SELECT  Id, 
                    Customer__c, 
                    Trip__c, 
                    Trip__r.TripID__c 
            FROM CustomersAndTrips__c
        ];

        List<ClaimsAndCustomers__c> customerClaimsToUpdate = [
            SELECT Id, Case__c, Customer__c 
            FROM ClaimsAndCustomers__c
        ];

        for(ClaimsAndCustomers__c customerClaimItem : customerClaimsToUpdate) {
            for (Id caseIdItem : tripIdByCaseId.keySet()) {
                String strTripId = tripIdByCaseId.get(caseIdItem);
                for (CustomersAndTrips__c customerTripItem : customerTrips) {
                    if (customerTripItem.Trip__r.TripID__c == strTripId) {
                        customerClaimItem.Case__c = caseIdItem;    
                        customerClaimItem.Customer__c = customerTripItem.Customer__c;
                    }
                }
            }
        }
        
        update customerClaimsToUpdate;
    }

    public void finish (Database.BatchableContext bc) { }

    public void execute(SchedulableContext sc) {
        database.executebatch(new BatchToCheckTripIDs());
    }
}
