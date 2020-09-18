public with sharing class CustomersAndTripsController {
    @AuraEnabled(cacheable=true)
    public static List<CustomersAndTrips__c> getCustomerTrips(Id recordId) {
        List<ClaimsAndCustomers__c> claims = [
            SELECT Id, Case__c, Customer__c
            FROM ClaimsAndCustomers__c
            WHERE Case__c = :recordId
            WITH SECURITY_ENFORCED
        ];

        Set<Id> customerIds = new Set<Id>(); 
        for (ClaimsAndCustomers__c claimItem : claims) {
            customerIds.add(claimItem.Customer__c);
        }

        List<CustomersAndTrips__c> customerTrips = [
            SELECT Id, Customer__c, Customer__r.Name, Trip__r.Name
            FROM CustomersAndTrips__c
            WHERE Customer__c IN :customerIds
            WITH SECURITY_ENFORCED
        ];
        return customerTrips;
    }
}
