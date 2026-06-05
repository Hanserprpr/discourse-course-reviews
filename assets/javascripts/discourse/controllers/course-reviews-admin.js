import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";

export default class CourseReviewsAdminController extends Controller {
  @tracked savingId = null;
  @tracked error = null;

  @action
  async setStatus(review, status) {
    this.savingId = review.id;
    this.error = null;

    const response = await fetch(`/course-reviews/reviews/${review.id}.json`, {
      method: "PUT",
      credentials: "same-origin",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ status }),
    });

    this.savingId = null;

    if (!response.ok) {
      const payload = await response.json();
      this.error = payload && payload.errors ? payload.errors.join(", ") : "操作失败。";
      return;
    }

    this.model.reviews = this.model.reviews.filter((item) => item.id !== review.id);
    this.notifyPropertyChange("model");
  }

  get csrfToken() {
    const meta = document.querySelector("meta[name=csrf-token]");
    return meta && meta.content;
  }
}
