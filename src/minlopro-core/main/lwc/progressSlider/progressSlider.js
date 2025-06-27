import { LightningElement, api } from 'lwc';

// Custom CSS stylesheets/classes;
import $Stylesheet from 'c/progressSliderCss';
const SECTION_CLASS_NAME = 'section';
const SECTION_EXPANDED_CLASS_NAME = 'expanded';
const SECTION_COLLAPSE_CLASS_NAME = 'collapsed';

export default class ProgressSlider extends LightningElement {
    static stylesheets = [$Stylesheet];

    @api next() {
        if (this?.$currentSection?.nextElementSibling) {
            this.showSection(this?.$currentSection?.nextElementSibling);
        }
    }

    @api previous() {
        if (this?.$currentSection?.previousElementSibling) {
            this.showSection(this?.$currentSection?.previousElementSibling);
        }
    }

    get $container() {
        return this.refs.container;
    }

    get $currentSection() {
        return this.querySelector(`c-progress-slider-section.${SECTION_EXPANDED_CLASS_NAME}`);
    }

    get $sections() {
        return this.querySelectorAll('c-progress-slider-section');
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            this.initialize();
        }
    }

    handleSlotChange() {
        this.initialize();
    }

    // Service Methods;

    showSection(sectionElement) {
        // Reset all;
        this.$sections.forEach((element) => {
            element.classList.remove(SECTION_EXPANDED_CLASS_NAME);
            element.classList.add(SECTION_COLLAPSE_CLASS_NAME);
        });
        // Expand particular section;
        sectionElement.classList.add(SECTION_EXPANDED_CLASS_NAME);
        sectionElement.classList.remove(SECTION_COLLAPSE_CLASS_NAME);
    }

    initialize() {
        const sectionsCount = Array.from(this.$sections).length;
        if (sectionsCount < 2) {
            throw new Error('There should be at least 2 sections defined.');
        }
        // Assign initial CSS state;
        for (const sectionElement of this.$sections) {
            sectionElement.classList.add(SECTION_CLASS_NAME);
            sectionElement.classList.remove(SECTION_EXPANDED_CLASS_NAME);
            sectionElement.classList.add(SECTION_COLLAPSE_CLASS_NAME);
        }
        // Pre-open the first section;
        this.$sections[0].classList.add(SECTION_EXPANDED_CLASS_NAME);
        this.$sections[0].classList.remove(SECTION_COLLAPSE_CLASS_NAME);
        // Calculate CSS hooks that control expanded vs collapsed sections width ratio;
        const expandedSectionRatio = 65;
        this.$container.style.setProperty('--section-expanded-ratio', `${expandedSectionRatio}%`);
        const collapsedSectionRatio = (100 - expandedSectionRatio) / (sectionsCount - 1);
        this.$container.style.setProperty('--section-collapsed-ratio', `${collapsedSectionRatio}%`);
    }
}
