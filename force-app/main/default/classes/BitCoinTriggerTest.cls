@IsTest
private class BitCoinTriggerTest {
    @isTest static void testUpdateOpenOpportunity() {
        // Test data setup
        // Create an account with an opportunity, and then try to delete it
        Account acct = new Account(Name='Test Account');
        insert acct;
        // Open Opportunity 
        Opportunity opp1 = new Opportunity(Name=acct.Name + ' Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          AccountId=acct.Id,
                                          Amount=20000);
        // Closed Opportunity                                          
        Opportunity opp2 = new Opportunity(Name=acct.Name + ' Closed Opportunity',
                                          StageName='Closed Won',
                                          CloseDate=System.today().addMonths(1),
                                          AccountId=acct.Id,
                                          Amount=10000);
        // Open Opportunity with no Amount                                          
        Opportunity opp3 = new Opportunity(Name=acct.Name + ' Amountless Opportunity',
                                          StageName='Needs Analysis',
                                          CloseDate=System.today().addMonths(1),
                                          AccountId=acct.Id);
        List<Opportunity> opps = new List<Opportunity>{opp1, opp2, opp3};
        insert opps;

        // Perform test
        // Insert a dummy rate for BTC
        Test.startTest();
        Exchange_Rate__c BTC = new Exchange_Rate__c(Name='BTC', Rate__c=0.5);
        Database.SaveResult result = Database.insert(BTC, false);
        Test.stopTest();

        // Verify the result
        // Open opportunity should have amount in BTC updated
        // Closed opportunity should not have amount in BTC
        // Open opportunity with no amount should not have amount in BTC
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
        opps = [SELECT Id, Name, StageName, Amount, Amount_in_BTC__c FROM opportunity];
        for (Opportunity opp : opps) {
            if (opp.StageName != 'Closed Won' && opp.Amount != null) {
                System.assertEquals(opp.Amount_in_BTC__c, opp.Amount*BTC.Rate__c);
            } else {
                System.assertEquals(opp.Amount_in_BTC__c, null);
            }
        }
    }
}