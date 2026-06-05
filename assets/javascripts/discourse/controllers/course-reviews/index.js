import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";

export default class CourseReviewsIndexController extends Controller {
  @service currentUser;

  @tracked q = "";
  @tracked course_type = "";
  @tracked recommendation = "";
  @tracked workload = "";
  @tracked assessment_method = "";
  @tracked suitable_for = "";
  @tracked sort = "recent";

  queryParams = ["q", "course_type", "recommendation", "workload", "assessment_method", "suitable_for", "sort"];

  get isAdmin() {
    return this.currentUser && this.currentUser.admin;
  }

  @action
  setValue(field, event) {
    this[field] = event.target.value;
  }

  @action
  applyFilters(event) {
    if (event) {
      event.preventDefault();
    }
    this.send("refresh");
  }
}
