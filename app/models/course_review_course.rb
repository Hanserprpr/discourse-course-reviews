class ::CourseReviewCourse < ActiveRecord::Base
  self.table_name = "course_review_courses"

  has_many :course_teachers,
           class_name: "CourseReviewCourseTeacher",
           foreign_key: :course_id,
           dependent: :destroy
  has_many :teachers, through: :course_teachers, source: :teacher
  has_many :reviews, class_name: "CourseReviewReview", foreign_key: :course_id
  has_many :summaries, class_name: "CourseReviewSummary", foreign_key: :course_id

  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :merged_into, class_name: "CourseReviewCourse", optional: true

  validates :name, presence: true

  scope :active, -> { where(merged_into_id: nil) }

  def self.search(term, limit: 20)
    scope = active.order(:name).limit(limit)
    return scope if term.blank?

    query = "%#{sanitize_sql_like(term)}%"
    scope.where("name ILIKE :query OR department ILIKE :query", query: query)
  end
end
