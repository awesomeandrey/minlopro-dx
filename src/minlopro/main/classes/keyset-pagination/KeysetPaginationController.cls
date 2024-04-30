/**
 * Inspired by https://medium.com/@rjallu01/salesforce-lwc-datatable-with-pagination-e81c7df5693c
 */
public with sharing class KeysetPaginationController {
    @AuraEnabled
    public static Integer getTotalContactsCount() {
        try {
            return Database.countQuery('SELECT COUNT() FROM Contact');
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<Contact> getContactRecords(QueryRequest queryRequest) {
        try {
            return queryRequest.fetch();
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class QueryRequest {
        @AuraEnabled
        public Integer currentPageNumber { get; set; } // 1
        @AuraEnabled
        public Integer requestedPageNumber { get; set; } // 2
        @AuraEnabled
        public Integer totalRecordsCount { get; set; } // 25
        @AuraEnabled
        public Integer pageSize { get; set; } // 10
        @AuraEnabled
        public String sortBy { get; set; } // Title
        @AuraEnabled
        public String sortDirection { get; set; } // ASC
        /**
         * Stores the Id of the first record on the current page.
         * It's used as an additional sorting criterion to ensure consistent ordering
         * and to handle cases where multiple records have the same value for the sorting field.
         */
        @AuraEnabled
        public Id previousRecordId { get; set; }
        /**
         * Stores the Id of the last record on the current page.
         * It's used as an additional sorting criterion to ensure consistent ordering
         * and to handle cases where multiple records have the same value for the sorting field.
         */
        @AuraEnabled
        public Id nextRecordId { get; set; }
        /**
         * Stores the value of the first sorting field of the first record on the current page.
         * This value is used as the starting point for retrieving the previous page of records.
         */
        @AuraEnabled
        public String previousSortValue { get; set; }
        /**
         * Stores the value of the last sorting field of the last record on the current page.
         * This value is used as the starting point for retrieving the next page of records.
         */
        @AuraEnabled
        public String nextSortValue { get; set; }

        // Private getters;
        private final Integer totalPagesCount {
            get {
                return (Integer) Math.ceil((Decimal) this.totalRecordsCount / this.pageSize);
            }
        }
        private final Integer lastPageSize {
            get {
                Integer remainder = Math.mod(this.totalRecordsCount, this.pageSize);
                return remainder == 0 ? this.pageSize : remainder;
            }
        }
        private final Boolean isFirstPage {
            get {
                return this.requestedPageNumber == 1;
            }
        }
        private final Boolean isLastPage {
            get {
                return !this.isFirstPage && this.requestedPageNumber == this.totalPagesCount;
            }
        }
        private final String paginationVector {
            get {
                if (this.isFirstPage) {
                    return 'firstPage';
                } else if (this.isLastPage) {
                    return 'lastPage';
                } else if (this.currentPageNumber < this.requestedPageNumber) {
                    return 'forward';
                } else if (this.currentPageNumber > this.requestedPageNumber) {
                    return 'backward';
                }
                return null;
            }
        }
        private final Boolean isForwardVector {
            get {
                return String.isNotBlank(this.paginationVector) &&
                    this.paginationVector.equalsIgnoreCase('forward') &&
                    String.isNotBlank(this.nextRecordId);
            }
        }
        private final Boolean isBackwardVector {
            get {
                return String.isNotBlank(this.paginationVector) &&
                    this.paginationVector.equalsIgnoreCase('backward') &&
                    String.isNotBlank(this.previousRecordId);
            }
        }
        private final List<String> fieldApiNames {
            get {
                return new List<String>{ 'Id', 'Name', 'Title', 'AccountId', 'MobilePhone', 'FirstName', 'LastName' };
            }
        }

        public QueryRequest() {
            this.currentPageNumber = 1;
            this.requestedPageNumber = 1;
            this.totalRecordsCount = 25;
            this.pageSize = 5;
            this.sortBy = 'Title';
            this.sortDirection = 'ASC';

            this.previousRecordId = null;
            this.nextRecordId = null;
            this.previousSortValue = null;
            this.nextSortValue = null;
        }

        private List<Contact> fetch() {
            fflib_QueryFactory factory = new fflib_QueryFactory(Contact.SObjectType);
            factory.selectFields(this.fieldApiNames);
            factory.setLimit(this.pageSize);

            // Cast raw ordering value to FFLIB counterpart object;
            fflib_QueryFactory.SortOrder sortOrderParam = this.resolveOrderEnum(this.sortDirection);
            Boolean nullsLast = this.sortDirection.equalsIgnoreCase('asc') ? false : true;

            // Determine valid 'WHERE' & 'ORDER' clauses depending on pagination vector;
            if (this.isFirstPage) {
                // No condition needed since it's an initial data load (just ordering matters for this case);
                factory.setOrdering(this.sortBy, sortOrderParam, nullsLast);
                factory.addOrdering('Id', sortOrderParam, nullsLast);
            } else if (this.isLastPage) {
                // Reverse ordering from FORWARD navigation vector;
                sortOrderParam = this.reverseOrderEnum(sortOrderParam); // 'ASC' becomes 'DESC';
                nullsLast = !nullsLast;
                factory.setOrdering(this.sortBy, sortOrderParam, nullsLast);
                factory.addOrdering('Id', sortOrderParam, nullsLast);
                // Pay attention to LIMIT clause for the last page;
                factory.setLimit(this.lastPageSize);
            } else if (this.isForwardVector) {
                // Preserve same ordering as for initial data load;
                factory.setOrdering(this.sortBy, sortOrderParam, nullsLast);
                factory.addOrdering('Id', sortOrderParam, nullsLast);
                // Resolve comparison operator for FORWARD navigation;
                String comparisonOperator = this.resolveComparisonOperator(this.sortDirection);
                String whereCondition = this.buildKeySetCondition(
                    this.sortBy,
                    comparisonOperator,
                    this.nextSortValue,
                    this.nextRecordId
                );
                // Define WHERE clause;
                factory.setCondition(whereCondition);
            } else if (this.isBackwardVector) {
                // Reverse ordering from FORWARD navigation vector;
                sortOrderParam = this.reverseOrderEnum(sortOrderParam); // 'ASC' becomes 'DESC';
                nullsLast = !nullsLast;
                factory.setOrdering(this.sortBy, sortOrderParam, nullsLast);
                factory.addOrdering('Id', sortOrderParam, nullsLast);
                // Resolve comparison operator for BACKWARD navigation;
                String comparisonOperator = this.resolveComparisonOperatorInverse(this.sortDirection); // Reversed too;
                String whereCondition = this.buildKeySetCondition(
                    this.sortBy,
                    comparisonOperator,
                    this.previousSortValue,
                    this.previousRecordId
                );
                // Define WHERE clause;
                factory.setCondition(whereCondition);
            }

            // Execute the SOQL query with the constructed clauses;
            String finalQuery = factory.toSOQL();
            Logger.debug('{0} | {1}', Lists.of(this.paginationVector, finalQuery));
            List<Contact> records = Database.query(finalQuery);

            // Reverse the order of records if navigating to the last page or moving backwards;
            if ((this.isBackwardVector && !this.isFirstPage) || this.isLastPage) {
                records = this.reverseRecordsOrder(records);
            }
            return records;
        }

        private fflib_QueryFactory.SortOrder resolveOrderEnum(String sortParam) {
            return sortParam.equalsIgnoreCase('asc')
                ? fflib_QueryFactory.SortOrder.ASCENDING
                : fflib_QueryFactory.SortOrder.DESCENDING;
        }

        private fflib_QueryFactory.SortOrder reverseOrderEnum(fflib_QueryFactory.SortOrder sortOrderParam) {
            return sortOrderParam.equals(fflib_QueryFactory.SortOrder.ASCENDING)
                ? fflib_QueryFactory.SortOrder.DESCENDING
                : fflib_QueryFactory.SortOrder.ASCENDING;
        }

        private String resolveComparisonOperator(String sortParam) {
            return sortParam.equalsIgnoreCase('asc') ? '>' : '<';
        }

        private String resolveComparisonOperatorInverse(String sortParam) {
            return sortParam.equalsIgnoreCase('asc') ? '<' : '>';
        }

        private String buildKeySetCondition(
            String sortByField,
            String comparisonOperator,
            String comparisonValue,
            String nextRecordId
        ) {
            // Note: the field type & value matters!
            Boolean doSortByNull = comparisonValue == null;
            String conditionTemplate = doSortByNull
                ? '({0} {1} \' \') OR ({0} = NULL AND Id {1} :nextRecordId)'
                : '({0} {1} :comparisonValue) OR ({0} = :comparisonValue AND Id {1} :nextRecordId)';
            return String.format(conditionTemplate, Lists.of(sortByField, comparisonOperator))
                .replace(':comparisonValue', '\'' + comparisonValue + '\'')
                .replace(':nextRecordId', '\'' + nextRecordId + '\'');
        }

        private List<Contact> reverseRecordsOrder(List<Contact> records) {
            List<Contact> reversedRecords = new List<Contact>();
            for (Integer i = records.size() - 1; i >= 0; i--) {
                reversedRecords.add(records.get(i));
            }
            return reversedRecords;
        }
    }
}
