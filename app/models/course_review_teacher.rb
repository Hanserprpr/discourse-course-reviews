class ::CourseReviewTeacher < ActiveRecord::Base
  self.table_name = "course_review_teachers"

  has_many :course_teachers,
           class_name: "CourseReviewCourseTeacher",
           foreign_key: :teacher_id,
           dependent: :destroy
  has_many :courses, through: :course_teachers, source: :course
  has_many :reviews, class_name: "CourseReviewReview", foreign_key: :teacher_id

  validates :name, presence: true
end
