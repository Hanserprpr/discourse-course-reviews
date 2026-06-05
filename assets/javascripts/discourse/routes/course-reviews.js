import DiscourseRoute from "discourse/routes/discourse";
import { service } from "@ember/service";

export default class CourseReviewsRoute extends DiscourseRoute {
  @service currentUser;
  @service site;

  beforeModel(transition) {
    if (super.beforeModel) {
      super.beforeModel(transition);
    }

    if (!this.currentUser) {
      const redirect = encodeURIComponent(
        `${window.location.pathname}${window.location.search}`
      );
      transition.abort();
      window.location.href = `/login?redirect=${redirect}`;
      return;
    }

    if (this.site && !this.site.can_view_course_reviews) {
      transition.abort();
      window.location.href = `${window.location.pathname}${window.location.search}`;
    }
  }
}
