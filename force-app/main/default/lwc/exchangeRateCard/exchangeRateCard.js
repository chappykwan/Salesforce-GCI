import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getBTCRate from '@salesforce/apex/ExchangeRatesContoller.getBTCRate';
import updateExchangeRates from '@salesforce/apex/ExchangeRatesContoller.updateExchangeRates';

export default class ExchangeRateCard extends LightningElement {
  // Exchange Rate Display Fields
  @track rate;
  @track updateDate;
  @track error;

  // Refresh Exchange Rate Button Controls
  @track isButtonDisabled = false;
  @track buttonLabel = 'Update Exchange Rates';

  // Retrieve BTC Rate
  @wire(getBTCRate)
  wiredRates({ data }) {
    if (data) {
      this.rate = data.Rate__c;
      this.updateDate = data.LastModifiedDate;
      this.error = undefined;
    }
  }

  // Refresh Exchange Rate Button Logic
  handleClick() {
    this.isButtonDisabled = true;
    this.buttonLabel = 'Refreshing...';   
    // Call the Apex method
    updateExchangeRates()
      .then(response => {
        this.rate = response.Rate__c;
        this.updateDate = response.LastModifiedDate;
        this.isButtonDisabled = false;
        this.buttonLabel = 'Update Exchange Rates';
      })
      .catch(error => {
        console.log('error: ', error);
        this.showToastMethods('WARNING', 'Exchange Rate cannot be refreshed. Please try again later.');
        this.isButtonDisabled = false;
        this.buttonLabel = 'Update Exchange Rates';
      });
  }

  // Toast for error message which shows when the API call failed
  showToastMethods(title, message) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
    });
    this.dispatchEvent(event);
  }
}