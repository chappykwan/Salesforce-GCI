public class ExchangeRatesService {
    public static void updateExchangeRates() {
        try {
            // Retrieve Exchange Rates from API
            Map<String, Object> rates = ExchangeRatesCallouts.getExchangeRates();
            
            // Free Coinbase API returns many currencies. We only pick BTC and ETH for now
            // Can store more currencies in the Exchange Rate Object By adding them to this list 
            String[] cryptoCurrencies = new String[] {'BTC', 'ETH'};
            
            List<Exchange_Rate__c> exchangeRates = new List<Exchange_Rate__c>();
            for (String cryptoCurrency : cryptoCurrencies) {
                String rateString = (String)rates.get(cryptoCurrency);
                Double rate = Double.valueOf(rateString);
                System.debug(cryptoCurrency + ': ' + rate);
                Exchange_Rate__c exchangeRate = new Exchange_Rate__c(Name=cryptoCurrency,
                                                                     Rate__c=rate);
                exchangeRates.add(exchangeRate);
            }
            
            // Upsert the rates using name as the identifier
            upsert exchangeRates Name;
        } catch (DmlException e) {
            System.debug(loggingLevel.ERROR, e.getMessage());
            throw e;
        } catch (CalloutException e) {
            System.debug(loggingLevel.ERROR, e.getMessage());
            throw e;
        }
    }

    public static Exchange_Rate__c getBTCRate() {
        // Retrieve the BTC rate
        List<Exchange_Rate__c> rateList = [
            SELECT Name, Rate__c, lastModifiedDate
            FROM Exchange_Rate__c
            WHERE Name = 'BTC'
        ];
        return rateList.get(0);
    }
}