import { LightningElement, api, track, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { cloneObject, flatten } from 'c/utilities';
import $Toastify from 'c/toastify';

// D3 JavaScript Library;
import D3_STATIC_RESOURCE from '@salesforce/resourceUrl/D3';

// Apex;
import generateHierarchyGraphApex from '@salesforce/apex/ApprovalProcessController.generateHierarchyGraph';

/**
 * Inspired by https://medium.com/@anala007/mastering-salesforce-approval-processes-object-model-7e006bd9f5b9.
 */
export default class ApprovalProcessGraph extends LightningElement {
    @api
    get processInstanceId() {
        return this._processInstanceId;
    }
    set processInstanceId(value) {
        this._processInstanceId = value;
        if (this.d3Initialized) {
            this.handleRefresh();
        }
    }

    @track _processInstanceId = null;
    @track graphData = {};
    @track $D3 = null;
    @track loading = false;
    @track error = null;

    d3Initialized = false;

    get svgWidth() {
        return 600;
    }

    get svgHeight() {
        return 500;
    }

    renderedCallback() {
        if (this.d3Initialized) {
            return;
        }
        this.d3Initialized = true;
        this.loading = true;
        // Load third-party library;
        loadScript(this, D3_STATIC_RESOURCE + '/d3.v7.min.js')
            .then(() => {
                this.$D3 = window.d3;
                // Render graph;
                return this.handleRefresh();
            })
            .catch((error) => {
                console.error(error);
                this.error = cloneObject(error);
            })
            .finally(() => {
                this.loading = false;
            });
    }

    // Event Handler;

    handleNodeClick(d) {
        const nodeInfo = cloneObject(d.target.__data__.data);
        const flattenedInfo = cloneObject(flatten(nodeInfo));
        console.group(nodeInfo['displayName']);
        console.table(flattenedInfo);
        console.groupEnd();
    }

    async handleRefresh(event) {
        if (!this.d3Initialized) {
            $Toastify.error({ message: 'D3.js was not initialized!' }, this);
            return;
        }
        await this.pullGraph();
        this.visualize();
    }

    // Service Methods;

    async pullGraph() {
        try {
            this.loading = true;
            this.error = null;
            let result = await generateHierarchyGraphApex({
                processInstanceId: this.processInstanceId
            });
            this.graphData = cloneObject(result);
            console.table(this.graphData);
        } catch (error) {
            this.error = cloneObject(error);
        } finally {
            this.loading = false;
        }
    }

    visualize() {
        const width = this.svgWidth;
        const height = this.svgHeight;

        // Reset SVG;
        d3.select(this.refs.svg).selectAll('*').remove();

        // Initiate SVG;
        const svg = d3
            .select(this.refs.svg)
            .attr('width', width)
            .attr('height', height)
            .append('g')
            .attr('transform', 'translate(100,0)');

        // Ingest data into graph;
        const tree = d3.tree().size([height, width - 200]);
        // const root = d3.hierarchy(this.SAMPLE_DATA);
        const root = d3.hierarchy(this.graphData);
        tree(root);

        // Render links between nodes;
        svg.selectAll('.link')
            .data(root.links())
            .enter()
            .append('path')
            .attr('class', 'link')
            .attr(
                'd',
                d3
                    .linkHorizontal()
                    .x((d) => d.y)
                    .y((d) => d.x)
            );

        // Format nodes;
        const node = svg
            .selectAll('.node')
            .data(root.descendants())
            .enter()
            .append('g')
            // Add custom CSS class;
            .attr('class', (d) => `node`)
            .attr('data-object-name', (d) => d.data['objectName'])
            .attr('transform', (d) => `translate(${d.y},${d.x})`)
            // Add 'click' handler;
            .on('click', this.handleNodeClick.bind(this));

        // Format each node as a circle;
        node.append('circle').attr('r', 15);

        // Add text legend to nodes;
        node.append('text')
            .attr('dy', '1%')
            .attr('x', (d) => (d.children ? -19 : 19))
            .style('text-anchor', (d) => (d.children ? 'end' : 'start'))
            .text((d) => d.data.displayName || d.data.name);
    }
}
