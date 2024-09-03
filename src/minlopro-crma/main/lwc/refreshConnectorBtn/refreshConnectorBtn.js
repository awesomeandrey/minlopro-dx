import { LightningElement, track, wire } from 'lwc';
import { getDataConnectors, ingestDataConnector } from 'lightning/analyticsWaveApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RefreshConnectorBtn extends LightningElement {
    @track loading = false;

    get doDisableBtn() {
        return this.loading || !Boolean(this.sfdcLocalConnectorId);
    }

    get sfdcLocalConnectorId() {
        return this.wiredConnectors?.data?.dataConnectors[0].id;
    }

    @wire(getDataConnectors, { connectorType: ['SfdcLocal'] })
    wiredConnectors = {};

    async handleClick(event) {
        console.log(`Refreshing data connector with ID = ${this.sfdcLocalConnectorId} ...`);
        try {
            this.loading = true;
            const result = await ingestDataConnector({ connectorIdOrApiName: this.sfdcLocalConnectorId });
            console.log('Connector Ingestion Response', JSON.stringify(result));
            if (Array.isArray(result)) {
                console.log('IsArray');
                // The connector has already been triggered;
                let { message, errorCode } = result[0];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `${message} (${errorCode})`,
                        variant: 'warning'
                    })
                );
            } else {
                console.log('NOT IsArray');
                // New connector refresh;
                let { message } = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: message,
                        variant: 'success'
                    })
                );
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error ingesting data connector',
                    message: error?.message || error?.body?.message || 'Unknown Error Occurred',
                    variant: 'error'
                })
            );
        } finally {
            this.loading = false;
        }
    }
}
