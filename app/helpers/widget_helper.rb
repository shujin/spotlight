module WidgetHelper

  def widget_category_choices
    [
      ['Continuous Integration Status', 'ci_widget'],
      ['Continuous Integration Status - Concourse', 'ci_concourse_widget'],
      ['Clock', 'clock_widget'],
      ['Google Calendar', 'gcal_widget'],
      ['Google Calendar Resource', 'gcal_resource_widget'],
      ['XKCD Comic', 'comic_widget'],
      ['Render URL', 'url_widget'],
      ['OpenAir Timesheet Status', 'openair_widget']
    ]
  end

  def widget_size_choices
    (DashboardConfig::MIN_WIDGET_WIDTH..DashboardConfig::MAX_WIDGET_WIDTH).map(&:to_s)
  end

  def widgets_hash(widgets)
    widgets.map do |widget|
      {
        uuid: widget.uuid,
        title: widget.title,
        layout: {
          w: widget.width,
          h: widget.height,
          x: widget.position_x,
          y: widget.position_y
        },
        widgetPath: widget_path(id: widget.id)
      }
    end
  end

end
