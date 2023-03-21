import * as $Commons from 'c/commons';

const crypto = require('crypto');

describe('Invoke utilities in "commons.js"', () => {
    it('to()', async () => {
        const resolvedPromise = Promise.resolve(true);
        const [error1, result1] = await $Commons.to(resolvedPromise);
        expect(error1).toBeNull();
        expect(result1).toEqual(true);

        const rejectedPromise = Promise.reject({ message: 'Original Message!' });
        const overwrittenErrorMessage = 'Rejected Promise!';
        const [error2, result2] = await $Commons.to(rejectedPromise, {
            message: overwrittenErrorMessage
        });
        expect(error2.message).toEqual(overwrittenErrorMessage);
        expect(result2).toBeUndefined();
    });

    it('wait()', () => {
        jest.useFakeTimers();
        let counter = 0;
        $Commons.wait(() => {
            counter = 10;
        });
        jest.runOnlyPendingTimers();
        expect(counter).toEqual(10);
    });

    it('uniqueId()', () => {
        // Mock 'window.crypto' with Node.js counterpart;
        Object.defineProperty(globalThis, 'crypto', {
            value: {
                getRandomValues: (arr) => crypto.randomBytes(arr.length)
            }
        });
        const uniqueIdsArray = new Array(100).fill(0).map($Commons.uniqueId);
        const uniqueIdsSet = new Set(uniqueIdsArray);
        expect(uniqueIdsSet.size).toEqual(uniqueIdsArray.length);
    });

    it('isArray() & isEmptyArray()', () => {
        expect($Commons.isArray([])).toEqual(true);
        expect($Commons.isArray({})).toEqual(false);
        expect($Commons.isArray({ length: 5 })).toEqual(false);
        expect($Commons.isEmptyArray([])).toEqual(true);
        expect($Commons.isEmptyArray({})).toEqual(true);
        expect($Commons.isEmptyArray({ length: 5 })).toEqual(true);
    });

    it('isEmpty() & isNotEmpty()', () => {
        expect($Commons.isEmpty(null)).toEqual(true);
        expect($Commons.isEmpty(undefined)).toEqual(true);
        expect($Commons.isEmpty([])).toEqual(true);
        expect($Commons.isEmpty(['apex'])).toEqual(false);
        expect($Commons.isEmpty({})).toEqual(true);
        expect($Commons.isEmpty({ key: 'value' })).toEqual(false);
        expect($Commons.isEmpty(0)).toEqual(true);
        expect($Commons.isEmpty(-5051)).toEqual(false);
        expect($Commons.isEmpty(5051)).toEqual(false);
        expect($Commons.isEmpty('   ')).toEqual(true);
        expect($Commons.isEmpty('apex')).toEqual(false);
        expect($Commons.isNotEmpty('   ')).toEqual(false);
        expect($Commons.isNotEmpty('apex')).toEqual(true);
    });

    it('cloneObject() & flatten()', () => {
        const carObj = {
            model: 'Karoq',
            brand: {
                name: 'Skoda',
                country: 'Czech Republic'
            },
            price: 1000000
        };
        const clonedCarObj = $Commons.cloneObject(carObj);
        expect(clonedCarObj.model).toEqual(carObj.model);
        expect(clonedCarObj.price).toEqual(carObj.price);
        expect(clonedCarObj.brand.name).toEqual(carObj.brand.name);
        expect(clonedCarObj.brand.country).toEqual(carObj.brand.country);
        const flattenedCarObj = $Commons.flatten(carObj);
        expect(flattenedCarObj.model).toEqual(carObj.model);
        expect(flattenedCarObj.price).toEqual(carObj.price);
        expect(flattenedCarObj['brand.name']).toEqual(carObj.brand.name);
        expect(flattenedCarObj['brand.country']).toEqual(carObj.brand.country);
    });

    it('splitByComma()', () => {
        expect($Commons.splitByComma()).toEqual([]);
        expect($Commons.splitByComma('')).toEqual([]);
        expect($Commons.splitByComma('apple, orange, plum')).toEqual(['apple', 'orange', 'plum']);
        expect($Commons.splitByComma('apple,orange,plum')).toEqual(['apple', 'orange', 'plum']);
        expect($Commons.splitByComma(' apple,orange,plum ')).toEqual(['apple', 'orange', 'plum']);
        expect($Commons.splitByComma('apple,,plum')).toEqual(['apple', 'plum']);
        expect($Commons.splitByComma(',')).toEqual([]);
        expect($Commons.splitByComma(',,,')).toEqual([]);
    });

    it('pipe()', () => {
        const add5 = (_) => _ + 5;
        const add10 = (_) => _ + 10;
        const add100 = (_) => _ + 100;
        const result = $Commons.pipe(add5, add10, add100)(5);
        expect(result).toEqual(5 + 5 + 10 + 100);
    });

    it('throttle()', () => {
        let counter = 0;
        const throttledFunction = jest.fn(
            $Commons.throttle(() => {
                counter++;
            }, 2000)
        );
        const times = 100;
        new Array(times).fill(0).forEach(throttledFunction);
        expect(throttledFunction).toHaveBeenCalledTimes(times);
        expect(counter).toEqual(1);
    });

    it('debounce()', () => {
        jest.useFakeTimers();
        let counter = 0;
        const debouncedFunction = jest.fn(
            $Commons
                .debounce(() => {
                    counter++;
                }, 2000)
                .bind({})
        );
        const times = 100;
        new Array(times).fill(0).forEach(debouncedFunction);
        jest.runOnlyPendingTimers();
        expect(debouncedFunction).toHaveBeenCalledTimes(times);
        expect(counter).toEqual(1);
    });
});
