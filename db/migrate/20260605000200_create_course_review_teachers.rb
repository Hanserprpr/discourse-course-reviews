class CreateCourseReviewTeachers < ActiveRecord::Migration[7.0]
  def change
    create_table :course_review_teachers do |t|
      t.string :name, null: false
      t.string :department
      t.timestamps
    end

    add_index :course_review_teachers, :name
    add_index :course_review_teachers, :department
  end
end
