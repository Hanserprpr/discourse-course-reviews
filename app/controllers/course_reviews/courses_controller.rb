class ::CourseReviews::CoursesController < ::ApplicationController
  requires_plugin CourseReviews::PLUGIN_NAME

  before_action :ensure_logged_in
  before_action :ensure_can_access_course_reviews

  def index
    courses = CourseReviewCourse.active.includes(:teachers, :summaries, :reviews)
    courses = apply_filters(courses)

    order =
      case params[:sort]
      when "review_count"
        "review_count DESC NULLS LAST"
      else
        "last_reviewed_at DESC NULLS LAST"
      end

    courses =
      courses
        .left_joins(:summaries)
        .where("course_review_summaries.teacher_id IS NULL")
        .select("course_review_courses.*, course_review_summaries.review_count, course_review_summaries.last_reviewed_at")
        .order(Arel.sql(order), :name)
        .limit(50)

    render_json_dump(
      courses: ActiveModel::ArraySerializer.new(
        courses,
        each_serializer: CourseReviewCourseSerializer,
        scope: guardian
      ).as_json
    )
  end

  def search
    query = params[:q].to_s.strip
    courses = CourseReviewCourse.search(query).includes(:teachers, :summaries)
    teachers = CourseReviewTeacher.where("name ILIKE ?", "%#{CourseReviewTeacher.sanitize_sql_like(query)}%").order(:name).limit(20)

    render_json_dump(
      courses: ActiveModel::ArraySerializer.new(
        courses,
        each_serializer: CourseReviewCourseSerializer,
        scope: guardian
      ).as_json,
      teachers: teachers.map { |teacher| { id: teacher.id, name: teacher.name, department: teacher.department } }
    )
  end

  def show
    course = CourseReviewCourse.includes(:teachers, :summaries).find(params[:id])

    if course.merged_into_id.present?
      return render_json_dump(merged_into_id: course.merged_into_id)
    end

    reviews =
      CourseReviewReview
        .includes(:teacher, :user)
        .where(course_id: course.id, status: "published")
        .order(created_at: :desc)
        .limit(50)

    render_json_dump(
      course: CourseReviewCourseSerializer.new(course, scope: guardian, root: false).as_json,
      reviews: ActiveModel::ArraySerializer.new(
        reviews,
        each_serializer: CourseReviewReviewSerializer,
        scope: guardian
      ).as_json
    )
  end

  def merge
    raise Discourse::InvalidAccess.new unless guardian.is_admin?

    source = CourseReviewCourse.find(params[:id])
    target = CourseReviewCourse.find(params.require(:target_course_id))
    raise Discourse::InvalidParameters.new(:target_course_id) if source.id == target.id

    CourseReviewReview.where(course_id: source.id).update_all(course_id: target.id, updated_at: Time.zone.now)
    CourseReviewCourseTeacher.where(course_id: source.id).find_each do |link|
      CourseReviewCourseTeacher.find_or_create_by!(course_id: target.id, teacher_id: link.teacher_id)
    end

    aliases = (target.aliases + source.aliases + [source.name]).uniq
    target.update!(aliases: aliases)
    source.update!(merged_into_id: target.id)
    CourseReviewSummary.refresh_for(course_id: target.id)
    target.teachers.find_each do |teacher|
      CourseReviewSummary.refresh_for(course_id: target.id, teacher_id: teacher.id)
    end

    render_json_dump(course: CourseReviewCourseSerializer.new(target, scope: guardian, root: false).as_json)
  end

  private

  def ensure_can_access_course_reviews
    CourseReviews::Access.ensure_can_access!(guardian)
  end

  def apply_filters(courses)
    courses = courses.where("course_review_courses.name ILIKE :q OR course_review_courses.department ILIKE :q", q: "%#{CourseReviewCourse.sanitize_sql_like(params[:q])}%") if params[:q].present?
    courses = courses.where(course_type: params[:course_type]) if params[:course_type].present?

    if params[:teacher_id].present?
      courses = courses.joins(:course_teachers).where(course_review_course_teachers: { teacher_id: params[:teacher_id] })
    end

    summary_filters = {
      recommendation: :top_recommendation,
      workload: :top_workload,
      difficulty: :top_difficulty,
      attendance: :top_attendance
    }

    summary_filters.each do |param_key, column|
      next if params[param_key].blank?

      courses = courses.joins(:summaries).where(course_review_summaries: { teacher_id: nil, column => params[param_key] })
    end

    if params[:assessment_method].present?
      courses = courses.joins(:summaries).where("course_review_summaries.teacher_id IS NULL AND course_review_summaries.top_assessment_methods ? :value", value: params[:assessment_method])
    end

    if params[:suitable_for].present?
      courses = courses.joins(:summaries).where("course_review_summaries.teacher_id IS NULL AND course_review_summaries.top_suitable_for ? :value", value: params[:suitable_for])
    end

    courses
  end
end
