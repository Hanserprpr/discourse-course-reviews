# frozen_string_literal: true

class ::CourseReviews::FrontendController < ::ApplicationController
  requires_plugin CourseReviews::PLUGIN_NAME

  def index
    render html: "", layout: "application"
  end
end
