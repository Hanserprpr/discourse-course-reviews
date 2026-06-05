import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  if (api.addNavigationBarItem) {
    api.addNavigationBarItem({
      name: "course-reviews",
      displayName: "课程评价",
      href: "/course-reviews",
    });
  }
});
