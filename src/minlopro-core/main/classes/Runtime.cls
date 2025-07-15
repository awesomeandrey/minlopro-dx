public inherited sharing class Runtime {
    // `Runtime.sleep(2000)` - Waits 2 seconds until executing next line.
    public static void sleep(Long milliSeconds) {
        Long startTime = System.currentTimeMillis();
        Long diff = 0;
        while (diff < milliSeconds) {
            diff = System.currentTimeMillis() - startTime;
        }
    }
}
