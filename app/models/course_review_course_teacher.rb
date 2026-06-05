class ::CourseReviewCourseTeacher < ActiveRecord::Base
  self.table_name = "course_review_course_teachers"

  belongs_to :course, class_name: "CourseReviewCourse"
  belongs_to :teacher, class_name: "CourseReviewTeacher"
end
