public inherited sharing class DebugTableFormatter {
    private final String delimiter = ' ︱ ';
    private final Integer maxColumnWidth = 60;
    private List<String> fieldNames;
    private List<Map<String, String>> records;

    private Map<String, Integer> columnWidths {
        get {
            if (this.columnWidths == null) {
                Map<String, Integer> columnWidths = new Map<String, Integer>();
                for (String fieldName : this.fieldNames) {
                    columnWidths.put(fieldName, Math.min(fieldName.length(), this.maxColumnWidth));
                }
                // Determine the width of each column;
                for (Map<String, String> record : this.records) {
                    for (String fieldName : this.fieldNames) {
                        String fieldValue = '' + record.get(fieldName);
                        Integer length = Math.min(fieldValue.length(), this.maxColumnWidth);
                        if (length > columnWidths.get(fieldName)) {
                            columnWidths.put(fieldName, length);
                        }
                    }
                }
                this.columnWidths = columnWidths;
            }
            return this.columnWidths;
        }
        set;
    }

    public DebugTableFormatter(List<String> fieldNames, List<Map<String, String>> records) {
        this.fieldNames = fieldNames;
        this.records = records;
    }

    public DebugTableFormatter(List<String> fieldNames, List<SObject> records) {
        this.fieldNames = fieldNames;
        this.records = this.cast(records);
    }

    public void log() {
        this.log(null);
    }

    public void log(String title) {
        String log = '\n\n';
        // Title;
        if (String.isNotBlank(title)) {
            log += title + '\n';
        }
        // Header;
        String columnsHeader = '';
        for (String fieldName : this.fieldNames) {
            Integer columnWidth = this.columnWidths.get(fieldName);
            columnsHeader += this.formatColumn(fieldName, columnWidth) + this.delimiter;
        }
        log += columnsHeader + '\n';
        // Rows;
        String rows = '';
        for (Map<String, String> record : this.records) {
            String row = '';
            for (String fieldName : this.fieldNames) {
                String fieldValue = '' + record.get(fieldName); // Convert field value to String;
                Integer columnWidth = this.columnWidths.get(fieldName);
                row += this.formatColumn(fieldValue, columnWidth) + this.delimiter;
            }
            rows += row + '\n';
        }
        log += rows;
        System.debug(log);
    }

    private List<Map<String, String>> cast(List<SObject> sObjects) {
        List<Map<String, String>> records = new List<Map<String, String>>();
        for (SObject sObjectItem : sObjects) {
            Map<String, String> recordAsMap = new Map<String, String>();
            Map<String, Object> sObjectAsMap = sObjectItem.getPopulatedFieldsAsMap();
            for (String fieldName : this.fieldNames) {
                recordAsMap.put(fieldName, '' + sObjectAsMap.get(fieldName));
            }
            records.add(recordAsMap);
        }
        return records;
    }

    private String formatColumn(String value, Integer width) {
        value = value != null ? value : '';
        if (value.length() > width) {
            value = value.substring(0, width - 1) + '~'; // Truncate and add tilde to indicate more content
        } else {
            // Pad the string to maintain column width
            while (value.length() < width) {
                value += ' ';
            }
        }
        return value;
    }
}
