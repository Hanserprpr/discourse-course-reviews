# name: discourse-course-reviews
# about: Structured course reviews for Discourse without numeric ratings.
# version: 0.1.0
# authors: Codex
# required_version: 3.4.0

enabled_site_setting :course_reviews_enabled

register_asset "stylesheets/course-reviews.scss"

after_initialize do
  module ::CourseReviews
    PLUGIN_NAME = "discourse-course-reviews"
    REVIEW_CATEGORY_SETTING = :course_reviews_category_slug
  end

  %w[
    app/lib/course_reviews/access.rb
    app/lib/course_reviews/labels.rb
    app/models/course_review_course.rb
    app/models/course_review_teacher.rb
    app/models/course_review_course_teacher.rb
    app/models/course_review_review.rb
    app/models/course_review_summary.rb
    app/serializers/course_review_course_serializer.rb
    app/serializers/course_review_review_serializer.rb
    app/controllers/course_reviews/frontend_controller.rb
    app/controllers/course_reviews/courses_controller.rb
    app/controllers/course_reviews/reviews_controller.rb
  ].each { |path| load File.expand_path(path, __dir__) }

  add_to_serializer(:site, :course_reviews_category_slug) { SiteSetting.course_reviews_category_slug }
  add_to_serializer(:site, :can_view_course_reviews) do
    CourseReviews::Access.can_access?(scope && scope.user)
  end

  add_to_serializer(:topic_view, :course_review, respect_plugin_enabled: false) do
    next nil if !CourseReviews::Access.can_access?(scope && scope.user)

    review = CourseReviewReview.includes(:course, :teacher).find_by(topic_id: object.topic.id)
    review ? CourseReviewReviewSerializer.new(review, scope: scope, root: false).as_json : nil
  end

  Discourse::Application.routes.append do
    get "/course-reviews.json" => "course_reviews/courses#index"
    get "/course-reviews/courses/search.json" => "course_reviews/courses#search"
    get "/course-reviews/courses/:id.json" => "course_reviews/courses#show"
    get "/course-reviews/reviews/pending.json" => "course_reviews/reviews#pending"
    post "/course-reviews/reviews.json" => "course_reviews/reviews#create"
    put "/course-reviews/reviews/:id.json" => "course_reviews/reviews#update"
    post "/course-reviews/courses/:id/merge.json" => "course_reviews/courses#merge"

    get "/course-reviews" => "course_reviews/frontend#index", :format => false
    get "/course-reviews/new" => "course_reviews/frontend#index", :format => false
    get "/course-reviews/admin" => "course_reviews/frontend#index", :format => false
    get "/course-reviews/courses/:id" => "course_reviews/frontend#index", :format => false
  end
end
