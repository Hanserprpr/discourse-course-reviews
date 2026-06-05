import DiscourseRoute from "discourse/routes/discourse";

export default class CourseReviewsIndexRoute extends DiscourseRoute {
  queryParams = {
    q: { refreshModel: true },
    course_type: { refreshModel: true },
    recommendation: { refreshModel: true },
    workload: { refreshModel: true },
    assessment_method: { refreshModel: true },
    suitable_for: { refreshModel: true },
    sort: { refreshModel: true },
  };

  model(params) {
    const query = new URLSearchParams(params).toString();
    return fetch(`/course-reviews.json${query ? `?${query}` : ""}`, {
      credentials: "same-origin",
    }).then((response) => response.json());
  }
}
