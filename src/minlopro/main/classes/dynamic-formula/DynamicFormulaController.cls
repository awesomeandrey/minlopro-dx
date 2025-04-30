public without sharing class DynamicFormulaController {
    @AuraEnabled
    public static Object evaluate(Inputs formulaInputs) {
        try {
            FormulaEval.FormulaInstance fInstance = Formula.builder()
                .withReturnType(formulaInputs.formulaReturnType)
                .withType(formulaInputs.objectType)
                .withFormula(formulaInputs.formulaExpression)
                .build();
            if (formulaInputs.isPrototype()) {
                return fInstance.evaluate(formulaInputs.record);
            } else {
                fflib_ISObjectSelector objectSelector = Application.Selector.newInstance(formulaInputs.objectType);
                SObject targetRecord = objectSelector.selectSObjectsById(Sets.of(formulaInputs.record.Id)).get(0);
                return fInstance.evaluate(targetRecord);
            }
        } catch (Exception rootException) {
            Logger.error(rootException);
            IllegalArgumentException ex = new IllegalArgumentException(rootException.getMessage());
            ex.initCause(rootException);
            throw ex;
        }
    }

    public class Inputs {
        @AuraEnabled
        public SObject record { get; set; }
        @AuraEnabled
        public FormulaEval.FormulaReturnType formulaReturnType { get; set; }
        @AuraEnabled
        public String formulaExpression { get; set; }

        public SObjectType objectType {
            get {
                return this.record.getSObjectType();
            }
            private set;
        }

        public Boolean isPrototype() {
            return String.isBlank(this.record.Id);
        }
    }
}
