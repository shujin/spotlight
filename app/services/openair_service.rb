class OpenairService
  def initialize(api_client:)
    @api_client = api_client
  end

  def timesheet_statuses_for_previous_week(user_ids)
    request_template = File.read('app/views/api/openair/timesheet_status_request.xml.erb')

    start_date = Date.today.beginning_of_week - 1.week
    end_date = Date.today.beginning_of_week - 1.day

    response = @api_client.send_request(
        template: request_template.squish,
        model: 'Timesheet',
        locals: {
            user_ids: user_ids,
            start_date: start_date,
            end_date: end_date
        }
    )

    response['Timesheet']
  end

  def user_ids_for_emails(user_emails)
    request_template = File.read('app/views/api/openair/user_ids_request.xml.erb')

    response = @api_client.send_request(
        template: request_template.squish,
        model: 'User',
        locals: {
            user_emails: user_emails
        }
    )

    response['User'].map { |u| u['id'] }
  end

  def self.overall_submission_status(statuses)
    return Category::OpenairWidget::STATUS_PENDING if statuses.empty?

    statuses.all? { |s| %w(S A).include? s['status'] } ? Category::OpenairWidget::STATUS_SUBMITTED : Category::OpenairWidget::STATUS_PENDING
  end
end

class OpenairServiceFactory
  def initialize(widget)
    @widget = widget
  end

  def client
    sinclair_client = Sinclair::OpenAirApiClient.new(
                                                    username: @widget.username,
                                                    password: @widget.password,
                                                    company: @widget.company,
                                                    client: @widget.client,
                                                    key: @widget.key,
                                                    url: @widget.url
    )

    OpenairService.new(api_client: sinclair_client)
  end
end