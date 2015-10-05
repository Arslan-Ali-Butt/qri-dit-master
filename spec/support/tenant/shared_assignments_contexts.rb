shared_context "it has start and end timestamp filters" do |subdomain|
  before do
    @all_assignments = []
    @oldest_assignments = []
    @old_assignments = []
    @todays_assignment = []

    if subdomain == 'api'
      @current_user = create(:staff)
      controller.instance_variable_set(:@current_user, @current_user)
    else
      @current_user = @user
    end

    3.times do ||
      assignment = create(:assignment, assignee: @current_user, start_at: Time.now - 3.days)
      @oldest_assignments << assignment
      @all_assignments << assignment
    end

    2.times do ||
      assignment = create(:assignment, assignee: @current_user, start_at: Time.now - 2.days)
      @old_assignments << assignment
      @all_assignments << assignment
    end

    @todays_assignment << create(:assignment, assignee: @current_user)
    @all_assignments << @todays_assignment
  end

  it "assigns the @resources falling in a very old time period" do
    get :index, subdomain: subdomain, format: 'json', start: (Time.now - 5.days).to_i, 
      'end'.to_sym => (Time.now - 2.days - 16.hours).to_i

    expect(response.status).to eq(200)
    expect(assigns(:resources)).to eq(@oldest_assignments)
  end

  it "assigns the @resources falling in an old time period" do
    get :index, subdomain: subdomain, format: 'json', start: (Time.now - 2.days - 12.hours).to_i, 
      'end'.to_sym => (Time.now - 1.days).to_i

    expect(response.status).to eq(200)
    expect(assigns(:resources)).to eq(@old_assignments)
  end
end

shared_context "it has an assignee_id filter" do |subdomain|
  before do
    @current_user_assignments = []
    @another_user_assignments = []
    
    @another_user = create(:staff)

    if subdomain == 'api'
      @current_user = create(:staff)
      controller.instance_variable_set(:@current_user, @current_user)
    else
      @current_user = @user
    end

    3.times do ||
      @current_user_assignments << create(:assignment, assignee: @current_user)
    end

    2.times do ||
      @another_user_assignments << create(:assignment, assignee: @another_user)
    end
  end

  it "assigns the @resources belonging to a given assignee" do
    get :index, subdomain: subdomain, format: 'json', assignee_id: @another_user.id

    expect(response.status).to eq(200)
    expect(assigns(:resources)).to eq(@another_user_assignments)
  end
end

shared_context "it has a qrid_id filter" do |subdomain|
  before do
    @qrid_1_assignments = []
    @qrid_2_assignments = []
    @qrid_1 = create(:qrid)
    @qrid_2 = create(:qrid)

    if subdomain == 'api'
      @current_user = create(:staff)
      controller.instance_variable_set(:@current_user, @current_user)
    else
      @current_user = @user
    end

    3.times do ||
      @qrid_1_assignments << create(:assignment, assignee: @current_user, qrid: @qrid_1)
    end

    2.times do ||
      @qrid_2_assignments << create(:assignment, assignee: @current_user, qrid: @qrid_2)
    end
  end

  it "assigns the @resources belonging to a given qrid" do
    get :index, subdomain: subdomain, format: 'json', qrid_id: @qrid_1.id

    expect(response.status).to eq(200)
    expect(assigns(:resources)).to eq(@qrid_1_assignments)
  end
end