class CreateCourseReviewCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :course_review_courses do |t|
      t.string :name, null: false
      t.string :department
      t.string :course_type
      t.integer :created_by_id
      t.integer :merged_into_id
      t.jsonb :aliases, null: false, default: []
      t.timestamps
    end

    add_index :course_review_courses, :name
    add_index :course_review_courses, :department
    add_index :course_review_courses, :merged_into_id
  end
end
