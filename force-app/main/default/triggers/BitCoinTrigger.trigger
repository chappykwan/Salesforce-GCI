trigger BitCoinTrigger on Exchange_Rate__c (after insert, after update) {
    // Get the latest BTC exchange rate
    Double BTCRate;
    for (Exchange_Rate__c rate : Trigger.new) {
        if (rate.Name == 'BTC') {
            BTCRate = rate.Rate__c;
            break;
        }
    }
    // Retrieve a list of open opportunities
	List<Opportunity> openOpportunities = [SELECT Id, Name, Amount, StageName FROM Opportunity 
                     WHERE StageName NOT IN ('Closed Lost', 'Closed Won')];
    // Calculate the amount in BTC and set into the object
    Datetime applyDate = Datetime.now();
    for (Opportunity openOpportunity : openOpportunities) {
        if (openOpportunity.Amount != null) {
            openOpportunity.Exchange_Rate_BTC__c = BTCRate;
            openOpportunity.Amount_in_BTC__c = BTCRate * openOpportunity.Amount;
            openOpportunity.Exchange_Rate_BTC_Apply_Date__c = applyDate;
    	}
    }
    update openOpportunities;
}