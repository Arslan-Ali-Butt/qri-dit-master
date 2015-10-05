require 'sidekiq/web'
# The priority is based upon order of creation: first created -> highest priority.
# See how all your routes lay out with "rake routes".
QRIDit::Application.routes.draw do

  
  scope '/webhooks/chargify' do
    post '/', to: 'webhooks/chargify#index'
  end

  # QRIDit Home Watch API
  constraints ApiConstraint do
    api_version(:module => "API::V0", :header => {:name => "Accept", :value => "application/vnd.quickreportsystems.com; version=0"}, :path => {:value => "v0"}, :defaults => {:format => "json"}, :default => true) do
      get '/test', to: 'tenant/test#api_test'
      post '/login', to: 'tenant/login#login'

      put '/ios_auth_token', to: 'tenant/login#ios_auth_token'

      scope module: :tenant, as: :api_tenant do
        resources :assignments
        resources :qrids, only: [:show, :index]
        resources :reports, only: [:create]

        scope '/account' do 
          get 'settings', to: 'settings#index'
        end
      end
    end

  end
  
  # Admin panel
  scope module: :admin, as: :admin do
    constraints subdomain: 'admin' do
      get '/',          to: 'dashboard#index',  as: :root
      match 'login',    to: 'auth#login',       via: [:get, :post], as: :login
      get 'logout',     to: 'auth#logout',      as: :logout

      constraints AdminConstraint do
        concern :deletable do
          get   :delete,  on: :member
        end
        resources :landlords, concerns: :deletable
        resources :tenants,   concerns: :deletable do
          resources :notes,   concerns: :deletable, controller: 'tenant_notes'
          match 'resend', to: 'tenants#resend', via: [:get, :patch, :post], as: :resend
        end
        mount Sidekiq::Web => '/sidekiq'
      end
    end
  end

  # Tenant
  constraints TenantConstraint do
    scope module: :tenant, as: :tenant do
      get '/', to: 'dashboard#index', as: :root
      get 'dashboard/:action' => 'dashboard'

      concern :deletable do
        get   :delete,  on: :member
      end
      concern :invitable do
        post  :invite, on: :member
      end
      concern :rebuildable do
        post  :rebuild, on: :collection
      end
      concern :restorable do
        get :restore, on: :member
      end

      resources :users,           concerns: [:invitable, :deletable]
      resources :managers,        concerns: [:invitable, :deletable]
      resources :reporters,       concerns: [:invitable, :deletable]
      resources :clients,         concerns: [:invitable, :deletable, :restorable]
      resources :client_imports, only: [:index, :create, :new, :update, :edit]
      resources :staff,         concerns: [:invitable, :deletable]

      resources :zones,           concerns: :deletable,     except: [:show]
      resources :work_types,      concerns: :deletable,     except: [:show]

      resources :sites,           concerns: :deletable
      resources :my_sites, only: [:index, :show]

      match 'tasks/trial', via: [:get, :post], to: 'tasks#trial', as: 'template_tasks_trial'
      resources :tasks,           concerns: :rebuildable do
        match 'trial', via: [:get, :post], on: :member
      end
    
      #match 'permatasks/trial', via: [:get, :post], to: 'permatasks#trial', as: 'permatasks_trial'
      resources :permatasks,      concerns: :rebuildable do
        match 'trial', via: [:get, :post], on: :member
      end
      
      scope '/:context', context: /(datatables)/ do
        resources :qrids, only: [:index], as: :datatables_qrids
        resources :clients, only: [:index], as: :datatables_clients
        resources :time, only: :index, as: :datatables_time
        resources :sites, only: :index, as: :datatables_sites
        resources :staff, only: :index, as: :datatables_staff
      end

      resources :qrids, concerns: :deletable do
        resources :photos, controller: 'qrid_photos' do
          get :print, on: :member
          get :download, on: :member
        end
        
        get   :qrcard,  on: :member
        get   :qrcode,  on: :member
        get   :duplicate, on: :member
        post  :duplicate, on: :member
        match :trial,   via: [:get, :post], on: :member
        get :nominate, on: :member        
        match :populate, via: [:post, :patch], on: :member
        match :customize, via: [:get, :post, :patch], on: :member
        match :rehash, via: [:get, :post, :patch], on: :member
        get :augment, on: :member
      end

      resources :my_qrids,  only: [:index] do
        match :start,   via: [:get, :post], on: :member
        match :trial,    via: [:get,:post], on: :member
      end

      resources :assignments do
        post  :reschedule, on: :member
      end
      resources :my_assignments, only: [:index, :show]

      resources :reports,         only: [:index, :show] do
        get :time, on: :collection
        
        resources :photos,    controller: 'report_photos', only: [:index, :show, :create, :destroy] do
          get :print, on: :member
          get :download, on: :member
        end
        resources :solutions, controller: 'report_solutions'
        resources :notes,   concerns: :deletable, controller: 'report_notes'
      end
      resources :c_reports,       only: [:index, :show] do
        resources :photos,    controller: 'report_photos', only: [:index, :show]
        resources :notes,   concerns: :deletable, controller: 'report_notes'
      end
      resources :my_reports,      only: [:index, :show, :update] do
        resources :photos, controller: 'report_photos', only: [:index, :show, :create, :destroy]
        patch  :submit, on: :member
      end

      match 'settings', to: 'settings#index', via: [:get, :post], as: :settings
      get 'settings/billing/statements/:id', to: 'settings#show_statement', as: :billing_show_statement, :defaults => { :format => 'pdf' }
      post 'settings/create_logo', to: 'settings#create_logo'
      match 'settings/change_plan_details', via: [:get, :post], to: 'settings#change_plan_details', as: :change_plan_details
      match 'settings/process_change_plan_details.:format', via: [:get, :post, :patch], to: 'settings#process_change_plan_details', as: :process_change_plan_details
      match 'settings/process_change_card_details', via: [:get, :post, :patch], to: 'settings#process_change_card_details', as: :process_change_card_details
      get 'settings/billing'

      resources :time,            only: [:index, :show]

      get 'address/regions', to: 'address#regions'

      get 'search', to: 'search#search'

      get 'help/:action' => 'help'
      get 'help', to: 'help#index'
      
      get 'toolsandresources/:action' => 'tools_resources'
      get 'toolsandresources', to: 'tools_resources#index'
      
      match 'support/request', via: [:get, :post, :patch], to: 'support#request_feature'
      match 'support/report', via: [:get, :post, :patch], to: 'support#report_bug'
      match 'support/thanks', via: [:get], to: 'support#thanks'
      
      %w(404 500).each do |code|
        get code, to: 'errors#show', code: code
      end
      #Affiliates Section
      resources :affiliates, except: :new do
        get :confirmed
      end
      match 'signup', via: :get, to: 'affiliates#new'
      get 'tac', to: 'affiliates#tac', as: :affiliate_tac
    end

    devise_for :users, class_name: 'Tenant::User', path: '', path_names: {sign_in: 'login', sign_out: 'logout'}, skip: [:invitations]
    devise_scope :user do
      resource :user_invitation, only: [:update], path: 'invitation', controller: 'devise/invitations' do
        get :edit, path: 'accept', as: :accept
      end
      resource :user_account, only: [:show, :edit, :update], path: 'account', controller: 'tenant/account'
    end
  end

  # Front
  scope module: :front do
    root to: 'pages#index'

    get 'index', to: 'pages#index'
    get 'about', to: 'pages#about'

    match 'contact', via: [:get,:post], to: 'pages#contact'
    get 'contact/thanks', to: 'pages#contact_thanks'

    match 'signup/', via: [:get, :post], to: 'signup#purchase'
    match 'purchase', via: [:get, :post], to: 'signup#purchase'
    
    match 'signup/details', via: [:get,:post], to: 'signup#details', as: :signup_details
    get 'signup/subregion_select/:parent_region.:format', to: 'signup#subregion_select', as: :signup_subregion_select
    match 'signup/confirmation', via: [:get, :post], to: 'signup#confirmation', as: :signup_confirmation
    match 'signup/create', via: [:get, :post], to: 'signup#create', as: :signup_create
    get 'signup/thanks', to: 'signup#thanks',  as: :signup_thanks
    get 'signup/tac', to: 'signup#tac', as: :signup_tac

    get 'features', to: 'pages#features'
    get 'technology',to: 'pages#technology'
  end

  namespace :emailpreview do
    get 'unlock_instructions'
    get 'confirmation_instructions'
    get 'reset_password_instructions'
    get 'invitation_instructions_su'
    get 'invitation_instructions_regular'

    get 'assignment_cancelled'
    get 'assignment_notification'
    get 'c_report_notification'
    get 'reply_notification'
    get 'report_notification'
    get 'welcome_message'
    get 'send_all'
    get 'index'
    get 'affiliate_request'
  end
end
