import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";

export default class CourseReviewsShowController extends Controller {
  @service currentUser;

  @tracked targetCourseId = "";
  @tracked mergeError = null;

  get isAdmin() {
    return this.currentUser && this.currentUser.admin;
  }

  @action
  setTargetCourseId(event) {
    this.targetCourseId = event.target.value;
  }

  @action
  async mergeCourse(event) {
    if (event) {
      event.preventDefault();
    }
    this.mergeError = null;

    const response = await fetch(
      `/course-reviews/courses/${this.model.course.id}/merge.json`,
      {
        method: "POST",
      credentials: "same-origin",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
        body: JSON.stringify({ target_course_id: this.targetCourseId }),
      }
    );

    if (!response.ok) {
      const payload = await response.json();
      this.mergeError = payload && payload.errors ? payload.errors.join(", ") : "合并失败。";
      return;
    }

    window.location.href = `/course-reviews/courses/${this.targetCourseId}`;
  }

  get csrfToken() {
    const meta = document.querySelector("meta[name=csrf-token]");
    return meta && meta.content;
  }
}
