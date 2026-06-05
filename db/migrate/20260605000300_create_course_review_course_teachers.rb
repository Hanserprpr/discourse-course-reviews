class CreateCourseReviewCourseTeachers < ActiveRecord::Migration[7.0]
  def change
    create_table :course_review_course_teachers do |t|
      t.integer :course_id, null: false
      t.integer :teacher_id, null: false
      t.timestamps
    end

    add_index :course_review_course_teachers, %i[course_id teacher_id], unique: true, name: "idx_course_review_course_teachers_unique"
    add_index :course_review_course_teachers, :teacher_id
  end
end
