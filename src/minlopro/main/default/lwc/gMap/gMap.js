import { LightningElement, api, track } from 'lwc';
import { subscribeToEvent, publishEvent } from 'c/bridge';
import { isNotEmpty, isEmpty, uniqueId, debounce, cloneObject } from 'c/commons';
import * as MarkerLabel from 'c/gMarkerLabelMgr';

export default class GMap extends LightningElement {
    /**
     * External wrapper object providing access to Google Map APIs.
     * @type {{Object}}
     */
    @api googleApiLib = {};

    @track markersMap = new Map();
    @track $map = null;

    connectedCallback() {
        subscribeToEvent('sync_locations', this.handleSyncLocations.bind(this));
        subscribeToEvent('pan_to_location', this.handlePanToLocation.bind(this));
    }

    renderedCallback() {
        const isMapRendered = this.refs.mapContainer.childElementCount !== 0;
        if (!isMapRendered) {
            this.initializeGoogleMap(this.refs.mapContainer);
        }
    }

    handleSyncLocations({ locationsObjToUpdate = {}, locationsObjToDelete = {} }) {
        const { Marker: $Marker, Animation: $Animation } = this.googleApiLib;
        // Delete & un-render markers;
        Object.values(locationsObjToDelete).forEach((locationToDelete) => {
            if (this.markersMap.has(locationToDelete.id)) {
                const markerToDelete = this.markersMap.get(locationToDelete.id);
                // Revoke marker label letter;
                MarkerLabel.revoke(markerToDelete.getLabel());
                // Un-render marker;
                markerToDelete.setMap(null);
                // Purge marker from store;
                this.markersMap.delete(locationToDelete.id);
            }
        });
        // Add/update & (re)render markers;
        Object.values(locationsObjToUpdate).forEach((locationToUpdate) => {
            const { id, label, position } = cloneObject(locationToUpdate);
            if (this.markersMap.has(id)) {
                // Re-render existing marker;
                this.markersMap.get(id).setPosition(position);
            } else {
                // Create and render new marker;
                const marker = new $Marker({
                    position,
                    label,
                    id,
                    draggable: true,
                    animation: $Animation.DROP
                });
                // Add marker handlers;
                const debouncedHandler = debounce(this.onMarkerDragOrDragend.bind(marker), 700);
                marker.addListener('drag', debouncedHandler);
                marker.addListener('dragend', debouncedHandler);
                // Store marker;
                this.markersMap.set(id, marker);
                // Add marker to map;
                marker.setMap(this.$map);
            }
        });
        // Pan to marker (optional);
        if (this.markersMap.size === 1) {
            const [marker] = this.markersMap.values();
            this.$map.panTo(marker.getPosition());
        }
    }

    handlePanToLocation({ locationId }) {
        if (this.markersMap.has(locationId)) {
            const marker = this.markersMap.get(locationId);
            this.$map.panTo(marker.getPosition());
        }
    }

    // Service Methods;

    initializeGoogleMap(domElement) {
        // Draw Google Map;
        const { Map: $GoogleMap } = this.googleApiLib;
        const gMap = new $GoogleMap(domElement, {
            center: { lat: 40.7128, lng: 74.006 }, // Default centering;
            zoom: 6
        });
        // Add listeners;
        gMap.addListener('click', this.onMapClick.bind(this));
        // Store Google Map reference;
        this.$map = gMap;
    }

    onMapClick(mapsMouseEvent) {
        if (!MarkerLabel.hasNext() || this.markersMap.size >= 10) {
            const { InfoWindow: $InfoWindow } = this.googleApiLib;
            const infoWindow = new $InfoWindow({
                content: 'You have reached the limit of custom markers.'
            });
            infoWindow.setPosition(mapsMouseEvent.latLng);
            infoWindow.open({
                map: this.$map
            });
            setTimeout(() => {
                infoWindow.close();
            }, 1500);
        } else {
            const uid = uniqueId(),
                locationsObjToUpdate = {
                    [uid]: {
                        id: uid,
                        label: MarkerLabel.gain(),
                        position: mapsMouseEvent.latLng
                    }
                };
            // Notify component(s);
            publishEvent('sync_locations', { locationsObjToUpdate });
        }
    }

    onMarkerDragOrDragend(dragEvent) {
        const marker = this;
        const locationsObjToUpdate = {
            [marker.id]: {
                id: marker.id,
                label: marker.getLabel(),
                position: dragEvent.latLng
            }
        };
        // Notify component(s);
        publishEvent('sync_locations', { locationsObjToUpdate });
    }
}
