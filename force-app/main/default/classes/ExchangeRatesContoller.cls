public with sharing class ExchangeRatesContoller {
    @AuraEnabled(cacheable=true)
    public static Exchange_Rate__c getBTCRate(){
        try {
            // Retrieve the BTC Rates from Salesforce Data using ExchangeRatesService
            Exchange_Rate__c BTCRate = ExchangeRatesService.getBTCRate();
            return BTCRate;
        } catch (Exception e) {
            System.debug(loggingLevel.ERROR, e.getMessage());
            throw new AuraHandledException('Cannot find BitCoin Exchange Rate.');
        }
    }

    @AuraEnabled
    public static Exchange_Rate__c updateExchangeRates() {
        try {
            // Call API to refresh the BTC Rates using ExchangeRatesService            
            ExchangeRatesService.updateExchangeRates();

            // Return the latest rate
            return getBTCRate();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());            
        }
    }
    
    // Callout from scheduled Apex is not supported
    // To fix this, call a future or queueable from the scheduled job.
    @future(callout=true)
    public static void schedulingExchangeRatesUpdate() {
    	ExchangeRatesService.updateExchangeRates();
    }
}