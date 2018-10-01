@isTest 
public class DateFormatterTest {   
    @isTest 
    public static void testGetFormattedDate() {
        // Create a mock version of the DateHelper class.
        DateHelper mockDH = (DateHelper)MockUtil.createMock(DateHelper.class);
        DateFormatter df = new DateFormatter();
        
        // Use the mocked object in the test.
        System.assertEquals('Today\'s date is 8/8/2016', df.getFormattedDate(mockDH));
    }
}