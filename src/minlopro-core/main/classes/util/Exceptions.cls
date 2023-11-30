public inherited sharing class Exceptions {
    public static Map<String, String> getDetails(Exception ex) {
        return new Map<String, String>{
            'quiddity' => Request.getCurrent().getQuiddity().name(),
            'message' => ex.getMessage(),
            'type' => ex.getTypeName(),
            'stackTrace' => ex.getStackTraceString()
        };
    }
}
