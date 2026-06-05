class CreateCourseReviewSummaries < ActiveRecord::Migration[7.0]
  def change
    create_table :course_review_summaries do |t|
      t.integer :course_id, null: false
      t.integer :teacher_id
      t.integer :review_count, null: false, default: 0
      t.string :top_recommendation
      t.string :top_workload
      t.string :top_difficulty
      t.string :top_attendance
      t.jsonb :top_assessment_methods, null: false, default: []
      t.jsonb :top_suitable_for, null: false, default: []
      t.datetime :last_reviewed_at
      t.timestamps
    end

    add_index :course_review_summaries,
              :course_id,
              unique: true,
              where: "teacher_id IS NULL",
              name: "idx_course_review_summaries_course_only"
    add_index :course_review_summaries,
              %i[course_id teacher_id],
              unique: true,
              where: "teacher_id IS NOT NULL",
              name: "idx_course_review_summaries_course_teacher"
  end
end
