import { createElement } from '@lwc/engine-dom';
import { setImmediate } from 'timers';

import ExchangeRateCard from 'c/exchangeRateCard';

import getBTCRate from '@salesforce/apex/ExchangeRatesContoller.getBTCRate';
import updateExchangeRates from '@salesforce/apex/ExchangeRatesContoller.updateExchangeRates';

// Setting mocks for getBTCRate
jest.mock(
    "@salesforce/apex/ExchangeRatesContoller.getBTCRate",
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

// Setting mocks for updateExchangeRates
jest.mock(
    "@salesforce/apex/ExchangeRatesContoller.updateExchangeRates",
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

// mock responses
const mockBTCRate = { Rate__c: 0.0001, LastModifiedDate: new Date() }
const mockNewBTCRate = { Rate__c: 0.0005, LastModifiedDate: new Date() }
const mockUpdateError = { error: "404 Not Found" }

// To wait until pending Promises are resolved
const flushPromises = () => new Promise(setImmediate);

describe('c-exchange-rate-card', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    it('getBTCRate @wire data', async () => {
        const element = createElement('c-exchange-rate-card', {
            is: ExchangeRateCard
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getBTCRate.emit(mockBTCRate);

        // Assert
        return Promise.resolve().then(() => {
            // Select elements for validation
            const rateElements = element.shadowRoot.querySelectorAll('lightning-formatted-number');
            expect(rateElements.length).toBe(1);
            expect(rateElements[0].value).toBe(mockBTCRate.Rate__c);

            const dateElements = element.shadowRoot.querySelectorAll('lightning-formatted-date-time');
            expect(dateElements.length).toBe(1);
            expect(dateElements[0].value).not.toBe('');

            const refreshBtn = element.shadowRoot.querySelector('.refresh-button');
            expect(refreshBtn.label).toBe('Update Exchange Rates');
            expect(refreshBtn.disabled).toBe(false);
        });
    });

    it('click the refresh button', async () => {
        // updateExchangeRates to return mock BTC rate
        updateExchangeRates.mockResolvedValue(mockNewBTCRate);
        const element = createElement('c-exchange-rate-card', {
            is: ExchangeRateCard
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getBTCRate.emit(mockBTCRate);

        // Select elements for validation
        const refreshBtn = element.shadowRoot.querySelector('.refresh-button');
        expect(refreshBtn.label).toBe('Update Exchange Rates');
        expect(refreshBtn.disabled).toBe(false);

        // Click the refresh rate button
        refreshBtn.click();

        // Assert without waiting for re-rendering
        return Promise.resolve().then(() => {
            expect(refreshBtn.label).toBe('Refreshing...');
            expect(refreshBtn.disabled).toBe(true);
        });
    });

    it('click the refresh button and wait for refresh is done', async () => {
        // updateExchangeRates to return mock BTC rate
        updateExchangeRates.mockResolvedValue(mockNewBTCRate);
        const element = createElement('c-exchange-rate-card', {
            is: ExchangeRateCard
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getBTCRate.emit(mockBTCRate);

        // Select elements for validation
        const refreshBtn = element.shadowRoot.querySelector('.refresh-button');
        expect(refreshBtn.label).toBe('Update Exchange Rates');
        expect(refreshBtn.disabled).toBe(false);

        // Click the refresh rate button
        refreshBtn.click();

        // Assert after re-rendering
        return flushPromises().then(() => {
            expect(refreshBtn.label).toBe('Update Exchange Rates');
            expect(refreshBtn.disabled).toBe(false);

            const rateElements = element.shadowRoot.querySelectorAll('lightning-formatted-number');
            expect(rateElements.length).toBe(1);
            expect(rateElements[0].value).toBe(mockNewBTCRate.Rate__c);

            const dateElements = element.shadowRoot.querySelectorAll('lightning-formatted-date-time');
            expect(dateElements.length).toBe(1);
            expect(dateElements[0].value).not.toBe('');
        });
    });

    it('update exchange rate failed', async () => {
        // updateExchangeRates to return an error
        updateExchangeRates.mockRejectedValue(mockUpdateError);
        const element = createElement('c-exchange-rate-card', {
            is: ExchangeRateCard
        });
        document.body.appendChild(element);

        // When a toast is fired it’s event name is lightning__showtoast
        // but exporting ShowToastEventName from platformShowToastEvent.js will return undefined.
        const showToastHandler = jest.fn();
        const SHOW_TOAST_EVT = 'lightning__showtoast';
        element.addEventListener(SHOW_TOAST_EVT, showToastHandler);

        // Emit data from @wire
        getBTCRate.emit(mockBTCRate);

        // Select elements for validation
        const refreshBtn = element.shadowRoot.querySelector('.refresh-button');
        expect(refreshBtn.label).toBe('Update Exchange Rates');
        expect(refreshBtn.disabled).toBe(false);

        // Click the refresh rate button
        refreshBtn.click();

        // Assert the toast message handler was called to show an error message
        return flushPromises().then(() => {
            expect(refreshBtn.label).toBe('Update Exchange Rates');
            expect(refreshBtn.disabled).toBe(false);

            const rateElements = element.shadowRoot.querySelectorAll('lightning-formatted-number');
            expect(rateElements.length).toBe(1);
            expect(rateElements[0].value).toBe(mockBTCRate.Rate__c);

            expect(showToastHandler).toHaveBeenCalledTimes(1);
        });
    });
});