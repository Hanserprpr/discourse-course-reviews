import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const site = api.container.lookup("service:site");

  if (api.addNavigationBarItem) {
    api.addNavigationBarItem({
      name: "course-reviews",
      displayName: "课程评价",
      href: "/course-reviews",
      customFilter: () => site.can_view_course_reviews,
    });
  }
});
