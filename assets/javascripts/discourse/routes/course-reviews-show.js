import DiscourseRoute from "discourse/routes/discourse";

export default class CourseReviewsShowRoute extends DiscourseRoute {
  model(params) {
    return fetch(`/course-reviews/courses/${params.course_id}.json`, {
      credentials: "same-origin",
    }).then((response) => response.json());
  }
}
