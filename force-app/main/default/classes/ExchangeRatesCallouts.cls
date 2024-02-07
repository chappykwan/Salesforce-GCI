public class ExchangeRatesCallouts {
    public static Map<String, Object> getExchangeRates() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Exchange_Rates_API_Named');
        request.setMethod('GET');
        
        // Maximum number of retry attempts
        Integer numAttempts = 1; 
        // Delay in seconds between attempts
        // Can reach CPU limits if the value is set to more than 5 seconds
        Integer delayInSeconds = 2; 
        
        while (numAttempts > 0) {
            try {                
                HttpResponse response = http.send(request);
                // If the request is successful, parse the JSON response.
                if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                    // Deserializes the JSON string into collections of primitive data types.
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    // Cast the values in the 'data' key as a list
                    Map<String, Object> data = (Map<String, Object>) results.get('data');
                    Map<String, Object> rates = (Map<String, Object>) data.get('rates');
                    System.debug(LoggingLevel.INFO, rates);
                    return rates;
                }
                // Callout was not successful, decrement attempts and retry
                System.debug(logginglevel.INFO, 'Callout to Exchange Rate API not successful, retrying...');
                numAttempts--;
            } catch (Exception ex) {
                // An exception occurred during the callout, decrement attempts and retry
                System.debug(logginglevel.INFO, 'An exception occurred during the callout, retrying...');
                numAttempts--;
            }

            // Wait before retrying
            DateTime now = datetime.now();
            DateTime newDateTime = now.addSeconds(delayInSeconds);
            while (datetime.now() < newDateTime ) {}
        }
        // Maximum number of retry attempts reached, throw CalloutException
        System.debug(logginglevel.ERROR, 'Maximum number of retry attempts reached');
        throw new CalloutException('WARNING: Cannot get exchange rates from API.');
    }
}