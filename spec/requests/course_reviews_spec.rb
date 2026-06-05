# frozen_string_literal: true

require "rails_helper"

describe "Course reviews", type: :request do
  fab!(:user)
  fab!(:category) { Fabricate(:category, slug: "course-reviews") }

  before do
    SiteSetting.course_reviews_enabled = true
    SiteSetting.course_reviews_category_slug = category.slug
    sign_in(user)
  end

  it "creates a structured review" do
    post "/course-reviews/reviews.json",
         params: {
           course_name: "数据结构",
           teacher_name: "张老师",
           department: "计算机学院",
           term: "2026春",
           course_type: "major",
           recommendation: "recommend",
           workload: "heavy",
           difficulty: "high",
           attendance: "occasional",
           assessment_methods: %w[homework exam],
           suitable_for: %w[learning advanced],
           one_line_advice: "能学到东西。",
           detail_text: "作业比较多。"
         }

    expect(response.status).to eq(200)
    review = CourseReviewReview.last
    expect(review.course.name).to eq("数据结构")
    expect(review.teacher.name).to eq("张老师")
    expect(review.recommendation).to eq("recommend")
  end

  it "lets admins list pending reviews" do
    admin = Fabricate(:admin)
    sign_in(admin)

    course = CourseReviewCourse.create!(name: "大学物理", created_by_id: user.id)
    teacher = CourseReviewTeacher.create!(name: "李老师")
    review =
      CourseReviewReview.create!(
        course: course,
        teacher: teacher,
        user: user,
        term: "2026春",
        recommendation: "depends",
        workload: "medium",
        difficulty: "medium",
        attendance: "occasional",
        one_line_advice: "看老师和考试安排。",
        status: "pending"
      )

    get "/course-reviews/reviews/pending.json"

    expect(response.status).to eq(200)
    expect(response.parsed_body["reviews"].map { |item| item["id"] }).to include(review.id)
  end
end
