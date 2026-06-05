class ::CourseReviewCourseSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :aliases,
             :department,
             :course_type,
             :course_type_label,
             :created_by_id,
             :merged_into_id,
             :created_at,
             :updated_at,
             :review_count,
             :summary,
             :summary_labels,
             :teachers

  def review_count
    object.reviews.where(status: "published").count
  end

  def summary
    summary = object.summaries.find_by(teacher_id: nil)
    return nil if summary.blank?

    {
      review_count: summary.review_count,
      top_recommendation: summary.top_recommendation,
      top_workload: summary.top_workload,
      top_difficulty: summary.top_difficulty,
      top_attendance: summary.top_attendance,
      top_assessment_methods: summary.top_assessment_methods,
      top_suitable_for: summary.top_suitable_for,
      last_reviewed_at: summary.last_reviewed_at
    }
  end

  def course_type_label
    CourseReviews::Labels.call(object.course_type)
  end

  def summary_labels
    summary = object.summaries.find_by(teacher_id: nil)
    return nil if summary.blank?

    {
      top_recommendation: CourseReviews::Labels.call(summary.top_recommendation),
      top_workload: CourseReviews::Labels.call(summary.top_workload),
      top_difficulty: CourseReviews::Labels.call(summary.top_difficulty),
      top_attendance: CourseReviews::Labels.call(summary.top_attendance),
      top_assessment_methods: CourseReviews::Labels.array(summary.top_assessment_methods),
      top_suitable_for: CourseReviews::Labels.array(summary.top_suitable_for)
    }
  end

  def teachers
    object.teachers.order(:name).map { |teacher| { id: teacher.id, name: teacher.name, department: teacher.department } }
  end
end
