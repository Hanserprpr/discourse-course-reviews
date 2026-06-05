import Component from "@glimmer/component";
import { service } from "@ember/service";

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
}
