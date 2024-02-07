@IsTest
private class ExchangeRatesControllerTest {
    @IsTest static void testGetBTCRate() {
        // Create test record
        Exchange_Rate__c BTC = new Exchange_Rate__c(Name='BTC', Rate__c=0.5);
        insert BTC;

        // Call method to test
        Test.startTest();
        Exchange_Rate__c result = ExchangeRatesContoller.getBTCRate();
        Test.stopTest();

        // Verify the result     
        System.assertEquals('BTC', result.Name, 'The name should be BTC.');
        System.assertEquals(0.5, result.Rate__c, 'The rate should be 0.5.');
    }

    @IsTest static void testGetBTCRateEmpty() {
        try {
            // Call method to test
            // No test record has been set so the method so return nothing
            Test.startTest();
            Exchange_Rate__c result = ExchangeRatesContoller.getBTCRate();
            Test.stopTest();
        } catch (AuraHandledException e) {
            // Controller should throw an exception
            System.assert(true);
        }
    }

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
        Exchange_Rate__c result = ExchangeRatesContoller.updateExchangeRates();
        Test.stopTest();

        // Verify the array contains 2 items     
        List<Exchange_Rate__c> rates = [
            SELECT Name, Rate__c, lastModifiedDate
            FROM Exchange_Rate__c
        ];        
        System.assertEquals(2, rates.size(), 'The array should only contain 2 items.');
    }

    @IsTest static void testUpdateExchangeRatesFailed() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetExchangeRateResource');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        // Call method to test
        try {
            Test.startTest();
            Exchange_Rate__c result = ExchangeRatesContoller.updateExchangeRates();
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assert(true);
        }

        // Verify the array contains 2 items     
        List<Exchange_Rate__c> rates = [
            SELECT Name, Rate__c, lastModifiedDate
            FROM Exchange_Rate__c
        ];        
        System.assertEquals(0, rates.size(), 'The array should not contain any items.');
    }
}