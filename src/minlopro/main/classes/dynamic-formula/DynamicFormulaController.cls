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
                fflib_QueryFactory queryFactory = new fflib_QueryFactory(formulaInputs.objectType)
                    .selectFields(fInstance.getReferencedFields())
                    .setCondition('Id = \'' + formulaInputs.record.Id + '\'')
                    .setLimit(1);
                Repository repository = (Repository) Application.Service.newInstance(Repository.class);
                List<SObject> queriedSObjects = (List<SObject>) repository.query(queryFactory.toSOQL());
                return fInstance.evaluate(queriedSObjects.get(0));
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
        public String formulaReturnTypeName { get; set; }
        @AuraEnabled
        public String formulaExpression { get; set; }

        public SObjectType objectType {
            get {
                return this.record.getSObjectType();
            }
            private set;
        }
        public FormulaEval.FormulaReturnType formulaReturnType {
            get {
                return FormulaEval.FormulaReturnType.valueOf(this.formulaReturnTypeName.toUpperCase());
            }
            private set;
        }

        public Boolean isPrototype() {
            return String.isBlank(this.record.Id);
        }
    }
}
