class ::CourseReviewReview < ActiveRecord::Base
  self.table_name = "course_reviews"

  RECOMMENDATIONS = %w[recommend depends cautious].freeze
  WORKLOADS = %w[light medium heavy].freeze
  DIFFICULTIES = %w[low medium high].freeze
  ATTENDANCE = %w[none occasional frequent].freeze
  ASSESSMENT_METHODS = %w[exam paper presentation homework project].freeze
  SUITABLE_FOR = %w[gpa learning easy_credit beginner advanced].freeze
  STATUSES = %w[pending published hidden].freeze

  belongs_to :course, class_name: "CourseReviewCourse"
  belongs_to :teacher, class_name: "CourseReviewTeacher"
  belongs_to :user
  belongs_to :topic, optional: true
  belongs_to :post, optional: true

  validates :term, :recommendation, :one_line_advice, presence: true
  validates :recommendation, inclusion: { in: RECOMMENDATIONS }
  validates :workload, inclusion: { in: WORKLOADS }, allow_blank: true
  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_blank: true
  validates :attendance, inclusion: { in: ATTENDANCE }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }
  validate :valid_array_values

  after_commit :refresh_summaries, if: :saved_change_to_status?

  def self.status_for_user(user)
    return "published" if user.staff?

    threshold = SiteSetting.course_reviews_low_trust_level_requires_review.to_i
    user.trust_level.to_i <= threshold ? "pending" : "published"
  end

  def build_topic_title
    "[课程评价] #{course.name} - #{teacher.name} - #{term}"
  end

  def build_raw
    [
      "课程：#{course.name}",
      "老师：#{teacher.name}",
      "学期：#{term}",
      "建议：#{CourseReviews::Labels.call(recommendation)}",
      "工作量：#{CourseReviews::Labels.call(workload)}",
      "难度：#{CourseReviews::Labels.call(difficulty)}",
      "点名：#{CourseReviews::Labels.call(attendance)}",
      "考核：#{CourseReviews::Labels.array(assessment_methods).join('、')}",
      "适合：#{CourseReviews::Labels.array(suitable_for).join('、')}",
      "",
      "一句话建议：",
      one_line_advice,
      "",
      "详细评价：",
      detail_text.presence || "未填写。"
    ].join("\n")
  end

  def sync_discourse_post!
    category = Category.find_by(slug: SiteSetting.course_reviews_category_slug)
    raise Discourse::InvalidParameters.new(:category) if category.blank?

    if topic_id.present? && post_id.present?
      post.update!(raw: build_raw)
      topic.update!(title: build_topic_title, visible: true)
      return
    end

    creator = PostCreator.new(
      user,
      title: build_topic_title,
      raw: build_raw,
      category: category.id,
      skip_validations: false
    )
    created_post = creator.create!
    update_columns(topic_id: created_post.topic_id, post_id: created_post.id, updated_at: Time.zone.now)
  end

  def hide_discourse_topic!
    topic&.update!(visible: false)
  end

  def refresh_summaries
    CourseReviewSummary.refresh_for(course_id: course_id)
    CourseReviewSummary.refresh_for(course_id: course_id, teacher_id: teacher_id)
  end

  private

  def valid_array_values
    invalid_assessments = assessment_methods - ASSESSMENT_METHODS
    invalid_suitable = suitable_for - SUITABLE_FOR

    errors.add(:assessment_methods, :invalid) if invalid_assessments.any?
    errors.add(:suitable_for, :invalid) if invalid_suitable.any?
  end

end
