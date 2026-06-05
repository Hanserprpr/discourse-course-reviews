class ::CourseReviewSummary < ActiveRecord::Base
  self.table_name = "course_review_summaries"

  belongs_to :course, class_name: "CourseReviewCourse"
  belongs_to :teacher, class_name: "CourseReviewTeacher", optional: true

  def self.refresh_for(course_id:, teacher_id: nil)
    reviews = CourseReviewReview.where(course_id: course_id, status: "published")
    reviews = reviews.where(teacher_id: teacher_id) if teacher_id

    summary = find_or_initialize_by(course_id: course_id, teacher_id: teacher_id)
    summary.review_count = reviews.count
    summary.top_recommendation = most_common(reviews, :recommendation)
    summary.top_workload = most_common(reviews, :workload)
    summary.top_difficulty = most_common(reviews, :difficulty)
    summary.top_attendance = most_common(reviews, :attendance)
    summary.top_assessment_methods = most_common_array_values(reviews, :assessment_methods)
    summary.top_suitable_for = most_common_array_values(reviews, :suitable_for)
    summary.last_reviewed_at = reviews.maximum(:created_at)
    summary.save!
    summary
  end

  def self.most_common(reviews, column)
    reviews.where.not(column => [nil, ""]).group(column).order(Arel.sql("COUNT(*) DESC")).limit(1).count.keys.first
  end
  private_class_method :most_common

  def self.most_common_array_values(reviews, column)
    counts = Hash.new(0)
    reviews.pluck(column).flatten.compact.each { |value| counts[value] += 1 }
    counts.sort_by { |_key, count| -count }.first(5).map(&:first)
  end
  private_class_method :most_common_array_values
end
