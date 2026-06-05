import Component from "@glimmer/component";
import { service } from "@ember/service";
import CourseReviewForm from "../../components/course-review-form";

export default class CourseReviewComposerConnector extends Component {
  @service siteSettings;

  get shouldShow() {
    const outletArgs = this.args && this.args.outletArgs;
    const model = outletArgs && outletArgs.model;
    const category = model && model.category;
    const slug = category && category.slug ? category.slug : category;

    return (
      this.siteSettings.course_reviews_enabled &&
      slug === this.siteSettings.course_reviews_category_slug
    );
  }

  <template>
    {{#if this.shouldShow}}
      <div class="course-review-composer-form">
        <strong>课程评价</strong>
        <p class="course-review-muted">请通过下面的结构化表单提交。提交后会自动生成论坛主题和首帖正文。</p>
        <CourseReviewForm />
      </div>
    {{/if}}
  </template>
}
