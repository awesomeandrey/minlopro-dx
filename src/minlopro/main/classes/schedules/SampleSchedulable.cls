public class SampleSchedulable implements Schedulable {
    public void execute(SchedulableContext ctx) {
        Logger.debug('This is sample Schedulable job execution [{0}].', Lists.of(ctx.getTriggerId()));
    }
}
