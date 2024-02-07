public class ExchangeRatesJob implements Schedulable {
    public void execute(SchedulableContext ctx) {
        // Update the exchange rates objects from the Exchange Rates API
        ExchangeRatesContoller.schedulingExchangeRatesUpdate();
    }
}