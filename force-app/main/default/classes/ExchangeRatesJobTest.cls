@IsTest
private class ExchangeRatesJobTest {
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2042';

    @IsTest static void testExchangeRatesJob() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetExchangeRateResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call method to test
        Test.startTest();
        
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new ExchangeRatesJob());
        
        // Get the information from the CronTrigger API object         
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression);       
        // Verify the job has not run       
        System.assertEquals(0, ct.TimesTriggered); 
        
        // Verify the next time the job will run         
        System.assertEquals('2042-03-15 00:00:00', String.valueOf(ct.NextFireTime));   
        
        Test.stopTest();        
    }   
}