import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const site = api.container.lookup("service:site");

  if (api.registerValueTransformer) {
    api.registerValueTransformer(
      "welcome-banner-display-for-route",
      ({ value, context }) => {
        if (
          context.currentRouteName &&
          context.currentRouteName.startsWith("courseReviews")
        ) {
          return true;
        }

        return value;
      }
    );
  }

  if (api.addNavigationBarItem) {
    api.addNavigationBarItem({
      name: "course-reviews",
      displayName: "课程评价",
      href: "/course-reviews",
      customFilter: () => site.can_view_course_reviews,
      forceActive: (_category, _args, router) =>
        router.currentURL.startsWith("/course-reviews"),
    });
  }
});
