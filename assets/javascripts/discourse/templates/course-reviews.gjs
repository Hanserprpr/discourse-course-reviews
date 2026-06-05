import DiscourseBanner from "discourse/components/discourse-banner";
import DNavigation from "discourse/components/d-navigation";

export default <template>
  <div class="course-reviews-page">
    <DiscourseBanner />
    <DNavigation @filterMode={{@controller.filterMode}} />

    {{outlet}}
  </div>
</template>;
