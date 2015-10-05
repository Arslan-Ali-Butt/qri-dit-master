class Tenant::Datatable

  def initialize(view, resources)
    @view = view
    @resources = resources
  end

  def as_json(options = {})
  end

private

  def data
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end