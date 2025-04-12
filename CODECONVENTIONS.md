# Code Conventions

- [Introduction](#introduction)
- [General Best Practices](#general-best-practices)
- [Code Conventions](#code-conventions)
    - [Apex Classes](#apex-classes)
        - [Naming Conventions](#naming-conventions)
        - [Critical Coding Standards](#critical-coding-standards)
        - [Class Design](#class-design)
        - [Unit Tests](#unit-tests)
    - [LWC (Lightning Web Components)](#lwc-lightning-web-components)
        - [Naming Conventions](#naming-conventions-1)
        - [Critical Coding Standards](#critical-coding-standards-1)
    - [Aura Components](#aura-components)
        - [Naming Conventions](#naming-conventions-2)
        - [Critical Coding Standards](#critical-coding-standards-2)

## Introduction

This guide serves as a comprehensive reference for Salesforce developers, covering best practices and conventions to ensure consistency, maintainability, and scalability across projects.

---

## General Best Practices

- Every declarative metadata component (flow, custom object, custom field etc.) must have clear & meaningful description provided.
- Configure/wWrite polite, user-friendly error messages.
    - Example: Prefer “Please provide a value for the Status field” over “Missing required field.”
- Avoid hardcoding sensitive data like IDs or credentials.
- Design your logic to handle large data sets and avoid hitting Salesforce's governor limits.

---

## Code Conventions

### Apex Classes

#### Naming Conventions

1. **Classes**:
    - Use PascalCase (e.g., `AccountTriggerHandler`).
    - Test classes should append `Test` to the name (e.g., `AccountServiceTest`).
2. **Variables**:
    - Use camelCase (e.g., `recordIndex`).
    - Avoid single-character variables except in loop counters.
3. **Methods**:
    - Start with a lowercase letter and use camelCase (e.g., `fetchCustomerRecords`).
4. **Constants**:
    - Use uppercase with underscores (e.g., `MAX_LIMIT`).

#### Prefix Your Booleans

• IS for simple states

- ❌ active
- ✅ isActive

HAS for ownership

- ❌ subscription
- ✅ hasSubscription

• SHOULD for expected behavior

- ❌ retry
- ✅ shouldRetry

• CAN for capabilities

- ❌ edit
- ✅ canEdit

Your IF statements should read like plain English. Write code for humans to read, not just for machines to execute.

#### Critical Coding Standards

1. Use **PascalCase** for class names and **camelCase** for method and variable names.
2. Write one trigger per object and delegate logic to handler classes.
3. Always bulkify your code to handle collections of records efficiently.
4. Avoid SOQL or DML operations inside loops.
5. Use `Queueable` Apex for asynchronous processing when logic doesn’t need to run immediately.
6. Never hardcode IDs, user names, or sensitive data in your code.
7. Always check for **CRUD** and **FLS** permissions before performing DML or SOQL operations.
8. Use `try-catch` blocks for error handling, and throw custom exceptions for clarity.
9. Use `addError()` in triggers to provide user-friendly validation error messages.
10. Avoid SOQL queries without `WHERE` clauses or `LIMIT` to prevent retrieving excessive records.
11. Use `RecordType.DeveloperName` instead of `RecordType.Name` for better locale-independent queries.
12. Write descriptive comments for methods, classes, and complex logic to improve readability.
13. Use **Separation of Concerns**: divide logic into service, controller, and utility classes.
14. Mock data and external calls in unit tests to avoid dependency on dynamic data.
15. Avoid HTTP callouts within loops; batch them or use Asynchronous Apex.

#### Class Design

Follow the separation of concerns (SoC) principle:

- **Controller Classes**: Handle UI-related logic.
- **Service Classes**: Contain business logic.
- **Selector Classes**: Perform SOQL queries.

Example Class Structure:

```apex
public with sharing class AccountService {
    public void processAccounts(List<Account> accounts) {
        // Business logic
    }
}
```

#### Unit Tests

1. Ensure every test method has clear, descriptive names that indicate the purpose of the test.
2. Aim for **100% code coverage**, with at least **85% coverage** as the minimum standard.
3. Write unit tests for both **positive** and **negative** scenarios to cover all use cases.
4. Use `Test.startTest()` and `Test.stopTest()` to reset governor limits and isolate test execution.
5. Create all necessary test data programmatically within the test method using utility classes or static methods.
6. Never rely on existing data in the database for tests - avoid `@SeeAllData=true` annotation.
7. Use mocking frameworks like **ApexMocks** to mock data, external services, and dependent methods.
8. Avoid using real DML operations in tests where possible; use mock objects to test business logic.
9. Test **bulk operations** by inserting or updating 200 records to simulate real-world scenarios.
10. Include meaningful **assertions** to validate expected outcomes.
11. Test for exceptions explicitly using `Assert.fail` or `try-catch` blocks.
12. Avoid hardcoding IDs, record names, or other sensitive data in test methods.
13. Verify CRUD and FLS permissions in tests to simulate different user profiles and permissions.
14. Use test classes to validate that SOQL and DML operations respect governor limits and query performance.

---

### LWC (Lightning Web Components)

#### Naming Conventions

1. Use **camelCase** for JavaScript variables and methods (e.g., `handleButtonClick`).
2. Use descriptive names for public properties and annotate them with `@api` (e.g., `@api accountId`).
3. Use meaningful event names prefixed by the component name (e.g., `accountSelected`).
4. Use PascalCase for class names in JavaScript (e.g., `AccountOverview`).
5. Prefer [SLDS](https://www.lightningdesignsystem.com) CSS classes over custom ones for styling purposes.
6. For reusable components, append `-util` or `-helper` to the name (e.g., `date-picker-util`).
7. Use `handle<EventName>` for event handler names (e.g., `handleSaveClick`).
8. Define constant values in uppercase with underscores (e.g., `MAX_ITEMS`).
9. Use `camelCase` for HTML template bindings and JavaScript properties (e.g., `isVisible`).
10. Avoid abbreviations in names unless widely recognized (e.g., use `calculateTotal`, not `calcTotal`).
11. Use singular or plural naming based on the context (e.g., `product` for a single item, `products` for lists).

#### Critical Coding Standards

1. Always use `@api` to define public properties and methods explicitly.
2. Avoid hardcoding object or field names; use dynamic binding or Lightning Data Service (LDS).
3. Use two-way data binding (`getter` and `setter`) for calculated or reactive properties.
4. Avoid business logic in components; delegate to Apex or utility classes for maintainability.
5. Do not manipulate the DOM directly; rely on framework methods and lifecycle hooks.
6. Use `template.querySelector` only when necessary, and avoid global selectors.
7. Always clean up resources like intervals, event listeners, or timers in the `disconnectedCallback`.
8. Follow HTML structure conventions: slot attributes first, system properties next, and event handlers last.
9. Use `import` for sharing JavaScript utilities across components (e.g., `import { calculateTax } from 'c/utils'`).
10. Leverage CSS custom properties for theming instead of inline styles.
11. Use `lightning` components wherever possible instead of custom implementations (e.g., `lightning-input`).
12. Avoid circular dependencies by properly structuring imports and exports.
13. Use the `wired` decorator (`@wire`) to connect to Salesforce data and cache results for efficiency.
14. Validate user input at both the component level and in the backend (Apex).
15. Ensure every event dispatched uses `CustomEvent` and bubbles only when necessary.

---

### Aura Components

#### Naming Conventions

1. Use **camelCase** for attribute names (e.g., `recordId`).
2. Use **PascalCase** for component names (e.g., `AccountDetails`).
3. Use a descriptive name for component events with an appropriate suffix (e.g., `onAccountSelect`).
4. Prefer [SLDS](https://www.lightningdesignsystem.com) CSS classes over custom ones for styling purposes.
5. Name application events descriptively and append `Evt` (e.g., `AccountSelectedEvt`).
6. Append `Container` to the name of wrapper components (e.g., `AccountContainer`).
7. Prefix custom CSS classes with the component name to avoid global conflicts (e.g., `accountDetails__header`).
8. Use the same name for event and handler where applicable (e.g., `saveButtonClick` for `onSaveButtonClick`).
9. Use `handle<EventName>` for JavaScript handler functions (e.g., `handleAccountSave`).
10. Constants in JavaScript should be named in uppercase with underscores (e.g., `MAX_RECORDS`).
11. Avoid abbreviations in names unless they are widely recognized (e.g., use `Component` instead of `Cmp`).
12. Use singular or plural naming based on the purpose (e.g., `account` for one record, `accounts` for collections).

#### Critical Coding Standards

1. Always use **attributes** with proper `type` definitions (e.g., `type="String"`).
2. Define default values for attributes where applicable using the `default` attribute.
3. Minimize business logic in the controller; delegate logic to helper methods.
4. Use `event.getParam()` and avoid directly accessing event parameters for flexibility.
5. Avoid hardcoding field and object names; use dynamic references or design patterns.
6. Use `action.setParams()` and avoid passing too many parameters in Apex methods.
7. Validate data at both the client and server-side for security and consistency.
8. Use `aura:if` sparingly; prefer dynamic expressions in `aura:iteration`.
9. Always handle `callback` responses from server-side controllers to manage state or errors.
10. Dispatch meaningful and user-friendly error messages to the UI on server-side errors.
11. Avoid deep nesting of components; aim for flatter hierarchies for better readability.
12. Cache frequently used data in component-level attributes to reduce server calls.
13. Use descriptive comments for each function, especially helper methods and server calls.

---
