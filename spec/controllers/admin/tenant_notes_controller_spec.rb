require 'rails_helper'

describe Admin::TenantNotesController do

  controller do
    def authorize
      true
    end
  end

  it_behaves_like 'a CRUD resource', Admin::TenantNote, :tenant_note, 'js'

end
