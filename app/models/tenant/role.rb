class Tenant::Role < ActiveRecord::Base
  has_and_belongs_to_many :users#, after_add: :rebuild_sphinx_index, after_remove: :rebuild_sphinx_index

  validates :name, presence: true, uniqueness: true

  strip_attributes allow_empty: true

  protected
    def rebuild_sphinx_index
      db = Apartment::Tenant.current_tenant
      ThinkingSphinx::RealTime.callback_for("user_#{db}".to_sym, [:users])
    end
end
