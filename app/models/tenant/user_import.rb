class Tenant::UserImport < ActiveRecord::Base
  SPREADSHEET_COLUMNS = %w(name email) # likely not a very useful spreadsheet at this point

  before_create :set_status

  def set_status
    self.status = 0 # means we have a pending/ongoing import
  end

  def import_users
    users = imported_users

    if users.present? and users.map{ |user| user.valid? }.all?

      begin
        self.transaction do
          users.each do |valid_user|
            puts "Sending #{valid_user.email}"
            save_and_invite_user(valid_user)
          end
        end

        self.num_users = users.size
        self.status = 1 # status of 1 means the import is complete and went off without a hitch

        importing_done
      rescue Exception => e
        self.error_messages = ["Unexpected error for user #{e.record.name} #{e.message}"]
        self.status = 2
      end      
    else
      handle_model_errors(users)

      self.status = 2 # there was some kind of error with the import

      # we'll save the import anyway in order to reference/reuse later
    end

    self.save
  end

  def importing_done
    # override in subclass
  end

  def handle_model_errors(users)
    if users.present?
      self.error_messages = []
      
      users.each_with_index do |user, index|
        user.errors.full_messages.each do |message|

          errors = Array.new(self.error_messages).push "Row #{index+2}: #{message}"
          self.error_messages = errors
        end
      end
    end
  end

  def save_and_invite_user(user)
    # implement in subclass
  end

  def imported_users
    @imported_users ||= load_imported_users
  end

  def load_imported_users
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      if validate_spreadsheet(row.keys)
        # go ahead and load all the user data into the models here
        load_imported_user(row)
      else
        return nil
      end
      # end of load operation
    end
  end

  def validate_spreadsheet(keys)
    expected_columns = Set.new(self.class::SPREADSHEET_COLUMNS)

    missing_columns = expected_columns - keys.to_set
    extra_columns = keys.to_set - expected_columns

    if missing_columns.empty? and extra_columns.empty?
      return true # the sheet contains the exact number of columns expected
    elsif missing_columns.size > 0
      self.error_messages = ["The following required columns are missing from the spreadsheet: " + missing_columns.to_a.join(", ")]

      self.save
      return false
    elsif extra_columns.size > 0
      self.error_messages = ["The following columns could not be recognized: " + extra_columns.to_a.join(", ")]

      self.save
      return false
    end
  end

  def load_imported_user(row)
    # implement in subclass
  end

  def open_spreadsheet
    spreadsheet_url = import_file_url.to_s

    case self.user_import_file.split('.')[-1]
    when "csv" then Roo::CSV.new(spreadsheet_url)
    when "xls" then Roo::Excel.new(spreadsheet_url)
    when "xlsx" then Roo::Excelx.new(spreadsheet_url)
    when "ods" then Roo::OpenOffice.new(spreadsheet_url)
    else raise "Unknown file type: #{self.user_import_file}"
    end
  end

  def import_file_url
    # TODO, fix this code, not quite right, i.e. files cannot have both spaces and plus signs now
    if self.user_import_file.include? " "
      uri = URI.parse(self.user_import_file.gsub(/ /, '+'))
    elsif self.user_import_file.include? "+"
      uri = URI.parse(self.user_import_file.gsub('+', '%2B'))
    else
      uri = URI.parse(self.user_import_file)
    end

    key = CGI.unescape(uri.path.split('/')[1..-1].join('/')) # the first array element is an empty string

    signed_url = S3_BUCKET.objects[key].url_for(:read, :expires => 10*60)

    signed_url
  end
end
