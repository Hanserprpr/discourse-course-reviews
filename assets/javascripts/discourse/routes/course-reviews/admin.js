import DiscourseRoute from "discourse/routes/discourse";

export default class CourseReviewsAdminRoute extends DiscourseRoute {
  model() {
    return fetch("/course-reviews/reviews/pending.json", {
      credentials: "same-origin",
      headers: { Accept: "application/json" },
    }).then((response) => response.json());
  }
}
