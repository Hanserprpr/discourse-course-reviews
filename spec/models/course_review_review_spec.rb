# frozen_string_literal: true

require "rails_helper"

describe CourseReviewReview do
  fab!(:user)
  fab!(:category) { Fabricate(:category, slug: "course-reviews") }
  let!(:course) { CourseReviewCourse.create!(name: "数据结构", course_type: "major", created_by_id: user.id) }
  let!(:teacher) { CourseReviewTeacher.create!(name: "张老师") }

  before do
    SiteSetting.course_reviews_category_slug = category.slug
  end

  it "does not allow numeric rating fields and validates enum values" do
    review =
      described_class.new(
        course: course,
        teacher: teacher,
        user: user,
        term: "2026春",
        recommendation: "recommend",
        workload: "heavy",
        difficulty: "high",
        attendance: "occasional",
        assessment_methods: %w[homework exam],
        suitable_for: %w[learning advanced],
        one_line_advice: "能学到东西。"
      )

    expect(review).to be_valid
    expect(review.attributes).not_to have_key("rating")
  end

  it "builds a Discourse-compatible raw post body" do
    review =
      described_class.new(
        course: course,
        teacher: teacher,
        user: user,
        term: "2026春",
        recommendation: "recommend",
        workload: "heavy",
        difficulty: "high",
        attendance: "occasional",
        assessment_methods: %w[homework exam],
        suitable_for: %w[learning advanced],
        one_line_advice: "能学到东西。",
        detail_text: "作业比较多。"
      )

    expect(review.build_topic_title).to eq("[课程评价] 数据结构 - 张老师 - 2026春")
    expect(review.build_raw).to include("课程：数据结构")
    expect(review.build_raw).to include("建议：推荐")
    expect(review.build_raw).to include("考核：作业、考试")
    expect(review.build_raw).to include("适合：真想学、有基础")
  end

  it "keeps synced Discourse topics out of public topic lists" do
    review =
      described_class.create!(
        course: course,
        teacher: teacher,
        user: user,
        term: "2026春",
        recommendation: "recommend",
        workload: "heavy",
        difficulty: "high",
        attendance: "occasional",
        assessment_methods: %w[homework exam],
        suitable_for: %w[learning advanced],
        one_line_advice: "能学到东西。",
        detail_text: "作业比较多。",
        status: "published"
      )

    review.sync_discourse_post!

    expect(review.topic).to be_present
    expect(review.topic.visible).to eq(false)

    review.update!(one_line_advice: "更新后的建议。")
    review.sync_discourse_post!

    expect(review.topic.reload.visible).to eq(false)
  end
end
