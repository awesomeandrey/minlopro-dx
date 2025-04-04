/*
 Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 * @nodoc
 */
@IsTest
private class fflib_AnswerTest {
    private static fflib_InvocationOnMock actualInvocation = null;

    @IsTest
    static void thatAnswersWithException() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi')).thenAnswer(new fflib_AnswerTest.ExceptionForAnswer());
        mocks.stopStubbing();

        // When
        try {
            mockList.get2(0, 'Hi hi Hello Hi hi');
            System.Assert.fail('an exception is expected to be thrown on the answer execution');
        } catch (fflib_ApexMocks.ApexMocksException ansExpt) {
            String expectedMessage = 'an error occurs on the execution of the answer';
            // Then
            System.Assert.areEqual(expectedMessage, ansExpt.getMessage(), 'the message from the answer is not as expected');
        }
    }

    @IsTest
    static void thatStoresMethodIntoInvocationOnMock() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi')).thenAnswer(new fflib_AnswerTest.BasicAnswer());
        mocks.stopStubbing();

        // When
        mockList.get2(0, 'Hi hi Hello Hi hi');

        // Then

        Object methodCalled = actualInvocation.getMethod();
        System.Assert.isInstanceOfType(
            methodCalled,
            fflib_QualifiedMethod.class,
            'the object returned is not a method as expected'
        );

        String expectedMethodSignature = fflib_MyList.getStubClassName() + '.get2(Integer, String)';
        System.Assert.areEqual(
            expectedMethodSignature,
            ((fflib_QualifiedMethod) methodCalled).toString(),
            ' the method is no the one expected'
        );
    }

    @IsTest
    static void thatAnswerOnlyForTheMethodStubbedWithAnswer() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.get(3)).thenReturn('ted');
        mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi')).thenAnswer(new fflib_AnswerTest.BasicAnswer());
        mocks.stopStubbing();

        // When
        mockList.add('one');
        String noAnswered = mockList.get(3);
        mockList.get2(0, 'Hi hi Hello Hi hi');

        // Then
        Object methodCalled = actualInvocation.getMethod();
        System.Assert.isInstanceOfType(
            methodCalled,
            fflib_QualifiedMethod.class,
            'the object returned is not a method as expected'
        );

        String expectedMethodSignature = fflib_MyList.getStubClassName() + '.get2(Integer, String)';
        System.Assert.areEqual(
            expectedMethodSignature,
            ((fflib_QualifiedMethod) methodCalled).toString(),
            ' the method is no the one expected'
        );

        System.Assert.areEqual('ted', noAnswered, 'the get method should have returned the stubbed string');
    }

    @IsTest
    static void thatMultipleAnswersAreHandled() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.get(3)).thenAnswer(new fflib_AnswerTest.FirstAnswer());
        mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi')).thenAnswer(new fflib_AnswerTest.SecondAnswer());
        mocks.stopStubbing();

        // When
        mockList.add('one');
        String answer1 = mockList.get(3);
        String answer2 = mockList.get2(0, 'Hi hi Hello Hi hi');

        System.Assert.areEqual('this is the first answer', answer1, 'the answer wasnt the one expected');
        System.Assert.areEqual('and this is the second one', answer2, 'the answer wasnt the one expected');
    }

    @IsTest
    static void thatStoresMockInstanceIntoInvocationOnMock() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi')).thenAnswer(new fflib_AnswerTest.BasicAnswer());
        mocks.stopStubbing();

        // When
        String mockCalled = mockList.get2(0, 'Hi hi Hello Hi hi');

        // Then
        System.Assert.isInstanceOfType(
            actualInvocation.getMock(),
            fflib_MyList.IList.class,
            'the object returned is not a mock instance as expected'
        );
        System.Assert.areEqual(
            mockList,
            actualInvocation.getMock(),
            'the mock returned should be the mockList used in the stubbing'
        );
    }

    @IsTest
    static void thatMethodsParametersAreAccessible() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi')).thenAnswer(new fflib_AnswerTest.ProcessArgumentAnswer());
        mocks.stopStubbing();

        // When
        String actualValue = mockList.get2(0, 'Hi hi Hello Hi hi');

        // Then
        System.Assert.areEqual('Bye hi Hello Bye hi', actualValue, 'the answer is not correct');
    }

    @IsTest
    static void thatAnswerOnlyForTheStubbedParameter() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi')).thenAnswer(new fflib_AnswerTest.ProcessArgumentAnswer());
        mocks.stopStubbing();

        // When
        String actualValue1 = mockList.get2(0, 'some string for my method');
        String actualValue2 = mockList.get2(0, 'Hi hi Hello Hi hi');
        String actualValue3 = mockList.get2(0, 'another string for the same method');

        // Then
        System.Assert.areEqual('Bye hi Hello Bye hi', actualValue2, 'the answer is not correct');
        System.Assert.areEqual(null, actualValue1, 'the answer is not correct');
        System.Assert.areEqual(null, actualValue3, 'the answer is not correct');
    }

    @IsTest
    static void thatMethodsParametersAreAccessibleWhenCalledWithMatchers() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.get2(fflib_Match.anyInteger(), fflib_Match.anyString()))
            .thenAnswer(new fflib_AnswerTest.ProcessArgumentAnswer());
        mocks.stopStubbing();

        // When
        String actualValue = mockList.get2(0, 'Hi hi Hello Hi hi');

        // Then
        System.Assert.areEqual('Bye hi Hello Bye hi', actualValue, 'the answer is not correct');
    }

    @IsTest
    static void thatExceptionIsThrownWhenAccessOutOfIndexArgument() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi')).thenAnswer(new fflib_AnswerTest.ExceptionForArgumentsOutOfBound());
        mocks.stopStubbing();

        // When
        String actualValue = mockList.get2(0, 'Hi hi Hello Hi hi');
    }

    @IsTest
    static void thatExceptionIsThrownWhenAccessNegativeIndexArgument() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi')).thenAnswer(new fflib_AnswerTest.ExceptionForNegativeArgumentIndex());
        mocks.stopStubbing();

        // When
        String actualValue = mockList.get2(0, 'Hi hi Hello Hi hi');
    }

    @IsTest
    static void thatArgumentListEmptyForMethodWithNoArgument() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        mocks.when(mockList.isEmpty()).thenAnswer(new fflib_AnswerTest.ArgumentListEmptyForMethodWithNoArgument());
        mocks.stopStubbing();

        // When
        Boolean actualValue = mockList.isEmpty();
    }

    @IsTest
    static void thatAnswerToVoidMethod() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        ((fflib_MyList) mocks.doAnswer(new fflib_AnswerTest.BasicAnswer(), mockList)).addMore('Hi hi Hello Hi hi');
        mocks.stopStubbing();

        // When
        mockList.addMore('Hi hi Hello Hi hi');

        // Then
        Object methodCalled = actualInvocation.getMethod();
        System.Assert.isInstanceOfType(
            methodCalled,
            fflib_QualifiedMethod.class,
            'the object returned is not a method as expected'
        );

        String expectedMethodSignature = fflib_MyList.getStubClassName() + '.addMore(String)';
        System.Assert.areEqual(
            expectedMethodSignature,
            ((fflib_QualifiedMethod) methodCalled).toString(),
            'Unexpected method name: ' + methodCalled
        );
    }

    @IsTest
    static void thatAnswerToVoidAndNotVoidMethods() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        mocks.startStubbing();
        ((fflib_MyList) mocks.doAnswer(new fflib_AnswerTest.FirstAnswer(), mockList)).get(3);
        ((fflib_MyList) mocks.doAnswer(new fflib_AnswerTest.BasicAnswer(), mockList)).addMore('Hi hi Hello Hi hi');
        ((fflib_MyList) mocks.doAnswer(new fflib_AnswerTest.SecondAnswer(), mockList)).get2(4, 'Hi hi Hello Hi hi');
        mocks.stopStubbing();

        // When
        String answer1 = mockList.get(3);
        String answer2 = mockList.get2(4, 'Hi hi Hello Hi hi');
        mockList.addMore('Hi hi Hello Hi hi');

        // Then
        Object methodCalled = actualInvocation.getMethod();
        System.Assert.isInstanceOfType(
            methodCalled,
            fflib_QualifiedMethod.class,
            'the object returned is not a method as expected'
        );

        String expectedMethodSignature = fflib_MyList.getStubClassName() + '.addMore(String)';
        System.Assert.areEqual(
            expectedMethodSignature,
            ((fflib_QualifiedMethod) methodCalled).toString(),
            'the last method called should be the addMore, so should be the last to set the actualInvocation variable.'
        );

        System.Assert.areEqual('this is the first answer', answer1, 'the answer was not the one expected');
        System.Assert.areEqual('and this is the second one', answer2, 'the answer was not the one expected');
    }

    @IsTest
    static void thatAnswerToDifferentVoidMethods() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_MyList mockList = (fflib_MyList) mocks.mock(fflib_MyList.class);

        fflib_AnswerTest.FirstAnswer answer1 = new fflib_AnswerTest.FirstAnswer();
        fflib_AnswerTest.SecondAnswer answer2 = new fflib_AnswerTest.SecondAnswer();

        System.Assert.areEqual(null, answer1.getMessage(), 'the answer message should be null at this stage');
        System.Assert.areEqual(null, answer2.getMessage(), 'the answer message should be null at this stage');

        mocks.startStubbing();
        ((fflib_MyList) mocks.doAnswer(answer1, mockList)).addMore('Hi hi Hello Hi hi');
        ((fflib_MyList) mocks.doAnswer(answer2, mockList)).add('Hello');
        mocks.stopStubbing();

        // When
        mockList.addMore('Hi hi Hello Hi hi');
        mockList.add('Hello');

        // Then
        System.Assert.areEqual('this is the first answer', answer1.getMessage(), 'the answer was not the one expected');
        System.Assert.areEqual('and this is the second one', answer2.getMessage(), 'the answer was not the one expected');
    }

    //Answers

    public class BasicAnswer implements fflib_Answer {
        public Object answer(fflib_InvocationOnMock invocation) {
            actualInvocation = invocation;
            return null;
        }
    }

    public class ExceptionForAnswer implements fflib_Answer {
        public Object answer(fflib_InvocationOnMock invocation) {
            actualInvocation = invocation;

            throw new fflib_ApexMocks.ApexMocksException('an error occurs on the execution of the answer');
        }
    }

    public class ExceptionForArgumentsOutOfBound implements fflib_Answer {
        public Object answer(fflib_InvocationOnMock invocation) {
            actualInvocation = invocation;

            try {
                Object noExistingObj = invocation.getArgument(2);
                System.Assert.fail('an exception was expected because the argument in the method are only 2');
            } catch (fflib_ApexMocks.ApexMocksException exp) {
                String expectedMessage = 'Invalid index, must be greater or equal to zero and less of 2.';
                String actualMessage = exp.getMessage();
                System.Assert.areEqual(expectedMessage, actualMessage, 'the message return by the exception is not as expected');
            }
            return null;
        }
    }

    public class ExceptionForNegativeArgumentIndex implements fflib_Answer {
        public Object answer(fflib_InvocationOnMock invocation) {
            actualInvocation = invocation;

            try {
                Object noExistingObj = invocation.getArgument(-1);
                System.Assert.fail('an exception was expected because the argument index cannot be negative');
            } catch (fflib_ApexMocks.ApexMocksException exp) {
                String expectedMessage = 'Invalid index, must be greater or equal to zero and less of 2.';
                String actualMessage = exp.getMessage();
                System.Assert.areEqual(expectedMessage, actualMessage, 'the message return by the exception is not as expected');
            }
            return null;
        }
    }

    public class ArgumentListEmptyForMethodWithNoArgument implements fflib_Answer {
        public Object answer(fflib_InvocationOnMock invocation) {
            actualInvocation = invocation;

            List<Object> emptyList = invocation.getArguments();

            System.Assert.areEqual(0, emptyList.size(), 'the argument list from a method without arguments should be empty');

            return null;
        }
    }

    public class FirstAnswer implements fflib_Answer {
        private String answerMessage;

        public String getMessage() {
            return this.answerMessage;
        }

        public Object answer(fflib_InvocationOnMock invocation) {
            actualInvocation = invocation;

            this.answerMessage = 'this is the first answer';

            return answerMessage;
        }
    }

    public class SecondAnswer implements fflib_Answer {
        private String answerMessage;

        public String getMessage() {
            return this.answerMessage;
        }

        public Object answer(fflib_InvocationOnMock invocation) {
            actualInvocation = invocation;

            this.answerMessage = 'and this is the second one';

            return answerMessage;
        }
    }

    public class ProcessArgumentAnswer implements fflib_Answer {
        public Object answer(fflib_InvocationOnMock invocation) {
            actualInvocation = invocation;

            String argument = (String) invocation.getArgument(1);
            System.Assert.areNotEqual(null, argument, ' the argument should have some value');
            argument = argument.replace('Hi', 'Bye');
            return argument;
        }
    }
}
