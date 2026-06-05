import DiscourseRoute from "discourse/routes/discourse";

export default class CourseReviewsAdminRoute extends DiscourseRoute {
  model() {
    return fetch("/course-reviews/reviews/pending.json", {
      credentials: "same-origin",
    }).then((response) => response.json());
  }
}
