class ::CourseReviewReviewSerializer < ApplicationSerializer
  attributes :id,
             :topic_id,
             :post_id,
             :course_id,
             :teacher_id,
             :user_id,
             :term,
             :recommendation,
             :workload,
             :difficulty,
             :attendance,
             :assessment_methods,
             :suitable_for,
             :one_line_advice,
             :detail_text,
             :status,
             :created_at,
             :updated_at,
             :labels,
             :course_name,
             :teacher_name,
             :username

  def course_name
    object.course&.name
  end

  def teacher_name
    object.teacher&.name
  end

  def username
    object.user&.username
  end

  def labels
    {
      recommendation: CourseReviews::Labels.call(object.recommendation),
      workload: CourseReviews::Labels.call(object.workload),
      difficulty: CourseReviews::Labels.call(object.difficulty),
      attendance: CourseReviews::Labels.call(object.attendance),
      assessment_methods: CourseReviews::Labels.array(object.assessment_methods),
      suitable_for: CourseReviews::Labels.array(object.suitable_for),
      status: CourseReviews::Labels.call(object.status)
    }
  end
end
