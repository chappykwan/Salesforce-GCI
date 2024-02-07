@isTest
private class ExchangeRatesCalloutTest {    
    static String errorMsg = 'Cannot get exchange rates from API.';

    @isTest static void testGetCallout() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetExchangeRateResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        // Call method to test
        Map<String, Object> rates = ExchangeRatesCallouts.getExchangeRates();

        // Verify mock response is not null
        // Verify the array contains 3 items     
        System.assertNotEquals(null, rates, 'The callout returned a null response.');
        System.assertEquals(3, rates.size(), 'The array should only contain 3 items.');          
    }
    @isTest static void testGetCalloutFailed() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetExchangeRateResource');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        // Call method to test
        try {
        	Map<String, Object> rates = ExchangeRatesCallouts.getExchangeRates();
        } catch (Exception e) {
        	// Verify CalloutException is thrown with the expected message
        	System.assert(e.getMessage().contains(errorMsg), 'Unexpected exception thrown.');
        }
    }
    @isTest static void testGetCalloutException() {
        // Create the mock response based on a static resource
        // Not setting static resource to cause an exception in the response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        // Call method to test
        try {
        	Map<String, Object> rates = ExchangeRatesCallouts.getExchangeRates();
        } catch (Exception e) {
        	// Verify CalloutException is thrown with the expected message
        	System.assert(e.getMessage().contains(errorMsg), 'Unexpected exception thrown.');
        }
    }
}