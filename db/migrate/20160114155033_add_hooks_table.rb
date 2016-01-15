class AddHooksTable < ActiveRecord::Migration
  def change
    create_table :hook_logs do |t|
      t.text :the_params
    end
  end
end
