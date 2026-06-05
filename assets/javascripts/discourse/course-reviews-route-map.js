export default function () {
  this.route("courseReviews", { path: "/course-reviews" }, function () {
    this.route("show", { path: "/courses/:course_id" });
    this.route("new");
    this.route("admin");
  });
}
