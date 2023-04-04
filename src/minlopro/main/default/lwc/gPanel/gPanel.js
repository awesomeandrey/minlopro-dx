import { LightningElement, api, track } from 'lwc';
import { subscribeToEvent, publishEvent } from 'c/bridge';
import { cloneObject, isNotEmpty, uniqueId, flatten } from 'c/utilities';
import * as MarkerLabel from 'c/gMarkerLabelMgr';

export default class GPanel extends LightningElement {
    @track locationsByIdsObj = {};
    @track defaultCoords = {};

    get hasDefaultCoords() {
        return isNotEmpty(this.defaultCoords);
    }

    get locationColumns() {
        return [
            {
                fieldName: 'label',
                label: 'Marker',
                type: 'text'
            },
            {
                fieldName: 'position.lat',
                label: 'Lat',
                type: 'number',
                typeAttributes: {
                    maximumFractionDigits: 3
                }
            },
            {
                fieldName: 'position.lng',
                label: 'Lng',
                type: 'number',
                typeAttributes: {
                    maximumFractionDigits: 3
                }
            },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: [
                        { label: 'Remove', name: 'remove_location' },
                        { label: 'Pan To', name: 'pan_to_location' }
                    ]
                }
            }
        ];
    }

    get locationData() {
        return Object.values(this.locationsByIdsObj).map((_) => flatten(_));
    }

    async connectedCallback() {
        // Subscribe;
        subscribeToEvent('sync_locations', this.handleSyncLocations.bind(this));
        // Calculate current coordinates;
        this.defaultCoords = await this.getCurrentPosition();
        // Notify MAP component;
        const uid = uniqueId(),
            locationsObjToUpdate = {
                [uid]: {
                    id: uid,
                    label: MarkerLabel.gain(),
                    position: this.defaultCoords
                }
            };
        publishEvent('sync_locations', { locationsObjToUpdate });
    }

    handleSyncLocations({ locationsObjToUpdate = {}, locationsObjToDelete = {} }) {
        if (isNotEmpty(locationsObjToDelete)) {
            Object.keys(locationsObjToDelete).forEach((locationId) => {
                delete this.locationsByIdsObj[locationId];
            });
        }
        if (isNotEmpty(locationsObjToUpdate)) {
            this.locationsByIdsObj = {
                ...this.locationsByIdsObj,
                ...cloneObject(locationsObjToUpdate)
            };
        }
    }

    handleRowAction(event) {
        const { action, row: location } = event.detail;
        if (action.name === 'remove_location') {
            publishEvent('sync_locations', {
                locationsObjToDelete: {
                    [location.id]: location
                }
            });
        } else if (action.name === 'pan_to_location') {
            publishEvent('pan_to_location', {
                locationId: location.id
            });
        }
    }

    getCurrentPosition() {
        const defaultCoordinates = { lat: -34.397, lng: 150.644 }; // Sydney;
        return new Promise((resolve) => {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(({ coords }) => {
                    resolve({
                        lat: coords.latitude,
                        lng: coords.longitude
                    });
                }, resolve.bind(this, defaultCoordinates));
            } else {
                resolve(defaultCoordinates);
            }
        });
    }
}
