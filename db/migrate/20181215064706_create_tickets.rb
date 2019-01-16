class CreateTickets < ActiveRecord::Migration[5.0]
  def change
    create_table :tickets do |t|
      t.string  "title",limit: 191, null: false
      t.text    "content",          null: false
      t.references :user, foreign_key: true
      t.integer "status",           null: false, default: 0
      t.datetime "created_at",                null: false
      t.datetime "updated_at",                null: false
    end
  end
end
