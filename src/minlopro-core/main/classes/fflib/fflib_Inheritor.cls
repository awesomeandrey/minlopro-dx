/*
 * Copyright (c) 2016-2017 FinancialForce.com, inc.  All rights reserved.
 */
@IsTest
public class fflib_Inheritor implements IA, IB, IC {
    public interface IA {
        String doA();
    }
    public interface IB {
        String doB();
    }
    public interface IC {
        String doC();
    }

    public String doA() {
        return 'Did A';
    }
    public String doB() {
        return 'Did B';
    }
    public String doC() {
        return 'Did C';
    }
}
