public with sharing class LeadsManagementController {
    private static final LeadSelector leadSelector = (LeadSelector) Application.Selector.newInstance(Lead.SObjectType);

    @AuraEnabled(Cacheable=true)
    public static List<Lead> getMineNonConvertedLeads() {
        try {
            return leadSelector.selectMineNonConverted();
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<Lead> getMineConvertedLeads() {
        try {
            return leadSelector.selectMineConverted();
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String convertLead(String config, Boolean dryRun) {
        try {
            // Deserialize convert preferences;
            ConvertConfig convertConfigDto = (ConvertConfig) JSON.deserialize(config, ConvertConfig.class);
            Logger.debug(JSON.serialize(convertConfigDto));
            // Construct 'LeadConvert' settings;
            Database.LeadConvert leadConvert = convertConfigDto.build();
            // Construct 'DMLOptions' settings;
            Database.DMLOptions dmlOptions = convertConfigDto.buildDmlOptions();
            // Invoke standard conversion;
            Savepoint sp = Database.setSavepoint();
            Database.LeadConvertResult convertResult = Database.convertLead(leadConvert, dmlOptions, AccessLevel.SYSTEM_MODE);
            if (dryRun) {
                Database.rollback(sp);
            }
            return JSON.serialize(convertResult);
        } catch (Exception ex) {
            Logger.error(ex);
            Logger.error(ex.getMessage());
            Logger.error(ex.getStackTraceString());
            Logger.error(ex.getTypeName());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class ConvertConfig {
        @AuraEnabled
        public Id leadId { get; set; }
        @AuraEnabled
        public Id accountId { get; set; }
        @AuraEnabled
        public Id contactId { get; set; }
        @AuraEnabled
        public Boolean doNotCreateOpportunity {
            get {
                return this.doNotCreateOpportunity == null ? false : this.doNotCreateOpportunity;
            }
            set;
        }
        @AuraEnabled
        public Boolean sendNotificationEmail {
            get {
                return this.sendNotificationEmail == null ? false : this.sendNotificationEmail;
            }
            set;
        }
        @AuraEnabled
        public String convertedStatus {
            get {
                if (String.isBlank(this.convertedStatus)) {
                    return [SELECT Id, MasterLabel, ApiName FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1][0].ApiName;
                }
                return this.convertedStatus;
            }
            set;
        }
        @AuraEnabled
        public Boolean overwriteLeadSource {
            get {
                return this.overwriteLeadSource == null ? false : this.overwriteLeadSource;
            }
            set;
        }
        @AuraEnabled
        public Boolean allowSaveOnDuplicateRules {
            get {
                return this.allowSaveOnDuplicateRules == null ? false : this.allowSaveOnDuplicateRules;
            }
            set;
        }

        public ConvertConfig() {
            this.doNotCreateOpportunity = true;
            this.sendNotificationEmail = false;
            this.allowSaveOnDuplicateRules = false;
        }

        public Database.LeadConvert build() {
            Database.LeadConvert convertConfig = new Database.LeadConvert();
            convertConfig.setLeadId(this.leadId);
            convertConfig.setAccountId(this.accountId);
            convertConfig.setContactId(this.contactId);
            convertConfig.setDoNotCreateOpportunity(this.doNotCreateOpportunity);
            convertConfig.setSendNotificationEmail(this.sendNotificationEmail);
            convertConfig.setConvertedStatus(this.convertedStatus);
            convertConfig.setOverwriteLeadSource(this.overwriteLeadSource);
            return convertConfig;
        }

        public Database.DMLOptions buildDmlOptions() {
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.optAllOrNone = true;
            dmlOptions.duplicateRuleHeader = new Database.DMLOptions.DuplicateRuleHeader();
            dmlOptions.duplicateRuleHeader.allowSave = this.allowSaveOnDuplicateRules;
            dmlOptions.duplicateRuleHeader.runAsCurrentUser = true;
            return dmlOptions;
        }
    }
}
