@IsTest
public class TestFailingBatch implements Database.Batchable<String>, Database.RaisesPlatformEvents {
    public List<String> start(Database.BatchableContext context) {
        return new List<String>{ 'Minlopro!' };
    }
    public void execute(Database.BatchableContext context, List<String> phoneNumbersToCheck) {
        if (2 > 1) {
            throw new IllegalArgumentException('This batch should fail!');
        }
    }
    public void finish(Database.BatchableContext context) {
    }
}
