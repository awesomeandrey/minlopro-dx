# Survey Force

This folder contains metadata related to [Survey Force](https://github.com/SalesforceLabs/survey-force) **unmanaged** package.

## Post-Deployment Steps

1. Assign `Survey_Force_SuperAdmin` & `Survey_Force_Admin` permission set to Admin user(s)
2. Create `Force.com` site and assign `Survey_Force_Guest` permission set to guest user

## TODOs

-   Install unmanaged package in DevHub environment
-   Incorporate unmanaged package into CI/CD
-   Assign "Survey Force - SuperAdmin" permission set to system administrator
-   Assign "Survey Force - Admin" to anyone who will administer specific surveys
-   Assign "Survey Force - Guest" permission set to Force.com Site guest user (Complete steps on Force.com Site configuration below)
-   Handle data migration (questions, surveys)
-   Create reports
