@IsTest
private class ExchangeRatesServiceTest {
    @IsTest static void testUpdateExchangeRates() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetExchangeRateResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        // Call method to test
        Test.startTest();
        ExchangeRatesService.updateExchangeRates();
        Test.stopTest();

        // Verify the array contains 2 items     
        List<Exchange_Rate__c> rates = [
            SELECT Name, Rate__c, lastModifiedDate
            FROM Exchange_Rate__c
        ];        
        System.assertEquals(2, rates.size(), 'The array should only contain 2 items.');
    }

    @IsTest static void testUpdateExchangeRatesCalloutException() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetExchangeRateResource');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        // Call method to test
        Test.startTest();
        String errorMsg = 'Cannot get exchange rates from API.';
        try {
        	ExchangeRatesService.updateExchangeRates();
        } catch (Exception e) {
        	// Verify an exception is thrown with the expected message
        	System.assert(e.getMessage().contains(errorMsg), 'Unexpected exception thrown.');
        }
        Test.stopTest();

        // Verify the array contains zero item
        List<Exchange_Rate__c> rates = [
            SELECT Name, Rate__c, lastModifiedDate
            FROM Exchange_Rate__c
        ];        
        System.assertEquals(0, rates.size(), 'The array should only contain zero items.');
    }

    @IsTest static void testUpdateExchangeRatesDMLException() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetInvalidExchangeRateResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        // Call method to test
        Test.startTest();
        String errorMsg = 'Exchange Rates cannot be zero or negative.';
        try {
        	ExchangeRatesService.updateExchangeRates();
        } catch (Exception e) {
        	// Verify an exception is thrown with the expected message
        	System.assert(e.getMessage().contains(errorMsg), 'Unexpected exception thrown.');
        }
        Test.stopTest();

        // Verify the array contains zero item
        List<Exchange_Rate__c> rates = [
            SELECT Name, Rate__c, lastModifiedDate
            FROM Exchange_Rate__c
        ];        
        System.assertEquals(0, rates.size(), 'The array should only contain zero items.');
    }
    
    @IsTest static void testGetBTCRate() {
        // Create test record
        Exchange_Rate__c BTC = new Exchange_Rate__c(Name='BTC', Rate__c=0.5);
        insert BTC;

        // Call method to test
        Test.startTest();
        Exchange_Rate__c result = ExchangeRatesService.getBTCRate();
        Test.stopTest();

        // Verify the result     
        System.assertEquals('BTC', result.Name, 'The name should be BTC.');
        System.assertEquals(0.5, result.Rate__c, 'The rate should be 0.5.');
    }
}