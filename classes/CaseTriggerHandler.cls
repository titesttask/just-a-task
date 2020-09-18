public with sharing class CaseTriggerHandler {
    private static final Integer TRIP_ID_LEN = 7;
    private static final String CASE_ORIGIN = 'Email';
    private static final String SEARCH_STRING = 'T#';

    public static void setCaseToCustomer(List<Case> cases) {
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

        List<ClaimsAndCustomers__c> customerClaimsToInsert = new List<ClaimsAndCustomers__c>();

        for (Id caseIdItem : tripIdByCaseId.keySet()) {
            String strTripId = tripIdByCaseId.get(caseIdItem);
            for (CustomersAndTrips__c customerTripItem : customerTrips) {
                if (customerTripItem.Trip__r.TripID__c == strTripId) {
                    customerClaimsToInsert.add(new ClaimsAndCustomers__c(
                        Case__c = caseIdItem, 
                        Customer__c = customerTripItem.Customer__c
                    ));
                }
            }
        }

        insert customerClaimsToInsert;
    }
}