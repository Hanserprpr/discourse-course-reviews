class ::CourseReviews::ReviewsController < ::ApplicationController
  requires_plugin CourseReviews::PLUGIN_NAME

  before_action :ensure_logged_in

  def pending
    raise Discourse::InvalidAccess.new unless guardian.is_admin?

    reviews =
      CourseReviewReview
        .includes(:course, :teacher, :user)
        .where(status: "pending")
        .order(created_at: :asc)
        .limit(100)

    render_json_dump(
      reviews: ActiveModel::ArraySerializer.new(
        reviews,
        each_serializer: CourseReviewReviewSerializer,
        scope: guardian
      ).as_json
    )
  end

  def create
    review = nil

    ActiveRecord::Base.transaction do
      course = find_or_create_course
      teacher = find_or_create_teacher
      CourseReviewCourseTeacher.find_or_create_by!(course_id: course.id, teacher_id: teacher.id)

      review =
        CourseReviewReview.create!(
          create_review_params.merge(
            course_id: course.id,
            teacher_id: teacher.id,
            user_id: current_user.id,
            status: CourseReviewReview.status_for_user(current_user)
          )
        )

      review.sync_discourse_post! if review.status == "published"
      review.refresh_summaries
    end

    render_json_dump(review: CourseReviewReviewSerializer.new(review, scope: guardian, root: false).as_json)
  rescue ActiveRecord::RecordInvalid => e
    render_json_error(e.record.errors.full_messages)
  end

  def update
    review = CourseReviewReview.find(params[:id])
    raise Discourse::InvalidAccess.new unless can_edit_review?(review)

    attrs = update_review_params.to_h
    attrs[:status] = params[:status] if guardian.is_admin? && params[:status].present?
    review.update!(attrs)
    if review.status == "published"
      review.sync_discourse_post!
    elsif review.status == "hidden"
      review.hide_discourse_topic!
    end
    review.refresh_summaries

    render_json_dump(review: CourseReviewReviewSerializer.new(review, scope: guardian, root: false).as_json)
  rescue ActiveRecord::RecordInvalid => e
    render_json_error(e.record.errors.full_messages)
  end

  private

  def can_edit_review?(review)
    guardian.is_admin? || review.user_id == current_user.id
  end

  def find_or_create_course
    if params[:course_id].present?
      return CourseReviewCourse.find(params[:course_id])
    end

    existing =
      CourseReviewCourse.active.find_by(
        "LOWER(name) = ? AND COALESCE(department, '') = ?",
        params.require(:course_name).to_s.strip.downcase,
        params[:department].to_s
      )
    return existing if existing

    CourseReviewCourse.create!(
      name: params.require(:course_name).to_s.strip,
      department: params[:department].presence,
      course_type: params[:course_type].presence,
      created_by_id: current_user.id
    )
  end

  def find_or_create_teacher
    if params[:teacher_id].present?
      return CourseReviewTeacher.find(params[:teacher_id])
    end

    existing =
      CourseReviewTeacher.find_by(
        "LOWER(name) = ? AND COALESCE(department, '') = ?",
        params.require(:teacher_name).to_s.strip.downcase,
        params[:department].to_s
      )
    return existing if existing

    CourseReviewTeacher.create!(
      name: params.require(:teacher_name).to_s.strip,
      department: params[:department].presence
    )
  end

  def create_review_params
    permitted = permitted_review_params
    permitted[:assessment_methods] ||= []
    permitted[:suitable_for] ||= []
    permitted
  end

  def update_review_params
    permitted_review_params
  end

  def permitted_review_params
    permitted =
      params.permit(
        :term,
        :recommendation,
        :workload,
        :difficulty,
        :attendance,
        :one_line_advice,
        :detail_text,
        assessment_methods: [],
        suitable_for: []
      )
    permitted
  end
end
