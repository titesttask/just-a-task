import { LightningElement, wire, api } from 'lwc';
import getCustomerTrips from '@salesforce/apex/CustomersAndTripsController.getCustomerTrips';

export default class CustomersAndTripsComponent extends LightningElement {
    @api recordId;
    @wire(getCustomerTrips, { recordId: '$recordId' }) customerTrips;
}