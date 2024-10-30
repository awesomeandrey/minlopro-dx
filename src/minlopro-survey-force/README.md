# Survey Force

This folder contains metadata related to [Survey Force](https://github.com/SalesforceLabs/survey-force) **unmanaged** package.

Package ID: `04t6S00000160LFQAY`.

## Setup Steps

-   Install unmanaged package in DevHub environment
-   Incorporate unmanaged package into CI/CD (update bash scrips)
-   Assign `Survey_Force_SuperAdmin` & `Survey_Force_Admin` permission sets to System Administrator
-   Create `Force.com` site and assigned `Survey_Force_Guest` permission set to guest user
-   Create sharing rule on `Survey__c` object to let guest users submit surveys in _Force.com site_
