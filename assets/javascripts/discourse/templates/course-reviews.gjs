import DNavigation from "discourse/components/d-navigation";

export default <template>
  <div class="course-reviews-page">
    <DNavigation @filterMode={{@controller.filterMode}} />

    {{outlet}}
  </div>
</template>;
