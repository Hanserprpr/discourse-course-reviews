import DNavigation from "discourse/components/d-navigation";

export default <template>
  <div class="course-reviews-page">
    <DNavigation @filterMode={{@controller.filterMode}} />

    <div class="course-reviews-header">
      <h2>课程评价</h2>
      <div class="course-review-header-actions">
        {{#if @controller.isAdmin}}
          <a href="/course-reviews/admin" class="btn">审核</a>
        {{/if}}
        <a href="/course-reviews/new" class="btn btn-primary">发布评价</a>
      </div>
    </div>

    <nav class="course-reviews-tabs" aria-label="课程评价切换栏">
      <a href="/course-reviews">全部课程</a>
      <a href="/course-reviews/new">发布评价</a>
      {{#if @controller.isAdmin}}
        <a href="/course-reviews/admin">审核</a>
      {{/if}}
    </nav>

    {{outlet}}
  </div>
</template>;
