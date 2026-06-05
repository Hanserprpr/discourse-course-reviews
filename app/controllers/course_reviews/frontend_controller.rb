# frozen_string_literal: true

class ::CourseReviews::FrontendController < ::ApplicationController
  requires_plugin CourseReviews::PLUGIN_NAME

  before_action :ensure_logged_in
  before_action :ensure_can_access_course_reviews

  def index
    render html: "", layout: "application"
  end

  private

  def ensure_can_access_course_reviews
    CourseReviews::Access.ensure_can_access!(guardian)
  end
end
