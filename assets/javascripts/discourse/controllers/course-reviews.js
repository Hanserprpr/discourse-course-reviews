import Controller from "@ember/controller";
import { service } from "@ember/service";

export default class CourseReviewsController extends Controller {
  @service currentUser;
  @service router;

  get isAdmin() {
    return this.currentUser && this.currentUser.admin;
  }

  get filterMode() {
    return "latest";
  }
}
